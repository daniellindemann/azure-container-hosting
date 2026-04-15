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

// variables
variable "IMAGE_TAGS" {
  default = ["10", "10.0.103", "latest"]
}

variable "BACKEND_NAMES" {
  default = ["beer-rating-backend", "daniellindemann/beer-rating-backend"]
}

variable "FRONTEND_NAMES" {
  default = ["beer-rating-frontend", "daniellindemann/beer-rating-frontend"]
}

variable "CONSOLE_NAMES" {
  default = ["beer-rating-console-beerquotes", "daniellindemann/beer-rating-console-beerquotes"]
}

target "beer-rating-backend" {
  context = "."
  dockerfile = "src/Demo.BeerRating.Backend/Dockerfile"
  tags = flatten([
    for name in BACKEND_NAMES : [
      for tag in IMAGE_TAGS : "${name}:${tag}"
    ]
  ])
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=docker"]
}

target "beer-rating-frontend" {
  context = "."
  dockerfile = "src/Demo.BeerRating.Frontend/Dockerfile"
  tags = flatten([
    for name in FRONTEND_NAMES : [
      for tag in IMAGE_TAGS : "${name}:${tag}"
    ]
  ])
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=docker"]
}

target "beer-rating-console-beerquotes" {
  context = "."
  dockerfile = "src/Demo.BeerRating.Console.BeerQuotes/Dockerfile"
  tags = flatten([
    for name in CONSOLE_NAMES : [
      for tag in IMAGE_TAGS : "${name}:${tag}"
    ]
  ])
  platforms = ["linux/amd64", "linux/arm64"]
  output = ["type=docker"]
}
