namespace Demo.BeerVoting.Backend.Models;

public class Rating : BaseAuditableEntity
{
    public double Score { get; set; }

    public Beer? Beer { get; set; }
}
