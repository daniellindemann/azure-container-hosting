param tags object

resource privateDnsZoneWebsites 'Microsoft.Network/privateDnsZones@2024-06-01' = {
  name: 'privatelink.azurewebsites.net'
  location: 'global'
  tags: tags
  properties: {}
}

output privateDnsZoneWebsitesName string = privateDnsZoneWebsites.name
output privateDnsZoneWebsitesId string = privateDnsZoneWebsites.id
