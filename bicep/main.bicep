targetScope = 'subscription'

param location string = deployment().location
param tags object = {}

@minValue(3)
@maxValue(13)
param suffixLength int = 8

param skipDemo1WebApps bool = false
param skipDemo2ContainerInstances bool = false
param skipDemo3ContainerApps bool = false
param skipDemo4Aks bool = false
param skipDemo5Vnet bool = false

param sqlAdminUsername string = 'sqladmin'
@secure()
param sqlAdminPassword string = 'P@ssw0rd1234!'

param aksEntraAdminGroupObjectIds string

var suffix = substring(uniqueString(subscription().id), 0, suffixLength)
var allTags = union({
    environment: 'demo'
    project: 'azure-container-hosting'
    deployer: deployer().userPrincipalName
}, tags)
var aksShutdownTags = {
    'auto-aks-start-at-utc': '05:00' // 05:00 UTC = 06:00 CET = 07:00 CEST
    'auto-aks-stop-at-utc': '17:00' // 17:00 UTC = 18:00 CET = 19:00 CEST
    'auto-aks-days': 'Mon,Tue,Wed,Thu,Fri,Sat,Sun'
}

//
// Shared
//

resource rgShared 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: 'rg-azh-shared-${suffix}'
  location: location
  tags: allTags
}

