using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

HostApplicationBuilder builder = Host.CreateApplicationBuilder(args);
builder.Services.AddSingleton<App>();

var host = builder.Build();
await host.Services.GetRequiredService<App>().RunAsync();
