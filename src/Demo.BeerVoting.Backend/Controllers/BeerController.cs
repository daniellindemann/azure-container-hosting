using Demo.BeerVoting.Backend.Data;
using Demo.BeerVoting.Backend.Dtos.Requests;
using Demo.BeerVoting.Backend.Dtos.Responses;
using Demo.BeerVoting.Backend.Models;

using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace Demo.BeerVoting.Backend.Controllers;

public class BeerController : ApiControllerBase
{
    private readonly ILogger<BeerController> _logger;
    private readonly IBeerDbContext _dbContext;

    public BeerController(ILogger<BeerController> logger, IBeerDbContext dbContext)
    {
        _logger = logger;
        _dbContext = dbContext;
    }

    [HttpGet]
    public async Task<ActionResult> GetBeers()
    {
        try
        {
            _logger.LogInformation("Get all beers");

            List<GetBeerResponse> beers = await _dbContext.Beers
                .AsNoTracking()
                .Include(b => b.Brewery)
                .Select(b => new GetBeerResponse()
                {
                    Id = b.Id,
                    Brewery = b.Brewery!.Name,
                    Name = b.Name,
                    Nickname = b.Nickname,
                    Type = b.Type
                })
                .ToListAsync();

            _logger.LogInformation("Got {numberOfBeers} beers", beers.Count);

            return Ok(beers);
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to get beers");
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult> GetBeerById(Guid id)
    {
        try
        {
            _logger.LogInformation("Get specific beer with id {beerId}", id);

            Beer? beer = await _dbContext.Beers
                .AsNoTracking()
                .Include(b => b.Brewery)
                .FirstOrDefaultAsync(b => b.Id == id);

            if(beer == null)
            {
                _logger.LogWarning("Beer with id {beerId} not found", id);
                return Problem(title: "Beer not found",
                    statusCode: 404,
                    instance: Request.Path);
            }

            _logger.LogInformation("Got beer with id {beerId}", id);
            GetBeerResponse beerDto = new()
            {
                Id = beer.Id,
                Brewery = beer.Brewery!.Name,
                Name = beer.Name,
                Nickname = beer.Nickname,
                Type = beer.Type
            };

            return Ok(beerDto);
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to get specific beer with id {beerId}", id);
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }

    [HttpPost()]
    public async Task<ActionResult> CreateBeer([FromBody] CreateBeerRequest createBeerDto)
    {
        try
        {
            _logger.LogInformation("Create new beer");

            _logger.LogInformation("Get specific brewery with id {breweryId}", createBeerDto.BreweryId);
            Brewery? brewery = await _dbContext.Breweries.FirstOrDefaultAsync(b => b.Id == createBeerDto.BreweryId);

            if(brewery == null)
            {
                _logger.LogWarning("Brewery with id {breweryId} not found", createBeerDto.BreweryId);
                return Problem(title: "Brewery for beer creation not found",
                    detail: $"Brewery with ID {createBeerDto.BreweryId} not found",
                    statusCode: 404,
                    instance: Request.Path);
            }

            _logger.LogInformation("Set new beer properties");
            Beer beer = new()
            {
                Brewery = brewery,
                Name = createBeerDto.Name,
                Nickname = createBeerDto.Nickname,
                Type = createBeerDto.Type
            };

            _logger.LogInformation("Saving new beer to database");
            await _dbContext.Beers.AddAsync(beer);
            int changes = await _dbContext.SaveChangesAsync();

            if(changes == 0)
            {
                _logger.LogError("New beer not stored in database");
                return Problem(title: "Beer not saved",
                    statusCode: 500,
                    instance: Request.Path);
            }

            _logger.LogInformation("New beer named {beerName} stored in database with id {beerId}",
                createBeerDto.Name, beer.Id);

            GetBeerResponse beerDto = new()
            {
                Id = beer.Id,
                Brewery = brewery.Name,
                Name = beer.Name,
                Nickname = beer.Nickname,
                Type = beer.Type
            };

            return CreatedAtAction(nameof(GetBeerById), new { id = beer.Id }, beerDto);
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to create beer with metdadata {@createObject}", createBeerDto);
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult> UpdateBeer(Guid id, [FromBody] UpdateBeerRequest updateBeerDto)
    {
        try
        {
            _logger.LogInformation("Update beer");

            _logger.LogInformation("Get specific beer with id {beerId}", id);
            Beer? beer = await _dbContext.Beers.FirstOrDefaultAsync(b => b.Id == id);

            if(beer == null)
            {
                _logger.LogWarning("Beer with id {beerId} not found", id);
                return Problem(title: "Beer for beer update not found",
                    detail: $"Beer with ID {id} not found",
                    statusCode: 404,
                    instance: Request.Path);
            }

            _logger.LogInformation("Get specific brewery with id {breweryId}", updateBeerDto.BreweryId);
            Brewery? brewery = await _dbContext.Breweries.FirstOrDefaultAsync(b => b.Id == updateBeerDto.BreweryId);

            if(brewery == null)
            {
                _logger.LogWarning("Brewery with id {breweryId} not found", updateBeerDto.BreweryId);
                return Problem(title: "Brewery for beer update not found",
                    detail: $"Brewery with ID {updateBeerDto.BreweryId} not found",
                    statusCode: 404,
                    instance: Request.Path);
            }

            _logger.LogInformation("Saving updated beer information to database");

            beer.Brewery = brewery;
            beer.Name = updateBeerDto.Name;
            beer.Nickname = updateBeerDto.Nickname;
            beer.Type = updateBeerDto.Type;

            int changes = await _dbContext.SaveChangesAsync();

            if(changes == 0)
            {
                _logger.LogError("Updated beer information not stored in database");
                return Problem(title: "Beer not saved",
                    statusCode: 500,
                    instance: Request.Path);
            }

            _logger.LogInformation("Updated beer information stored in database for beer with id {beerId}",
                beer.Id);

            GetBeerResponse beerDto = new()
            {
                Id = beer.Id,
                Brewery = brewery.Name,
                Name = beer.Name,
                Nickname = beer.Nickname,
                Type = beer.Type
            };

            return UpdatedAtAction(nameof(GetBeerById), new { id = beer.Id }, beerDto);
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to update beer with metdadata {@updateObject}", updateBeerDto);
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult> DeleteBeer(Guid id)
    {
        try
        {
            _logger.LogInformation("Deleting beer");

            _logger.LogInformation("Get specific beer with id {beerId}", id);
            Beer? beer = await _dbContext.Beers.FirstOrDefaultAsync(b => b.Id == id);

            if(beer == null)
            {
                _logger.LogWarning("Beer with id {beerId} not found", id);
                return Problem(title: "Beer for beer deletion not found",
                    detail: $"Beer with ID {id} not found",
                    statusCode: 404,
                    instance: Request.Path);
            }

            _logger.LogInformation("Removing beer with name {beerName} and id {beerId}", beer.Name, beer.Id);
            _dbContext.Beers.Remove(beer);
            int changes = await _dbContext.SaveChangesAsync();

            if(changes == 0)
            {
                _logger.LogError("Unable to delete beer with name {beerName} and id {beerId} from database",
                    beer.Name, beer.Id);
                return Problem(title: "Beer not removed",
                    statusCode: 500,
                    instance: Request.Path);
            }

            _logger.LogWarning("Deleted beer with name {beerName} and id {beerId}", beer.Name, beer.Id);

            return NoContent();
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to delete beer with id {beerId}", id);
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }

    [HttpGet("favorites")]
    public async Task<ActionResult> GetFavoriteBeers()
    {
        try
        {
            _logger.LogInformation("Get favorite beers");

            List<GetFavoriteBeerResponse> favoriteBeers = await _dbContext.Beers
                .AsNoTracking()
                .Include(b => b.Brewery)
                .Include(b => b.Ratings)
                .Select(b => new GetFavoriteBeerResponse()
                {
                    Id = b.Id,
                    Brewery = b.Brewery!.Name,
                    Name = b.Name,
                    Nickname = b.Nickname,
                    Type = b.Type,
                    Score = Math.Round(b.Ratings!.Average(r => r.Score), 2)
                })
                .OrderByDescending(fb => fb.Score)
                .ToListAsync();

            _logger.LogInformation("Got {numberOfBeers} favorite beers", favoriteBeers.Count);

            return Ok(favoriteBeers);
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to get favorite beers");
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }

    [HttpGet("favorites/{id:guid}")]
    public async Task<ActionResult> GetFavoriteBeerById(Guid id)
    {
        try
        {
            _logger.LogInformation("Get specific favorite beer with id {beerId}", id);

            Beer? beer = await _dbContext.Beers
                .AsNoTracking()
                .Include(b => b.Brewery)
                .Include(b => b.Ratings)
                .FirstOrDefaultAsync(b => b.Id == id);

            if(beer == null)
            {
                _logger.LogWarning("Favorite beer with id {beerId} not found", id);
                return Problem(title: "Beer not found",
                    statusCode: 404,
                    instance: Request.Path);
            }

            _logger.LogInformation("Got favorite beer with id {beerId}", id);

            GetFavoriteBeerResponse favoriteBeerDto = new()
            {
                Id = beer.Id,
                Brewery = beer.Brewery!.Name,
                Name = beer.Name,
                Nickname = beer.Nickname,
                Type = beer.Type,
                Score = Math.Round(beer.Ratings!.Average(r => r.Score), 2)
            };

            return Ok(favoriteBeerDto);
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to get specific favorite beer with id {beerId}", id);
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }

    [HttpPost("favorites/{id:guid}/rate")]
    public async Task<ActionResult> RateBeer(Guid id, [FromBody] RateBeerRequest rating)
    {
        try
        {
            _logger.LogInformation("Rate specific beer with id {beerId} and score of {score}", id, rating.Score);

            _logger.LogInformation("Get specific beer with id {beerId}", id);
            Beer? beer = await _dbContext.Beers
                .Include(b => b.Brewery)
                .Include(b => b.Ratings)
                .FirstOrDefaultAsync(b => b.Id == id);

            if(beer == null)
            {
                _logger.LogWarning("Favorite beer with id {beerId} not found", id);
                return Problem(title: "Beer not found",
                    statusCode: 404,
                    instance: Request.Path);
            }

            _logger.LogInformation("Saving beer rating to database");

            Rating newRating = new()
            {
                Beer = beer,
                Score = rating.Score
            };

            await _dbContext.Ratings.AddAsync(newRating);
            int changes = await _dbContext.SaveChangesAsync();

            if(changes == 0)
            {
                _logger.LogError("Rating not stored in database");
                return Problem(title: "Rating not saved",
                    statusCode: 500,
                    instance: Request.Path);
            }

            _logger.LogInformation("Rating for beer {beerName} ({beerId}) with score {score} stored in database",
                beer.Name, beer.Id, rating.Score);

            // get new detailed rating
            // THIS IS NOT GOOD CODE! DO IT NOT LIKE THAT!
            return await GetFavoriteBeerById(id);
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to save rating with metdadata {@rating}", rating);
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }

    [HttpGet("favorites/totalratings")]
    public async Task<ActionResult> GetFavoriteTotalRatings()
    {
        try
        {
            _logger.LogInformation("Get total ratings");

            int totalRatings = await _dbContext.Ratings.CountAsync();

            _logger.LogInformation("Got {count} total ratings", totalRatings);

            return Ok(new GetFavoriteTotalRatingsResponse()
            {
                Count = totalRatings
            });
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to get total ratings");
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }
}
