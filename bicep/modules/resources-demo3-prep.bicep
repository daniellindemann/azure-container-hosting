targetScope = 'subscription'

import { managedIdentityReference } from '../types/managedIdentityReference.bicep'

param location string
param tags object
param suffix string

param rgDemo3AcaName string
param rgSharedName string

param acrName string
param keyVaultName string

resource rgDemo3Aca 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
    name: rgDemo3AcaName
}

resource rgShared 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
    name: rgSharedName
}

module managedIdentityDemo3Aca 'demo3-aca/idAca.bicep' = {
    name: 'module-demo3-aca-idAca'
    scope: rgDemo3Aca
    params: {
        location: location
        tags: tags
        suffix: suffix
    }
}

module roleAssignmentsDemo3Aca 'demo3-aca/roleAssignments.bicep' = {
    name: 'module-demo3-aca-roleAssignments'
    scope: rgShared
    params: {
        acrName: acrName
        keyVaultName: keyVaultName
        managedIdentityManagementPrincipalId: managedIdentityDemo3Aca.outputs.principalId
    }
}

output managedIdentityCi managedIdentityReference = {
  id: managedIdentityDemo3Aca.outputs.id
  clientId: managedIdentityDemo3Aca.outputs.clientId
}
