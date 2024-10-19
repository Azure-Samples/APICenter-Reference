#!/bin/bash

# Imports the API definitions to the APIC Analyzer as a part of post-provisioning process
# It does the following:
#   1. Gets the list of APIs registered in the API Center
#   2. Iterates over the APIs and imports the API definitions
#   3. Gets the list of APIs registered in the API Management
#   4. Iterates over the APIs and imports the APIs from API Management to API Center

set -e

# REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
REPOSITORY_ROOT="$(dirname "$(realpath "$0")")/../.."

# Load the azd environment variables
"$REPOSITORY_ROOT/infra/hooks/load_azd_env.sh"

echo "Importing API definitions..."

RESOURCE_GROUP="rg-$AZURE_ENV_NAME"
APIC_NAME=$AZURE_API_CENTER
DEFINITIONS=(
    '{ "id": "pet-store-api", "specification": { "name": "openapi" }, "value": "petstore.yaml" }'
    '{ "id": "star-wars-api", "specification": { "name": "graphql" }, "value": "star-wars-swapi.graphql" }'
    '{ "id": "global-weather-api", "specification": { "name": "wsdl" }, "value": "globalweather.wsdl" }'
)

# Get the list of APIs registered in the API Center
API_IDs=$(az apic api list -g $RESOURCE_GROUP -n $APIC_NAME --query "[].name" -o json | jq -r '.[]')

# Iterate over the APIs and import the API definitions
for API_ID in $API_IDs; do
    VERSION_ID=$(az apic api version list -g $RESOURCE_GROUP -n $APIC_NAME --api-id $API_ID --query "[].name" -o tsv)
    DEFINITION_ID=$(az apic api definition list -g $RESOURCE_GROUP -n $APIC_NAME --api-id $API_ID --version-id $VERSION_ID --query "[].name" -o tsv)

    for DEFINITION in "${DEFINITIONS[@]}"; do
        DEFINITION_ID_JSON=$(echo "$DEFINITION" | jq -r '.id')
        if [[ "$DEFINITION_ID_JSON" == "$DEFINITION_ID" ]]; then
            SPECIFICATION=$(echo "$DEFINITION" | jq -c '.specification')
            VALUE=$(echo "$DEFINITION" | jq -r '.value')

            az apic api definition import-specification \
                -g "$RESOURCE_GROUP" \
                -n "$APIC_NAME" \
                --api-id "$API_ID" \
                --version-id "$VERSION_ID" \
                --definition-id "$DEFINITION_ID" \
                --specification "$SPECIFICATION" \
                --format inline \
                --value "@./infra/apis/$VALUE"
        fi
    done
done

# Get the list of APIs registered in the API Management
APIM_NAME=$(az resource list --namespace "Microsoft.ApiManagement" --resource-type "service" -g $RESOURCE_GROUP --query "[].name" -o tsv)

# # Import APIs from API Management to API Center
# az apic import-from-apim -g $RESOURCE_GROUP -n $APIC_NAME --apim-name $APIM_NAME --apim-apis *

API_IDs=$(az apim api list -g $RESOURCE_GROUP -n $APIM_NAME --query "[].name" | jq -r '.[]')

# Iterate over the APIs and import the APIs from API Management to API Center
for API_ID in $API_IDs
do
    az apic import-from-apim -g $RESOURCE_GROUP -n $APIC_NAME --apim-name $APIM_NAME --apim-apis $API_ID
done
