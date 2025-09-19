param location string
param tags object
param suffix string

resource containerRegistry 'Microsoft.ContainerRegistry/registries@2025-04-01' = {
  name: replace('cr-azh-shared-${suffix}', '-', '')
  location: location
  tags: tags
  sku: {
    name: 'Basic'
  }
  properties: {
    adminUserEnabled: false
  }
}

output name string = containerRegistry.name
output loginServer string = containerRegistry.properties.loginServer
