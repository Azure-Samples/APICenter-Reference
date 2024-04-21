metadata description = 'Creates an Event Grid System Topic and Subscription instance.'
// param name string
param location string
param tags object = {}

param apiCenterName string

param eventGridTopicName string
param eventGridTopicSubscriptionName string

param logicAppName string

resource apiCenter 'Microsoft.ApiCenter/services@2024-03-01' existing = {
  name: apiCenterName
}

resource eventgridTopic 'Microsoft.EventGrid/systemTopics@2023-12-15-preview' = {
  name: eventGridTopicName
  location: location
  tags: tags
  properties: {
    source: apiCenter.id
    topicType: 'microsoft.apicenter.services'
  }
}

resource logicApp 'Microsoft.Logic/workflows@2019-05-01' existing = {
  name: logicAppName
}

resource eventgridTopicSubscription 'Microsoft.EventGrid/systemTopics/eventSubscriptions@2023-12-15-preview' = {
  name: eventGridTopicSubscriptionName
  parent: eventgridTopic
  properties: {
    destination: {
      endpointType: 'WebHook'
      properties: {
        endpointUrl: listCallbackUrl('${logicApp.id}/triggers/OnEventReceived', '2019-05-01').value
      }
    }
    eventDeliverySchema: 'EventGridSchema'
    filter: {
      includedEventTypes: [
        'Microsoft.ApiCenter.AnalysisResultsUpdated'
      ]
    }
    labels: []
  }
}
