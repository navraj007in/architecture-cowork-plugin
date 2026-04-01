# Environment Setup — .NET / ASP.NET Core

> **Per-service .env scoping** — For multi-service projects, scope env vars to only the services that need them using `architecture.services[].dependsOn[]` from the SDL (check `solution.sdl.yaml` first; if absent, check `sdl/architecture.yaml` or `sdl/services.yaml`). See the "Multi-Service Projects — Per-Service .env Scoping" section in `skills/setup-env/SKILL.md`.

## appsettings.json approach

.NET uses `appsettings.json` + `appsettings.{Environment}.json` + environment variables. All three are merged — env vars override JSON files.

### File structure
```
appsettings.json               # defaults and non-sensitive config
appsettings.Development.json   # local dev overrides
appsettings.Staging.json       # staging overrides
appsettings.Production.json    # production overrides
.env                           # not native — use User Secrets instead
```

### `appsettings.json`
```json
{
  "App": {
    "ServiceName": "api",
    "ServiceVersion": "0.1.0",
    "AllowedOrigins": "http://localhost:3000"
  },
  "ConnectionStrings": {
    "Default": "Host=localhost;Database=myapp;Username=postgres;Password=password"
  },
  "Redis": {
    "ConnectionString": "localhost:6379"
  },
  "Jwt": {
    "Issuer": "myapp",
    "Audience": "myapp",
    "Algorithm": "HS256",
    "ExpiryMinutes": 30
  },
  "Logging": {
    "LogLevel": { "Default": "Information" }
  }
}
```

### Strongly-typed settings with validation

```csharp
// Configuration/AppSettings.cs
using System.ComponentModel.DataAnnotations;

public class AppSettings
{
    [Required] public string ServiceName { get; set; } = string.Empty;
    [Required] public string ServiceVersion { get; set; } = string.Empty;
    [Required] public string AllowedOrigins { get; set; } = string.Empty;
}

public class JwtSettings
{
    [Required] public string Issuer { get; set; } = string.Empty;
    [Required] public string Audience { get; set; } = string.Empty;
    [Required] public string Secret { get; set; } = string.Empty;
    public int ExpiryMinutes { get; set; } = 30;
}
```

`Program.cs`:
```csharp
builder.Services
    .AddOptions<AppSettings>()
    .Bind(builder.Configuration.GetSection("App"))
    .ValidateDataAnnotations()
    .ValidateOnStart();

builder.Services
    .AddOptions<JwtSettings>()
    .Bind(builder.Configuration.GetSection("Jwt"))
    .ValidateDataAnnotations()
    .ValidateOnStart();
```

Inject via DI:
```csharp
public class MyService(IOptions<JwtSettings> jwtOptions)
{
    private readonly JwtSettings _jwt = jwtOptions.Value;
}
```

### User Secrets (local development — never commit)
```bash
dotnet user-secrets init
dotnet user-secrets set "Jwt:Secret" "your-super-secret-key"
dotnet user-secrets set "ConnectionStrings:Default" "Host=localhost;..."
```

Secrets are stored in `~/.microsoft/usersecrets/<project-id>/secrets.json` — not in the project directory.

Enable in `Program.cs` (automatic in Development, manual otherwise):
```csharp
if (builder.Environment.IsDevelopment())
    builder.Configuration.AddUserSecrets<Program>();
```

### `appsettings.Production.json` — override pattern
```json
{
  "App": {
    "AllowedOrigins": "https://app.example.com"
  },
  "Logging": {
    "LogLevel": { "Default": "Warning" }
  }
}
```

Sensitive production values come from environment variables (not JSON files):
```bash
# Set in Azure App Service / AWS ECS / Kubernetes Secret:
ConnectionStrings__Default="Host=prod-db.example.com;..."
Jwt__Secret="..."
```

.NET automatically maps `ConnectionStrings__Default` → `ConnectionStrings:Default` (double underscore = nesting).

### Docker environment injection
```yaml
# docker-compose.yml
services:
  api:
    environment:
      - ASPNETCORE_ENVIRONMENT=Staging
      - ConnectionStrings__Default=${DATABASE_URL}
      - Jwt__Secret=${JWT_SECRET}
```

### `.env.example` (for local reference — not loaded natively)
```dotenv
# Not loaded by .NET natively — use User Secrets for local dev
# These document what environment variables must be set in CI/CD/production

ConnectionStrings__Default=Host=localhost;Database=myapp;Username=postgres;Password=password
Jwt__Secret=your-jwt-secret
App__AllowedOrigins=http://localhost:3000
ASPNETCORE_ENVIRONMENT=Development
```
