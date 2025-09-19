import { managedIdentityReference } from '../types/managedIdentityReference.bicep'

param location string
param tags object
param suffix string

param managedIdentity managedIdentityReference
param acrLoginServer string
param connectionStringKeyVaultUri string

module logAnalyticsWorkspace 'demo2-ci/logAnalyticsWorkspace.bicep' = {
  name: 'module-demo2-ci-loganalyticsWorkspace'
  params: {
    location: location
    tags: tags
    suffix: suffix
  }
}

module ciBackend 'demo2-ci/containerInstanceSidecar.bicep' = {
  name: 'module-demo2-ci-containerInstanceBackend'
  params: {
    location: location
    tags: tags

    name: 'ci-azh-demo2-ci-backend-${suffix}'
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
    containerImageMain: 'daniellindemann/beer-rating-backend:9.0.0'
    containerPortMain: 5178
    containerImageSidecar: 'daniellindemann/beer-rating-console-beerquotes:9.0.0'
    acrLoginServer: acrLoginServer
    managedIdentity: managedIdentity
    connectionStringSecretUri: connectionStringKeyVaultUri
    environmentVariables: {
      ASPNETCORE_URLS: 'http://+:5178'
      Database__UseInMemoryDatabase: 'false'
      Database__UseAutoMigration: 'false'
      Database__UseDataSeeding: 'true'
    }
  }
}

module ciFrontend 'demo2-ci/containerInstance.bicep' = {
  name: 'module-demo2-ci-containerInstanceFrontend'
  params: {
    location: location
    tags: tags

    name: 'ci-azh-demo2-ci-frontend-${suffix}'
    logAnalyticsWorkspaceName: logAnalyticsWorkspace.outputs.name
    containerImageMain: 'daniellindemann/beer-rating-frontend:9.0.0'
    containerPortMain: 5179
    acrLoginServer: acrLoginServer
    managedIdentity: managedIdentity
    environmentVariables: {
      ASPNETCORE_URLS: 'http://+:5179'
      Backend__HostUrl: 'http://${ciBackend.outputs.fqdn}:5178'
    }
  }
}
