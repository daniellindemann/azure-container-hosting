# Beer Rating Console Beer Quotes

This application just outputs some random quotes about beer to the console.

## Configuration

| Key | Default | Description |
| --- | ------- | ----------- |
| `QuoteSleepInSeconds` | `300` | Sleep time to wait before posting a new quote |

> **💡 Info**  
> All configuration values can be overwritten via environment variables using the default .NET configuration behavior. For example, `QuoteSleepInSeconds` can be set with the environment variable `QuoteSleepInSeconds`. Nested keys use `__` (double underscore) as a separator (e.g., `Section__Key`).

## Container

A container image of this application is available on Docker Hub: [daniellindemann/beer-rating-console-beerquotes](https://hub.docker.com/r/daniellindemann/beer-rating-console-beerquotes)

### Usage

Run a container using the latest version of the image:

```bash
docker run -it --rm daniellindemann/beer-rating-console-beerquotes
```
