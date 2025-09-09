using Demo.BeerVoting.Backend.Dtos.Responses;
using Microsoft.AspNetCore.Mvc;

namespace Demo.BeerVoting.Backend.Controllers;

public class WeatherForecastController : ApiControllerBase
{
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<WeatherForecastController> _logger;

    public WeatherForecastController(ILogger<WeatherForecastController> logger)
    {
        _logger = logger;
    }

    [HttpGet()]
    public ActionResult Get()
    {
        var forecast = Enumerable.Range(1, 5).Select(index =>
        {
            var randomTempC = Random.Shared.Next(-20, 55);
            return new GetWeatherForecastResponse
            {
                Date = DateOnly.FromDateTime(DateTime.Now.AddDays(index)),
                TemperatureC = randomTempC,
                TemperatureF = 32 + (int)(randomTempC / 0.5556),
                Summary = Summaries[Random.Shared.Next(Summaries.Length)]
            };
        })
        .ToArray();

        return Ok(forecast);
    }
}
