import { managedIdentityReference } from '../types/managedIdentityReference.bicep'

param location string
param tags object
param suffix string

param managedIdentity managedIdentityReference
param acrLoginServer string
param connectionStringKeyVaultUri string

module applicationInsights 'demo1-webapps/applicationInsights.bicep' = {
  name: 'module-demo1-webapps-applicationInsights'
  params: {
    location: location
    tags: tags
    suffix: suffix
  }
}

module appServicePlan 'demo1-webapps/appServicePlan.bicep' = {
  name: 'module-demo1-webapps-plan'
  params: {
    location: location
    tags: tags
    suffix: suffix
  }
}

module appServiceBackend 'demo1-webapps/appServiceSiteContainers.bicep' = {
  name: 'module-demo1-webapps-appServiceBackend'
  params: {
    location: location
    tags: tags

    name: 'app-azh-demo1-webapps-backend-${suffix}'
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
  }
}

module appServiceFrontend 'demo1-webapps/appService.bicep' = {
  name: 'module-demo1-webapps-appServiceFrontend'
  params: {
    location: location
    tags: tags

    name: 'app-azh-demo1-webapps-frontend-${suffix}'
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
  }
}
