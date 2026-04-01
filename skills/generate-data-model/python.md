# Data Model Generation — Python

> **Entity source** — Always read `domain.entities[]` from `solution.sdl.yaml` as the primary entity list. See Step 1 "Resolve Entity Inventory" in `skills/generate-data-model/SKILL.md` for the full fallback chain.

## ORM Selection by Framework

| Framework | Recommended ORM | Migration tool |
|---|---|---|
| FastAPI (async) | SQLAlchemy 2.x async | Alembic |
| FastAPI (sync) | SQLAlchemy 2.x sync | Alembic |
| Django | Django ORM (built-in) | Django migrations |
| Flask | SQLAlchemy 2.x | Alembic |
| Standalone | SQLAlchemy 2.x or Tortoise ORM | Alembic / Aerich |

## SQLAlchemy 2.x — Async (FastAPI)

### Base model setup
```python
# app/db/base.py
from datetime import datetime
from sqlalchemy import func
from sqlalchemy.ext.asyncio import AsyncAttrs
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column

class Base(AsyncAttrs, DeclarativeBase):
    pass

class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(server_default=func.now())
    updated_at: Mapped[datetime] = mapped_column(
        server_default=func.now(), onupdate=func.now()
    )

class SoftDeleteMixin:
    deleted_at: Mapped[datetime | None] = mapped_column(nullable=True, index=True)
```

### Entity definition
```python
# app/models/user.py
from uuid import UUID, uuid4
from sqlalchemy import String, ForeignKey, Index
from sqlalchemy.orm import Mapped, mapped_column, relationship
from app.db.base import Base, TimestampMixin, SoftDeleteMixin

class User(Base, TimestampMixin, SoftDeleteMixin):
    __tablename__ = "users"

    id: Mapped[UUID] = mapped_column(primary_key=True, default=uuid4)
    email: Mapped[str] = mapped_column(String(255), unique=True, nullable=False, index=True)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    role: Mapped[str] = mapped_column(String(50), nullable=False, default="user")

    # Relationship
    orders: Mapped[list["Order"]] = relationship("Order", back_populates="user")

    __table_args__ = (
        Index("ix_users_email_deleted", "email", "deleted_at"),
    )
```

### Async session setup
```python
# app/db/session.py
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from app.config import settings

engine = create_async_engine(settings.database_url, echo=False, pool_size=10, max_overflow=20)
AsyncSessionLocal = async_sessionmaker(engine, expire_on_commit=False)

async def get_db() -> AsyncSession:
    async with AsyncSessionLocal() as session:
        yield session
```

### Alembic setup
```
alembic init alembic
```

`alembic/env.py` — connect async engine:
```python
from alembic import context
from sqlalchemy.ext.asyncio import create_async_engine
from app.models import Base  # import all models to register them

def run_migrations_online():
    connectable = create_async_engine(context.config.get_main_option("sqlalchemy.url"))
    with connectable.connect() as connection:
        context.configure(connection=connection, target_metadata=Base.metadata)
        with context.begin_transaction():
            context.run_migrations()
```

Run migrations:
```bash
alembic revision --autogenerate -m "add users table"
alembic upgrade head
```

## Django ORM

### Model definition
```python
# models.py
import uuid
from django.db import models

class TimestampModel(models.Model):
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    deleted_at = models.DateTimeField(null=True, blank=True, db_index=True)

    class Meta:
        abstract = True

class User(TimestampModel):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    email = models.EmailField(unique=True, db_index=True)
    name = models.CharField(max_length=100)
    role = models.CharField(max_length=50, default="user")

    class Meta:
        db_table = "users"
        indexes = [
            models.Index(fields=["email", "deleted_at"]),
        ]
```

Migrations:
```bash
python manage.py makemigrations
python manage.py migrate
```

Seed data:
```python
# management/commands/seed.py
from django.core.management.base import BaseCommand
from myapp.models import User

class Command(BaseCommand):
    def handle(self, *args, **kwargs):
        User.objects.bulk_create([
            User(email=f"user{i}@example.com", name=f"User {i}")
            for i in range(1, 11)
        ], ignore_conflicts=True)
```

## Pydantic Schemas (request/response — all frameworks)

Always define separate Pydantic schemas for API I/O. Never expose ORM models directly:

```python
# app/schemas/user.py
from uuid import UUID
from datetime import datetime
from pydantic import BaseModel, EmailStr, Field

class UserBase(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100)
    role: str = Field(default="user")

class UserCreate(UserBase):
    pass

class UserUpdate(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=100)
    role: str | None = None

class UserResponse(UserBase):
    id: UUID
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}  # enables ORM mode
```

## Relationship patterns

One-to-many:
```python
# Parent model
orders: Mapped[list["Order"]] = relationship("Order", back_populates="user", lazy="selectin")

# Child model
user_id: Mapped[UUID] = mapped_column(ForeignKey("users.id"), nullable=False, index=True)
user: Mapped["User"] = relationship("User", back_populates="orders")
```

Many-to-many (association table):
```python
product_tags = Table(
    "product_tags",
    Base.metadata,
    Column("product_id", ForeignKey("products.id"), primary_key=True),
    Column("tag_id", ForeignKey("tags.id"), primary_key=True),
)
```

## Index conventions

- Single field lookup: `index=True` on the column
- Composite lookups: `__table_args__ = (Index("ix_name", "col1", "col2"),)`
- Partial index (soft deletes): `Index("ix_email_active", "email", postgresql_where=text("deleted_at IS NULL"))`
- Unique constraint: `UniqueConstraint("email", name="uq_users_email")`

## Required packages

```
sqlalchemy[asyncio]>=2.0
asyncpg          # PostgreSQL async driver
alembic>=1.13
pydantic>=2.0
pydantic-settings>=2.0
```
