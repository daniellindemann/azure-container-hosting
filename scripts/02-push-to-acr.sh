#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

# script variables
acr_starts_with='crazhshared'
backend_image='daniellindemann/beer-rating-backend'
frontend_image='daniellindemann/beer-rating-frontend'
console_image='daniellindemann/beer-rating-console-beerquotes'
imageTags=(
    '10'
    '10.0.103'
    'latest'
)


echo "🔎 Get ACR name starting with '${acr_starts_with}'"
acr_name=$(az acr list --query "[?starts_with(name, '${acr_starts_with}')].name" -o tsv)
echo "🐕 Retrieved '${acr_name}'"

echo "🗝️ Log in to ACR '${acr_name}'"
az acr login --name $acr_name
echo "🔓 Authenticated on ACR '${acr_name}'"

for tag in "${imageTags[@]}"; do
    echo "🫸 Push backend container image (${backend_image}:${tag})"
    docker tag "${backend_image}:${tag}" "${acr_name}.azurecr.io/${backend_image}:${tag}"
    docker push "${acr_name}.azurecr.io/${backend_image}:${tag}"
    echo "🚀 Pushed backend container image (${backend_image}:${tag})"
done

for tag in "${imageTags[@]}"; do
    echo "🫸 Push frontend container image (${frontend_image}:${tag})"
    docker tag "${frontend_image}:${tag}" "${acr_name}.azurecr.io/${frontend_image}:${tag}"
    docker push "${acr_name}.azurecr.io/${frontend_image}:${tag}"
    echo "🚀 Pushed frontend container image (${frontend_image}:${tag})"
done

for tag in "${imageTags[@]}"; do
    echo "🫸 Push console container image (${console_image}:${tag})"
    docker tag "${console_image}:${tag}" "${acr_name}.azurecr.io/${console_image}:${tag}"
    docker push "${acr_name}.azurecr.io/${console_image}:${tag}"
    echo "🚀 Pushed console container image (${console_image}:${tag})"
done

echo '✅ Script finished!'
