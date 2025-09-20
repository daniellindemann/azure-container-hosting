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

echo "🔎 Get key vault starting with '${keyvault_starts_with}'"
keyvault_json_data=$(az keyvault list --query "[?starts_with(name, '${keyvault_starts_with}')].{name: name, resourceGroup: resourceGroup}[0]" -o json)
keyvault_name=$(echo $keyvault_json_data | jq -r '.name')
keyvault_resourceGroup=$(echo $keyvault_json_data | jq -r '.resourceGroup')
echo "🐕 Retrieved '${keyvault_name}' on resource group '${keyvault_resourceGroup}'"

echo "🔎 Get container registry starting with '${acr_starts_with}'"
acr_json_data=$(az acr list --query "[?starts_with(name, '${acr_starts_with}')].{name: name, resourceGroup: resourceGroup, loginServer: loginServer}[0]" -o json)
acr_name=$(echo $acr_json_data | jq -r '.name')
acr_resourceGroup=$(echo $acr_json_data | jq -r '.resourceGroup')
acr_loginServer=$(echo $acr_json_data | jq -r '.loginServer')
echo "🐕 Retrieved '${acr_name}' on resource group '${acr_resourceGroup}'"

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

echo "Get AKS nodes to ensure connection works"
kubectl get nodes
echo "Nodes retrieved"

echo "Install nginx ingress controller"
kubectl apply -f $script_dir/../k8s/ingress-controller-nginx.yaml
# check if ingress controller is running
while true; do
    kubectl rollout status deployment/ingress-nginx-controller -n ingress-nginx --timeout=180s
    if [ $? -eq 0 ]; then
        break
    fi
done
# wait until public ip is assigned
while true; do
    ingressPublicIp=$(kubectl get services \
        --namespace ingress-nginx \
        ingress-nginx-controller \
        --output jsonpath='{.status.loadBalancer.ingress[0].ip}')
    if [[ -n "$ingressPublicIp" && $(grep -o "\." <<< "$ingressPublicIp" | wc -l) -eq 3 ]]; then
        echo "Ingress controller public ip is '$ingressPublicIp'"
        break
    fi
    sleep 5
done
echo "Ingress controller installed"

echo "Configure secret provider class to get secrets from key vault"
secretProviderClassYaml="$(cat "$script_dir/../k8s/secret-provider-class-keyvault-backend.yml")"
replacedUserAssignedIdentityId=$(echo "$secretProviderClassYaml" | yq ".spec.parameters.\"userAssignedIdentityID\" = \"${aks_keyVaultIdentity_clientId}\"")
replacedTenantId=$(echo "$replacedUserAssignedIdentityId" | yq ".spec.parameters.\"tenantId\" = \"${tenantId}\"")
replacedKeyVaultName=$(echo "$replacedTenantId" | yq ".spec.parameters.\"keyvaultName\" = \"${keyvault_name}\"")
echo "$replacedKeyVaultName" | kubectl apply -f -
echo "Secret provider class configured"

echo "Apply deployments and services"
# kubectl apply -f $script_dir/../k8s/deployment-backend.yml
# replace the image name in the deployment yaml file of the backend with the one from container registry
backendDeploymentYaml="$(cat "$script_dir/../k8s/deployment-backend.yml")"
replacedBackendImage=$(echo "$backendDeploymentYaml" | yq ".spec.template.spec.containers[0].image = \"${acr_loginServer}/${backend_image}\"")
replacedConsoleImage=$(echo "$replacedBackendImage" | yq ".spec.template.spec.containers[1].image = \"${acr_loginServer}/${console_image}\"")
echo "$replacedConsoleImage" | kubectl apply -f -
kubectl apply -f $script_dir/../k8s/service-backend.yaml
# kubectl apply -f $script_dir/../k8s/deployment-frontend.yml
# replace the image name in the deployment yaml file of the frontend with the one from container registry
frontendDeploymentYaml="$(cat "$script_dir/../k8s/deployment-frontend.yml")"
replacedFrontendImage=$(echo "$frontendDeploymentYaml" | yq ".spec.template.spec.containers[0].image = \"${acr_loginServer}/${frontend_image}\"")
echo "$replacedFrontendImage" | kubectl apply -f -
kubectl apply -f $script_dir/../k8s/service-frontend.yaml
echo "Deployments and services applied"

echo "Apply ingress rules"
kubectl apply -f $script_dir/../k8s/ingress-frontend.yml
echo "Ingress rules applied"

kubectl get secretproviderclass,pods,svc,ingress

echo "Everything applied successfully"
echo "> You can access the application on http://${ingressPublicIp} or http://${ingressPublicIp}.nip.io"
echo "> Use ip ${ingressPublicIp} to create a DNS A record for your custom domain"
