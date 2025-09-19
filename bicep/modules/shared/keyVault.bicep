param location string
param tags object
param suffix string

param enableKeyVaultPurgeProtection bool = false

resource keyVault 'Microsoft.KeyVault/vaults@2024-11-01' = {
  name: 'kv-azh-shared-${suffix}'
  location: location
  tags: tags
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    enablePurgeProtection: enableKeyVaultPurgeProtection ? true : null // to disable purge protection the value must not be set
    tenantId: tenant().tenantId
    enableRbacAuthorization: true
    enabledForTemplateDeployment: true
  }
}

output id string = keyVault.id
output name string = keyVault.name
