# Beer Rating Backend

This backend is a REST API for a beer rating and voting solution. It provides endpoints to manage **breweries** and **beers**, including the ability to mark beers as favorites and rate them. The API is organized around the following resources:

- **`/api/brewery`** — CRUD operations for breweries (list, get by ID, create, update, delete)
- **`/api/beer`** — CRUD operations for beers (list, get by ID, create, update, delete)
- **`/api/beer/favorites`** — manage and list favorite beers
- **`/api/beer/favorites/{id}/rate`** — submit a rating for a favorite beer
- **`/api/beer/favorites/totalratings`** — retrieve aggregated total ratings
- **`/api/ping`** — health/liveness check endpointIt is part of a multi-service solution.
