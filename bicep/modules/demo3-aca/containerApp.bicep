import { managedIdentityReference } from '../../types/managedIdentityReference.bicep'

param location string
param tags object

param name string
param managedIdentity managedIdentityReference
param acrLoginServer string
param containerImageMain string
param containerPortMain int
param environmentVariables object = {}

param environmentId string
@allowed(['external', 'internal'])
param ingress string

var environmentVariablesArray = [
  for item in items(environmentVariables): {
    name: item.key
    value: item.value
  }
]

resource containerApp 'Microsoft.App/containerApps@2025-01-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${managedIdentity.id}': {}
    }
  }
  properties: {
    environmentId: environmentId
    configuration: {
      activeRevisionsMode: 'Single'
      maxInactiveRevisions: 100
      registries: [
        {
          server: acrLoginServer
          identity: managedIdentity.id
        }
      ]
      ingress: {
        external: ingress == 'external' ? true : false
        targetPort: containerPortMain
        transport: 'auto'
        allowInsecure: false
        stickySessions: {
          affinity: 'none'
        }
        traffic: [
          {
            latestRevision: true
            weight: 100
          }
        ]
      }
    }
    template: {
      containers: [
        {
          name: 'main'
          image: '${acrLoginServer}/${containerImageMain}'
          env: environmentVariablesArray
          resources: {
            cpu: json('0.25')
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 2
        cooldownPeriod: 300 // default is 300 seconds
        pollingInterval: 30 // default is 30 seconds
      }
    }
  }
}
