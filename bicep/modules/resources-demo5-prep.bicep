targetScope = 'subscription'

import { managedIdentityReference } from '../types/managedIdentityReference.bicep'

param location string
param tags object
param suffix string

param rgDemo5WebAppsVnetName string
param rgSharedName string

param acrName string
param keyVaultName string
param privateDnsZoneWebsitesName string

resource rgDemo5WebAppsVnet 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
    name: rgDemo5WebAppsVnetName
}

resource rgShared 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
    name: rgSharedName
}

module nsgWeb 'demo5-webapps-vnet/nsgWeb.bicep' = {
    name: 'module-demo5-webapps-vnet-nsgWeb'
    scope: rgDemo5WebAppsVnet
    params: {
        location: location
        tags: tags
        suffix: suffix
    }
}

module vnet 'demo5-webapps-vnet/vnet.bicep' = {
    name: 'module-demo5-webapps-vnet-vnet'
    scope: rgDemo5WebAppsVnet
    params: {
        location: location
        tags: tags
        suffix: suffix

        nsgWebId: nsgWeb.outputs.id
    }
}

module privateDnsZoneVnetLinkWeb 'demo5-webapps-vnet/privateDnsZoneVnetLink.bicep' = {
    name: 'module-demo5-webapps-vnet-privateDnsZoneVnetLinkWeb'
    scope: rgShared
    params: {
        privateDnsZoneName: privateDnsZoneWebsitesName // it's "privatelink.azurewebsites.net"
        tags: tags
        vnet: vnet.outputs.info
    }
}

module managedIdentityDemo5WebApp 'demo5-webapps-vnet/idWebApp.bicep' = {
    name: 'module-demo5-webapps-vnet-idWebApp'
    scope: rgDemo5WebAppsVnet
    params: {
        location: location
        tags: tags
        suffix: suffix
    }
}

module roleAssignmentsDemo5WebApp 'demo5-webapps-vnet/roleAssignments.bicep' = {
    name: 'module-demo5-webapps-vnet-roleAssignments'
    scope: rgShared
    params: {
        acrName: acrName
        keyVaultName: keyVaultName
        managedIdentityManagementPrincipalId: managedIdentityDemo5WebApp.outputs.principalId
    }
}

output managedIdentityWebApp managedIdentityReference = {
  id: managedIdentityDemo5WebApp.outputs.id
  clientId: managedIdentityDemo5WebApp.outputs.clientId
}
output subnetIdAzureWebsitesInbound string = vnet.outputs.subnetIdAzureWebsitesInbound
output subnetIdAzureWebsitesOutbound string = vnet.outputs.subnetIdAzureWebsitesOutbound
