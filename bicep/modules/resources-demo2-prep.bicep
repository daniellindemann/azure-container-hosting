targetScope = 'subscription'

import { managedIdentityReference } from '../types/managedIdentityReference.bicep'

param location string
param tags object
param suffix string

param rgDemo2CiName string
param rgSharedName string

param acrName string
param keyVaultName string

resource rgDemo2Ci 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
    name: rgDemo2CiName
}

resource rgShared 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
    name: rgSharedName
}

module managedIdentityDemo2Ci 'demo2-ci/idCi.bicep' = {
    name: 'module-demo2-ci-idCi'
    scope: rgDemo2Ci
    params: {
        location: location
        tags: tags
        suffix: suffix
    }
}

module roleAssignmentsDemo2Ci 'demo2-ci/roleAssignments.bicep' = {
    name: 'module-demo2-ci-roleAssignments'
    scope: rgShared
    params: {
        acrName: acrName
        keyVaultName: keyVaultName
        managedIdentityManagementPrincipalId: managedIdentityDemo2Ci.outputs.principalId
    }
}

output managedIdentityCi managedIdentityReference = {
  id: managedIdentityDemo2Ci.outputs.id
  clientId: managedIdentityDemo2Ci.outputs.clientId
}
