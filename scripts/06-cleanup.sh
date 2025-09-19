#!/usr/bin/env bash

set -euo pipefail

script_dir=$(dirname "$0")

# script variables
webapp_rg_starts_with='rg-azh-demo1-webapps'
ci_rg_starts_with='rg-azh-demo2-ci'
aca_rg_starts_with='rg-azh-demo3-aca'
aks_rg_starts_with='rg-azh-demo4-aks'
webapp_vnet_rg_starts_with='rg-azh-demo5-webapps-vnet'
shared_rg_starts_with='rg-azh-shared'

echo "Get resource groups"
webapp_rg_name=$(az group list --query "[?starts_with(name, '${webapp_rg_starts_with}')].name | [0]" -o tsv)
ci_rg_name=$(az group list --query "[?starts_with(name, '${ci_rg_starts_with}')].name | [0]" -o tsv)
aca_rg_name=$(az group list --query "[?starts_with(name, '${aca_rg_starts_with}')].name | [0]" -o tsv)
aks_rg_name=$(az group list --query "[?starts_with(name, '${aks_rg_starts_with}')].name | [0]" -o tsv)
webapp_vnet_rg_name=$(az group list --query "[?starts_with(name, '${webapp_vnet_rg_starts_with}')].name | [0]" -o tsv)
shared_rg_name=$(az group list --query "[?starts_with(name, '${shared_rg_starts_with}')].name | [0]" -o tsv)
echo "Feteched resource groups:"
if [[ -n "$webapp_rg_name" ]]; then
    echo "  Web Apps RG: $webapp_rg_name"
else
    echo "  Web Apps RG: (not found)"
fi
if [[ -n "$ci_rg_name" ]]; then
    echo "  CI RG: $ci_rg_name"
else
    echo "  CI RG: (not found)"
fi
if [[ -n "$aca_rg_name" ]]; then
    echo "  ACA RG: $aca_rg_name"
else
    echo "  ACA RG: (not found)"
fi
if [[ -n "$aks_rg_name" ]]; then
    echo "  AKS RG: $aks_rg_name"
else
    echo "  AKS RG: (not found)"
fi
if [[ -n "$webapp_vnet_rg_name" ]]; then
    echo "  Web Apps VNet RG: $webapp_vnet_rg_name"
else
    echo "  Web Apps VNet RG: (not found)"
fi
if [[ -n "$shared_rg_name" ]]; then
    echo "  Shared RG: $shared_rg_name"
else
    echo "  Shared RG: (not found)"
fi

echo "Deleting resource groups and waiting for completion ..."
if [[ -n "$webapp_rg_name" ]]; then
    echo "  Deleting Web Apps RG: $webapp_rg_name"
    az group delete --name "$webapp_rg_name" --yes
fi
if [[ -n "$ci_rg_name" ]]; then
    echo "  Deleting CI RG: $ci_rg_name"
    az group delete --name "$ci_rg_name" --yes
fi
if [[ -n "$aca_rg_name" ]]; then
    echo "  Deleting ACA RG: $aca_rg_name"
    az group delete --name "$aca_rg_name" --yes
fi
if [[ -n "$aks_rg_name" ]]; then
    echo "  Deleting AKS RG: $aks_rg_name"
    az group delete --name "$aks_rg_name" --yes
fi
if [[ -n "$webapp_vnet_rg_name" ]]; then
    echo "  Deleting Web Apps VNet RG: $webapp_vnet_rg_name"
    az group delete --name "$webapp_vnet_rg_name" --yes
fi
if [[ -n "$shared_rg_name" ]]; then
    echo "  Deleting Shared RG: $shared_rg_name"
    az group delete --name "$shared_rg_name" --yes
fi
echo "Cleanup completed."
