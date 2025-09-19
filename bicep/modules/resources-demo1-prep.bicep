targetScope = 'subscription'

import { managedIdentityReference } from '../types/managedIdentityReference.bicep'

param location string
param tags object
param suffix string

param rgDemo1WebAppsName string
param rgSharedName string

param acrName string
param keyVaultName string

resource rgDemo1WebApps 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
    name: rgDemo1WebAppsName
}

resource rgShared 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
    name: rgSharedName
}

module managedIdentityDemo1WebApp 'demo1-webapps/idWebApp.bicep' = {
    name: 'module-demo1-webapps-idWebApp'
    scope: rgDemo1WebApps
    params: {
        location: location
        tags: tags
        suffix: suffix
    }
}

module roleAssignmentsDemo1WebApp 'demo1-webapps/roleAssignments.bicep' = {
    name: 'module-demo1-webapps-roleAssignments'
    scope: rgShared
    params: {
        acrName: acrName
        keyVaultName: keyVaultName
        managedIdentityManagementPrincipalId: managedIdentityDemo1WebApp.outputs.principalId
    }
}

output managedIdentityWebApp managedIdentityReference = {
  id: managedIdentityDemo1WebApp.outputs.id
  clientId: managedIdentityDemo1WebApp.outputs.clientId
}
