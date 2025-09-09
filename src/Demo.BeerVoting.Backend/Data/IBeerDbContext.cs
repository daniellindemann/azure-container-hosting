using Demo.BeerVoting.Backend.Models;

using Microsoft.EntityFrameworkCore;

namespace Demo.BeerVoting.Backend.Data;

public interface IBeerDbContext
{
    DbSet<Brewery> Breweries { get; }
    DbSet<Beer> Beers { get; }
    DbSet<Rating> Ratings { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
