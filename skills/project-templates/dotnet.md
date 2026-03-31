---
name: project-templates-dotnet
description: Starter file templates and boilerplate for scaffolding .NET backend services (ASP.NET Core Web API)
type: skill-extension
parent: project-templates
---

# .NET Project Templates

## Backend — ASP.NET Core Web API

Initialize with CLI (preferred):
```bash
dotnet new webapi -n {{component-name}} --use-controllers false
cd {{component-name}}
dotnet add package Serilog.AspNetCore
dotnet add package Serilog.Sinks.Console
dotnet add package Microsoft.EntityFrameworkCore.Design
dotnet add package Npgsql.EntityFrameworkCore.PostgreSQL
dotnet add package FluentValidation.AspNetCore
```

**{{component-name}}.csproj:**
```xml
<Project Sdk="Microsoft.NET.Sdk.Web">
  <PropertyGroup>
    <TargetFramework>net9.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <RootNamespace>{{PascalCaseName}}</RootNamespace>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Serilog.AspNetCore" Version="8.*" />
    <PackageReference Include="Serilog.Sinks.Console" Version="6.*" />
    <PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="9.*" />
    <PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="9.*">
      <IncludeAssets>runtime; build; native; contentfiles; analyzers</IncludeAssets>
      <PrivateAssets>all</PrivateAssets>
    </PackageReference>
    <PackageReference Include="FluentValidation.AspNetCore" Version="11.*" />
  </ItemGroup>
</Project>
```

**Program.cs:**
```csharp
using Serilog;
using {{PascalCaseName}}.Infrastructure;

Log.Logger = new LoggerConfiguration()
    .WriteTo.Console(outputTemplate: "[{Timestamp:HH:mm:ss} {Level:u3}] {Message:lj} {Properties:j}{NewLine}{Exception}")
    .Enrich.FromLogContext()
    .CreateLogger();

try
{
    var builder = WebApplication.CreateBuilder(args);

    builder.Host.UseSerilog();

    builder.Services.AddControllers();
    builder.Services.AddEndpointsApiExplorer();
    builder.Services.AddSwaggerGen();

    // CORS
    builder.Services.AddCors(options =>
    {
        options.AddDefaultPolicy(policy =>
        {
            var origins = builder.Configuration["CorsOrigins"]?.Split(",")
                ?? ["http://localhost:3000"];
            policy.WithOrigins(origins)
                  .AllowAnyHeader()
                  .AllowAnyMethod()
                  .AllowCredentials();
        });
    });

    // Infrastructure (DB, repos, etc.)
    builder.Services.AddInfrastructure(builder.Configuration);

    var app = builder.Build();

    if (app.Environment.IsDevelopment())
    {
        app.UseSwagger();
        app.UseSwaggerUI();
    }

    app.UseHttpsRedirection();
    app.UseCors();
    app.UseAuthentication();
    app.UseAuthorization();
    app.MapControllers();

    // Health endpoints
    app.MapGet("/health", () => Results.Ok(new { status = "ok", service = "{{component-name}}", timestamp = DateTime.UtcNow }));
    app.MapGet("/health/ready", async (AppDbContext db) =>
    {
        try
        {
            await db.Database.CanConnectAsync();
            return Results.Ok(new { status = "ok", service = "{{component-name}}", checks = new { database = "ok" } });
        }
        catch
        {
            return Results.Json(new { status = "degraded", checks = new { database = "fail" } }, statusCode: 503);
        }
    });

    app.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, "Application startup failed");
}
finally
{
    Log.CloseAndFlush();
}
```

**Infrastructure/ServiceExtensions.cs:**
```csharp
using Microsoft.EntityFrameworkCore;

namespace {{PascalCaseName}}.Infrastructure;

public static class ServiceExtensions
{
    public static IServiceCollection AddInfrastructure(
        this IServiceCollection services,
        IConfiguration configuration)
    {
        services.AddDbContext<AppDbContext>(options =>
            options.UseNpgsql(configuration.GetConnectionString("Default")));

        // TODO: Register repositories, services per manifest
        return services;
    }
}
```

**Infrastructure/AppDbContext.cs:**
```csharp
using Microsoft.EntityFrameworkCore;

namespace {{PascalCaseName}}.Infrastructure;

public class AppDbContext(DbContextOptions<AppDbContext> options) : DbContext(options)
{
    // TODO: Add DbSets per generate-data-model output
    // public DbSet<Order> Orders => Set<Order>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Soft-delete global query filter
        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            if (typeof(BaseEntity).IsAssignableFrom(entityType.ClrType))
            {
                modelBuilder.Entity(entityType.ClrType)
                    .HasQueryFilter(e => !EF.Property<bool>(e, "IsDeleted"));
            }
        }
    }

    public override async Task<int> SaveChangesAsync(CancellationToken cancellationToken = default)
    {
        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedAt = DateTime.UtcNow;
                    entry.Entity.UpdatedAt = DateTime.UtcNow;
                    break;
                case EntityState.Modified:
                    entry.Entity.UpdatedAt = DateTime.UtcNow;
                    break;
                case EntityState.Deleted:
                    entry.State = EntityState.Modified;
                    entry.Entity.IsDeleted = true;
                    entry.Entity.UpdatedAt = DateTime.UtcNow;
                    break;
            }
        }
        return await base.SaveChangesAsync(cancellationToken);
    }
}
```

