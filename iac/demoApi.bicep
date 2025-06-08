@description('Required. The name of the API Management service.')
param apimServiceName string = 'samb-poc-apim-demo'

resource apim 'Microsoft.ApiManagement/service@2024-05-01' existing = {
  name: apimServiceName
}


resource api 'Microsoft.ApiManagement/service/apis@2024-06-01-preview' = {
  parent: apim
  name: 'nr-demo-basic-api'
  properties: {
    apiRevision: '1'
    description: 'nr-demo-basic-api - for testing apim instrumentation.'
    displayName: 'nr-demo-basic-api'
    isCurrent: true
    path: 'nr-demo-basic-api'
    protocols: [
      'https'
    ]
    serviceUrl: 'https://httpbin.org/get'
    subscriptionRequired: false
  }
}


resource api_policy 'Microsoft.ApiManagement/service/apis/policies@2024-06-01-preview' = {
  parent: api
  name: 'policy'
  properties: {
    value: '<policies>\r\n  <!-- Throttle, authorize, validate, cache, or transform the requests -->\r\n  <inbound>\r\n    <!-- Setups the Tracing variables to use later + traceparent header -->\r\n    <include-fragment fragment-id="nr-trace-inbound" />\r\n    <base />\r\n  </inbound>\r\n  <!-- Control if and how the requests are forwarded to services  -->\r\n  <backend>\r\n    <base />\r\n  </backend>\r\n  <!-- Customize the responses -->\r\n  <outbound>\r\n    <!-- Publishes a trace to NR directly -->\r\n    <include-fragment fragment-id="nr-trace-publish" />\r\n    <!-- Create a payload to post to the eventhub logger -->\r\n    <include-fragment fragment-id="nr-logger" />\r\n    <base />\r\n  </outbound>\r\n  <!-- Handle exceptions and customize error responses  -->\r\n  <on-error>\r\n    <!-- Create a payload to post to the eventhub logger -->\r\n    <include-fragment fragment-id="nr-logger" />\r\n    <!-- Publishes a trace to NR directly -->\r\n    <include-fragment fragment-id="nr-trace-publish" />\r\n    <base />\r\n  </on-error>\r\n</policies>'
    format: 'xml'
  }
}


resource api_operations 'Microsoft.ApiManagement/service/apis/operations@2024-06-01-preview' = {
  parent: api
  name: 'get'
  properties: {
    displayName: 'get'
    method: 'GET'
    urlTemplate: '/'
    templateParameters: []
    responses: []
  }
}
