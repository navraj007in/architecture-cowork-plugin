# Production Hardening — Python / FastAPI

Apply these patterns when the SDL specifies `runtime: python` or `framework: python-fastapi` / `django`.

> **scaffold_depth gating** — Before applying patterns, resolve `scaffold_depth` from `solution.stage` in `solution.sdl.yaml`. Pattern 7 (retry+timeout) and Pattern 8 (soft delete) have reduced requirements at MVP stage. See the gating table in `skills/production-hardening/SKILL.md`.

---

### Pattern 1 — Correlation ID (Python)

**Dependency:** `pip install starlette-correlation-id` or implement manually.

```python
# app/middleware/correlation_id.py
import uuid
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request
from starlette.responses import Response

CORRELATION_ID_HEADER = "x-correlation-id"

class CorrelationIdMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next) -> Response:
        correlation_id = request.headers.get(CORRELATION_ID_HEADER) or str(uuid.uuid4())
        request.state.correlation_id = correlation_id
        response = await call_next(request)
        response.headers[CORRELATION_ID_HEADER] = correlation_id
        return response
```

Mount in `app/main.py`:
```python
app.add_middleware(CorrelationIdMiddleware)
```

In structured log calls, include `correlation_id=request.state.correlation_id`.

---

### Pattern 2 — Graceful Shutdown (Python / FastAPI)

```python
# app/main.py
import signal
import asyncio
from contextlib import asynccontextmanager
from fastapi import FastAPI
from app.db import engine  # SQLAlchemy async engine

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    yield
    # Shutdown — runs when SIGTERM received (uvicorn handles signal forwarding)
    await engine.dispose()
    # Close Redis if used:
    # await redis_client.aclose()

app = FastAPI(lifespan=lifespan)
```

Run with: `uvicorn app.main:app --host 0.0.0.0 --port 8000 --timeout-graceful-shutdown 10`

---

### Pattern 3 — Auth Token Interceptor (Python — outbound service calls)

For backend-to-backend calls using `httpx`:

```python
# app/lib/http_client.py
import httpx
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception

class ServiceClient:
    def __init__(self, base_url: str, token_fn=None):
        self.base_url = base_url
        self.token_fn = token_fn  # callable that returns a Bearer token

    @retry(
        stop=stop_after_attempt(3),
        wait=wait_exponential(multiplier=0.1, max=1),
        retry=retry_if_exception(lambda e: isinstance(e, httpx.HTTPStatusError) and e.response.status_code >= 500),
    )
    async def request(self, method: str, path: str, correlation_id: str = None, **kwargs):
        headers = kwargs.pop("headers", {})
        if correlation_id:
            headers["x-correlation-id"] = correlation_id
        if self.token_fn:
            headers["Authorization"] = f"Bearer {await self.token_fn()}"
        async with httpx.AsyncClient(timeout=10.0) as client:
            resp = await client.request(method, f"{self.base_url}{path}", headers=headers, **kwargs)
            resp.raise_for_status()
            return resp.json()
```

---

### Pattern 4 — Validation (Python / FastAPI)

FastAPI uses **Pydantic** natively — no extra dependency needed. Define request models as Pydantic schemas:

```python
# app/schemas/user.py
from pydantic import BaseModel, EmailStr, Field

class CreateUserRequest(BaseModel):
    email: EmailStr
    name: str = Field(..., min_length=1, max_length=100)
    role: str = Field(default="user")

class UpdateUserRequest(BaseModel):
    name: str | None = Field(None, min_length=1, max_length=100)
```

FastAPI auto-validates and returns 422 on failure. For env var validation:

```python
# app/config.py
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    database_url: str
    redis_url: str = "redis://localhost:6379"
    allowed_origins: str = "http://localhost:3000"
    service_name: str = "api"
    service_version: str = "0.1.0"

    class Config:
        env_file = ".env"

settings = Settings()  # raises ValidationError on startup if required vars missing
```

**Dependency:** `pip install pydantic-settings`

---

### Pattern 5 — Deep Health Check (Python / FastAPI)

