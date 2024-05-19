#!/bin/bash

# Installs the APIC Portal as a part of post-provisioning process
# It does the following:
#   1. Creates a new directory for the portal
#   2. Initializes the portal
#   3. Sets the environment variables
#   4. Installs the portal

set -e

# REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
REPOSITORY_ROOT="$(dirname "$(realpath "$0")")/../.."

# Load the azd environment variables
"$REPOSITORY_ROOT/infra/hooks/load_azd_env.sh"

echo "Installing the APIC Portal..."

# Create a new directory for the portal
PORTAL_NAME="${AZURE_API_CENTER_PORTAL_DIRECTORY}"
mkdir -p "$REPOSITORY_ROOT/$PORTAL_NAME"

pushd "$REPOSITORY_ROOT/$PORTAL_NAME"

# Initialize the portal
azd init -e $AZURE_ENV_NAME --template justinyoo/APICenter-Portal-Starter --branch feature/azdevfy

# Set the environment variables
azd env set AZURE_LOCATION $AZURE_API_CENTER_LOCATION
azd env set AZURE_SUBSCRIPTION_ID $AZURE_SUBSCRIPTION_ID
azd env set USE_EXISTING_API_CENTER true
azd env set AZURE_API_CENTER $AZURE_API_CENTER
azd env set AZURE_API_CENTER_RESOURCE_GROUP "rg-$AZURE_ENV_NAME"
azd env set AZURE_API_CENTER_PORTAL_DIRECTORY $PORTAL_NAME
azd env set AZURE_STATIC_APP_LOCATION $AZURE_STATIC_APP_LOCATION

# Install the portal
azd up

popd
