using Demo.BeerVoting.Backend.Models;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Demo.BeerVoting.Backend.Data.Configurations;

public class RatingConfiguration : IEntityTypeConfiguration<Rating>
{
    public void Configure(EntityTypeBuilder<Rating> builder)
    {
        builder.HasKey(b => b.Id);

        builder.Property(b => b.Score)
            .IsRequired();
    }
}
