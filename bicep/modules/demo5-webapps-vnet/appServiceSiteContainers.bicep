import { managedIdentityReference } from '../../types/managedIdentityReference.bicep'

param location string
param tags object

param name string
param appServicePlanId string
param managedIdentity managedIdentityReference
param acrLoginServer string
param containerImage string
param appSettings object
// configuration for site containers
param targetPortMainContainer string
param sideCarImage string
// network
param subnetIdAzureWebsitesOutbound string


resource appService 'Microsoft.Web/sites@2024-11-01' = {
  name: name
  location: location
  kind: 'app,linux,container'
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  tags: tags
  properties: {
    serverFarmId: appServicePlanId
    httpsOnly: true
    clientAffinityEnabled: false
    reserved: true
    keyVaultReferenceIdentity: managedIdentity.id
    siteConfig: {
      alwaysOn: true
      ftpsState: 'Disabled'
      acrUseManagedIdentityCreds: true
      acrUserManagedIdentityID: managedIdentity.clientId
      // linuxFxVersion: 'DOCKER|${acrLoginServer}/${containerImage}'
      linuxFxVersion: 'sitecontainers'
      healthCheckPath: '/healthz'
    }
    // networking
    virtualNetworkSubnetId: subnetIdAzureWebsitesOutbound
    publicNetworkAccess: 'Disabled'
  }
}

resource siteContainerMain 'Microsoft.Web/sites/sitecontainers@2024-11-01' = {
  name: 'main'
  parent: appService
  properties: {
    image:'${acrLoginServer}/${containerImage}'
    targetPort: targetPortMainContainer
    isMain: true
    authType: 'UserAssigned'
    userManagedIdentityClientId: managedIdentity.clientId
  }
}

resource siteContainerSidecar 'Microsoft.Web/sites/sitecontainers@2024-11-01' = {
  name: 'sidecar'
  parent: appService
  properties: {
    image:'${acrLoginServer}/${sideCarImage}'
    isMain: false
    authType: 'UserAssigned'
    userManagedIdentityClientId: managedIdentity.clientId
  }
}

resource appServiceSettings 'Microsoft.Web/sites/config@2024-11-01' = {
  parent: appService
  name: 'appsettings'
  properties: appSettings
}

output id string = appService.id
output url string = 'https://${appService.properties.defaultHostName}'
