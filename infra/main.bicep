targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

// Limited to the following locations due to the availability of API Center
@minLength(1)
@description('Primary location for all resources')
@allowed([
  'australiaeast'
  'centralindia'
  'eastus'
  'uksouth'
  'westeurope'
])
@metadata({
  azd: {
    type: 'location'
  }
})
param location string

param resourceGroupName string = ''

param apiCenterName string = '' // Set in main.parameters.json
// Set API Center location the same location as the main location
var apiCenterLocation = location

param logicAppsName string = '' // Set in main.parameters.json

param eventGridTopicName string = '' // Set in main.parameters.json

@description('Use Application Insights for monitoring and performance tracing')
param useApplicationInsights bool = false // Set in main.parameters.json

param logAnalyticsName string = '' // Set in main.parameters.json
param applicationInsightsName string = '' // Set in main.parameters.json
param applicationInsightsDashboardName string = '' // Set in main.parameters.json
param diagnosticsSettingsName string = ''

param appServicePlanName string = '' // Set in main.parameters.json
param appServiceSkuName string // Set in main.parameters.json
param appServiceNodeName string = '' // Set in main.parameters.json
param appServiceDotNetName string = '' // Set in main.parameters.json

// Limited to the following locations due to the availability of Static Web Apps
@minLength(1)
@description('Location for Static Web Apps')
@allowed([
  'centralus'
  'eastasia'
  'eastus2'
  'westeurope'
  'westus2'
])
@metadata({
  azd: {
    type: 'location'
  }
})
param staticAppLocation string
param staticAppSkuName string // Set in main.parameters.json
param staticAppNodeName string = '' // Set in main.parameters.json
param staticAppDotNetName string = '' // Set in main.parameters.json

param apiManagementName string = '' // Set in main.parameters.json
param apiManagementPublisherName string // Set in main.parameters.json
param apiManagementPublisherEmail string // Set in main.parameters.json

param apimProductName string // Set in main.parameters.json
param apimProductDisplayName string // Set in main.parameters.json
param apimProductDescription string // Set in main.parameters.json
param apimProductSubscriptionName string // Set in main.parameters.json
param apimProductSubscriptionDisplayName string // Set in main.parameters.json

var abbrs = loadJsonContent('./abbreviations.json')

// tags that should be applied to all resources.
var tags = {
  // Tag all resources with the environment name.
  'azd-env-name': environmentName
}

// Generate a unique token to be used in naming resources.
// Remove linter suppression after using.
#disable-next-line no-unused-vars
var resourceToken = toLower(uniqueString(subscription().id, environmentName, location))

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2022-09-01' = {
  name: !empty(resourceGroupName) ? resourceGroupName : '${abbrs.resourcesResourceGroups}${environmentName}'
  location: location
  tags: tags
}

// Provision API Center
module apiCenter './core/gateway/apicenter.bicep' = {
  name: 'apicenter'
  scope: rg
  params: {
    name: !empty(apiCenterName) ? apiCenterName : 'apic-${resourceToken}'
    location: apiCenterLocation
    tags: tags
  }
}

var metadataSchema = [
  {
    name: 'repository-url'
    schema: '{ "type": "string", "title": "Repository URL", "description": "The URL that the API application source code is hosted", "format": "uri", "examples": [ "https://github.com/Azure/APICenter-Reference" ] }'
    assignedTo: [
      {
        entity: 'api'
        required: false
        deprecated: false
      }
    ]
  }
  {
    name: 'compliance-reviewed'
    schema: '{ "type":"string", "title": "Compliance Reviewed", "description": "Value indicating whether the compliance review has passed or not.", "pattern": "(reviewed|need-for-review)", "format": "regex", "examples": [ "reviewed", "need-for-review" ] }'
    assignedTo: [
      {
        entity: 'api'
        required: false
        deprecated: false
      }
    ]
  }
]

module apiCenterMetadata './core/gateway/apicenter-metadata.bicep' = [for metadata in metadataSchema: {
  name: 'apicenter-metadata-${metadata.name}'
  scope: rg
  params: {
    apiCenterName: apiCenter.outputs.name
    apiCenterMetadataSchemaName: metadata.name
    apiCenterMetadataSchema: metadata.schema
    apiCenterMetadataSchemaAssignedTo: metadata.assignedTo
  }
}]

