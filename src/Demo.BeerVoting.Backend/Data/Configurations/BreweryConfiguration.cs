using Demo.BeerVoting.Backend.Models;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Demo.BeerVoting.Backend.Data.Configurations;

public class BreweryConfiguration : IEntityTypeConfiguration<Brewery>
{
    public void Configure(EntityTypeBuilder<Brewery> builder)
    {
        builder.HasKey(b => b.Id);

        builder.HasIndex(b => b.Name)
            .IsUnique();
        builder.Property(b => b.Name)
            .HasMaxLength(200)
            .IsRequired();
    }
}
