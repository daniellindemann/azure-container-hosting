using Demo.BeerVoting.Frontend.HealthChecks;
using Demo.BeerVoting.Frontend.Options;
using Demo.BeerVoting.Frontend.Services;

using Microsoft.ApplicationInsights.Extensibility.Implementation;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging.Console;
using Microsoft.Extensions.Options;

using Polly;
using Polly.Extensions.Http;

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
    // remove default loggers:
    // - ConsoleLoggerProvider
    // - DebugLoggerProvider
    // - EventSourceLoggerProvider
    builder.Logging.ClearProviders();
    builder.Logging.AddConsole();
}

// configure application insights
// if APPLICATIONINSIGHTS_CONNECTION_STRING is not available nothing will happen
builder.Services.AddApplicationInsightsTelemetry();
if(builder.Environment.IsDevelopment())
{
    // disable app insights tracing
    TelemetryDebugWriter.IsTracingDisabled = true;
}

builder.Services.Configure<BackendOptions>(builder.Configuration.GetSection("Backend"));
builder.Services.AddSingleton<IBackendService, BackendService>();
builder.Services.AddHttpClient<IBackendService, BackendService>((services, client) =>
{
    var backendOptions = services.GetService<IOptions<BackendOptions>>()?.Value;
    client.BaseAddress = new Uri(backendOptions?.HostUrl?.TrimEnd('/') ?? string.Empty);
})
.SetHandlerLifetime(TimeSpan.FromMinutes(5))  //Set lifetime to five minutes
.AddPolicyHandler((HttpRequestMessage msg) =>
{
    return HttpPolicyExtensions
        .HandleTransientHttpError()
        .OrResult(msg => msg.StatusCode == System.Net.HttpStatusCode.NotFound)
        .WaitAndRetryAsync(3, retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)));
});

builder.Services.AddHealthChecks()
    .AddCheck<BackendHealthCheck>("Backend");

// disable anti-forgery token for demo purpose, so calls with k6 or postman are possible
builder.Services.AddAntiforgery(options =>
{
    options.Cookie.Expiration = TimeSpan.Zero;
    options.SuppressXFrameOptionsHeader = true;
});
builder.Services.AddRazorPages(options =>
{
    options.Conventions.ConfigureFilter(new IgnoreAntiforgeryTokenAttribute());
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Error");
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

// the platform where it's hosted should do this. not the developer!
// app.UseHttpsRedirection();
app.UseStaticFiles();

app.UseRouting();

app.UseAuthorization();

app.MapHealthChecks("/healthz");

app.MapRazorPages();

app.Run();
