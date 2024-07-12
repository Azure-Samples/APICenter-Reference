param name string
param location string = resourceGroup().location
param tags object = {}

param deploymentNameSuffix string
param identityName string
param applicationInsightsName string
param containerAppsEnvironmentName string
param containerRegistryName string
param containerRegistryHostSuffix string
param serviceName string = 'api'
param corsAcaUrl string
param exists bool
param targetPort int = 80

resource apiIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: identityName
  location: location
}

module app '../core/host/container-app-upsert.bicep' = {
  name: '${serviceName}-container-app-${deploymentNameSuffix}'
  params: {
    name: name
    location: location
    tags: union(tags, { 'azd-service-name': '${serviceName}-${name}' })
    identityType: 'UserAssigned'
    identityName: apiIdentity.name
    exists: exists
    containerAppsEnvironmentName: containerAppsEnvironmentName
    containerRegistryName: containerRegistryName
    containerRegistryHostSuffix: containerRegistryHostSuffix
    env: [
      {
        name: 'AZURE_CLIENT_ID'
        value: apiIdentity.properties.clientId
      }
      {
        name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
        value: applicationInsights.properties.ConnectionString
      }
      {
        name: 'API_ALLOW_ORIGINS'
        value: corsAcaUrl
      }
    ]
    targetPort: targetPort
  }
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02' existing = {
  name: applicationInsightsName
}

output SERVICE_API_IDENTITY_PRINCIPAL_ID string = apiIdentity.properties.principalId
output SERVICE_API_NAME string = app.outputs.name
output SERVICE_API_URI string = app.outputs.uri
output SERVICE_API_IMAGE_NAME string = app.outputs.imageName
