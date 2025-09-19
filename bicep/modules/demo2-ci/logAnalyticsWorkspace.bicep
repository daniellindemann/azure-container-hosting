param location string
param tags object
param suffix string

@description('Daily cap in GB. Set to `-1` to disable the daily cap.')
param dailyCapQuotaInGb int = 3

resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: 'log-azh-demo2-ci-${suffix}'
  location: location
  tags: tags
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    workspaceCapping: {
      dailyQuotaGb: dailyCapQuotaInGb
    }
  }
}

output id string = logAnalyticsWorkspace.id
output name string = logAnalyticsWorkspace.name
output workspaceId string = logAnalyticsWorkspace.properties.customerId
