param acrName string
param keyVaultName string
param managedIdentityManagementPrincipalId string

var acrPullRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '7f951dda-4ed3-4680-a7ca-43fe172d538d') // role name: AcrPull
var keyVaultSecretUserRole = subscriptionResourceId('Microsoft.Authorization/roleDefinitions', '4633458b-17de-408a-b874-0445c86b69e6') // role name: Key Vault Secrets User

// --- Give identity 'Management' permissions to pull images from acr ---

resource acr 'Microsoft.ContainerRegistry/registries@2025-04-01' existing = {
  name: acrName
}

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' existing = {
  name: keyVaultName
}

resource acrPullImagesRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(acr.id, managedIdentityManagementPrincipalId, acrPullRole)
  scope: acr
  properties: {
    principalId: managedIdentityManagementPrincipalId
    roleDefinitionId: acrPullRole
    principalType: 'ServicePrincipal'
  }
}

resource keyVaultSecretUserRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVault.id, managedIdentityManagementPrincipalId, keyVaultSecretUserRole)
  scope: keyVault
  properties: {
    principalId: managedIdentityManagementPrincipalId
    roleDefinitionId: keyVaultSecretUserRole
    principalType: 'ServicePrincipal'
  }
}
