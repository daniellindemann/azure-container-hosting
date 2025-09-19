import { managedIdentityReference } from '../types/managedIdentityReference.bicep'

param location string
param tags object
param suffix string

param managedIdentity managedIdentityReference
param acrLoginServer string
param connectionStringKeyVaultUri string

param subnetIdAzureWebsitesInbound string
param subnetIdAzureWebsitesOutbound string
param privateDnsZoneWebsitesId string

module applicationInsights 'demo5-webapps-vnet/applicationInsights.bicep' = {
  name: 'module-demo5-webapps-vnet-applicationInsights'
  params: {
    location: location
    tags: tags
    suffix: suffix
  }
}

module appServicePlan 'demo5-webapps-vnet/appServicePlan.bicep' = {
  name: 'module-demo5-webapps-vnet-plan'
  params: {
    location: location
    tags: tags
    suffix: suffix
  }
}

module appServiceBackend 'demo5-webapps-vnet/appServiceSiteContainers.bicep' = {
  name: 'module-demo5-webapps-vnet-appServiceBackend'
  params: {
    location: location
    tags: tags

    name: 'app-azh-demo5-webapps-vnet-backend-${suffix}'
    appServicePlanId: appServicePlan.outputs.id
    managedIdentity: managedIdentity
    acrLoginServer: acrLoginServer
    containerImage: 'daniellindemann/beer-rating-backend:9.0.0'
    targetPortMainContainer: '5178'
    sideCarImage: 'daniellindemann/beer-rating-console-beerquotes:9.0.0'
    appSettings: {
      WEBSITES_PORT: '5178'
      Database__UseInMemoryDatabase: 'false'
      Database__UseAutoMigration: 'false'
      Database__UseDataSeeding: 'true'
      ConnectionStrings__Beer: '@Microsoft.KeyVault(SecretUri=${connectionStringKeyVaultUri})'
      WEBSITE_HTTPLOGGING_RETENTION_DAYS: '3'
      APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.outputs.connectionString
      ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
      XDT_MicrosoftApplicationInsights_Mode: 'Recommended'
    }
    // network
    subnetIdAzureWebsitesOutbound: subnetIdAzureWebsitesOutbound
  }
}

module privateEndpointWebsites 'demo5-webapps-vnet/privateEndpointWebsite.bicep' = {
  name: 'module-demo5-webapps-vnet-privateEndpointWebsites'
  params: {
    location: location
    tags: tags
    suffix: suffix

    subnetIdAzureWebsitesInbound: subnetIdAzureWebsitesInbound
    appServiceId: appServiceBackend.outputs.id
    privateDnsZoneWebsitesId: privateDnsZoneWebsitesId
  }
}

module appServiceFrontend 'demo5-webapps-vnet/appService.bicep' = {
  name: 'module-demo5-webapps-vnet-appServiceFrontend'
  params: {
    location: location
    tags: tags

    name: 'app-azh-demo5-webapps-vnet-frontend-${suffix}'
    appServicePlanId: appServicePlan.outputs.id
    managedIdentity: managedIdentity
    acrLoginServer: acrLoginServer
    containerImage: 'daniellindemann/beer-rating-frontend:9.0.0'
    appSettings: {
      WEBSITES_PORT: '5179'
      Backend__HostUrl: appServiceBackend.outputs.url
      WEBSITE_HTTPLOGGING_RETENTION_DAYS: '3'
      APPLICATIONINSIGHTS_CONNECTION_STRING: applicationInsights.outputs.connectionString
      ApplicationInsightsAgent_EXTENSION_VERSION: '~3'
      XDT_MicrosoftApplicationInsights_Mode: 'Recommended'
    }
    // network
    subnetIdAzureWebsitesOutbound: subnetIdAzureWebsitesOutbound
  }
}
