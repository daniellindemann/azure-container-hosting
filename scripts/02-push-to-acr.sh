#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

# script variables
acr_starts_with='crazhshared'
backend_image='daniellindemann/beer-rating-backend:10.0.0'
frontend_image='daniellindemann/beer-rating-frontend:10.0.0'
console_image='daniellindemann/beer-rating-console-beerquotes:10.0.0'


echo "🔎 Get ACR name starting with '${acr_starts_with}'"
acr_name=$(az acr list --query "[?starts_with(name, '${acr_starts_with}')].name" -o tsv)
echo "🐕 Retrieved '${acr_name}'"

echo "🗝️ Log in to ACR '${acr_name}'"
az acr login --name $acr_name
echo "🔓 Authenticated on ACR '${acr_name}'"

echo "🫸 Push backend container image (${backend_image})"
docker tag ${backend_image} ${acr_name}.azurecr.io/${backend_image}
docker push ${acr_name}.azurecr.io/${backend_image}
echo "🚀 Pushed backend container image (${backend_image})"

echo "🫸 Push frontend container image (${frontend_image})"
docker tag ${frontend_image} ${acr_name}.azurecr.io/${frontend_image}
docker push ${acr_name}.azurecr.io/${frontend_image}
echo "🚀 Pushed frontend container image (${frontend_image})"

echo "🫸 Push console container image (${console_image})"
docker tag ${console_image} ${acr_name}.azurecr.io/${console_image}
docker push ${acr_name}.azurecr.io/${console_image}
echo "🚀 Pushed console container image (${console_image})"

echo '✅ Script finished!'
