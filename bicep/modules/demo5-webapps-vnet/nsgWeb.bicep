param location string
param tags object
param suffix string

resource nsgWeb 'Microsoft.Network/networkSecurityGroups@2024-07-01' = {
  name: 'nsg-azh-demo5-webapps-vnet-${suffix}'
  location: location
  tags: tags
}

resource nsgRuleHttps 'Microsoft.Network/networkSecurityGroups/securityRules@2024-07-01' = {
  parent: nsgWeb
  name: 'AllowAnyHTTPSInbound'
  properties: {
    description: 'Allow ALL web traffic into 443. (If you wanted to allow-list specific IPs, this is where you\'d list them.)'
    protocol: 'Tcp'
    sourcePortRange: '*'
    sourceAddressPrefix: '*'
    destinationPortRange: '443'
    destinationAddressPrefix: '*'
    direction: 'Inbound'
    access: 'Allow'
    priority: 1000
  }
}

output id string = nsgWeb.id
