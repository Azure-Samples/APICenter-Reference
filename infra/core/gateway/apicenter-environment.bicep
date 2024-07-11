metadata description = 'Creates an environment on Azure API Center.'
// param name string
// param location string
// param tags object

param apiCenterName string
param apiCenterWorkspaceName string
param apiCenterEnvironmentName string
param apiCenterEnvironmentTitle string
@allowed([
  'development'
  'testing'
  'staging'
  'production'
])
param apiCenterEnvironmentKind string
@allowed([
  'Azure App Service'
  'Azure Container Apps'
  'Azure Functions'
  'Azure Compute Service'
  'Azure API Management'
  'AWS API Gateway'
  'Apigee API Management'
  'Kong API Gateway'
  'MuleSoft API Management'
  'Kubernetes'
])
param apiCenterEnvironmentServerType string

// Create an API Center service
resource apic 'Microsoft.ApiCenter/services@2024-03-15-preview' existing = {
  name: apiCenterName
}

// Create an API Center workspace
resource apicWorkspace 'Microsoft.ApiCenter/services/workspaces@2024-03-15-preview' existing = {
  name: apiCenterWorkspaceName
  parent: apic
}

// Create an environment on API Center
resource apicEnvironment 'Microsoft.ApiCenter/services/workspaces/environments@2024-03-15-preview' = {
  name: apiCenterEnvironmentName
  parent: apicWorkspace
  properties: {
    title: apiCenterEnvironmentTitle
    kind: apiCenterEnvironmentKind
    server: {
      type: apiCenterEnvironmentServerType
    }
  }
}