var events = [
  {
    name: 'on-api-added-or-updated'
    subscribedEventTypes: [
      'Microsoft.ApiCenter.ApiAdded'
      'Microsoft.ApiCenter.ApiUpdated'
    ]
  }
  {
    name: 'on-api-version-added-or-updated'
    subscribedEventTypes: [
      'Microsoft.ApiCenter.ApiVersionAdded'
      'Microsoft.ApiCenter.ApiVersionUpdated'
    ]
  }
  {
    name: 'on-analysis-results-updated'
    subscribedEventTypes: [
      'Microsoft.ApiCenter.AnalysisResultsUpdated'
    ]
  }
]

// Provision Logic Apps
module logicApps './core/integration/logicapps.bicep' = [for event in events:{
  name: 'logicapps-${event.name}'
  scope: rg
  params: {
    name: !empty(logicAppsName) ? '${logicAppsName}-${event.name}' : '${abbrs.logicWorkflows}${resourceToken}-${event.name}'
    location: apiCenterLocation
    tags: tags
  }
}]

// Provision Event Grid Topic
module eventGridTopic './core/integration/eventgrid-topic.bicep' = {
  name: 'eventgrid-topic'
  scope: rg
  params: {
    location: apiCenterLocation
    tags: tags
    apiCenterName: apiCenter.outputs.name
    eventGridTopicName: !empty(eventGridTopicName) ? eventGridTopicName : 'evgt-${resourceToken}'
  }
}

// Provision Event Grid Subscription
module eventGridSubscriptions './core/integration/eventgrid-subscription.bicep' = [for event in events:{
  name: 'eventgrid-subscription-${event.name}'
  scope: rg
  dependsOn: [
    logicApps
  ]
  params: {
    eventGridTopicName: eventGridTopic.outputs.name
    eventGridTopicSubscriptionName: event.name
    eventGridTopicSubscriptionIncludedEventTypes: event.subscribedEventTypes
    logicAppName: !empty(logicAppsName) ? '${logicAppsName}-${event.name}' : '${abbrs.logicWorkflows}${resourceToken}-${event.name}'
  }
}]

// Provision monitoring resource with Azure Monitor
module monitoring './core/monitor/monitoring.bicep' = if (useApplicationInsights) {
  name: 'monitoring'
  scope: rg
  params: {
    location: location
    tags: tags
    logAnalyticsName: !empty(logAnalyticsName) ? logAnalyticsName : '${abbrs.operationalInsightsWorkspaces}${resourceToken}'
    applicationInsightsName: !empty(applicationInsightsName) ? applicationInsightsName : '${abbrs.insightsComponents}${resourceToken}'
    applicationInsightsDashboardName: !empty(applicationInsightsDashboardName) ? applicationInsightsDashboardName : '${abbrs.portalDashboards}${resourceToken}'
  }
}

// Provision an App Service Plan to group applications under the same payment plan and SKU
module appServicePlan 'core/host/appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: rg
  params: {
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}-reference'
    location: location
    tags: tags
    sku: {
      name: appServiceSkuName
      capacity: 1
    }
    kind: 'app'
    reserved: false
  }
}

var apps = [
  {
    name: 'node'
    webInstanceName: appServiceNodeName
    staticInstanceName: staticAppNodeName
    runtimeName: 'node'
    runtimeVersion: '18-lts'
  }
  {
    name: 'dotnet'
    webInstanceName: appServiceDotNetName
    staticInstanceName: staticAppDotNetName
    runtimeName: 'dotnetcore'
    runtimeVersion: '8.0'
  }
]

