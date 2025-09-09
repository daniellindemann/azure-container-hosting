using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Infrastructure;
using Microsoft.AspNetCore.Mvc.Routing;

namespace Demo.BeerVoting.Backend.Http;

// Code stolen from: https://github.com/dotnet/aspnetcore/blob/main/src/Mvc/Mvc.Core/src/CreatedAtActionResult.cs

[DefaultStatusCode(DefaultStatusCode)]
public class UpdatedAtActionResult : ObjectResult
{
    private const int DefaultStatusCode = StatusCodes.Status200OK;

    public UpdatedAtActionResult(
        string? actionName,
        string? controllerName,
        object? routeValues,
        [ActionResultObjectValue] object? value)
        : base(value)
    {
        ActionName = actionName;
        ControllerName = controllerName;
        RouteValues = routeValues == null ? null : new RouteValueDictionary(routeValues);
        StatusCode = DefaultStatusCode;
    }

    public IUrlHelper? UrlHelper { get; set; }

    public string? ActionName { get; set; }

    public string? ControllerName { get; set; }

    public RouteValueDictionary? RouteValues { get; set; }

    public override void OnFormatting(ActionContext context)
    {
        ArgumentNullException.ThrowIfNull(context);

        base.OnFormatting(context);

        var request = context.HttpContext.Request;

        var urlHelper = UrlHelper;
        if (urlHelper == null)
        {
            var services = context.HttpContext.RequestServices;
            urlHelper = services.GetRequiredService<IUrlHelperFactory>().GetUrlHelper(context);
        }

        var url = urlHelper.Action(
            ActionName,
            ControllerName,
            RouteValues,
            request.Scheme,
            request.Host.ToUriComponent());

        if (string.IsNullOrEmpty(url))
        {
            throw new InvalidOperationException("No matched route found");
        }

        context.HttpContext.Response.Headers.Location = url;
    }
}
