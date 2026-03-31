---
name: project-templates-go
description: Starter file templates and boilerplate for scaffolding Go backend services (Gin, Echo, net/http)
type: skill-extension
parent: project-templates
---

# Go Project Templates

## Backend — Go / Gin

**go.mod:**
```
module {{component-name}}

go 1.23

require (
	github.com/gin-gonic/gin v1.10.0
	github.com/gin-contrib/cors v1.7.2
	github.com/joho/godotenv v1.5.1
	github.com/google/uuid v1.6.0
	go.uber.org/zap v1.27.0
)
```

**main.go:**
```go
package main

import (
	"context"
	"log/slog"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-contrib/cors"
	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	_ = godotenv.Load()

	logger := slog.New(slog.NewJSONHandler(os.Stdout, nil))
	slog.SetDefault(logger)

	r := gin.New()
	r.Use(gin.Recovery())
	r.Use(cors.New(cors.Config{
		AllowOrigins:     []string{os.Getenv("ALLOWED_ORIGINS")},
		AllowMethods:     []string{"GET", "POST", "PUT", "PATCH", "DELETE", "OPTIONS"},
		AllowHeaders:     []string{"Origin", "Content-Type", "Authorization"},
		AllowCredentials: true,
	}))

	r.GET("/health", healthHandler)
	r.GET("/health/ready", readyHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	srv := &http.Server{Addr: ":" + port, Handler: r}

	go func() {
		slog.Info("server starting", "port", port)
		if err := srv.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			slog.Error("server error", "err", err)
			os.Exit(1)
		}
	}()

	quit := make(chan os.Signal, 1)
	signal.Notify(quit, syscall.SIGINT, syscall.SIGTERM)
	<-quit

	slog.Info("shutting down gracefully")
	ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
	defer cancel()
	_ = srv.Shutdown(ctx)
}

func healthHandler(c *gin.Context) {
	c.JSON(http.StatusOK, gin.H{
		"status":    "ok",
		"service":   "{{component-name}}",
		"timestamp": time.Now().UTC().Format(time.RFC3339),
	})
}

func readyHandler(c *gin.Context) {
	checks := map[string]string{}

	// TODO: Add dependency checks
	// if err := db.PingContext(c.Request.Context()); err != nil {
	//     checks["database"] = "fail"
	// } else {
	//     checks["database"] = "ok"
	// }

	allOk := true
	for _, v := range checks {
		if v != "ok" {
			allOk = false
			break
		}
	}

	status := http.StatusOK
	state := "ok"
	if !allOk {
		status = http.StatusServiceUnavailable
		state = "degraded"
	}

	c.JSON(status, gin.H{
		"status":    state,
		"service":   "{{component-name}}",
		"checks":    checks,
		"timestamp": time.Now().UTC().Format(time.RFC3339),
	})
}
```

**internal/config/config.go:**
```go
package config

import (
	"fmt"
	"os"
)

type Config struct {
	Port        string
	DatabaseURL string
	CorsOrigins string
	Env         string
}

func Load() (*Config, error) {
	dbURL := os.Getenv("DATABASE_URL")
	if dbURL == "" {
		return nil, fmt.Errorf("DATABASE_URL is required")
	}
	return &Config{
		Port:        getEnv("PORT", "8080"),
		DatabaseURL: dbURL,
		CorsOrigins: getEnv("ALLOWED_ORIGINS", "http://localhost:3000"),
		Env:         getEnv("APP_ENV", "development"),
	}, nil
}

func getEnv(key, fallback string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return fallback
}
```

**internal/middleware/auth.go:**
```go
package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)

// RequireAuth validates the Authorization: Bearer <token> header.
// TODO: Replace stub with actual auth provider verification (Clerk, Auth0, etc.)
func RequireAuth() gin.HandlerFunc {
	return func(c *gin.Context) {
		header := c.GetHeader("Authorization")
		if !strings.HasPrefix(header, "Bearer ") {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{
				"code":    "UNAUTHORIZED",
				"message": "Missing or invalid Authorization header",
			})
			return
		}
		// token := strings.TrimPrefix(header, "Bearer ")
		// TODO: verify token, set c.Set("user", user)
		c.Next()
	}
}
```

