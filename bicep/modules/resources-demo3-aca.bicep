import { managedIdentityReference } from '../types/managedIdentityReference.bicep'

param location string
param tags object
param suffix string

param managedIdentity managedIdentityReference
param acrLoginServer string
param connectionStringKeyVaultUri string

module logAnalyticsWorkspace 'demo3-aca/logAnalyticsWorkspace.bicep' = {
  name: 'module-demo3-aca-loganalyticsWorkspace'
  params: {
    location: location
    tags: tags
    suffix: suffix
  }
}

module containerAppsEnvironment 'demo3-aca/containerAppsEnvironment.bicep' = {
  name: 'module-demo3-aca-containerAppsEnvironment'
  params: {
    location: location
    tags: tags
    suffix: suffix

    managedIdentity: managedIdentity
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
  }
}

module containerAppBackend 'demo3-aca/containerAppSidecar.bicep' = {
  name: 'module-demo3-aca-containerAppBackend'
  params: {
    location: location
    tags: tags

    name: 'ca-azh-demo3-aca-bend-${suffix}'
    managedIdentity: managedIdentity
    connectionStringSecretUri: connectionStringKeyVaultUri
    acrLoginServer: acrLoginServer

    environmentId: containerAppsEnvironment.outputs.id
    ingress: 'internal'
    containerImageMain: 'daniellindemann/beer-rating-backend:9.0.0'
    containerPortMain: 5178
    containerImageSidecar: 'daniellindemann/beer-rating-console-beerquotes:9.0.0'
    environmentVariables: {
      Database__UseInMemoryDatabase: 'false'
      Database__UseAutoMigration: 'false'
      Database__UseDataSeeding: 'true'
    }
  }
}

module containerAppFrontend 'demo3-aca/containerApp.bicep' = {
  name: 'module-demo3-aca-containerAppFrontend'
  params: {
    location: location
    tags: tags

    name: 'ca-azh-demo3-aca-fend-${suffix}'
    managedIdentity: managedIdentity
    acrLoginServer: acrLoginServer

    environmentId: containerAppsEnvironment.outputs.id
    ingress: 'external'
    containerImageMain: 'daniellindemann/beer-rating-frontend:9.0.0'
    containerPortMain: 5179
    environmentVariables: {
      Backend__HostUrl: 'https://${containerAppBackend.outputs.fqdn}'
    }
  }
}
