metadata description = 'Creates an Azure API Center instance.'
// param name string
// param location string
// param tags object

param apiCenterName string
param apiCenterMetadataSchemaName string
param apiCenterMetadataSchemaAssignedTo array
param apiCenterMetadataSchema string

// Create an API center service
resource apiCenter 'Microsoft.ApiCenter/services@2024-03-01' existing = {
  name: apiCenterName
}

resource apiCenterMetadata 'Microsoft.ApiCenter/services/metadataSchemas@2024-03-01' = {
  name: apiCenterMetadataSchemaName
  parent: apiCenter
  properties: {
    schema: apiCenterMetadataSchema
    assignedTo: apiCenterMetadataSchemaAssignedTo
  }
}

output name string = apiCenterMetadata.name
output id string = apiCenterMetadata.id
