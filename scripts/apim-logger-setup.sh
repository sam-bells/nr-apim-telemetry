SUBSCRIPTION_ID="" ## The Subscription where APIM is located
LOGGER_ID="nr-logger" ## Friendly name to keep the demo consistent
EVENTHUB_NAMESPACE="" ## The EventHub Namespace provisioned by the New Relic Log Forwarder solution
EVENTHUB_INSTANCE="" ## The New Relic Log Forwarder EventHub instance
CONNECTION_STRING="" ## This is the Connection String for the `Event Hub` not the `Namespace`.
APIM_API_VERSION="2021-08-01"
AZ_RG="" ## Azure Resource Group where APIM is running
AZ_APIM="" ## The name of the Azure APIM instance


cat << EOF > logger.json
 {
     "properties": {
         "loggerType": "azureEventHub",
         "description": "New Relic log forwarder",
         "credentials": {
             "name": "$EVENTHUB_NAMESPACE",
             "connectionString": "$CONNECTION_STRING"
         }
     }
 }
EOF

## Create the new Logger
az rest --method put \
    --url "https://management.azure.com/subscriptions/$SUBSCRIPTION_ID/resourceGroups/$AZ_RG/providers/Microsoft.ApiManagement/service/$AZ_APIM/loggers/$LOGGER_ID?api-version=$APIM_API_VERSION" \
    --body @logger.json
