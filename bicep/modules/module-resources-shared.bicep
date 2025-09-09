param location string
param tags object
param suffix string

param sqlAdminUsername string
@secure()
param sqlAdminPassword string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: replace('cr-azure-container-hosting-${suffix}', '-', '')
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

module sql 'sql.bicep' = {
    name: 'module-sql'
    params: {
        location: location
        tags: tags
        suffix: suffix

        sqlAdminUsername: sqlAdminUsername
        sqlAdminPassword: sqlAdminPassword
    }
}



output acr_name string = containerRegistry.name
output acr_loginServer string = containerRegistry.properties.loginServer
