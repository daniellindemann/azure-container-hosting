using Demo.BeerVoting.Backend.Models;

using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Demo.BeerVoting.Backend.Data.Configurations;

public class BeerConfiguration : IEntityTypeConfiguration<Beer>
{
    public void Configure(EntityTypeBuilder<Beer> builder)
    {
        builder.HasKey(b => b.Id);

        builder.HasIndex(b => b.Name)
            .IsUnique();
        builder.Property(b => b.Name)
            .HasMaxLength(200)
            .IsRequired();

        builder.Property(b => b.Nickname)
            .HasMaxLength(50)
            .IsRequired(false);

        builder.Property(b => b.Type)
            .HasMaxLength(50)
            .IsRequired();
    }
}
