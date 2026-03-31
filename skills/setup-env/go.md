# Environment Setup — Go

## Recommended: `caarlos0/env` package

**Install:** `go get github.com/caarlos0/env/v11`

### `internal/config/config.go`
```go
package config

import (
    "log/slog"
    "github.com/caarlos0/env/v11"
)

type Config struct {
    // App
    AppEnv         string `env:"APP_ENV"         envDefault:"local"`
    ServiceName    string `env:"SERVICE_NAME"    envDefault:"api"`
    ServiceVersion string `env:"SERVICE_VERSION" envDefault:"0.1.0"`
    Port           int    `env:"PORT"            envDefault:"8080"`
    AllowedOrigins string `env:"ALLOWED_ORIGINS" envDefault:"http://localhost:3000"`

    // Database (required — no default)
    DatabaseURL    string `env:"DATABASE_URL,required"`
    DBMaxOpenConns int    `env:"DB_MAX_OPEN_CONNS" envDefault:"10"`
    DBMaxIdleConns int    `env:"DB_MAX_IDLE_CONNS" envDefault:"5"`

    // Redis (optional)
    RedisURL string `env:"REDIS_URL" envDefault:"redis://localhost:6379"`

    // Auth
    JWTSecret            string `env:"JWT_SECRET,required"`
    JWTAlgorithm         string `env:"JWT_ALGORITHM"          envDefault:"HS256"`
    AccessTokenExpiryMin int    `env:"ACCESS_TOKEN_EXPIRY_MIN" envDefault:"30"`

    // Inter-service URLs (add per SDL consumer)
    // OtherServiceURL string `env:"OTHER_SERVICE_URL" envDefault:"http://localhost:3001"`
}

func Load() (*Config, error) {
    cfg := &Config{}
    if err := env.Parse(cfg); err != nil {
        return nil, err
    }
    slog.Info("config loaded",
        slog.String("env", cfg.AppEnv),
        slog.String("service", cfg.ServiceName),
    )
    return cfg, nil
}
```

### `main.go` — fail fast on missing config
```go
func main() {
    cfg, err := config.Load()
    if err != nil {
        slog.Error("failed to load config", "err", err)
        os.Exit(1)
    }
    // ...
}
```

### `.env.example`
```dotenv
# App
APP_ENV=local
SERVICE_NAME=api
SERVICE_VERSION=0.1.0
PORT=8080
ALLOWED_ORIGINS=http://localhost:3000

# Database (required)
DATABASE_URL=postgres://postgres:password@localhost:5432/myapp?sslmode=disable
DB_MAX_OPEN_CONNS=10
DB_MAX_IDLE_CONNS=5

# Redis
REDIS_URL=redis://localhost:6379

# Auth (required)
JWT_SECRET=your-jwt-secret-here
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRY_MIN=30
```

### Loading `.env` files in development

Go doesn't load `.env` files automatically. Use `godotenv`:

**Install:** `go get github.com/joho/godotenv`

```go
// In main.go, before config.Load():
if os.Getenv("APP_ENV") == "" {
    _ = godotenv.Load(".env")  // ignore error — file may not exist in production
}
```

Or in Makefile:
```makefile
run:
    APP_ENV=local go run cmd/api/main.go
```

### Per-environment files
```dotenv
# .env.staging
APP_ENV=staging
DATABASE_URL=postgres://user:pass@db.staging.example.com:5432/myapp?sslmode=require
REDIS_URL=redis://:password@redis.staging.example.com:6379
ALLOWED_ORIGINS=https://app.staging.example.com
```

Load in Docker:
```yaml
services:
  api:
    env_file:
      - .env.${APP_ENV:-local}
    environment:
      - APP_ENV=${APP_ENV:-local}
```

### Alternative: `viper` (for complex config scenarios)
Use `viper` when you need config file support (YAML/TOML) in addition to env vars — e.g., agent services with complex nested config:

```go
import "github.com/spf13/viper"

viper.SetConfigName("config")
viper.SetConfigType("yaml")
viper.AddConfigPath("./config")
viper.AutomaticEnv()  // env vars override config file
viper.ReadInConfig()

type Config struct {
    Port int `mapstructure:"port"`
}
var cfg Config
viper.Unmarshal(&cfg)
```
