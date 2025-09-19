param location string
param tags object
param suffix string

param sqlAdminUsername string
@secure()
param sqlAdminPassword string

module privateDnsAzureWebsites 'shared/privateDnsAzureWebsites.bicep' = {
    name: 'module-shared-privateDnsAzureWebsites'
    params: {
        tags: tags
    }
}

module acr 'shared/acr.bicep' = {
    name: 'module-shared-acr'
    params: {
        location: location
        tags: tags
        suffix: suffix
    }
}

module keyVault 'shared/keyVault.bicep' = {
    name: 'module-shared-keyVault'
    params: {
        location: location
        tags: tags
        suffix: suffix
    }
}

module sql 'shared/sql.bicep' = {
    name: 'module-shared-sql'
    params: {
        location: location
        tags: tags
        suffix: suffix

        sqlAdminUsername: sqlAdminUsername
        sqlAdminPassword: sqlAdminPassword

        keyVaultName: keyVault.outputs.name
    }
}

module roleAssignments 'shared/roleAssignments.bicep' = {
    name: 'module-shared-roleAssignments'
    params: {
        keyVaultName: keyVault.outputs.name
    }
}

output acrName string = acr.outputs.name
output acrLoginServer string = acr.outputs.loginServer
output keyVaultName string = keyVault.outputs.name
output keyVaultConnectionStringSecretUri string = sql.outputs.sqlConnectionStringSecretUri
output privateDnsZoneWebsitesName string = privateDnsAzureWebsites.outputs.privateDnsZoneWebsitesName
output privateDnsZoneWebsitesId string = privateDnsAzureWebsites.outputs.privateDnsZoneWebsitesId
