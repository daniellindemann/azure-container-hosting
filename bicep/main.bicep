targetScope = 'subscription'

param location string = deployment().location
param tags object = {}

param sqlAdminUsername string = 'sqladmin'
@secure()
param sqlAdminPassword string = 'P@ssw0rd1234!'

var suffix = uniqueString(subscription().id)
var allTags = union({
    demo: 'azure-container-hosting'
    deployer: deployer().userPrincipalName
}, tags)

//
// Shared
//

resource rgShared 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-azure-container-hosting-shared-${suffix}'
  location: location
  tags: allTags
}

module sharedResources 'modules/module-resources-shared.bicep' = {
    name: 'module-resources-shared'
    scope: rgShared
    params: {
        location: location
        tags: allTags
        suffix: suffix

        sqlAdminUsername: sqlAdminUsername
        sqlAdminPassword: sqlAdminPassword
    }
}

//
// Demo 1 - Web Apps
//

resource rgDemo1WebApps 'Microsoft.Resources/resourceGroups@2025-04-01' = {
    name: 'rg-azure-container-hosting-demo1-webapps-${suffix}'
    location: location
    tags: allTags
}

module demo1WebAppsResources 'modules/module-resources-demo1-webapps.bicep' = {
    name: 'module-resources-shared'
    scope: rgDemo1WebApps
    params: {
        location: location
        tags: allTags
        suffix: suffix
    }
}

output acr_name string = sharedResources.outputs.acr_name
output acr_loginServer string = sharedResources.outputs.acr_loginServer
