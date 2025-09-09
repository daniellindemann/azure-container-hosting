using Demo.BeerVoting.Backend.Models;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking;
using Microsoft.EntityFrameworkCore.Diagnostics;

namespace Demo.BeerVoting.Backend.Data;

public class AuditableEntitySaveChangesInterceptor : SaveChangesInterceptor
{
    private readonly ILogger<AuditableEntitySaveChangesInterceptor> _logger;

    public AuditableEntitySaveChangesInterceptor(ILogger<AuditableEntitySaveChangesInterceptor> logger)
    {
        _logger = logger;
    }

    public override InterceptionResult<int> SavingChanges(DbContextEventData eventData, InterceptionResult<int> result)
    {
        UpdateEntities(eventData.Context);

        return base.SavingChanges(eventData, result);
    }

    public override ValueTask<InterceptionResult<int>> SavingChangesAsync(DbContextEventData eventData, InterceptionResult<int> result, CancellationToken cancellationToken = default)
    {
        UpdateEntities(eventData.Context);

        return base.SavingChangesAsync(eventData, result, cancellationToken);
    }

    public void UpdateEntities(DbContext? context)
    {
        DateTimeOffset dateTimeNowUtc = DateTime.UtcNow;
        _logger.LogInformation("Updating auditable information");
        if (context == null) return;

        foreach (var entry in context.ChangeTracker.Entries<BaseAuditableEntity>())
        {
            if (entry.State == EntityState.Added)
            {
                entry.Entity.Created = dateTimeNowUtc;
                _logger.LogInformation("Entitiy of type {entitityName} with id {id} added at {time}", entry.Entity.GetType().Name, entry.Entity.Id, dateTimeNowUtc);
            }

            if (entry.State == EntityState.Added || entry.State == EntityState.Modified || entry.HasChangedOwnedEntities())
            {
                entry.Entity.LastModified = dateTimeNowUtc;
                _logger.LogInformation("Entitiy of type {entitityName} with id {id} modified at {time}", entry.Entity.GetType().Name, entry.Entity.Id, dateTimeNowUtc);
            }
        }
    }
}

public static class Extensions
{
    public static bool HasChangedOwnedEntities(this EntityEntry entry) =>
        entry.References.Any(r =>
            r.TargetEntry != null &&
            r.TargetEntry.Metadata.IsOwned() &&
            (r.TargetEntry.State == EntityState.Added || r.TargetEntry.State == EntityState.Modified));
}
