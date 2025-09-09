#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

pushd $script_dir/..

# build frontend
echo '🏗️ Crafting backend container image'
docker build \
    --file src/Demo.BeerVoting.Backend/Dockerfile \
    --tag beer-rating-backend:9.0.0 \
    --tag daniellindemann/beer-rating-backend:9.0.0 \
    .
echo '🏭 Forged backend container image'

# build frontend
echo '🖌️ Tinker frontend container image'
docker build \
    --file src/Demo.BeerVoting.Frontend/Dockerfile \
    --tag beer-rating-frontend:9.0.0 \
    --tag daniellindemann/beer-rating-frontend:9.0.0 \
    .
echo '🧁 Forged backend container image'

popd

echo '✅ Script finished!'
