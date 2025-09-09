namespace Demo.BeerVoting.Backend.Models;

public class Beer : BaseAuditableEntity
{
    public string? Name { get; set; }
    public string? Nickname { get; set; }
    public string? Type { get; set; }   // can be more normalized if required

    public Brewery? Brewery { get; set; }
    public ICollection<Rating>? Ratings { get; set;}
}
