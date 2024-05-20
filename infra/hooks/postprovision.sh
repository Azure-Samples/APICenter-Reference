#!/bin/bash

# Runs the post-provision script after the environment is provisioned
# It does the following:
#   1. Creates a service principal
#   2. Adds required permissions to the app
#   3. Sets the environment variables
#   4. Installs the APIC Analyzer
#   5. Installs the APIC Portal
#   6. Imports the API definitions

set -e

echo "Running post-provision script..."

# REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
REPOSITORY_ROOT="$(dirname "$(realpath "$0")")/../.."

# Load the azd environment variables
"$REPOSITORY_ROOT/infra/hooks/load_azd_env.sh"

# Run only if GITHUB_WORKSPACE is NOT set - this is NOT running in a GitHub Action workflow
if [ -z "$GITHUB_WORKSPACE" ];
then
    echo "Registering the application in Azure..."

    # Create a service principal and assign the required permissions
    appId=$AZURE_CLIENT_ID
    if [ -z "$appId" ]
    then
        appId=$(az ad app list --display-name "spn-$AZURE_ENV_NAME" --query "[].appId" -o tsv)
        if [ -z "$appId" ]
        then
            appId=$(az ad app create --display-name "spn-$AZURE_ENV_NAME" --query "appId" -o tsv)
            spnId=$(az ad sp create --id $appId --query "id" -o tsv)
        fi
    fi

    spnId=$(az ad sp list --display-name "spn-$AZURE_ENV_NAME" --query "[].id" -o tsv)
    if [ -z "$spnId" ]
    then
        spnId=$(az ad sp create --id $appId --query "id" -o tsv)
    fi

    objectId=$(az ad app show --id $appId --query "id" -o tsv)

    # Add required permissions to the app
    requiredResourceAccess="[{\"resourceAppId\": \"c3ca1a77-7a87-4dba-b8f8-eea115ae4573\", \"resourceAccess\": [{\"type\": \"Scope\", \"id\": \"44327351-3395-414e-882e-7aa4a9c3b25d\"}]}]"

    payload=$(jq -n \
    --argjson requiredResourceAccess "$requiredResourceAccess" \
    "{\"requiredResourceAccess\": $requiredResourceAccess}")

    az rest -m PATCH \
        --uri "https://graph.microsoft.com/v1.0/applications/$objectId" \
        --headers Content-Type=application/json \
        --body "$payload"

    # Set the environment variables
    azd env set AZURE_CLIENT_ID $appId
else
    echo "Skipping to register the application in Azure..."
fi

# Run only if GITHUB_WORKSPACE is NOT set - this is NOT running in a GitHub Action workflow
if [ -z "$GITHUB_WORKSPACE" ];
then
    # Install the APIC Analyzer
    echo "About to install the APIC Analyzer..."

    "$REPOSITORY_ROOT/infra/hooks/install_apic_analyzer.sh"
else
    echo "Skipping to install the APIC Analyzer..."
fi

# Run only if GITHUB_WORKSPACE is NOT set - this is NOT running in a GitHub Action workflow
if [ -z "$GITHUB_WORKSPACE" ];
then
    # Install the APIC Portal
    echo "About to install the APIC Portal..."

    # azd env set AZURE_API_CENTER_PORTAL_DIRECTORY "$AZURE_ENV_NAME-portal"

    "$REPOSITORY_ROOT/infra/hooks/install_apic_portal.sh"
else
    echo "Skipping to install the APIC Portal..."
fi

# Import the API definitions
echo "About to import API definitions..."

"$REPOSITORY_ROOT/infra/hooks/import_api_definitions.sh"