module sharedResources 'modules/resources-shared.bicep' = {
    name: 'resources-shared'
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

resource rgDemo1WebApps 'Microsoft.Resources/resourceGroups@2025-04-01' = if(!skipDemo1WebApps) {
    name: 'rg-azh-demo1-webapps-${suffix}'
    location: location
    tags: allTags
}

module demo1WebAppsPrep 'modules/resources-demo1-prep.bicep' = if(!skipDemo1WebApps) {
    name: 'resources-demo1-webapps-prep'
    params: {
        location: location
        tags: allTags
        suffix: suffix

        rgDemo1WebAppsName: rgDemo1WebApps.name
        rgSharedName: rgShared.name

        acrName: sharedResources.outputs.acrName
        keyVaultName: sharedResources.outputs.keyVaultName
    }
}

module demo1WebAppsResources 'modules/resources-demo1-webapps.bicep' = if(!skipDemo1WebApps) {
    name: 'resources-demo1-webapps'
    scope: rgDemo1WebApps
    params: {
        location: location
        tags: allTags
        suffix: suffix

        managedIdentity: demo1WebAppsPrep!.outputs.managedIdentityWebApp
        acrLoginServer: sharedResources.outputs.acrLoginServer
        connectionStringKeyVaultUri: sharedResources.outputs.keyVaultConnectionStringSecretUri
    }
}

//
// Demo 2 - Container Instances
//

resource rgDemo2ContainerInstances 'Microsoft.Resources/resourceGroups@2025-04-01' = if(!skipDemo2ContainerInstances) {
    name: 'rg-azh-demo2-ci-${suffix}'
    location: location
    tags: allTags
}

module demo2CiPrep 'modules/resources-demo2-prep.bicep' = if(!skipDemo2ContainerInstances) {
    name: 'resources-demo2-ci-prep'
    params: {
        location: location
        tags: allTags
        suffix: suffix

        rgDemo2CiName: rgDemo2ContainerInstances.name
        rgSharedName: rgShared.name

        acrName: sharedResources.outputs.acrName
        keyVaultName: sharedResources.outputs.keyVaultName
    }
}

module demo2CiResources 'modules/resources-demo2-ci.bicep' = if(!skipDemo2ContainerInstances) {
    name: 'resources-demo2-ci'
    scope: rgDemo2ContainerInstances
    params: {
        location: location
        tags: allTags
        suffix: suffix

        managedIdentity: demo2CiPrep!.outputs.managedIdentityCi
        acrLoginServer: sharedResources.outputs.acrLoginServer
        connectionStringKeyVaultUri: sharedResources.outputs.keyVaultConnectionStringSecretUri
    }
}

//
// Demo 3 - Azure Container Apps
//

resource rgDemo3ContainerApps 'Microsoft.Resources/resourceGroups@2025-04-01' = if(!skipDemo3ContainerApps) {
    name: 'rg-azh-demo3-aca-${suffix}'
    location: location
    tags: allTags
}

module demo3AcaPrep 'modules/resources-demo3-prep.bicep' = if(!skipDemo3ContainerApps) {
    name: 'resources-demo3-aca-prep'
    params: {
        location: location
        tags: allTags
        suffix: suffix

        rgDemo3AcaName: rgDemo3ContainerApps.name
        rgSharedName: rgShared.name

        acrName: sharedResources.outputs.acrName
        keyVaultName: sharedResources.outputs.keyVaultName
    }
}

module demo3AcaResources 'modules/resources-demo3-aca.bicep' = if(!skipDemo3ContainerApps) {
    name: 'resources-demo3-aca'
    scope: rgDemo3ContainerApps
    params: {
        location: location
        tags: allTags
        suffix: suffix

        managedIdentity: demo3AcaPrep!.outputs.managedIdentityCi
        acrLoginServer: sharedResources.outputs.acrLoginServer
        connectionStringKeyVaultUri: sharedResources.outputs.keyVaultConnectionStringSecretUri
    }
}

//
// Demo 4 - AKS
//

resource rgDemo4Aks 'Microsoft.Resources/resourceGroups@2025-04-01' = if(!skipDemo4Aks) {
    name: 'rg-azh-demo4-aks-${suffix}'
    location: location
    tags: allTags
}

module demo4AksResources 'modules/resources-demo4-aks.bicep' = if(!skipDemo4Aks) {
    name: 'resources-demo4-aks'
    scope: rgDemo4Aks
    params: {
        location: location
        tags: union(allTags, aksShutdownTags)
        suffix: suffix

        aksEntraAdminGroupObjectIds: aksEntraAdminGroupObjectIds
    }
}

module demo4AksPost 'modules/resources-demo4-post.bicep' = if(!skipDemo4Aks) {
    name: 'resources-demo4-aks-post'
    params: {
        rgSharedName: rgShared.name

        acrName: sharedResources.outputs.acrName
        keyVaultName: sharedResources.outputs.keyVaultName
        managedIdentityKubeletPrincipalId: demo4AksResources!.outputs.kubeletObjectId
        managedIdentityKeyVaultSecretsProviderPrincipalId: demo4AksResources!.outputs.azureKeyVaultSecretsProviderIdentityObjectId
    }
}

//
// Demo 5 - Web Apps in VNet
//

resource rgDemo5WebAppsVnet 'Microsoft.Resources/resourceGroups@2025-04-01' = if(!skipDemo5Vnet) {
    name: 'rg-azh-demo5-webapps-vnet-${suffix}'
    location: location
    tags: allTags
}

module demo5WebAppsVnetPrep 'modules/resources-demo5-prep.bicep' = if(!skipDemo5Vnet) {
    name: 'resources-demo5-webapps-vnet-prep'
    params: {
        location: location
        tags: allTags
        suffix: suffix

        rgDemo5WebAppsVnetName: rgDemo5WebAppsVnet.name
        rgSharedName: rgShared.name

        acrName: sharedResources.outputs.acrName
        keyVaultName: sharedResources.outputs.keyVaultName
        privateDnsZoneWebsitesName: sharedResources.outputs.privateDnsZoneWebsitesName
    }
}

module demo5WebAppsVnetResources 'modules/resources-demo5-webapps-vnet.bicep' = if(!skipDemo5Vnet) {
    name: 'resources-demo5-webapps-vnet'
    scope: rgDemo5WebAppsVnet
    params: {
        location: location
        tags: allTags
        suffix: suffix

        managedIdentity: demo5WebAppsVnetPrep!.outputs.managedIdentityWebApp
        acrLoginServer: sharedResources.outputs.acrLoginServer
        connectionStringKeyVaultUri: sharedResources.outputs.keyVaultConnectionStringSecretUri

        privateDnsZoneWebsitesId: sharedResources.outputs.privateDnsZoneWebsitesId
        subnetIdAzureWebsitesInbound: demo5WebAppsVnetPrep!.outputs.subnetIdAzureWebsitesInbound
        subnetIdAzureWebsitesOutbound: demo5WebAppsVnetPrep!.outputs.subnetIdAzureWebsitesOutbound
    }
}
