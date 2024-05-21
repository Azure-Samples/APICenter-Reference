# Installs the APIC Portal as a part of post-provisioning process
# It does the following:
#   1. Creates a new directory for the portal
#   2. Initializes the portal
#   3. Sets the environment variables
#   4. Installs the portal

# $REPOSITORY_ROOT = git rev-parse --show-toplevel
$REPOSITORY_ROOT = "$(Split-Path $MyInvocation.MyCommand.Path)/../.."

# Load the azd environment variables
& "$REPOSITORY_ROOT/infra/hooks/load_azd_env.ps1"

Write-Host "Installing the APIC Portal..."

pwsh -Command {
    Param(
        [string]$REPOSITORY_ROOT,
        [string]$AZURE_ENV_NAME,
        [string]$AZURE_API_CENTER_LOCATION,
        [string]$AZURE_SUBSCRIPTION_ID,
        [string]$AZURE_API_CENTER,
        [string]$AZURE_API_CENTER_PORTAL_DIRECTORY,
        [string]$AZURE_STATIC_APP_LOCATION
    )
    # Create a new directory for the analyzer
    $PORTAL_NAME = $AZURE_API_CENTER_PORTAL_DIRECTORY
    New-Item -Type Directory "$REPOSITORY_ROOT/$PORTAL_NAME" -Force

    pushd "$REPOSITORY_ROOT/$PORTAL_NAME"

    # Initialize the analyzer
    azd init -e $AZURE_ENV_NAME --template Azure/APICenter-Portal-Starter --branch main

    # Set the environment variables
    azd env set AZURE_LOCATION $AZURE_API_CENTER_LOCATION
    azd env set AZURE_SUBSCRIPTION_ID $AZURE_SUBSCRIPTION_ID
    azd env set USE_EXISTING_API_CENTER true
    azd env set AZURE_API_CENTER $AZURE_API_CENTER
    azd env set AZURE_API_CENTER_RESOURCE_GROUP "rg-$AZURE_ENV_NAME"
    azd env set AZURE_API_CENTER_PORTAL_DIRECTORY $PORTAL_NAME
    azd env set AZURE_STATIC_APP_LOCATION $AZURE_STATIC_APP_LOCATION

    # Install the analyzer
    azd up

    popd
} -args $REPOSITORY_ROOT, $env:AZURE_ENV_NAME, $env:AZURE_API_CENTER_LOCATION, $env:AZURE_SUBSCRIPTION_ID, $env:AZURE_API_CENTER, $env:AZURE_API_CENTER_PORTAL_DIRECTORY, $env:AZURE_STATIC_APP_LOCATION
