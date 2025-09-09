namespace Demo.BeerVoting.Backend.Dtos.Responses;

public class GetFavoriteBeerResponse
{
    public Guid Id { get; set; }
    public string? Brewery { get; set; }
    public string? Name { get; set; }
    public string? Nickname { get; set; }
    public string? Type { get; set; }
    public double Score { get; set; }
}