// Provision App Services for each application
module appServices './core/host/appservice.bicep' = [for app in apps: {
  name: 'appservice-${app.name}'
  scope: rg
  params: {
    name: !empty(app.webInstanceName) ? app.webInstanceName : '${abbrs.webSitesAppService}${resourceToken}-${app.name}-reference'
    location: location
    tags: union(tags, { 'azd-service-name': 'appservice-${app.name}' })
    kind: 'api'
    appServicePlanId: appServicePlan.outputs.id
    runtimeName: app.runtimeName
    runtimeVersion: app.runtimeVersion
    managedIdentity: true
    use32BitWorkerProcess: appServiceSkuName == 'F1'
    alwaysOn: appServiceSkuName != 'F1'
    appSettings: {
      APPLICATIONINSIGHTS_CONNECTION_STRING: useApplicationInsights ? monitoring.outputs.applicationInsightsConnectionString : ''
    }
  }
}]

// Integrate Diagnostics settings
module diagnostics './core/monitor/appservice-diagnosticsettings.bicep' = [for (app, i) in apps: if (useApplicationInsights) {
  name: 'diagnostics-${app.name}'
  scope: rg
  params: {
    name: !empty(diagnosticsSettingsName) ? '${diagnosticsSettingsName}-${app.name}' : 'diag-${resourceToken}-${app.name}'
    logAnalyticsName: monitoring.outputs.logAnalyticsWorkspaceName
    appServiceName: appServices[i].outputs.name
    kind: 'appservice'
  }
}]

// Provision Static Web Apps for each application
module staticApps './core/host/staticwebapp.bicep' = [for app in apps: {
  name: 'staticapp-${app.name}'
  scope: rg
  params: {
    name: !empty(app.staticInstanceName) ? app.staticInstanceName : '${abbrs.webStaticSites}${resourceToken}-${app.name}-reference'
    location: staticAppLocation
    tags: union(tags, { 'azd-service-name': 'staticapp-${app.name}' })
    sku: {
      name: staticAppSkuName
      tier: staticAppSkuName
    }
  }
}]

var apicEnvironments = [
  {
    name: 'azure-container-apps-development'
    displayName: 'Azure Container Apps: Development'
    kind: 'development'
    serverType: 'Azure Container Apps'
  }
  {
    name: 'azure-kubernetes-service-testing'
    displayName: 'Azure Kubernetes Service: Testing'
    kind: 'testing'
    serverType: 'Kubernetes'
  }
  {
    name: 'azure-app-service-production'
    displayName: 'Azure App Service: Production'
    kind: 'production'
    serverType: 'Azure App Service'
  }
]

module apiCenterEnvironments './core/gateway/apicenter-environment.bicep' = [for env in apicEnvironments: {
  name: 'apicenter-environment-${env.name}'
  scope: rg
  params: {
    apiCenterName: apiCenter.outputs.name
    apiCenterWorkspaceName: apiCenter.outputs.workspaceName
    apiCenterEnvironmentName: env.name
    apiCenterEnvironmentTitle: env.displayName
    apiCenterEnvironmentKind: env.kind
    apiCenterEnvironmentServerType: env.serverType
  }
}]

var apis = [
  {
    name: 'pet-store-api'
    kind: 'rest'
    displayName: 'Pet Store API'
    description: 'This is a sample Pet Store Server based on the OpenAPI 3.0 specification.'
    deployment: {
      name: 'development'
      title: 'Development'
      environment: 'azure-container-apps-development'
      runtimeUri: 'https://api.contoso.com'
    }
    version: {
      name: '1-0-11'
      title: '1.0.11'
      lifecycleStage: 'development'
    }
    definition: {
      name: 'pet-store-api'
      title: 'Pet Store API'
      description: 'This is a sample Pet Store Server based on the OpenAPI 3.0 specification.'
    }
  }
  {
    name: 'star-wars-api'
    kind: 'graphql'
    displayName: 'Star Wars API'
    description: 'This GraphQL API retrieves all the Star Wars data you\'ve ever wanted: Planets, Spaceships, Vehicles, People, Films and Species from all seven Star Wars films.'
    deployment: {
      name: 'uat'
      title: 'UAT'
      environment: 'azure-kubernetes-service-testing'
      runtimeUri: 'https://graphql.contoso.com'
    }
    version: {
      name: '1-0-0'
      title: '1.0.0'
      lifecycleStage: 'testing'
    }
    definition: {
      name: 'star-wars-api'
      title: 'Star Wars API'
      description: 'This GraphQL API retrieves all the Star Wars data you\'ve ever wanted: Planets, Spaceships, Vehicles, People, Films and Species from all seven Star Wars films.'
    }
  }
  {
    name: 'global-weather-api'
    kind: 'soap'
    displayName: 'Global Weather API'
    description: 'This API gets weather report for all major cities around the world.'
    deployment: {
      name: 'production-apac'
      title: 'Production: APAC'
      environment: 'azure-app-service-production'
      runtimeUri: 'https://soap.contoso.com'
    }
    version: {
      name: '1-0-0'
      title: '1.0.0'
      lifecycleStage: 'production'
    }
    definition: {
      name: 'global-weather-api'
      title: 'Global Weather API'
      description: 'This API gets weather report for all major cities around the world.'
    }
  }
  {
    name: 'uspto-api'
    kind: 'apim'
    displayName: 'USPTO API'
    description: 'The Data Set API is accessible via https and http'
    serviceUrl: 'https://developer.uspto.gov/ds-api'
    path: 'uspto'
    subscriptionRequired: true
    format: 'openapi'
    value: loadTextContent('./apis/uspto.yaml')
  }
]

