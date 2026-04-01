# Environment Setup — Python

> **Per-service .env scoping** — For multi-service projects, scope env vars to only the services that need them using `architecture.services[].dependsOn[]` from `solution.sdl.yaml`. See the "Multi-Service Projects — Per-Service .env Scoping" section in `skills/setup-env/SKILL.md`.

## pydantic-settings (FastAPI / any Python backend)

**Install:** `pip install pydantic-settings python-dotenv`

### `app/config.py`
```python
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import AnyHttpUrl, PostgresDsn, RedisDsn, field_validator
from typing import Annotated

class Settings(BaseSettings):
    # App
    app_env: str = "local"
    debug: bool = False
    service_name: str = "api"
    service_version: str = "0.1.0"
    port: int = 8000
    secret_key: str                          # required — no default
    allowed_origins: str = "http://localhost:3000"

    # Database
    database_url: PostgresDsn               # required — validated as PostgreSQL URL
    database_pool_size: int = 10
    database_max_overflow: int = 20

    # Redis (optional — omit fields if no cache)
    redis_url: RedisDsn = "redis://localhost:6379/0"

    # Auth
    jwt_secret: str                          # required
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30

    # Inter-service URLs (add one per SDL consumer)
    # other_service_url: AnyHttpUrl = "http://localhost:3001"

    @field_validator("allowed_origins")
    @classmethod
    def parse_origins(cls, v: str) -> list[str]:
        return [o.strip() for o in v.split(",")]

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

settings = Settings()  # raises ValidationError on startup if required vars missing
```

### `.env.example`
```dotenv
# App
APP_ENV=local
DEBUG=true
SERVICE_NAME=api
SERVICE_VERSION=0.1.0
PORT=8000
SECRET_KEY=your-secret-key-here
ALLOWED_ORIGINS=http://localhost:3000

# Database
DATABASE_URL=postgresql+asyncpg://postgres:password@localhost:5432/myapp
DATABASE_POOL_SIZE=10

# Redis
REDIS_URL=redis://localhost:6379/0

# Auth
JWT_SECRET=your-jwt-secret-here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### `.env.staging` / `.env.production`
```dotenv
APP_ENV=staging           # or: production
DEBUG=false
DATABASE_URL=postgresql+asyncpg://user:pass@db.staging.example.com:5432/myapp?ssl=require
REDIS_URL=redis://:password@redis.staging.example.com:6379/0
ALLOWED_ORIGINS=https://app.staging.example.com
```

### Loading in FastAPI `main.py`
```python
from app.config import settings

app = FastAPI(
    title=settings.service_name,
    debug=settings.debug,
)
```

### Per-environment file loading
Python does not auto-load `.env.staging` — you must load the right file yourself:

```python
# In entrypoint or docker-compose command:
APP_ENV=staging uvicorn app.main:app
```

Or in `config.py`, load env-specific file explicitly:
```python
import os
env = os.getenv("APP_ENV", "local")
model_config = SettingsConfigDict(env_file=f".env.{env}", env_file_encoding="utf-8")
```

## Django settings pattern

Django uses a split-settings approach:

```
myapp/settings/
├── base.py          # shared settings
├── local.py         # development overrides
├── staging.py       # staging overrides
└── production.py    # production overrides
```

`settings/base.py`:
```python
import os
from pathlib import Path
from django.core.exceptions import ImproperlyConfigured

def env(key, default=None, required=False):
    value = os.environ.get(key, default)
    if required and value is None:
        raise ImproperlyConfigured(f"Environment variable {key!r} is required")
    return value

SECRET_KEY = env("SECRET_KEY", required=True)
DATABASES = {
    "default": {
        "ENGINE": "django.db.backends.postgresql",
        "NAME": env("DB_NAME", required=True),
        "USER": env("DB_USER", required=True),
        "PASSWORD": env("DB_PASSWORD", required=True),
        "HOST": env("DB_HOST", "localhost"),
        "PORT": env("DB_PORT", "5432"),
    }
}
```

Select settings module via `DJANGO_SETTINGS_MODULE`:
```bash
DJANGO_SETTINGS_MODULE=myapp.settings.production python manage.py runserver
```

## Docker environment injection

For containers, pass vars via `docker-compose.yml`:
```yaml
services:
  api:
    env_file:
      - .env.${APP_ENV:-local}
    environment:
      - APP_ENV=${APP_ENV:-local}
```

Or Kubernetes: use `ConfigMap` for non-sensitive vars, `Secret` for sensitive vars. Never bake `.env` files into Docker images.
