# Data Model Generation — Go

## ORM Selection

| Approach | Library | Best for |
|---|---|---|
| Full ORM | GORM | Rapid development, complex relations |
| Type-safe SQL | sqlc | Performance-critical, complex queries, explicit SQL |
| Raw SQL | database/sql | Maximum control, simple schemas |

## GORM — Full ORM

### Base model
```go
// internal/models/base.go
package models

import (
    "time"
    "github.com/google/uuid"
    "gorm.io/gorm"
)

type Base struct {
    ID        uuid.UUID      `gorm:"type:uuid;primarykey;default:gen_random_uuid()" json:"id"`
    CreatedAt time.Time      `json:"created_at"`
    UpdatedAt time.Time      `json:"updated_at"`
    DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`  // built-in soft delete
}
```

### Entity definition
```go
// internal/models/user.go
package models

import "github.com/google/uuid"

type User struct {
    Base
    Email  string  `gorm:"uniqueIndex;size:255;not null" json:"email"`
    Name   string  `gorm:"size:100;not null" json:"name"`
    Role   string  `gorm:"size:50;default:'user'" json:"role"`
    Orders []Order `gorm:"foreignKey:UserID" json:"orders,omitempty"`
}
```

### Database connection
```go
// internal/db/db.go
package db

import (
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
    "gorm.io/gorm/logger"
    "os"
)

func New(dsn string) (*gorm.DB, error) {
    logLevel := logger.Silent
    if os.Getenv("APP_ENV") == "local" {
        logLevel = logger.Info
    }
    return gorm.Open(postgres.Open(dsn), &gorm.Config{
        Logger: logger.Default.LogMode(logLevel),
    })
}

func AutoMigrate(db *gorm.DB) error {
    return db.AutoMigrate(
        &models.User{},
        &models.Order{},
        // add all models here
    )
}
```

### Migrations with goose
Prefer explicit SQL migrations over AutoMigrate in production:

```bash
go install github.com/pressly/goose/v3/cmd/goose@latest
goose -dir migrations postgres "$DATABASE_URL" create add_users_table sql
```

```sql
-- migrations/001_add_users_table.sql
-- +goose Up
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL DEFAULT 'user',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMPTZ
);
CREATE INDEX idx_users_email_active ON users(email) WHERE deleted_at IS NULL;

-- +goose Down
DROP TABLE users;
```

Apply:
```bash
goose -dir migrations postgres "$DATABASE_URL" up
```

## sqlc — Type-safe SQL

sqlc generates Go code from SQL queries. Better for read-heavy services or complex queries.

### Setup
```bash
go install github.com/sqlc-dev/sqlc/cmd/sqlc@latest
```

`sqlc.yaml`:
```yaml
version: "2"
sql:
  - engine: "postgresql"
    queries: "db/queries"
    schema: "db/migrations"
    gen:
      go:
        package: "sqlcdb"
        out: "internal/sqlcdb"
        emit_json_tags: true
        emit_prepared_queries: false
```

Query file `db/queries/users.sql`:
```sql
-- name: GetUser :one
SELECT * FROM users WHERE id = $1 AND deleted_at IS NULL LIMIT 1;

-- name: ListUsers :many
SELECT * FROM users WHERE deleted_at IS NULL ORDER BY created_at DESC LIMIT $1 OFFSET $2;

-- name: CreateUser :one
INSERT INTO users (email, name, role) VALUES ($1, $2, $3) RETURNING *;

-- name: SoftDeleteUser :exec
UPDATE users SET deleted_at = NOW() WHERE id = $1;
```

Generate:
```bash
sqlc generate
```

## Struct tags and JSON serialization

Always define separate request/response structs — never expose DB models directly:

```go
// internal/dto/user.go
package dto

import (
    "time"
    "github.com/google/uuid"
)

type UserResponse struct {
    ID        uuid.UUID `json:"id"`
    Email     string    `json:"email"`
    Name      string    `json:"name"`
    Role      string    `json:"role"`
    CreatedAt time.Time `json:"created_at"`
}

type CreateUserRequest struct {
    Email string `json:"email" validate:"required,email"`
    Name  string `json:"name"  validate:"required,min=1,max=100"`
    Role  string `json:"role"  validate:"omitempty,oneof=user admin"`
}
```

## Required modules

```
gorm.io/gorm v1.25.x
gorm.io/driver/postgres v1.5.x
github.com/pressly/goose/v3 v3.x   (migrations)
github.com/google/uuid v1.6.x
github.com/go-playground/validator/v10 v10.x
```

For sqlc:
```
github.com/sqlc-dev/sqlc (dev tool only)
github.com/jackc/pgx/v5 v5.x        (PostgreSQL driver)
```
