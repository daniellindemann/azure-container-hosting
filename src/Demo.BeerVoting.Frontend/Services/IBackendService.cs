using Demo.BeerVoting.Frontend.Dtos.Responses;

namespace Demo.BeerVoting.Frontend.Services;

public interface IBackendService
{
    Task<List<GetWeatherForecastResponse>> GetWeatherForecast();
    Task<List<GetBeerResponse>> GetBeers();
    Task<List<GetFavoriteBeerResponse>> GetFavoriteBeers();
    Task<GetFavoriteBeerResponse> RateFavoriteBeer(Guid id, double score);
    Task<bool> Ping();
    Task<int> GetTotalRatings();
}
