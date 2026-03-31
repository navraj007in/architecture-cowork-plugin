---
name: project-templates-python
description: Starter file templates and boilerplate for scaffolding Python backends (FastAPI, Python AI agents)
type: skill-extension
parent: project-templates
---

# Python Project Templates

## Backend — Python / FastAPI

**pyproject.toml:**
```toml
[project]
name = "{{component-name}}"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.34.0",
    "python-dotenv>=1.0.0",
    "pydantic-settings>=2.0.0",
    "structlog>=24.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "httpx>=0.28.0",
    "ruff>=0.6.0",
]
```

**requirements.txt:**
```
fastapi>=0.115.0
uvicorn[standard]>=0.34.0
python-dotenv>=1.0.0
pydantic-settings>=2.0.0
structlog>=24.0.0
```

**main.py:**
```python
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config import settings
from app.lib.logger import get_logger

logger = get_logger(__name__)


@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("startup", service="{{component-name}}")
    yield
    logger.info("shutdown", service="{{component-name}}")


app = FastAPI(title="{{component-name}}", lifespan=lifespan)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
async def health():
    return {"status": "ok", "service": "{{component-name}}"}


@app.get("/health/ready")
async def ready():
    checks: dict[str, str] = {}

    # TODO: Add dependency checks from manifest observability.health_checks
    # try:
    #     await db.execute("SELECT 1")
    #     checks["database"] = "ok"
    # except Exception:
    #     checks["database"] = "fail"

    all_ok = all(v == "ok" for v in checks.values())
    status_code = 200 if all_ok else 503
    from fastapi.responses import JSONResponse
    return JSONResponse(
        status_code=status_code,
        content={"status": "ok" if all_ok else "degraded", "checks": checks},
    )
```

**app/config.py:**
```python
from pydantic_settings import BaseSettings, SettingsConfigDict
from pydantic import field_validator


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

    port: int = 8000
    app_env: str = "development"
    database_url: str = ""
    cors_origins: list[str] = ["http://localhost:3000"]

    @field_validator("cors_origins", mode="before")
    @classmethod
    def parse_cors(cls, v: str | list[str]) -> list[str]:
        if isinstance(v, str):
            return [o.strip() for o in v.split(",")]
        return v


settings = Settings()
```

**app/routes/__init__.py:**
```python
# Route modules
```

**Directory structure:**
```
{{component-name}}/
├── main.py
├── pyproject.toml
├── requirements.txt
├── .env.example
├── Dockerfile
├── docker-compose.yml
├── app/
│   ├── config.py
│   ├── lib/
│   │   └── logger.py
│   ├── middleware/
│   │   └── auth.py
│   └── routes/
│       └── __init__.py
└── .github/
    └── workflows/
        └── ci.yml
```

Run with: `uvicorn main:app --reload`

---

## Python Agent (Claude SDK)

**pyproject.toml:**
```toml
[project]
name = "{{component-name}}"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "anthropic>=0.42.0",
    "fastapi>=0.115.0",
    "uvicorn[standard]>=0.34.0",
    "python-dotenv>=1.0.0",
    "structlog>=24.0.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=8.0.0",
    "httpx>=0.28.0",
]
```

**requirements.txt:**
```
anthropic>=0.42.0
fastapi>=0.115.0
uvicorn[standard]>=0.34.0
python-dotenv>=1.0.0
structlog>=24.0.0
```

**agent.py:**
```python
import anthropic
from dotenv import load_dotenv

load_dotenv()

client = anthropic.Anthropic()

SYSTEM_PROMPT = open("prompts/system.md").read()


def run_agent(user_message: str) -> str:
    """Run a single turn of the agent."""
    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=4096,
        system=SYSTEM_PROMPT,
        messages=[{"role": "user", "content": user_message}],
    )
    return response.content[0].text
```

**main.py:**
```python
from fastapi import FastAPI
from pydantic import BaseModel
from dotenv import load_dotenv
from agent import run_agent

load_dotenv()

app = FastAPI(title="{{component-name}}")


class AgentRequest(BaseModel):
    message: str


@app.post("/chat")
async def chat(request: AgentRequest):
    response = run_agent(request.message)
    return {"response": response}


@app.get("/health")
async def health():
    return {"status": "ok", "service": "{{component-name}}"}
```

**prompts/system.md:**
```markdown
You are {{component-name}}, an AI assistant that {{component-description}}.

## What You Do
- [Capability 1]
- [Capability 2]

## What You Don't Do
- [Limitation 1]
- [Limitation 2]

## Communication Style
Be helpful, concise, and professional.
```

**tools/__init__.py:**
```python
# Agent tools
```

---

## Security Middleware

**app/middleware/auth.py:**
```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

security = HTTPBearer()


async def require_auth(
    credentials: HTTPAuthorizationCredentials = Depends(security),
) -> dict:
    """
    JWT verification dependency.
    TODO: Replace with actual auth provider SDK based on the architecture's auth_strategy.
    """
    token = credentials.credentials
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing authentication token",
        )
    # TODO: Verify JWT with auth provider
    # user = await verify_token(token)
    # return user
    return {"token": token}
```

**app/middleware/correlation.py:**
```python
import uuid
from starlette.middleware.base import BaseHTTPMiddleware
from starlette.requests import Request

CORRELATION_HEADER = "X-Correlation-ID"


class CorrelationIdMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        correlation_id = request.headers.get(CORRELATION_HEADER, str(uuid.uuid4()))
        request.state.correlation_id = correlation_id
        response = await call_next(request)
        response.headers[CORRELATION_HEADER] = correlation_id
        return response
```

Register in main.py: `app.add_middleware(CorrelationIdMiddleware)`

---

## Observability

**app/lib/logger.py:**
```python
import structlog

structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.JSONRenderer(),
    ],
)


def get_logger(name: str = "{{component-name}}") -> structlog.BoundLogger:
    return structlog.get_logger(name)
```

---

## CI Workflow

**.github/workflows/ci.yml:**
```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: actions/setup-python@v5
        with:
          python-version: "3.13"

      - run: pip install -r requirements.txt

      - name: Lint
        run: ruff check .

      - name: Test
        run: pytest
```

---

## Dockerfile

```dockerfile
FROM python:3.13-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
EXPOSE {{dev-port}}
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "{{dev-port}}"]
```

---

## .gitignore

```
__pycache__/
*.pyc
.env
.venv/
venv/
dist/
*.egg-info/
.DS_Store
.pytest_cache/
```

---

## Shared Types Package

**packages/shared-types/pyproject.toml:**
```toml
[project]
name = "{{shared-library-name}}"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "pydantic>=2.0.0",
]
```

**packages/shared-types/src/types.py:**
```python
from pydantic import BaseModel


# Generated from manifest shared.types[]

class User(BaseModel):
    """Core user type. TODO: Add proper field types."""
    id: str
    email: str
    # TODO: Add remaining fields from manifest
```
