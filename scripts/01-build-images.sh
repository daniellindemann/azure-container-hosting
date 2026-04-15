#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

# script variables
useBake=true
imageBackendNames=(
    'beer-rating-backend'
    'daniellindemann/beer-rating-backend'
)
imageFrontendNames=(
    'beer-rating-frontend'
    'daniellindemann/beer-rating-frontend'
)
imageConsoleNames=(
    'beer-rating-console-beerquotes'
    'daniellindemann/beer-rating-console-beerquotes'
)
imageTags=(
    '10'
    '10.0.103'
    'latest'
)

# functions
build_image() {
    local dockerfile=$1
    local -n names=$2
    local -n tags=$3

    local tag_args=()
    for name in "${names[@]}"; do
        for tag in "${tags[@]}"; do
            tag_args+=(--tag "${name}:${tag}")
        done
    done

    docker buildx build \
        --file "$dockerfile" \
        --platform linux/amd64,linux/arm64 \
        "${tag_args[@]}" \
        --output type=docker \
        .
}


if [ "$useBake" = true ]; then
    echo "🍰 Use bake"
    docker buildx bake all --file $script_dir/../docker-bake.hcl
else
    pushd $script_dir/..

    # build backend
    echo '🏗️ Crafting backend container image'
    build_image src/Demo.BeerRating.Backend/Dockerfile imageBackendNames imageTags
    echo '🏭 Forged backend container image'

    # build frontend
    echo '🖌️ Tinker frontend container image'
    build_image src/Demo.BeerRating.Frontend/Dockerfile imageFrontendNames imageTags
    echo '🧁 Forged frontend container image'

    # build console
    echo '👷‍♂️ Build console container image'
    build_image src/Demo.BeerRating.Console.BeerQuotes/Dockerfile imageConsoleNames imageTags
    echo '🏡 Constructed console container image'

    popd
fi

echo '✅ Script finished!'
