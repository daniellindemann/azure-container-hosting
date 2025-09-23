#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

# script variables
aks_starts_with='aks-azh-demo4-aks'
keyvault_starts_with='kv-azh-shared'
acr_starts_with='crazhshared'
backend_image='daniellindemann/beer-rating-backend:9.0.0'
frontend_image='daniellindemann/beer-rating-frontend:9.0.0'
console_image='daniellindemann/beer-rating-console-beerquotes:9.0.0'

echo "🔎 Get AKS cluster starting with '${aks_starts_with}'"
aks_json_data=$(az aks list --query "[?starts_with(name, '${aks_starts_with}')].{name: name, resourceGroup: resourceGroup, keyVaultvIdentity: addonProfiles.azureKeyvaultSecretsProvider.identity}[0]" -o json)
aks_name=$(echo $aks_json_data | jq -r '.name')
aks_resourceGroup=$(echo $aks_json_data | jq -r '.resourceGroup')
aks_keyVaultIdentity_clientId=$(echo $aks_json_data | jq -r '.keyVaultvIdentity.clientId')
echo "🐕 Retrieved '${aks_name}' on resource group '${aks_resourceGroup}'"

echo "Installing aks cli tools"
if [ ! -x /usr/local/bin/kubelogin ]; then
  sudo az aks install-cli
fi
echo "Tools installed"

echo "Get AKS credentials for current user '$(az account show --query 'user.name' -o tsv)'"
tenantId=$(az account show --query 'tenantId' -o tsv)
az aks get-credentials --resource-group $aks_resourceGroup --name $aks_name --overwrite-existing
kubelogin convert-kubeconfig -l azurecli
echo "Credentials retrieved"

echo "Get AKS resources from default namespace to ensure connection works"
kubectl get secretproviderclass,pods,deployment,svc,ingress
echo "Resources retrieved"
