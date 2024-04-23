metadata description = 'Creates a role assignment for a service principal to API Center in API Management.'
// param name string
// param location string
// param tags object

param apiManagementName string

@allowed([
  'Device'
  'ForeignGroup'
  'Group'
  'ServicePrincipal'
  'User'
])
param principalType string = 'ServicePrincipal'
param principalId string
param roleDefinitions array = [
  {
    id: '71522526-b88f-4d52-b57f-d31fc3546d0d'
    name: 'API Management Service Reader Role'
  }
]

resource apimService 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: apiManagementName
}

resource roles 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for roleDefinition in roleDefinitions: {
  name: guid(subscription().id, resourceGroup().id, principalId, roleDefinition.id)
  scope: apimService
  properties: {
    principalId: principalId
    principalType: principalType
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleDefinition.id)
  }
}]
