# Data Model Generation — .NET / EF Core

## ORM: Entity Framework Core

EF Core is the standard ORM for .NET. Use Code-First approach — define models in C#, generate migrations.

### Base entity
```csharp
// Domain/Common/BaseEntity.cs
public abstract class BaseEntity
{
    public Guid Id { get; set; } = Guid.NewGuid();
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;
    public DateTime? DeletedAt { get; set; }  // soft delete
}
```

### Entity definition
```csharp
// Domain/Entities/User.cs
public class User : BaseEntity
{
    public string Email { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string Role { get; set; } = "user";

    // Navigation property
    public ICollection<Order> Orders { get; set; } = new List<Order>();
}
```

### DbContext
```csharp
// Infrastructure/Persistence/AppDbContext.cs
using Microsoft.EntityFrameworkCore;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

    public DbSet<User> Users => Set<User>();
    public DbSet<Order> Orders => Set<Order>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        // Apply all IEntityTypeConfiguration<T> from this assembly
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);

        // Global soft-delete query filter
        foreach (var entityType in modelBuilder.Model.GetEntityTypes())
        {
            if (typeof(BaseEntity).IsAssignableFrom(entityType.ClrType))
            {
                modelBuilder.Entity(entityType.ClrType)
                    .HasQueryFilter(e => EF.Property<DateTime?>(e, "DeletedAt") == null);
            }
        }
    }

    public override Task<int> SaveChangesAsync(CancellationToken ct = default)
    {
        foreach (var entry in ChangeTracker.Entries<BaseEntity>())
        {
            if (entry.State == EntityState.Modified)
                entry.Entity.UpdatedAt = DateTime.UtcNow;
        }
        return base.SaveChangesAsync(ct);
    }
}
```

### Entity configuration (Fluent API)
```csharp
// Infrastructure/Persistence/Configurations/UserConfiguration.cs
public class UserConfiguration : IEntityTypeConfiguration<User>
{
    public void Configure(EntityTypeBuilder<User> builder)
    {
        builder.HasKey(u => u.Id);
        builder.Property(u => u.Email).IsRequired().HasMaxLength(255);
        builder.HasIndex(u => u.Email).IsUnique().HasFilter("\"DeletedAt\" IS NULL");
        builder.Property(u => u.Name).IsRequired().HasMaxLength(100);
        builder.Property(u => u.Role).HasMaxLength(50).HasDefaultValue("user");

        builder.HasMany(u => u.Orders)
               .WithOne(o => o.User)
               .HasForeignKey(o => o.UserId)
               .OnDelete(DeleteBehavior.Restrict);
    }
}
```

### Migrations
```bash
# Install tools
dotnet tool install --global dotnet-ef

# Create migration
dotnet ef migrations add InitialCreate --project Infrastructure --startup-project API

# Apply
dotnet ef database update --project Infrastructure --startup-project API
```

### Repository pattern (optional but recommended)
```csharp
public interface IRepository<T> where T : BaseEntity
{
    Task<T?> GetByIdAsync(Guid id);
    Task<IReadOnlyList<T>> GetAllAsync();
    Task<T> AddAsync(T entity);
    Task UpdateAsync(T entity);
    Task DeleteAsync(T entity);  // sets DeletedAt
}
```

### DTOs (separate from entities)
```csharp
// Application/Users/DTOs/UserDto.cs
public record UserDto(Guid Id, string Email, string Name, string Role, DateTime CreatedAt);

public record CreateUserRequest(
    [Required][EmailAddress] string Email,
    [Required][MaxLength(100)] string Name,
    string Role = "user"
);
```

### Required NuGet packages
```xml
<PackageReference Include="Microsoft.EntityFrameworkCore" Version="8.0.*" />
<PackageReference Include="Microsoft.EntityFrameworkCore.Design" Version="8.0.*" />
<PackageReference Include="Npgsql.EntityFrameworkCore.PostgreSQL" Version="8.0.*" />
<PackageReference Include="Microsoft.EntityFrameworkCore.Tools" Version="8.0.*" />
```
