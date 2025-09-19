using Demo.BeerRating.Backend.Http;

using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Infrastructure;

namespace Demo.BeerRating.Backend.Controllers;

[ApiController]
[Route("api/[controller]")]
public abstract class ApiControllerBase : ControllerBase
{
    protected UpdatedAtActionResult UpdatedAtAction(string? actionName, object? routeValues, [ActionResultObjectValue] object? value)
        => new UpdatedAtActionResult(actionName, null, routeValues, value);
}
