metadata description = 'Creates an API on Azure API Center.'
// param name string
// param location string
// param tags object

param apiCenterName string
param apiCenterWorkspaceName string
param apiCenterApis array = [
  {
    name: ''
    kind: 'apic'
    displayName: ''
    description: ''
    deployment: {
      name: ''
      title: ''
      environment: ''
      runtimeUri: ''
    }
    version: {
      name: ''
      title: ''
      lifecycleStage: ''
    }
    definition: {
      name: ''
      title: ''
      description: ''
      format: ''
      value: ''
    }
  }
]

// Create an API Center service
resource apic 'Microsoft.ApiCenter/services@2024-03-01' existing = {
  name: apiCenterName
}

// Create an API Center workspace
resource apicWorkspace 'Microsoft.ApiCenter/services/workspaces@2024-03-15-preview' existing = {
  name: apiCenterWorkspaceName
  parent: apic
}
  
// Create an API Center environment
resource apicEnvironments 'Microsoft.ApiCenter/services/workspaces/environments@2024-03-15-preview' existing = [for api in apiCenterApis: {
  name: api.deployment.environment
  parent: apicWorkspace
}]

// Create APIs on the API Center workspace
resource apicApis 'Microsoft.ApiCenter/services/workspaces/apis@2024-03-15-preview' = [for api in apiCenterApis: {
  name: '${api.name}'
  parent: apicWorkspace
  properties: {
    title: api.displayName
    description: api.description
    kind: api.kind
  }
}]

// Create API versions on the API Center workspace
resource apicApiVersions 'Microsoft.ApiCenter/services/workspaces/apis/versions@2024-03-15-preview' = [for (api, index) in apiCenterApis: {
  name: '${api.version.name}'
  parent: apicApis[index]
  properties: {
    title: api.version.title
    lifecycleStage: api.version.lifecycleStage
  }
}]

// Create API definitions on the API Center workspace
resource apicApiDefinitions 'Microsoft.ApiCenter/services/workspaces/apis/versions/definitions@2024-03-15-preview' = [for (api, index) in apiCenterApis: {
  name: '${api.definition.name}'
  parent: apicApiVersions[index]
  properties: {
    title: api.definition.title
    description: api.definition.description
  }
}]

// Create API deployments on the API Center workspace
resource apicApiDeployments 'Microsoft.ApiCenter/services/workspaces/apis/deployments@2024-03-15-preview' = [for (api, index) in apiCenterApis: {
  name: '${api.deployment.name}'
  parent: apicApis[index]
  properties: {
    title: api.deployment.title
    environmentId: '/workspaces/${apicWorkspace.name}/environments/${api.deployment.environment}'
    definitionId: '/workspaces/${apicWorkspace.name}/apis/${apicApis[index].name}/versions/${apicApiVersions[index].name}/definitions/${apicApiDefinitions[index].name}'
    server: {
      runtimeUri: [
        api.deployment.runtimeUri
      ]
    }
  }
}]
