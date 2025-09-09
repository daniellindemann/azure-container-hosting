using Demo.BeerVoting.Frontend.Dtos.Requests;
using Demo.BeerVoting.Frontend.Dtos.Responses;
using Demo.BeerVoting.Frontend.Options;
using Microsoft.Extensions.Options;

namespace Demo.BeerVoting.Frontend.Services;

public class BackendService : IBackendService
{
    private readonly BackendOptions _options;
    private readonly HttpClient _httpClient;
    private readonly ILogger<BackendService> _logger;

    public BackendService(IOptions<BackendOptions> options, HttpClient httpClient, ILogger<BackendService> logger)
    {
        _options = options.Value;
        _httpClient = httpClient;
        _logger = logger;
    }

    public async Task<List<GetWeatherForecastResponse>> GetWeatherForecast()
    {
        var response = await _httpClient.GetAsync("/api/weatherforecast");
        response.EnsureSuccessStatusCode();

        var forecasts = await response.Content.ReadFromJsonAsync<List<GetWeatherForecastResponse>>();
        return forecasts!;
    }

    public async Task<List<GetBeerResponse>> GetBeers()
    {
        _logger.LogInformation("Get beers");

        string url = "/api/beer";
        var response = await _httpClient.GetAsync(url);
        if(!response.IsSuccessStatusCode)
        {
            _logger.LogError("Unable to get beers via url {requestUrl}", url);
            response.EnsureSuccessStatusCode(); // throws exception
        }
        
        try
        {
            _logger.LogInformation("Parsing response");
            var beers = await response.Content.ReadFromJsonAsync<List<GetBeerResponse>>();
            _logger.LogInformation("Response parsed. Got {count} beers", beers!.Count);
            return beers!;
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to parse response");
            throw;
        }
    }

    public async Task<List<GetFavoriteBeerResponse>> GetFavoriteBeers()
    {
        _logger.LogInformation("Get favorite beers");

        string url = "/api/beer/favorites";
        var response = await _httpClient.GetAsync(url);
        if(!response.IsSuccessStatusCode)
        {
            _logger.LogError("Unable to get favorite beers via url {requestUrl}", url);
            response.EnsureSuccessStatusCode(); // throws exception
        }
        
        try
        {
            _logger.LogInformation("Parsing response");
            var favoriteBeers = await response.Content.ReadFromJsonAsync<List<GetFavoriteBeerResponse>>();
            _logger.LogInformation("Response parsed. Got {count} favorite beers", favoriteBeers!.Count);
            return favoriteBeers!;
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to parse response");
            throw;
        }
    }

    public async Task<GetFavoriteBeerResponse> RateFavoriteBeer(Guid id, double score)
    {
        _logger.LogInformation("Get favorite beers");

        string url = $"/api/beer/favorites/{id}/rate";
        var response = await _httpClient.PostAsJsonAsync(url, new CreateRateBeerRequest()
        {
            Score = score
        });

        if(!response.IsSuccessStatusCode)
        {
            _logger.LogError("Unable to rate favorite beers via url {requestUrl}", url);
            response.EnsureSuccessStatusCode(); // throws exception
        }
        
        try
        {
            _logger.LogInformation("Parsing response");
            var favoriteBeer = await response.Content.ReadFromJsonAsync<GetFavoriteBeerResponse>();
            _logger.LogInformation("Response parsed. Added rating of {score} to beers {beerName} ({beerId})",
                score, favoriteBeer!.Name, favoriteBeer!.Id);
            return favoriteBeer!;
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to parse response");
            throw;
        }
    }

    public async Task<bool> Ping()
    {
        string url = $"/api/ping";

        try
        {
            using var cts = new CancellationTokenSource();
            cts.CancelAfter(TimeSpan.FromSeconds(1));
            string? response = await _httpClient.GetStringAsync(url, cts.Token);
    
            if(response == "Pong")
            {
                return true;
            }
    
            return false;
        }
        catch
        {
            return false;
        }
    }

    public async Task<int> GetTotalRatings()
    {
        _logger.LogInformation("Get total ratings");

        string url = $"/api/beer/favorites/totalratings";

        var response = await _httpClient.GetAsync(url);
        if(!response.IsSuccessStatusCode)
        {
            _logger.LogError("Unable to get total ratings via url {requestUrl}", url);
            response.EnsureSuccessStatusCode(); // throws exception
        }
        
        try
        {
            _logger.LogInformation("Parsing response");
            var totalRatings = await response.Content.ReadFromJsonAsync<GetFavoriteTotalRatingsResponse>();
            _logger.LogInformation("Response parsed");

            return totalRatings?.Count ?? 0;
        }
        catch (System.Exception ex)
        {
            _logger.LogError(ex, "Unable to parse response");
            throw;
        }
    }
}
