namespace Demo.BeerVoting.Backend.Models;

public class Brewery : BaseAuditableEntity
{
    public string? Name { get; set; }

    public ICollection<Beer>? Beers { get; set;}
}
