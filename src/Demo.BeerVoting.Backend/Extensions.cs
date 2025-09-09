using Demo.BeerVoting.Backend.Data;

using Microsoft.EntityFrameworkCore;

public static class Extensions
{
    public static IServiceCollection AddDatabase(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddScoped<AuditableEntitySaveChangesInterceptor>();

        var useInMemoryDatabase = configuration.GetValue<bool>("Database:UseInMemoryDatabase");
        if(useInMemoryDatabase)
        {
            services.AddDbContext<BeerDbContext>(options =>
            {
                options.UseInMemoryDatabase("BeerDb");
            });
        }
        else
        {
            services.AddDbContext<BeerDbContext>(options =>
            {
                options.UseSqlServer(configuration.GetConnectionString("Beer"), builder =>
                {
                    builder.EnableRetryOnFailure(5, TimeSpan.FromSeconds(30), null);
                    builder.MigrationsAssembly(typeof(BeerDbContext).Assembly.FullName);
                });
            });
        }

        services.AddScoped<IBeerDbContext>(provider => provider.GetRequiredService<BeerDbContext>());
        services.AddScoped<BeerDbContextInitializer>();

        return services;
    }

    public static async Task SeedBeerData(this IApplicationBuilder app, bool useAutoMigration)
    {
        using var scope = app.ApplicationServices.CreateScope();
        var services = scope.ServiceProvider;

        var logger = services.GetService<ILogger<BeerDbContextInitializer>>()!;
        var dbContext = services.GetService<BeerDbContext>()!;

        BeerDbContextInitializer initializer = new(dbContext, logger);
        if(useAutoMigration)
        {
            await initializer.InitializeAsync();
        }
        await initializer.SeedAsync();
    }
}
