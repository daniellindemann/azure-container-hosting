namespace Demo.BeerVoting.Backend.Dtos.Requests;

public class UpdateBeerRequest
{
    public Guid BreweryId { get; set; }
    public string? Name { get; set; }
    public string? Nickname { get; set; }
    public string? Type { get; set; }
}
