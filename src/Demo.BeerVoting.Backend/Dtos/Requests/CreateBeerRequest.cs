namespace Demo.BeerVoting.Backend.Dtos.Requests;

public class CreateBeerRequest
{
    public Guid BreweryId { get; set; }
    public string? Name { get; set; }
    public string? Nickname { get; set; }
    public string? Type { get; set; }
}
