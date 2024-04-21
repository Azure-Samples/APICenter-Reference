metadata description = 'Creates a Logic App instance.'
param name string
param location string
param tags object = {}

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' = {
  name: name
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    state: 'Enabled'
    parameters: {}
    definition: {
      '$schema': 'https://schema.management.azure.com/providers/Microsoft.Logic/schemas/2016-06-01/workflowdefinition.json#'
      contentVersion: '1.0.0.0'
      parameters: {}
      triggers: {
        OnEventReceived: {
          type: 'Request'
          kind: 'Http'
        }
      }
      actions: {
        GetEventDetails: {
          type: 'Compose'
          runAfter: {}
          inputs: '@triggerBody()'
        }
      }
      outputs: {}
    }
  }
}

output id string = logicApp.id
output name string = logicApp.name
