param location string
param tags object
param suffix string

resource appServicePlan 'Microsoft.Web/serverfarms@2025-03-01' = {
  name: 'plan-azh-demo5-webapps-vnet-${suffix}'
  location: location
  tags: tags
  sku: {
    name: 'B1'
  }
  kind: 'linux'
  properties: {
    reserved: true
  }
}

output id string = appServicePlan.id
