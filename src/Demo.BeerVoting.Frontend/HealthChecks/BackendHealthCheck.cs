using Demo.BeerVoting.Frontend.Services;

using Microsoft.Extensions.Diagnostics.HealthChecks;

namespace Demo.BeerVoting.Frontend.HealthChecks;

public class BackendHealthCheck : IHealthCheck
{
    private readonly IBackendService _backendService;

    public BackendHealthCheck(IBackendService backendService)
    {
        _backendService = backendService;
    }

    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default)
    {
        bool isHealty = await _backendService.Ping();

        if(isHealty)
        {
            return HealthCheckResult.Healthy("Healthy");
        }

        return HealthCheckResult.Unhealthy("Unhealthy");
    }
}