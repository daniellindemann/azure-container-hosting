#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

# script variables
useBake=true


if [ "$useBake" = true ]; then
    echo "🍰 Use bake"
    docker buildx bake all --file $script_dir/../docker-bake.hcl
else
    pushd $script_dir/..

    # build backend
    echo '🏗️ Crafting backend container image'
    docker buildx build \
        --file src/Demo.BeerRating.Backend/Dockerfile \
        --platform linux/amd64,linux/arm64 \
        --tag beer-rating-backend:9.0.0 \
        --tag daniellindemann/beer-rating-backend:9.0.0 \
        --output type=docker \
        .
    echo '🏭 Forged backend container image'

    # build frontend
    echo '🖌️ Tinker frontend container image'
    docker buildx build \
        --file src/Demo.BeerRating.Frontend/Dockerfile \
        --platform linux/amd64,linux/arm64 \
        --tag beer-rating-frontend:9.0.0 \
        --tag daniellindemann/beer-rating-frontend:9.0.0 \
        --output type=docker \
        .
    echo '🧁 Forged backend container image'

    # build console
    echo '👷‍♂️ Build console container image'
    docker buildx build \
        --file src/Demo.BeerRating.Console.BeerQuotes/Dockerfile \
        --platform linux/amd64,linux/arm64 \
        --tag beer-rating-console-beerquotes:9.0.0 \
        --tag daniellindemann/beer-rating-console-beerquotes:9.0.0 \
        --output type=docker \
        .
    echo '🏡 Constructed console container image'

    popd
fi

echo '✅ Script finished!'
