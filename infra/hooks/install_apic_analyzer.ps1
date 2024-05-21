# Installs the APIC Analyzer as a part of post-provisioning process
# It does the following:
#   1. Creates a new directory for the analyzer
#   2. Initializes the analyzer
#   3. Sets the environment variables
#   4. Installs the analyzer

# $REPOSITORY_ROOT = git rev-parse --show-toplevel
$REPOSITORY_ROOT = "$(Split-Path $MyInvocation.MyCommand.Path)/../.."

# Load the azd environment variables
& "$REPOSITORY_ROOT/infra/hooks/load_azd_env.ps1"

Write-Host "Installing the APIC Analyzer..."

pwsh -Command {
    Param(
        [string]$REPOSITORY_ROOT,
        [string]$AZURE_ENV_NAME,
        [string]$AZURE_API_CENTER_LOCATION,
        [string]$AZURE_SUBSCRIPTION_ID,
        [string]$AZURE_API_CENTER
    )
    # Create a new directory for the analyzer
    $ANALYZER_NAME = "$($AZURE_ENV_NAME)-analyzer"
    New-Item -Type Directory "$REPOSITORY_ROOT/$ANALYZER_NAME" -Force

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
} -args $REPOSITORY_ROOT, $env:AZURE_ENV_NAME, $env:AZURE_API_CENTER_LOCATION, $env:AZURE_SUBSCRIPTION_ID, $env:AZURE_API_CENTER
