import { managedIdentityReference } from '../../types/managedIdentityReference.bicep'

param location string
param tags object

param name string
param appServicePlanId string
param managedIdentity managedIdentityReference
param acrLoginServer string
param containerImage string
param appSettings object


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
      linuxFxVersion: 'DOCKER|${acrLoginServer}/${containerImage}'
      healthCheckPath: '/healthz'
    }
  }
}

resource appServiceSettings 'Microsoft.Web/sites/config@2024-11-01' = {
  parent: appService
  name: 'appsettings'
  properties: appSettings
}

output url string = 'https://${appService.properties.defaultHostName}'
