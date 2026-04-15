# Beer Rating Frontend

This frontend is an ASP.NET Core Razor Pages web application that serves as the user-facing interface for the beer rating solution. It communicates with the backend API via `IBackendService` and offers the following functionality:

- **View favorite beers** — displays a table of favorite beers with their name, brewery, nickname, and current rating score
- **Rate a beer** — allows users to submit a rating (1–5) for any listed favorite beer
- **Total ratings counter** — shows the aggregated total number of ratings submitted across all beers
- **QR code** — generates a QR code pointing to the current page URL for easy sharing
