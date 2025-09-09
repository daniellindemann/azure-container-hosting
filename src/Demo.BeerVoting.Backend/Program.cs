using Demo.BeerVoting.Backend.Data;

using Microsoft.Extensions.Logging.Console;

var builder = WebApplication.CreateBuilder(args);

// configure logging
if (builder.Environment.IsProduction())
{
    builder.Logging.ClearProviders();
    builder.Logging.AddConsole(options =>
    {
        options.FormatterName = ConsoleFormatterNames.Json;
    });
}
else
{
    builder.Logging.ClearProviders();
    builder.Logging.AddConsole();
}

// configure application insights
// if APPLICATIONINSIGHTS_CONNECTION_STRING is not available nothing will happen
if(!builder.Environment.IsDevelopment())
{
    builder.Services.AddApplicationInsightsTelemetry();
}

// Add services to the container.
builder.Services.AddDatabase(builder.Configuration);

var healthCheckBuilder = builder.Services.AddHealthChecks();
if(!builder.Configuration.GetValue<bool>("Database:UseInMemoryDatabase"))
{
    healthCheckBuilder.AddDbContextCheck<BeerDbContext>();
}

builder.Services.AddControllers();
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();


var app = builder.Build();

// seed data
if (builder.Configuration.GetValue<bool>("Database:UseDataSeeding"))
{
    bool useAutoMigration = builder.Configuration.GetValue<bool>("Database:UseAutoMigration");
    await app.SeedBeerData(useAutoMigration);
}

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.UseSwaggerUI(options =>
    {
        options.SwaggerEndpoint("/openapi/v1.json", "v1");
    });
}

// the platform where it's hosted should do this. not the developer!
// app.UseHttpsRedirection();

app.UseAuthorization();

app.MapHealthChecks("/healthz");

app.MapControllers();

app.Run();
