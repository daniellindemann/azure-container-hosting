using Demo.BeerVoting.Frontend.Dtos.Responses;
using Demo.BeerVoting.Frontend.Services;

using Microsoft.AspNetCore.Http.Extensions;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;

using QRCoder;

using static QRCoder.PayloadGenerator;

namespace Demo.BeerVoting.Frontend.Pages;

public class IndexModel : PageModel
{
    private readonly IBackendService _backendService;
    private readonly ILogger<IndexModel> _logger;

    public IndexModel(IBackendService backendService, ILogger<IndexModel> logger)
    {
        _backendService = backendService;
        _logger = logger;
    }

    public List<GetFavoriteBeerResponse> FavoriteBeers { get; set; } = null!;

    public async Task OnGet()
    {
        _logger.LogInformation("Get total votes");
        int totalVotes = await _backendService.GetTotalRatings();
        this.ViewData.Add("TotalRatings", totalVotes);
        _logger.LogInformation("Got {count} total votes", totalVotes);

        _logger.LogInformation("Get favorite beers");
        FavoriteBeers = await _backendService.GetFavoriteBeers();
        _logger.LogInformation("Got {count} beers", FavoriteBeers.Count);
    }

    public async Task<ActionResult> OnPostRate(Guid id, int value)
    {
        _logger.LogInformation("Rate beer with id {beerId}", id);

        await _backendService.RateFavoriteBeer(id, Convert.ToDouble(value));

        return RedirectToPage();
    }

    public string GetQrCodeForUrl()
    {
        Url generator = new Url(Request.GetDisplayUrl());
        string payload = generator.ToString();

        QRCodeGenerator qrGenerator = new QRCodeGenerator();
        QRCodeData qrCodeData = qrGenerator.CreateQrCode(payload, QRCodeGenerator.ECCLevel.Q);

        using SvgQRCode qrCode = new SvgQRCode(qrCodeData);
        string qrCodeAsSvg = qrCode.GetGraphic(12);

        return qrCodeAsSvg;
    }
}
