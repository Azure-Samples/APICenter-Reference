metadata description = 'Creates an Event Grid System Topic instance.'
// param name string
param location string
param tags object = {}

param apiCenterName string

param eventGridTopicName string

resource apiCenter 'Microsoft.ApiCenter/services@2024-03-15-preview' existing = {
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

output name string = eventgridTopic.name
