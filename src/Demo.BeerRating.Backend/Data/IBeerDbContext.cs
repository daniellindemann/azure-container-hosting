using Demo.BeerRating.Backend.Models;

using Microsoft.EntityFrameworkCore;

namespace Demo.BeerRating.Backend.Data;

public interface IBeerDbContext
{
    DbSet<Brewery> Breweries { get; }
    DbSet<Beer> Beers { get; }
    DbSet<Rating> Ratings { get; }

    Task<int> SaveChangesAsync(CancellationToken cancellationToken = default);
}
