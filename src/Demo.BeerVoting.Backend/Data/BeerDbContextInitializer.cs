using Demo.BeerVoting.Backend.Models;

using Microsoft.EntityFrameworkCore;

namespace Demo.BeerVoting.Backend.Data;

public class BeerDbContextInitializer
{
    private readonly BeerDbContext _dbContext;
    private readonly ILogger<BeerDbContextInitializer> _logger;

    public BeerDbContextInitializer(BeerDbContext dbContext, ILogger<BeerDbContextInitializer> logger)
    {
        _dbContext = dbContext;
        _logger = logger;
    }

    public async Task InitializeAsync()
    {
        if(_dbContext == null)
        {
            _logger.LogInformation("DbContext not initialized");
            return;
        }

        try
        {
            if (_dbContext.Database.IsSqlServer())
            {
                await _dbContext.Database.MigrateAsync();
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An error occurred while initializing the database.");
            throw;
        }
    }

    public async Task SeedAsync()
    {
        if(_dbContext == null)
        {
            _logger.LogInformation("DbContext not initialized");
            return;
        }

        try
        {
            /* -------- Breweries -------- */
            Dictionary<string, Brewery> breweries = null!;
            if (!_dbContext.Breweries.Any())
            {
                breweries = new Dictionary<string, Brewery>()
                {
                    { "Karlsberg Brauerei", new Brewery() { Id = Guid.NewGuid(), Name = "Karlsberg Brauerei" } },
                    { "Berliner-Kindl-Schultheiss-Brauerei", new Brewery() { Id = Guid.NewGuid(), Name = "Berliner-Kindl-Schultheiss-Brauerei" } },
                    { "Badische Staatsbrauerei Rothaus", new Brewery() { Id = Guid.NewGuid(), Name = "Badische Staatsbrauerei Rothaus" } },
                    { "Bayreuther Bierbrauerei", new Brewery() { Id = Guid.NewGuid(), Name = "Bayreuther Bierbrauerei" } },
                    { "Flensburger Brauerei", new Brewery() { Id = Guid.NewGuid(), Name = "Flensburger Brauerei" } },
                    { "Bitburger Brauerei", new Brewery() { Id = Guid.NewGuid(), Name = "Bitburger Brauerei" } },
                    { "Spaten-Franziskaner-Bräu", new Brewery() { Id = Guid.NewGuid(), Name = "Spaten-Franziskaner-Bräu" } }
                };
                await _dbContext.AddRangeAsync(breweries.Values);
                await _dbContext.SaveChangesAsync();
            }

            /* -------- Beers -------- */
            Dictionary<string, Beer> beers = null!;
            if(!_dbContext.Beers.Any())
            {
                beers = new Dictionary<string, Beer>()
                {
                    { "Karlsberg Ur-Pils",
                        new Beer()
                        {
                            Id = Guid.NewGuid(),
                            Brewery = breweries["Karlsberg Brauerei"],
                            Name = "Karlsberg Ur-Pils",
                            Nickname = "Stubbi",
                            Type = "Pils"
                        }
                    },
                    { "Berliner Kindl Jubiläums Pilsner",
                        new Beer()
                        {
                            Id = Guid.NewGuid(),
                            Brewery = breweries["Berliner-Kindl-Schultheiss-Brauerei"],
                            Name = "Berliner Kindl Jubiläums Pilsner",
                            Nickname = "Jubi",
                            Type = "Pils"
                        }
                    },
                    { "Rothaus Tannenzäpfle",
                        new Beer()
                        {
                            Id = Guid.NewGuid(),
                            Brewery = breweries["Badische Staatsbrauerei Rothaus"],
                            Name = "Rothaus Tannenzäpfle",
                            Type = "Helles"
                        }
                    },
                    { "Flensburger Pilsener",
                        new Beer()
                        {
                            Id = Guid.NewGuid(),
                            Brewery = breweries["Flensburger Brauerei"],
                            Name = "Flensburger Pilsener",
                            Nickname = "Flens",
                            Type = "Pils"
                        }
                    },
                    { "Bitburger Premium Pils",
                        new Beer()
                        {

                            Id = Guid.NewGuid(),
                            Brewery = breweries["Bitburger Brauerei"],
                            Name = "Bitburger Premium Pils",
                            Type = "Pils"
                        }
                    },
                    { "Franziskaner Hefe-Weissbier Naturtrüb",
                        new Beer()
                        {
                            Id = Guid.NewGuid(),
                            Brewery = breweries["Spaten-Franziskaner-Bräu"],
                            Name = "Franziskaner Hefe-Weissbier Naturtrüb",
                            Type = "Weissbier"
                        }
                    }
                };

                await _dbContext.AddRangeAsync(beers.Values);
                await _dbContext.SaveChangesAsync();
            }

            /* -------- Ratings -------- */
            if(!_dbContext.Ratings.Any())
            {
                List<Rating> ratings = new()
                {
                    // ur-pils ratings
                    new Rating()
                    {
                        Beer = beers["Karlsberg Ur-Pils"],
                        Score = 5d
                    },
                    new Rating()
                    {
                        Beer = beers["Karlsberg Ur-Pils"],
                        Score = 5d
                    },
                    new Rating()
                    {
                        Beer = beers["Karlsberg Ur-Pils"],
                        Score = 5d
                    },
                    // Jubi ratings
                    new Rating()
                    {
                        Beer = beers["Berliner Kindl Jubiläums Pilsner"],
                        Score = 2.5d
                    },
                    new Rating()
                    {
                        Beer = beers["Berliner Kindl Jubiläums Pilsner"],
                        Score = 2d
                    },
                    // Tannenzäpfle ratings
                    new Rating()
                    {
                        Beer = beers["Rothaus Tannenzäpfle"],
                        Score = 4d
                    },
                    // Flens ratings
                    new Rating()
                    {
                        Beer = beers["Flensburger Pilsener"],
                        Score = 4.5d
                    },
                    new Rating()
                    {
                        Beer = beers["Flensburger Pilsener"],
                        Score = 4d
                    },
                    new Rating()
                    {
                        Beer = beers["Flensburger Pilsener"],
                        Score = 4d
                    },
                    new Rating()
                    {
                        Beer = beers["Flensburger Pilsener"],
                        Score = 5d
                    },
                    // Bitburger Premium Pils
                    new Rating()
                    {
                        Beer = beers["Bitburger Premium Pils"],
                        Score = 1.5d
                    },
                    new Rating()
                    {
                        Beer = beers["Bitburger Premium Pils"],
                        Score = 2d
                    },
                    new Rating()
                    {
                        Beer = beers["Bitburger Premium Pils"],
                        Score = 0.5d
                    },
                    // Franziskaner Hefe-Weissbier Naturtrüb
                    new Rating()
                    {
                        Beer = beers["Franziskaner Hefe-Weissbier Naturtrüb"],
                        Score = 4.5d
                    }
                };

                await _dbContext.Ratings.AddRangeAsync(ratings);
                await _dbContext.SaveChangesAsync();
            }
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "An error occurred while seeding the database.");
            throw;
        }
    }
}
