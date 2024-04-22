metadata description = 'Creates an Event Grid Subscription instance.'
// param name string
// param location string
// param tags object = {}

param eventGridTopicName string
param eventGridTopicSubscriptionName string
param eventGridTopicSubscriptionIncludedEventTypes array = []

param logicAppName string

resource eventgridTopic 'Microsoft.EventGrid/systemTopics@2023-12-15-preview' existing = {
  name: eventGridTopicName
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
      includedEventTypes: eventGridTopicSubscriptionIncludedEventTypes
    }
    labels: []
  }
}
