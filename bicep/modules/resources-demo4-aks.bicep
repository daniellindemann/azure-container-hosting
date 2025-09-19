param location string
param tags object
param suffix string

param aksEntraAdminGroupObjectIds string

module logAnalyticsWorkspace 'demo4-aks/logAnalyticsWorkspace.bicep' = {
  name: 'module-demo4-aks-loganalyticsWorkspace'
  params: {
    location: location
    tags: tags
    suffix: suffix
  }
}

module aksCluster 'demo4-aks/aksCluster.bicep' = {
  name: 'module-demo4-aks-aksCluster'
  params: {
    location: location
    tags: tags
    suffix: suffix

    logAnalyticsWorkspaceId: logAnalyticsWorkspace.outputs.id
    entraAdminGroupObjectIds: [aksEntraAdminGroupObjectIds]
  }
}

output kubeletObjectId string = aksCluster.outputs.kubeletObjectId
output azureKeyVaultSecretsProviderIdentityObjectId string = aksCluster.outputs.azureKeyVaultSecretsProviderIdentityObjectId
output azureKeyVaultSecretsProviderIdentityClientId string = aksCluster.outputs.azureKeyVaultSecretsProviderIdentityClientId
