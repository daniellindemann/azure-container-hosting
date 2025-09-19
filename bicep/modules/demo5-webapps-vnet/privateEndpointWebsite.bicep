param location string
param tags object
param suffix string

param subnetIdAzureWebsitesInbound string
param appServiceId string
param privateDnsZoneWebsitesId string

resource privateEndpointWebsitesBackend 'Microsoft.Network/privateEndpoints@2024-07-01' = {
  name: 'pep-azh-demo5-webapps-vnet-backend-${suffix}'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: subnetIdAzureWebsitesInbound
    }
    customNetworkInterfaceName: 'nic-pep-azh-demo5-webapps-vnet-backend-${suffix}'
    privateLinkServiceConnections: [
      {
        name: 'websites'
        properties: {
          privateLinkServiceId: appServiceId
          groupIds: [
            'sites'
          ]
        }
      }
    ]
  }
}

resource privateEndpointDnsZoneGroupWebsitesBackend 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2024-07-01' = {
  parent: privateEndpointWebsitesBackend
  name: 'default'
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'privatelink-azurewebsites-net'
        properties: {
          privateDnsZoneId: privateDnsZoneWebsitesId  // id of private dns zone "privatelink.azurewebsites.net"
        }
      }
    ]
  }
}
