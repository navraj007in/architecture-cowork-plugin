# Production Hardening — Go

Apply these patterns when the SDL specifies `runtime: go` or `framework: go`.

> **scaffold_depth gating** — Before applying patterns, resolve `scaffold_depth` from `solution.stage` in the SDL (check `solution.sdl.yaml` first; if absent, check `sdl/core.yaml` or `sdl/solution.yaml`). Pattern 7 (retry+timeout) and Pattern 8 (soft delete) have reduced requirements at MVP stage. See the gating table in `skills/production-hardening/SKILL.md`.

---

### Pattern 1 — Correlation ID (Go)

```go
// middleware/correlation_id.go
package middleware

import (
    "context"
    "github.com/google/uuid"
    "net/http"
)

type contextKey string
const CorrelationIDKey contextKey = "correlationID"
const CorrelationIDHeader = "X-Correlation-ID"

func CorrelationID(next http.Handler) http.Handler {
    return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
        id := r.Header.Get(CorrelationIDHeader)
        if id == "" {
            id = uuid.NewString()
        }
        ctx := context.WithValue(r.Context(), CorrelationIDKey, id)
        w.Header().Set(CorrelationIDHeader, id)
        next.ServeHTTP(w, r.WithContext(ctx))
    })
}

func GetCorrelationID(ctx context.Context) string {
    if id, ok := ctx.Value(CorrelationIDKey).(string); ok {
        return id
    }
    return ""
}
```

---

### Pattern 2 — Graceful Shutdown (Go)

```go
// main.go
package main

import (
    "context"
    "log/slog"
    "net/http"
    "os"
    "os/signal"
    "syscall"
    "time"
)

func main() {
    srv := &http.Server{Addr: ":8080", Handler: router}

    go func() {
        if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
            slog.Error("server error", "err", err)
            os.Exit(1)
        }
    }()

    quit := make(chan os.Signal, 1)
    signal.Notify(quit, syscall.SIGTERM, syscall.SIGINT)
    <-quit

    slog.Info("shutting down gracefully")
    ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
    defer cancel()

    if err := srv.Shutdown(ctx); err != nil {
        slog.Error("forced shutdown", "err", err)
    }

    db.Close()   // close DB pool
    slog.Info("server stopped")
}
```

---

### Pattern 3 — Auth Token Interceptor (Go — outbound HTTP)

```go
// lib/http_client.go
package lib

import (
    "context"
    "fmt"
    "net/http"
    "time"
)

type TokenProvider interface {
    GetToken(ctx context.Context) (string, error)
}

type ServiceClient struct {
    base     string
    client   *http.Client
    tokens   TokenProvider
}

func NewServiceClient(base string, tokens TokenProvider) *ServiceClient {
    return &ServiceClient{
        base:   base,
        client: &http.Client{Timeout: 10 * time.Second},
        tokens: tokens,
    }
}

func (c *ServiceClient) Get(ctx context.Context, path string) (*http.Response, error) {
    token, err := c.tokens.GetToken(ctx)
    if err != nil {
        return nil, err
    }
    req, err := http.NewRequestWithContext(ctx, http.MethodGet, c.base+path, nil)
    if err != nil {
        return nil, err
    }
    req.Header.Set("Authorization", fmt.Sprintf("Bearer %s", token))
    req.Header.Set("X-Correlation-ID", middleware.GetCorrelationID(ctx))
    return c.client.Do(req)
}
```

---

### Pattern 4 — Validation (Go)

**Module:** `github.com/go-playground/validator/v10`

```go
// schemas/user.go
package schemas

type CreateUserRequest struct {
    Email string `json:"email" validate:"required,email"`
    Name  string `json:"name"  validate:"required,min=1,max=100"`
    Role  string `json:"role"  validate:"omitempty,oneof=user admin"`
}

// middleware/validate.go
package middleware

import (
    "encoding/json"
    "net/http"
    "github.com/go-playground/validator/v10"
)

var validate = validator.New()

func ValidateBody[T any](next func(http.ResponseWriter, *http.Request, T)) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        var body T
        if err := json.NewDecoder(r.Body).Decode(&body); err != nil {
            http.Error(w, `{"error":"invalid JSON"}`, http.StatusBadRequest)
            return
        }
        if err := validate.Struct(body); err != nil {
            w.Header().Set("Content-Type", "application/json")
            w.WriteHeader(http.StatusBadRequest)
            json.NewEncoder(w).Encode(map[string]any{"error": err.Error()})
            return
        }
        next(w, r, body)
    }
}
```

Env var validation using `envconfig` or `github.com/caarlos0/env`:
```go
// config/config.go
package config

import "github.com/caarlos0/env/v11"

type Config struct {
    DatabaseURL    string `env:"DATABASE_URL,required"`
    RedisURL       string `env:"REDIS_URL" envDefault:"redis://localhost:6379"`
    AllowedOrigins string `env:"ALLOWED_ORIGINS" envDefault:"http://localhost:3000"`
    ServiceName    string `env:"SERVICE_NAME" envDefault:"api"`
}

func Load() (*Config, error) {
    cfg := &Config{}
    return cfg, env.Parse(cfg)
}
```

---

### Pattern 5 — Deep Health Check (Go)