// Provision APIs on API Center
module apiCenterApis './core/gateway/apicenter-api.bicep' = [for api in apis: {
  name: 'apicenter-api-${api.name}'
  scope: rg
  dependsOn: [
    apiCenterEnvironments
  ]
  params: {
    apiCenterName: apiCenter.outputs.name
    apiCenterWorkspaceName: apiCenter.outputs.workspaceName
    apiCenterApis: filter(apis, api => api.kind != 'apim')
  }
}]

// Provision API Management
module apiManagement './core/gateway/apim.bicep' = {
  name: 'apim'
  scope: rg
  params: {
    name: !empty(apiManagementName) ? apiManagementName : '${abbrs.apiManagementService}${resourceToken}'
    location: location
    tags: tags
    publisherName: apiManagementPublisherName
    publisherEmail: apiManagementPublisherEmail
    applicationInsightsName: useApplicationInsights ? monitoring.outputs.applicationInsightsName : ''
    productName: apimProductName
    productDisplayName: apimProductDisplayName
    productDescription: apimProductDescription
    productSubscriptionName: apimProductSubscriptionName
    productSubscriptionDisplayName: apimProductSubscriptionDisplayName
    apis: filter(apis, api => api.kind == 'apim')
  }
}

var roleDefinitions = [
  {
    id: '71522526-b88f-4d52-b57f-d31fc3546d0d'
    name: 'API Management Service Reader Role'
  }
]

// Assign roles to the API Management service
module apiManagementRoleAssignments './core/security/apim-role.bicep' = [for role in roleDefinitions: {
  name: 'apim-role-assignment-${replace(toLower(role.name), ' ', '')}'
  scope: rg
  params: {
    apiManagementName: apiManagement.outputs.name
    principalType: 'ServicePrincipal'
    principalId: apiCenter.outputs.identityPrincipalId
    roleDefinitions: roleDefinitions
  }
}]

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId

output AZURE_API_CENTER string = apiCenter.outputs.name
output AZURE_API_CENTER_LOCATION string = apiCenter.outputs.location

output AZURE_APP_SERVICE_LOCATION string = appServices[0].outputs.location
output AZURE_APP_SERVICE_NODE string = appServices[0].outputs.name
output AZURE_APP_SERVICE_NODE_URL string = appServices[0].outputs.uri
output AZURE_APP_SERVICE_DOTNET string = appServices[1].outputs.name
output AZURE_APP_SERVICE_DOTNET_URL string = appServices[1].outputs.uri

output AZURE_STATIC_APP_LOCATION string = staticApps[0].outputs.location
output AZURE_STATIC_APP_NODE string = staticApps[0].outputs.name
output AZURE_STATIC_APP_NODE_URL string = staticApps[0].outputs.uri
output AZURE_STATIC_APP_DOTNET string = staticApps[1].outputs.name
output AZURE_STATIC_APP_DOTNET_URL string = staticApps[1].outputs.uri

output AZURE_API_MANAGEMENT string = apiManagement.outputs.name
