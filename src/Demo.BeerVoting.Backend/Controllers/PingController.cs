using Microsoft.AspNetCore.Mvc;

namespace Demo.BeerVoting.Backend.Controllers;

public class PingController : ApiControllerBase
{
    [HttpGet]
    public ActionResult Ping()
    {
        return Ok("Pong");
    }
}