**internal/middleware/correlation.go:**
```go
package middleware

import (
	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
)

const CorrelationIDHeader = "X-Correlation-ID"

func CorrelationID() gin.HandlerFunc {
	return func(c *gin.Context) {
		id := c.GetHeader(CorrelationIDHeader)
		if id == "" {
			id = uuid.NewString()
		}
		c.Set("correlationID", id)
		c.Header(CorrelationIDHeader, id)
		c.Next()
	}
}
```

**Directory structure:**
```
{{component-name}}/
├── main.go
├── go.mod
├── go.sum
├── .env.example
├── Dockerfile
├── docker-compose.yml
├── internal/
│   ├── config/
│   │   └── config.go
│   ├── middleware/
│   │   ├── auth.go
│   │   └── correlation.go
│   ├── handlers/
│   │   └── .gitkeep
│   └── repository/
│       └── .gitkeep
└── .github/
    └── workflows/
        └── ci.yml
```

Run with: `go run main.go`
Build: `go build -o bin/{{component-name}} main.go`

---

## Go — Auth Middleware

**internal/middleware/auth.go** (see above — included in backend template)

---

## Go — Structured Logger

**internal/logger/logger.go:**
```go
package logger

import (
	"log/slog"
	"os"
)

func New(service string) *slog.Logger {
	handler := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{
		Level: slog.LevelInfo,
	})
	return slog.New(handler).With("service", service)
}
```

---

## Go — Linting

**.golangci.yml:**
```yaml
run:
  timeout: 5m

linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
    - gosec
    - bodyclose
    - noctx

linters-settings:
  gosec:
    excludes:
      - G104  # unhandled errors in defer
```

Run: `golangci-lint run ./...`

---

## Go — Testing

**main_test.go:**
```go
package main

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func setupRouter() *gin.Engine {
	gin.SetMode(gin.TestMode)
	r := gin.New()
	r.GET("/health", healthHandler)
	r.GET("/health/ready", readyHandler)
	return r
}

func TestHealthHandler(t *testing.T) {
	r := setupRouter()
	w := httptest.NewRecorder()
	req, _ := http.NewRequest(http.MethodGet, "/health", nil)
	r.ServeHTTP(w, req)

	if w.Code != http.StatusOK {
		t.Fatalf("expected 200, got %d", w.Code)
	}

	var body map[string]any
	if err := json.Unmarshal(w.Body.Bytes(), &body); err != nil {
		t.Fatal(err)
	}
	if body["status"] != "ok" {
		t.Errorf("expected status ok, got %v", body["status"])
	}
}
```

---

## Go — CI Workflow

**.github/workflows/ci.yml (Go):**
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

      - uses: actions/setup-go@v5
        with:
          go-version: "1.23"
          cache: true

      - name: Vet
        run: go vet ./...

      - name: Lint
        uses: golangci/golangci-lint-action@v6
        with:
          version: latest

      - name: Test
        run: go test -race -coverprofile=coverage.out ./...

      - name: Build
        run: go build ./...

      - name: Audit dependencies
        run: go install golang.org/x/vuln/cmd/govulncheck@latest && govulncheck ./...
```

---

## Go — Dockerfile

**Dockerfile:**
```dockerfile
# Build stage
FROM golang:1.23-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o /app/server main.go

# Runtime stage — distroless has no shell, use debug variant for HEALTHCHECK wget
FROM gcr.io/distroless/static-debian12
COPY --from=builder /app/server /server
EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD ["/server", "-healthcheck"]
ENTRYPOINT ["/server"]
```

> **HEALTHCHECK note for distroless:** distroless images have no wget/curl. Options:
> 1. Add a `-healthcheck` flag to your binary that GETs `/health` and exits 0/1
> 2. Use `FROM gcr.io/distroless/static-debian12:debug` and `CMD wget -qO- http://localhost:8080/health || exit 1`
> 3. Use Kubernetes liveness probes instead (preferred for k8s deployments)

---

## Go — .gitignore

**.gitignore:**
```
# Binaries
bin/
*.exe
*.exe~
*.dll
*.so
*.dylib

# Test binary
*.test

# Output of go coverage
*.out

# Vendor
vendor/

# Environment
.env
.env.local
.env.*.local
```

---

## Go — .env.example

**.env.example:**
```bash
PORT=8080
APP_ENV=development
DATABASE_URL=postgres://user:password@localhost:5432/{{component-name}}_dev?sslmode=disable
ALLOWED_ORIGINS=http://localhost:3000

# STAGING: {{staging-url}}
# PRODUCTION: {{production-url}}
```