```go
// handlers/health.go
package handlers

import (
    "database/sql"
    "encoding/json"
    "net/http"
    "runtime"
    "time"
)

type HealthStatus struct {
    Status  string            `json:"status"`
    Checks  map[string]Check  `json:"checks"`
    Uptime  float64           `json:"uptime_seconds"`
    Memory  uint64            `json:"heap_alloc_bytes"`
}

type Check struct {
    Status     string `json:"status"`
    ResponseMs int64  `json:"response_ms,omitempty"`
    Error      string `json:"error,omitempty"`
}

var startTime = time.Now()

func HealthCheck(db *sql.DB) http.HandlerFunc {
    return func(w http.ResponseWriter, r *http.Request) {
        checks := map[string]Check{}
        overall := "ok"

        // DB check
        start := time.Now()
        if err := db.PingContext(r.Context()); err != nil {
            checks["db"] = Check{Status: "fail", Error: err.Error()}
            overall = "unhealthy"
        } else {
            checks["db"] = Check{Status: "ok", ResponseMs: time.Since(start).Milliseconds()}
        }

        var m runtime.MemStats
        runtime.ReadMemStats(&m)

        resp := HealthStatus{
            Status: overall,
            Checks: checks,
            Uptime: time.Since(startTime).Seconds(),
            Memory: m.HeapAlloc,
        }

        w.Header().Set("Content-Type", "application/json")
        if overall == "unhealthy" {
            w.WriteHeader(http.StatusServiceUnavailable)
        }
        json.NewEncoder(w).Encode(resp)
    }
}
```

---

### Pattern 6 — Structured Logger (Go)

Go 1.21+ includes `log/slog` natively — no extra dependency:

```go
// lib/logger.go
package lib

import (
    "log/slog"
    "os"
)

func NewLogger(env string) *slog.Logger {
    if env == "production" || env == "staging" {
        return slog.New(slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
            Level: slog.LevelInfo,
        }))
    }
    return slog.New(slog.NewTextHandler(os.Stdout, &slog.HandlerOptions{
        Level: slog.LevelDebug,
    }))
}
```

Usage:
```go
logger.InfoContext(ctx, "request received",
    slog.String("correlation_id", middleware.GetCorrelationID(ctx)),
    slog.String("method", r.Method),
    slog.String("path", r.URL.Path),
)
```

---

### Pattern 7 — Retry + Timeout (Go)

**Module:** `github.com/avast/retry-go` or manual:

```go
// lib/retry.go
package lib

import (
    "context"
    "errors"
    "net/http"
    "time"
)

func WithRetry(ctx context.Context, maxAttempts int, fn func() (*http.Response, error)) (*http.Response, error) {
    delays := []time.Duration{100 * time.Millisecond, 200 * time.Millisecond, 400 * time.Millisecond}
    var lastErr error
    for i := 0; i < maxAttempts; i++ {
        resp, err := fn()
        if err == nil && resp.StatusCode < 500 {
            return resp, nil
        }
        if err == nil {
            lastErr = errors.New("server error: " + resp.Status)
        } else {
            lastErr = err
        }
        if i < len(delays) {
            select {
            case <-ctx.Done():
                return nil, ctx.Err()
            case <-time.After(delays[i]):
            }
        }
    }
    return nil, lastErr
}
```

---

### Pattern 8 — Soft Delete (Go / GORM)

```go
// models/base.go
package models

import (
    "gorm.io/gorm"
    "time"
)

type Base struct {
    ID        uint           `gorm:"primarykey"`
    CreatedAt time.Time
    UpdatedAt time.Time
    DeletedAt gorm.DeletedAt `gorm:"index"`  // GORM soft-delete built-in
}

// Usage — all models embedding Base get soft delete for free:
type User struct {
    Base
    Email string `gorm:"uniqueIndex"`
    Name  string
}

// GORM automatically filters deleted_at IS NULL on all queries
// db.Delete(&user) sets deleted_at instead of DELETE FROM
// db.Unscoped().Find(&users) bypasses the filter (admin use)
```

---

### Pattern 9 — CSP / Security Headers (Go)

**Module:** `github.com/unrolled/secure`

```go
// middleware/security.go
package middleware

import (
    "net/http"
    "os"
    "strings"
    "github.com/unrolled/secure"
    "github.com/rs/cors"
)

func SecurityHeaders() func(http.Handler) http.Handler {
    isDev := os.Getenv("APP_ENV") == "local"
    scriptSrc := "'self'"
    if isDev {
        scriptSrc = "'self' 'unsafe-eval'"
    }

    sm := secure.New(secure.Options{
        ContentSecurityPolicy: strings.Join([]string{
            "default-src 'self'",
            "script-src " + scriptSrc,
            "style-src 'self' 'unsafe-inline'",
            "img-src 'self' data: blob:",
            "connect-src 'self'",
            "font-src 'self' https://fonts.gstatic.com",
            "object-src 'none'",
        }, "; "),
        STSSeconds:            31536000,
        STSIncludeSubdomains:  true,
        STSPreload:            true,
        FrameDeny:             true,
        ContentTypeNosniff:    true,
        IsDevelopment:         isDev,
    })

    return sm.Handler
}

func CORS() func(http.Handler) http.Handler {
    origins := strings.Split(os.Getenv("ALLOWED_ORIGINS"), ",")
    return cors.New(cors.Options{
        AllowedOrigins:   origins,
        AllowedMethods:   []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
        AllowedHeaders:   []string{"*"},
        AllowCredentials: true,
    }).Handler
}
```
