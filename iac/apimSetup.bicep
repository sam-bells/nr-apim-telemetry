
@description('Required. The name of the API Management service.')
param apimServiceName string = ''
@description('Required. The New Relic ingest key to use for publishing traces to.')
param nrIngestKey string = ''


@description('Required. The name of the Event Hub Namespace and EventHub to use for logging to New Relic. Format: <eventHubNamespace>/<eventHubName>')
param nrEventHubNamespaceName string = '' // $eventHubNamespace/$eventHubName 

@description('Required. The connection string for the Event Hub to use for logging to New Relic. Not the Namespace connection string.')
param nrEventHubConnectionString string = ''

resource apim 'Microsoft.ApiManagement/service@2024-05-01' existing = {
  name: apimServiceName
}

resource apim_nrsecret 'Microsoft.ApiManagement/service/namedValues@2024-06-01-preview' = {
  parent: apim
  name: 'nr-ingest-key'
  properties: {
    displayName: 'nr-ingest-key'
    secret: true
    value: nrIngestKey
  }
}

resource apim_logger 'Microsoft.ApiManagement/service/loggers@2024-06-01-preview' = {
  name: 'nr-logger'
  parent: apim
  properties: {
    loggerType: 'azureEventHub'
    description: 'New Relic log forwarder'
    credentials: {
      name: nrEventHubNamespaceName
      connectionString: nrEventHubConnectionString
    }
    isBuffered: true
  }
}

resource policy_nrLogger 'Microsoft.ApiManagement/service/policyFragments@2024-05-01' = {
  parent: apim
  dependsOn: [
    apim_logger
  ]
  name: 'nr-logger'
  properties: {
    description: 'NR: Policy to log requests and responses to New Relic - leveraging the NR Log forwarder EventHub solution.'
    format: 'rawxml'
    value: loadTextContent('../policies/fragment-full-details.xml')
  }
}

resource policy_traceInbound 'Microsoft.ApiManagement/service/policyFragments@2024-05-01' = {
  parent: apim
  dependsOn: [
    apim_logger
  ]
  name: 'nr-trace-inbound'
  properties: {
    description: 'NR: Policy to collect w3c headers to decorate the downstream span and prep for collection to New Relic.'
    format: 'rawxml'
    value: loadTextContent('../policies/nr-trace-inbound.xml')
  }
}

resource policy_tracePublish 'Microsoft.ApiManagement/service/policyFragments@2024-05-01' = {
  parent: apim
  dependsOn: [
    apim_logger
    apim_nrsecret
  ]
  name: 'nr-trace-publish'
  properties: {
    description: 'NR: Policy to publish the collected trace details to New Relic.'
    format: 'rawxml'
    value: loadTextContent('../policies/nr-trace-publish.xml')
  }
}

