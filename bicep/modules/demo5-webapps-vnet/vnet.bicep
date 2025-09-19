import { vnetInfo } from '../../types/vnetInfo.bicep'

param location string
param tags object
param suffix string

param nsgWebId string

resource vnet 'Microsoft.Network/virtualNetworks@2024-07-01' = {
  name: 'vnet-azh-demo5-webapps-vnet-${suffix}'
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.13.37.0/24'
      ]
    }
    subnets: [
      {
        name: 'webapps-inbound'
        properties: {
          addressPrefix: '10.13.37.0/28'
          networkSecurityGroup: {
            id: nsgWebId
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Web'
              locations: ['*']
            }
          ]
        }
      }
      {
        name: 'webapps-outbound'
        properties: {
          addressPrefix: '10.13.37.16/28'
          networkSecurityGroup: {
            id: nsgWebId
          }
          serviceEndpoints: [
            {
              service: 'Microsoft.Web'
              locations: ['*']
            }
            {
              service: 'Microsoft.KeyVault'
              locations: ['*']
            }
            {
              service: 'Microsoft.ContainerRegistry'
              locations: ['*']
            }
            {
              service: 'Microsoft.Sql'
              locations: ['*']
            }
          ]
          delegations: [
            {
              name: 'delegation-webapps'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
    ]
  }

  resource subnetWebappsOutbound 'subnets' existing = {
    name: 'webapps-outbound'
  }

  resource subnetWebappsInbound 'subnets' existing = {
    name: 'webapps-inbound'
  }
}

output info vnetInfo = {
  id: vnet.id
  name: vnet.name
}
output subnetIdAzureWebsitesInbound string = vnet::subnetWebappsInbound.id
output subnetIdAzureWebsitesOutbound string = vnet::subnetWebappsOutbound.id