**Infrastructure/BaseEntity.cs:**
```csharp
namespace {{PascalCaseName}}.Infrastructure;

public abstract class BaseEntity
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public bool IsDeleted { get; set; }
}
```

**Directory structure:**
```
{{component-name}}/
├── {{component-name}}.csproj
├── Program.cs
├── appsettings.json
├── appsettings.Development.json
├── Dockerfile
├── docker-compose.yml
├── Controllers/
│   └── .gitkeep
├── Features/              # Vertical slices (optional)
│   └── .gitkeep
├── Infrastructure/
│   ├── AppDbContext.cs
│   ├── BaseEntity.cs
│   └── ServiceExtensions.cs
└── .github/
    └── workflows/
        └── ci.yml
```

---

## .NET — Configuration

**appsettings.json:**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "ConnectionStrings": {
    "Default": ""
  },
  "CorsOrigins": "http://localhost:3000"
}
```

**appsettings.Development.json:**
```json
{
  "ConnectionStrings": {
    "Default": "Host=localhost;Port=5432;Database={{component-name}}_dev;Username=postgres;Password=postgres"
  }
}
```

Environment variable override (double-underscore notation):
```bash
ConnectionStrings__Default=Host=...
CorsOrigins=https://app.example.com
```

---

## .NET — Auth Middleware

**Middleware/AuthMiddleware.cs:**
```csharp
namespace {{PascalCaseName}}.Middleware;

public class AuthMiddleware(RequestDelegate next)
{
    public async Task InvokeAsync(HttpContext context)
    {
        var authHeader = context.Request.Headers.Authorization.ToString();
        if (string.IsNullOrEmpty(authHeader) || !authHeader.StartsWith("Bearer "))
        {
            context.Response.StatusCode = 401;
            await context.Response.WriteAsJsonAsync(new { code = "UNAUTHORIZED", message = "Missing or invalid token" });
            return;
        }

        // var token = authHeader["Bearer ".Length..];
        // TODO: Verify with auth provider (Clerk, Auth0, etc.)

        await next(context);
    }
}
```

Register in Program.cs: `app.UseMiddleware<AuthMiddleware>();`

---

## .NET — Correlation ID Middleware

**Middleware/CorrelationIdMiddleware.cs:**
```csharp
namespace {{PascalCaseName}}.Middleware;

public class CorrelationIdMiddleware(RequestDelegate next)
{
    private const string Header = "X-Correlation-ID";

    public async Task InvokeAsync(HttpContext context)
    {
        var id = context.Request.Headers[Header].FirstOrDefault() ?? Guid.NewGuid().ToString();
        context.Items["CorrelationId"] = id;
        context.Response.Headers[Header] = id;
        await next(context);
    }
}
```

---

## .NET — CI Workflow

**.github/workflows/ci.yml (.NET):**
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

      - uses: actions/setup-dotnet@v4
        with:
          dotnet-version: "9.0.x"

      - name: Restore
        run: dotnet restore

      - name: Build
        run: dotnet build --no-restore --configuration Release

      - name: Test
        run: dotnet test --no-build --configuration Release --verbosity normal
```

---

## .NET — Dockerfile

**Dockerfile:**
```dockerfile
# Build stage
FROM mcr.microsoft.com/dotnet/sdk:9.0-alpine AS build
WORKDIR /src
COPY *.csproj ./
RUN dotnet restore
COPY . .
RUN dotnet publish -c Release -o /app/publish --no-restore

# Runtime stage
FROM mcr.microsoft.com/dotnet/aspnet:9.0-alpine AS runtime
WORKDIR /app
COPY --from=build /app/publish .
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "{{component-name}}.dll"]
```

---

## .NET — .gitignore

**.gitignore:**
```
# Build outputs
bin/
obj/

# User-specific files
*.user
*.suo
.vs/

# NuGet
*.nupkg
packages/

# Secrets
appsettings.*.local.json
secrets.json

# Environment
.env
.env.local
```

---

## .NET — .env.example

**.env.example:**
```bash
ASPNETCORE_ENVIRONMENT=Development
ConnectionStrings__Default=Host=localhost;Port=5432;Database={{component-name}}_dev;Username=postgres;Password=postgres
CorsOrigins=http://localhost:3000

# STAGING: {{staging-url}}
# PRODUCTION: {{production-url}}
```
