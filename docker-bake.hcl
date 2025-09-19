group "default" {
  targets = ["all"]
}

group "all" {
  targets = [
    "beer-rating-backend",
    "beer-rating-frontend",
    "beer-rating-console-beerquotes"
  ]
}

target "beer-rating-backend" {
  context = "."
  dockerfile = "src/Demo.BeerRating.Backend/Dockerfile"
  tags = [
    "beer-rating-backend:9.0.0",
    "beer-rating-backend:latest",
    "daniellindemann/beer-rating-backend:9.0.0",
    "daniellindemann/beer-rating-backend:latest"
  ]
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=docker"]
}

target "beer-rating-frontend" {
  context = "."
  dockerfile = "src/Demo.BeerRating.Frontend/Dockerfile"
  tags = [
    "beer-rating-frontend:9.0.0",
    "beer-rating-frontend:latest",
    "daniellindemann/beer-rating-frontend:9.0.0",
    "daniellindemann/beer-rating-frontend:latest"
  ]
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=docker"]
}

target "beer-rating-console-beerquotes" {
  context = "."
  dockerfile = "src/Demo.BeerRating.Console.BeerQuotes/Dockerfile"
  tags = [
    "beer-rating-console-beerquotes:9.0.0",
    "beer-rating-console-beerquotes:latest",
    "daniellindemann/beer-rating-console-beerquotes:9.0.0",
    "daniellindemann/beer-rating-console-beerquotes:latest"
  ]
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=docker"]
}
