targetScope = 'subscription'

@minLength(1)
@maxLength(64)
@description('Name of the the environment which is used to generate a short unique hash used in all resources.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

param resourceGroupName string = ''

// Limited to the following locations due to the availability of API Center
param apiCenterName string = '' // Set in main.parameters.json
@minLength(1)
@description('Location for API Center')
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
param apiCenterLocation string

@description('Use Application Insights for monitoring and performance tracing')
param useApplicationInsights bool = false // Set in main.parameters.json

param logAnalyticsName string = '' // Set in main.parameters.json
param applicationInsightsName string = '' // Set in main.parameters.json
param applicationInsightsDashboardName string = '' // Set in main.parameters.json

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
    name: !empty(appServicePlanName) ? appServicePlanName : '${abbrs.webServerFarms}${resourceToken}'
    location: location
    tags: tags
    sku: {
      name: appServiceSkuName
      capacity: 1
    }
    kind: 'linux'
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
    name: !empty(app.webInstanceName) ? app.webInstanceName : '${abbrs.webSitesAppService}${resourceToken}-${app.name}'
    location: location
    tags: union(tags, { 'azd-service-name': 'appservice-${app.name}' })
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

// Provision Static Web Apps for each application
module staticApps './core/host/staticwebapp.bicep' = [for app in apps: {
  name: 'staticapp-${app.name}'
  scope: rg
  params: {
    name: !empty(app.staticInstanceName) ? app.staticInstanceName : '${abbrs.webStaticSites}${resourceToken}-${app.name}'
    location: staticAppLocation
    tags: union(tags, { 'azd-service-name': 'staticapp-${app.name}' })
    sku: {
      name: staticAppSkuName
      tier: staticAppSkuName
    }
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
  }
}

output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId

output AZURE_API_CENTER string = apiCenter.outputs.name

output AZURE_APP_SERVICE_NODE string = appServices[0].outputs.name
output AZURE_APP_SERVICE_NODE_URL string = appServices[0].outputs.uri
output AZURE_APP_SERVICE_DOTNET string = appServices[1].outputs.name
output AZURE_APP_SERVICE_DOTNET_URL string = appServices[1].outputs.uri

output AZURE_STATIC_APP_NODE string = staticApps[0].outputs.name
output AZURE_STATIC_APP_NODE_URL string = staticApps[0].outputs.uri
output AZURE_STATIC_APP_DOTNET string = staticApps[1].outputs.name
output AZURE_STATIC_APP_DOTNET_URL string = staticApps[1].outputs.uri

output AZURE_API_MANAGEMENT string = apiManagement.outputs.apimServiceName
