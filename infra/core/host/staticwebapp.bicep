metadata description = 'Creates an Azure Static Web Apps instance.'
param name string
param location string = resourceGroup().location
param tags object = {}

param sku object = {
  name: 'Free'
  tier: 'Free'
}

resource web 'Microsoft.Web/staticSites@2022-09-01' = {
  name: name
  location: location
  tags: tags
  sku: {
    name: sku.name
    tier: sku.tier
  }
  properties: {
    stagingEnvironmentPolicy: 'Enabled'
  }
  identity: sku.name == 'Standard' ? {
    type: 'SystemAssigned'
  } : null
}

output name string = web.name
output location string = replace(toLower(web.location), ' ', '')
output uri string = 'https://${web.properties.defaultHostname}'
