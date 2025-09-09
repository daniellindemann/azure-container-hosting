using Demo.BeerVoting.Backend.Data;
using Demo.BeerVoting.Backend.Dtos.Requests;
using Demo.BeerVoting.Backend.Dtos.Responses;
using Demo.BeerVoting.Backend.Models;

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.EntityFrameworkCore;

namespace Demo.BeerVoting.Backend.Controllers;

public class BreweryController : ApiControllerBase
{
    private readonly ILogger<BreweryController> _logger;
    private readonly IBeerDbContext _dbContext;

    public BreweryController(ILogger<BreweryController> logger, IBeerDbContext dbContext)
    {
        _logger = logger;
        _dbContext = dbContext;
    }

    [HttpGet]
    public async Task<ActionResult> GetBreweries()
    {
        try
        {
            _logger.LogInformation("Get all breweries");

            List<GetBreweryResponse> breweries = await _dbContext.Breweries
                .AsNoTracking()
                .Select(b => new GetBreweryResponse()
                {
                    Id = b.Id,
                    Name = b.Name
                })
                .ToListAsync();

            _logger.LogInformation("Got {numberOfBreweries} breweries", breweries.Count);

            return Ok(breweries);
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to get breweries");
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }

    [HttpGet("{id:guid}")]
    public async Task<ActionResult> GetBreweryById(Guid id)
    {
        try
        {
            _logger.LogInformation("Get specific brewery with id {brewery}", id);

            Brewery? brewery = await _dbContext.Breweries
                .AsNoTracking()
                .FirstOrDefaultAsync(b => b.Id == id);

            if(brewery == null)
            {
                _logger.LogWarning("Brewery with id {breweryId} not found", id);
                return Problem(title: "Brewery not found",
                    statusCode: 404,
                    instance: Request.Path);
            }

            _logger.LogInformation("Got brewery with id {breweryId}", id);
            GetBreweryResponse breweryDto = new()
            {
                Id = brewery.Id,
                Name = brewery.Name
            };

            return Ok(breweryDto);
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to get specific brewery with id {breweryId}", id);
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }

    [HttpPost]
    public async Task<ActionResult> CreateBrewery([FromBody] CreateBreweryResponse createBreweryDto)
    {
        try
        {
            _logger.LogInformation("Create new brewery");

            if(string.IsNullOrEmpty(createBreweryDto.Name))
            {
                _logger.LogWarning("Metadata {@createObject} to create a new brewery is not valid", createBreweryDto);
                return Problem(statusCode: 400,
                    instance: Request.Path,
                    title: "Validation error occurred",
                    detail: $"{nameof(createBreweryDto.Name)} must not be null");
            }

            _logger.LogInformation("Set new brewery properties");
            Brewery newBrewery = new()
            {
                Name = createBreweryDto.Name
            };

            _logger.LogInformation("Saving new brewery to database");
            await _dbContext.Breweries.AddAsync(newBrewery);
            int changes = await _dbContext.SaveChangesAsync();

            if(changes == 0)
            {
                _logger.LogError("New brewery not stored in database");
                return Problem(title: "Brewery not saved",
                    statusCode: 500,
                    instance: Request.Path);
            }

            _logger.LogInformation("New brewery named {breweryId} stored in database with id {breweryId}",
                createBreweryDto.Name, newBrewery.Id);

            GetBreweryResponse breweryDto = new()
            {
                Id = newBrewery.Id,
                Name = newBrewery.Name
            };

            return CreatedAtAction(nameof(GetBreweryById), new { id = newBrewery.Id }, breweryDto);
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to create brewery with metdadata {@createObject}", createBreweryDto);
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }

    [HttpPut("{id:guid}")]
    public async Task<ActionResult> UpdateBrewery(Guid id, [FromBody] CreateBreweryResponse updateBreweryDto)
    {
        try
        {
            _logger.LogInformation("Update brewery");

            _logger.LogInformation("Get specific brewery with id {breweryId}", id);
            if(string.IsNullOrEmpty(updateBreweryDto.Name))
            {
                _logger.LogWarning("Metadata {@updateObject} to update a brewery with id {breweryId} is not valid", updateBreweryDto, id);
                return Problem(statusCode: 400,
                    instance: Request.Path,
                    title: "Validation error occurred",
                    detail: $"{nameof(updateBreweryDto.Name)} must not be null");
            }

            _logger.LogInformation("Get specific brewery with id {breweryId}", id);
            Brewery? brewery = await _dbContext.Breweries.FirstOrDefaultAsync(b => b.Id == id);

            if(brewery == null)
            {
                _logger.LogWarning("Brewery with id {breweryId} not found", id);
                return Problem(title: "Brewery for brewery update not found",
                    detail: $"Brewery with ID {id} not found",
                    statusCode: 404,
                    instance: Request.Path);
            }

            _logger.LogInformation("Saving updated brewery information to database");
            brewery.Name = updateBreweryDto.Name;

            int changes = await _dbContext.SaveChangesAsync();

            if(changes == 0)
            {
                _logger.LogError("Updated brewery information not stored in database");
                return Problem(title: "Brewery not saved",
                    statusCode: 500,
                    instance: Request.Path);
            }

            _logger.LogInformation("Updated brewery information stored in database for brewery with id {breweryId}",
                brewery.Id);

            GetBreweryResponse breweryDto = new()
            {
                Id = brewery.Id,
                Name = brewery.Name
            };

            return UpdatedAtAction(nameof(GetBreweryById), new { id = brewery.Id }, breweryDto);
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to update brewery with metdadata {@updateObject}", updateBreweryDto);
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }

    [HttpDelete("{id:guid}")]
    public async Task<ActionResult> DeleteBrewery(Guid id)
    {
        try
        {
            _logger.LogInformation("Deleting brewery");

            _logger.LogInformation("Get specific brewery with id {brewery}", id);
            Brewery? brewery = await _dbContext.Breweries.FirstOrDefaultAsync(b => b.Id == id);

            if(brewery == null)
            {
                _logger.LogWarning("Brewery with id {breweryId} not found", id);
                return Problem(title: "Brewery for brewery deletion not found",
                    detail: $"Brewery with ID {id} not found",
                    statusCode: 404,
                    instance: Request.Path);
            }

            _logger.LogInformation("Removing brewery with name {breweryName} and id {breweryId}", brewery.Name, brewery.Id);
            _dbContext.Breweries.Remove(brewery);
            int changes = await _dbContext.SaveChangesAsync();

            if(changes == 0)
            {
                _logger.LogError("Unable to delete brewerey with name {breweryName} and id {breweryId} from database",
                    brewery.Name, brewery.Id);
                return Problem(title: "Brewery not removed",
                    statusCode: 500,
                    instance: Request.Path);
            }

            _logger.LogWarning("Deleted brewery with name {breweryName} and id {breweryId}", brewery.Name, brewery.Id);

            return NoContent();
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to delete brewery with id {breweryId}", id);
            return Problem(detail: ex.Message,
                instance: Request.Path,
                statusCode: 500,
                title: "An error occurred",
                type: ex.GetType().Name
            );
        }
    }
}
