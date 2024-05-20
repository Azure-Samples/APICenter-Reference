metadata description = 'Creates an Azure API Center instance.'
param name string
param location string
param tags object

param workspaceName string = 'default'
param skuName string = 'Free'

// Create an API center service
resource apiCenter 'Microsoft.ApiCenter/services@2024-03-15-preview' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: skuName
  }
  identity: {
    type: 'SystemAssigned'
  }
}

resource apiCenterWorkspace 'Microsoft.ApiCenter/services/workspaces@2024-03-15-preview' = {
  name: workspaceName
  parent: apiCenter
  properties: {
    title: 'Default workspace'
    description: 'Default workspace'
  }
}

output id string = apiCenter.id
output name string = apiCenter.name
output location string = apiCenter.location
output workspaceName string = apiCenterWorkspace.name
output identityPrincipalId string = apiCenter.identity.principalId
