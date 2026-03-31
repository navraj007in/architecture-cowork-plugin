# Production Hardening — .NET / ASP.NET Core

Apply these patterns when the SDL specifies `runtime: dotnet` or `framework: dotnet`.

---

### Pattern 1 — Correlation ID (.NET)

**NuGet:** `CorrelationId` package or implement via middleware.

```csharp
// Middleware/CorrelationIdMiddleware.cs
public class CorrelationIdMiddleware
{
    private const string HeaderName = "x-correlation-id";
    private readonly RequestDelegate _next;

    public CorrelationIdMiddleware(RequestDelegate next) => _next = next;

    public async Task InvokeAsync(HttpContext context)
    {
        var correlationId = context.Request.Headers[HeaderName].FirstOrDefault()
            ?? Guid.NewGuid().ToString();

        context.Items["CorrelationId"] = correlationId;
        context.Response.Headers[HeaderName] = correlationId;

        using (LogContext.PushProperty("CorrelationId", correlationId))
        {
            await _next(context);
        }
    }
}
```

Register in `Program.cs`:
```csharp
app.UseMiddleware<CorrelationIdMiddleware>();
```

---

### Pattern 2 — Graceful Shutdown (.NET)

ASP.NET Core handles SIGTERM natively via `IHostApplicationLifetime`:

```csharp
// Program.cs
var builder = WebApplication.CreateBuilder(args);
builder.Services.AddSingleton<IHostedService, GracefulShutdownService>();

// In appsettings.json
// "ShutdownTimeout": "00:00:10"

// GracefulShutdownService.cs
public class GracefulShutdownService : IHostedService
{
    private readonly IHostApplicationLifetime _lifetime;
    private readonly ILogger<GracefulShutdownService> _logger;

    public GracefulShutdownService(IHostApplicationLifetime lifetime, ILogger<GracefulShutdownService> logger)
    {
        _lifetime = lifetime;
        _logger = logger;
    }

    public Task StartAsync(CancellationToken cancellationToken)
    {
        _lifetime.ApplicationStopping.Register(() =>
            _logger.LogInformation("Application stopping — draining requests..."));
        _lifetime.ApplicationStopped.Register(() =>
            _logger.LogInformation("Application stopped."));
        return Task.CompletedTask;
    }

    public Task StopAsync(CancellationToken cancellationToken) => Task.CompletedTask;
}
```

Set shutdown timeout in `Program.cs`:
```csharp
builder.Services.Configure<HostOptions>(opts => opts.ShutdownTimeout = TimeSpan.FromSeconds(10));
```

---

### Pattern 3 — Auth Token Interceptor (.NET — outbound HTTP)

Use `IHttpClientFactory` with a `DelegatingHandler`:

```csharp
// Infrastructure/TokenDelegatingHandler.cs
public class TokenDelegatingHandler : DelegatingHandler
{
    private readonly ITokenProvider _tokenProvider;

    public TokenDelegatingHandler(ITokenProvider tokenProvider)
        => _tokenProvider = tokenProvider;

    protected override async Task<HttpResponseMessage> SendAsync(
        HttpRequestMessage request, CancellationToken cancellationToken)
    {
        var token = await _tokenProvider.GetTokenAsync();
        request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);

        var response = await base.SendAsync(request, cancellationToken);

        if (response.StatusCode == HttpStatusCode.Unauthorized)
        {
            await _tokenProvider.RefreshAsync();
            token = await _tokenProvider.GetTokenAsync();
            request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token);
            response = await base.SendAsync(request, cancellationToken);
        }

        return response;
    }
}
```

Register:
```csharp
builder.Services.AddTransient<TokenDelegatingHandler>();
builder.Services.AddHttpClient("ServiceClient")
    .AddHttpMessageHandler<TokenDelegatingHandler>();
```

---

### Pattern 4 — Validation (.NET)

Use **FluentValidation** or Data Annotations. FluentValidation preferred:

**NuGet:** `FluentValidation.AspNetCore`

```csharp
// Validators/CreateUserRequestValidator.cs
using FluentValidation;

public class CreateUserRequestValidator : AbstractValidator<CreateUserRequest>
{
    public CreateUserRequestValidator()
    {
        RuleFor(x => x.Email).NotEmpty().EmailAddress();
        RuleFor(x => x.Name).NotEmpty().MaximumLength(100);
        RuleFor(x => x.Role).IsInEnum();
    }
}
```

Register in `Program.cs`:
```csharp
builder.Services.AddFluentValidationAutoValidation();
builder.Services.AddValidatorsFromAssemblyContaining<CreateUserRequestValidator>();
```

ASP.NET Core returns 400 automatically when validation fails.

