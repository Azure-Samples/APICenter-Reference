#!/bin/bash

# Installs the APIC Analyzer as a part of post-provisioning process
# It does the following:
#   1. Creates a new directory for the analyzer
#   2. Initializes the analyzer
#   3. Sets the environment variables
#   4. Installs the analyzer

set -e

# REPOSITORY_ROOT=$(git rev-parse --show-toplevel)
REPOSITORY_ROOT="$(dirname "$(realpath "$0")")/../.."

# Load the azd environment variables
"$REPOSITORY_ROOT/infra/hooks/load_azd_env.sh"

echo "Installing the APIC Analyzer..."

# Create a new directory for the analyzer
ANALYZER_NAME="${AZURE_ENV_NAME}-analyzer"
mkdir -p "$REPOSITORY_ROOT/$ANALYZER_NAME"

pushd "$REPOSITORY_ROOT/$ANALYZER_NAME"

# Initialize the analyzer
azd init -e $AZURE_ENV_NAME --template Azure/APICenter-Analyzer --branch preview

# Set the environment variables
azd env set AZURE_LOCATION $AZURE_API_CENTER_LOCATION
azd env set AZURE_SUBSCRIPTION_ID $AZURE_SUBSCRIPTION_ID
azd env set APIC_NAME $AZURE_API_CENTER
azd env set APIC_RESOURCE_GROUP_NAME "rg-$AZURE_ENV_NAME"
azd env set USE_MONITORING true

# Install the analyzer
azd up

popd
