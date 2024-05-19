#!/bin/bash

# Imports the API definitions to the APIC Analyzer as a part of post-provisioning process
# It does the following:
#   1. Gets the list of APIs registered in the API Center
#   2. Iterates over the APIs and imports the API definitions

set -e

# REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
REPOSITORY_ROOT="$(dirname "$(realpath "$0")")/../.."

# Load the azd environment variables
"$REPOSITORY_ROOT/infra/hooks/load_azd_env.sh"

echo "Importing API definitions..."

RESOURCE_GROUP="rg-$AZURE_ENV_NAME"
APIC_NAME=$AZURE_API_CENTER
DEFINITIONs=(
    "pet-store-api:openapi:petstore.yaml"
    "star-wars-api:graphql:star-wars-swapi.graphql"
    "global-weather-api:wsdl:globalweather.wsdl"
)

# Get the list of APIs registered in the API Center
API_IDs=$(az apic api list -g $RESOURCE_GROUP -s $APIC_NAME --query "[].name" -o json | jq -r '.[]')

# Iterate over the APIs and import the API definitions
for API_ID in $API_IDs
do
    VERSION_ID=$(az apic api version list -g $RESOURCE_GROUP -s $APIC_NAME --api-id $API_ID --query "[].name" -o tsv)
    DEFINITION_ID=$(az apic api definition list -g $RESOURCE_GROUP -s $APIC_NAME --api-id $API_ID --version-id $VERSION_ID --query "[].name" -o tsv)

    for DEFINITION in "${DEFINITIONs[@]}"
    do
        IFS=':' read -r -a array <<< "$DEFINITION"
        if [ "${array[0]}" = "$DEFINITION_ID" ]
        then
            SPECIFICATION="{\"name\":\"${array[1]}\"}"
            VALUE="${array[2]}"
            break
        fi
    done

    az apic api definition import-specification \
        -g $RESOURCE_GROUP \
        -s $APIC_NAME \
        --api-id $API_ID \
        --version-id $VERSION_ID \
        --definition-id $DEFINITION_ID \
        --specification "$SPECIFICATION" \
        --format inline \
        --value "@./infra/apis/$VALUE"
done