For env/config validation at startup:
```csharp
// Configuration/AppSettings.cs
public class AppSettings
{
    public string DatabaseUrl { get; set; } = null!;
    public string RedisUrl { get; set; } = "redis://localhost:6379";
    public string AllowedOrigins { get; set; } = "http://localhost:3000";
}

// Program.cs
builder.Services.AddOptions<AppSettings>()
    .Bind(builder.Configuration.GetSection("App"))
    .ValidateDataAnnotations()
    .ValidateOnStart();
```

---

### Pattern 5 — Deep Health Check (.NET)

**NuGet:** `AspNetCore.HealthChecks.NpgSql` + `AspNetCore.HealthChecks.Redis`

```csharp
// Program.cs
builder.Services.AddHealthChecks()
    .AddNpgSql(connectionString, name: "database", tags: new[] { "db" })
    .AddRedis(redisConnectionString, name: "cache", tags: new[] { "cache" })
    .AddCheck<CustomHealthCheck>("custom");

app.MapHealthChecks("/health", new HealthCheckOptions
{
    ResponseWriter = UIResponseWriter.WriteHealthCheckUIResponse,
    ResultStatusCodes =
    {
        [HealthStatus.Healthy]   = StatusCodes.Status200OK,
        [HealthStatus.Degraded]  = StatusCodes.Status200OK,
        [HealthStatus.Unhealthy] = StatusCodes.Status503ServiceUnavailable,
    }
});
```

---

### Pattern 6 — Structured Logger (.NET)

**NuGet:** `Serilog.AspNetCore` + `Serilog.Sinks.Console` + `Serilog.Formatting.Compact`

```csharp
// Program.cs
Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .Enrich.FromLogContext()
    .Enrich.WithMachineName()
    .Enrich.WithProperty("ServiceName", builder.Configuration["App:ServiceName"])
    .WriteTo.Console(
        builder.Environment.IsDevelopment()
            ? new ExpressionTemplate("[{@t:HH:mm:ss} {@l:u3}] {@m}\n{@x}")
            : (ITextFormatter)new CompactJsonFormatter()
    )
    .CreateLogger();

builder.Host.UseSerilog();
```

`appsettings.json`:
```json
{
  "Serilog": { "MinimumLevel": { "Default": "Information" } }
}
```

---

### Pattern 7 — Retry + Timeout (.NET)

**NuGet:** `Microsoft.Extensions.Http.Resilience` (Polly v8 built-in)

```csharp
// Program.cs
builder.Services.AddHttpClient("ServiceClient")
    .AddStandardResilienceHandler(options =>
    {
        options.Retry.MaxRetryAttempts = 3;
        options.Retry.Delay = TimeSpan.FromMilliseconds(100);
        options.Retry.BackoffType = DelayBackoffType.Exponential;
        options.AttemptTimeout.Timeout = TimeSpan.FromSeconds(10);
        options.TotalRequestTimeout.Timeout = TimeSpan.FromSeconds(30);
    });
```

---

### Pattern 8 — Soft Delete (.NET / EF Core)

```csharp
// Models/SoftDeleteEntity.cs
public abstract class SoftDeleteEntity
{
    public DateTime? DeletedAt { get; set; }
    public bool IsDeleted => DeletedAt.HasValue;
}

// Data/AppDbContext.cs — global query filter
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    foreach (var entityType in modelBuilder.Model.GetEntityTypes())
    {
        if (typeof(SoftDeleteEntity).IsAssignableFrom(entityType.ClrType))
        {
            modelBuilder.Entity(entityType.ClrType)
                .HasQueryFilter(e => EF.Property<DateTime?>(e, "DeletedAt") == null);
        }
    }
}

// In DELETE endpoints:
entity.DeletedAt = DateTime.UtcNow;
await dbContext.SaveChangesAsync();
```

---

### Pattern 9 — CSP / Security Headers (.NET)

**NuGet:** `NWebsec.AspNetCore.Middleware`

```csharp
// Program.cs
app.UseHsts();
app.UseHttpsRedirection();

app.Use(async (context, next) =>
{
    context.Response.Headers["Content-Security-Policy"] =
        "default-src 'self'; " +
        "script-src 'self'; " +
        "style-src 'self' 'unsafe-inline'; " +
        "img-src 'self' data: blob:; " +
        "connect-src 'self'; " +
        "font-src 'self' https://fonts.gstatic.com; " +
        "object-src 'none'";
    context.Response.Headers["X-Frame-Options"] = "DENY";
    context.Response.Headers["X-Content-Type-Options"] = "nosniff";
    context.Response.Headers["Referrer-Policy"] = "no-referrer-when-downgrade";
    await next();
});

// CORS
app.UseCors(policy => policy
    .WithOrigins(builder.Configuration["App:AllowedOrigins"]!.Split(","))
    .AllowAnyMethod()
    .AllowAnyHeader()
    .AllowCredentials());
```
