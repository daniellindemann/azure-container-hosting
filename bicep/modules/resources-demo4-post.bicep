targetScope = 'subscription'

param rgSharedName string

param acrName string
param keyVaultName string
param managedIdentityKubeletPrincipalId string
#disable-next-line secure-secrets-in-params
param managedIdentityKeyVaultSecretsProviderPrincipalId string

resource rgShared 'Microsoft.Resources/resourceGroups@2025-04-01' existing = {
    name: rgSharedName
}

module roleAssignmentsDemo4AksPost 'demo4-aks/roleAssignments.bicep' = {
    name: 'module-demo4-aks-roleAssignments'
    scope: rgShared
    params: {
        acrName: acrName
        keyVaultName: keyVaultName
        managedIdentityKubeletPrincipalId: managedIdentityKubeletPrincipalId
        managedIdentityKeyVaultSecretsProviderPrincipalId: managedIdentityKeyVaultSecretsProviderPrincipalId
    }
}