```python
# app/routes/health.py
import time
from fastapi import APIRouter
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import text
from app.db import AsyncSessionLocal
from app.config import settings
import redis.asyncio as aioredis

router = APIRouter()

@router.get("/health")
async def health_check():
    checks = {}
    overall = "ok"

    # Database check
    try:
        start = time.monotonic()
        async with AsyncSessionLocal() as session:
            await session.execute(text("SELECT 1"))
        checks["db"] = {"status": "ok", "response_ms": round((time.monotonic() - start) * 1000)}
    except Exception as e:
        checks["db"] = {"status": "fail", "error": str(e)}
        overall = "unhealthy"

    # Redis check
    try:
        r = aioredis.from_url(settings.redis_url)
        await r.ping()
        await r.aclose()
        checks["cache"] = {"status": "ok"}
    except Exception as e:
        checks["cache"] = {"status": "fail", "error": str(e)}
        if overall == "ok":
            overall = "degraded"

    status_code = 503 if overall == "unhealthy" else 200
    from fastapi.responses import JSONResponse
    return JSONResponse(
        content={"status": overall, "checks": checks, "service": settings.service_name},
        status_code=status_code,
    )
```

---

### Pattern 6 — Structured Logger (Python)

**Dependency:** `pip install structlog`

```python
# app/lib/logger.py
import logging
import structlog
from app.config import settings

def configure_logging():
    structlog.configure(
        processors=[
            structlog.contextvars.merge_contextvars,
            structlog.processors.add_log_level,
            structlog.processors.TimeStamper(fmt="iso"),
            structlog.processors.JSONRenderer() if settings.service_name != "local" else structlog.dev.ConsoleRenderer(),
        ],
        wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
        context_class=dict,
        logger_factory=structlog.PrintLoggerFactory(),
    )

logger = structlog.get_logger()
```

In middleware, bind correlation ID to context:
```python
import structlog
structlog.contextvars.bind_contextvars(correlation_id=request.state.correlation_id)
```

---

### Pattern 7 — Retry + Timeout (Python)

**Dependency:** `pip install tenacity httpx`

Already shown in Pattern 3's `ServiceClient`. For standalone use:

```python
from tenacity import retry, stop_after_attempt, wait_exponential, retry_if_exception_type
import httpx

@retry(
    stop=stop_after_attempt(3),
    wait=wait_exponential(multiplier=0.1, max=1),
    retry=retry_if_exception_type(httpx.HTTPStatusError),
)
async def call_with_retry(url: str) -> dict:
    async with httpx.AsyncClient(timeout=10.0) as client:
        resp = await client.get(url)
        if resp.status_code >= 500:
            resp.raise_for_status()  # triggers retry
        return resp.json()
```

---

### Pattern 8 — Soft Delete (Python / SQLAlchemy)

```python
# In SQLAlchemy models
from sqlalchemy import Column, DateTime, func
from sqlalchemy.orm import DeclarativeBase

class Base(DeclarativeBase):
    pass

class SoftDeleteMixin:
    deleted_at = Column(DateTime, nullable=True, index=True)

    def soft_delete(self):
        self.deleted_at = func.now()

# Usage: all models inherit SoftDeleteMixin
class User(Base, SoftDeleteMixin):
    __tablename__ = "users"
    # ...

# In queries, always filter:
session.query(User).filter(User.deleted_at.is_(None)).all()

# Or use a custom query class to enforce globally:
from sqlalchemy.orm import Query
class SoftDeleteQuery(Query):
    def __new__(cls, *args, **kwargs):
        obj = super().__new__(cls)
        return obj
    def __iter__(self):
        return super().__iter__()
```

For FastAPI with Alembic: add `deleted_at TIMESTAMP NULL` to migration files for all entity tables.

---

### Pattern 9 — CSP / Security Headers (Python / FastAPI)

**Dependency:** `pip install secure`

```python
# app/middleware/security.py
import secure
from starlette.middleware.base import BaseHTTPMiddleware

secure_headers = secure.Secure(
    csp=secure.ContentSecurityPolicy()
        .default_src("'self'")
        .script_src("'self'")
        .style_src("'self'", "'unsafe-inline'")
        .img_src("'self'", "data:", "blob:")
        .connect_src("'self'")
        .font_src("'self'", "https://fonts.gstatic.com")
        .object_src("'none'"),
    hsts=secure.StrictTransportSecurity().max_age(31536000).include_subdomains().preload(),
    referrer=secure.ReferrerPolicy().no_referrer_when_downgrade(),
    xfo=secure.XFrameOptions().deny(),
)

class SecurityHeadersMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request, call_next):
        response = await call_next(request)
        secure_headers.framework.fastapi(response)
        return response
```

CORS configuration:
```python
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.allowed_origins.split(","),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
```
