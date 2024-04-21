metadata description = 'Creates an Azure API Management product and subscription.'
param name string

param productName string
param productDisplayName string
param productDescription string
param productSubscriptionName string
param productSubscriptionDisplayName string

resource apim 'Microsoft.ApiManagement/service@2023-05-01-preview' existing = {
  name: name
}

// Provision APIM product
resource apimProduct 'Microsoft.ApiManagement/service/products@2022-08-01' = {
  name: productName
  parent: apim
  properties: {
    displayName: productDisplayName
    description: productDescription
    state: 'published'
    subscriptionRequired: true
  }
}

// Provision APIM subscription belongs to the product
resource apimSubscription 'Microsoft.ApiManagement/service/subscriptions@2022-08-01' = {
  name: productSubscriptionName
  parent: apim
  properties: {
    displayName: productSubscriptionDisplayName
    scope: apimProduct.id
  }
}
