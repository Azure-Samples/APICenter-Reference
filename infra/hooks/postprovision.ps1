# Runs the post-provision script after the environment is provisioned
# It does the following:
#   1. Creates a service principal
#   2. Adds required permissions to the app
#   3. Sets the environment variables
#   4. Installs the APIC Analyzer
#   5. Installs the APIC Portal
#   6. Imports the API definitions

Write-Host "Running post-provision script..."

# $REPOSITORY_ROOT = git rev-parse --show-toplevel
$REPOSITORY_ROOT = "$(Split-Path $MyInvocation.MyCommand.Path)/../.."

# Load the azd environment variables
& "$REPOSITORY_ROOT/infra/hooks/load_azd_env.ps1"

$AZURE_ENV_NAME = $env:AZURE_ENV_NAME

# Run only if GITHUB_WORKSPACE is NOT set - this is NOT running in a GitHub Action workflow
if ([string]::IsNullOrEmpty($env:GITHUB_WORKSPACE)) {
    Write-Host "Registering the application in Azure..."

    # Create a service principal
    $appId = $env:AZURE_CLIENT_ID
    if ([string]::IsNullOrEmpty($appId)) {
        $appId = az ad app list --display-name "spn-$AZURE_ENV_NAME" --query "[].appId" -o tsv
        if ([string]::IsNullOrEmpty($appId)) {
            $appId = az ad app create --display-name spn-$AZURE_ENV_NAME --query "appId" -o tsv
            $spnId = az ad sp create --id $appId --query "id" -o tsv
        }
    }

    $spnId = az ad sp list --display-name "spn-$AZURE_ENV_NAME" --query "[].id" -o tsv
    if ([string]::IsNullOrEmpty($spnId)) {
        $spnId = az ad sp create --id $appId --query "id" -o tsv
    }

    $objectId = az ad app show --id $appId --query "id" -o tsv

    # Add required permissions to the app
    $requiredResourceAccess = @( @{ resourceAppId = "c3ca1a77-7a87-4dba-b8f8-eea115ae4573"; resourceAccess = @( @{ type = "Scope"; id = "44327351-3395-414e-882e-7aa4a9c3b25d" } ) } )

    $payload = @{ requiredResourceAccess = $requiredResourceAccess; } | ConvertTo-Json -Depth 100 -Compress | ConvertTo-Json

    az rest -m PATCH `
        --uri "https://graph.microsoft.com/v1.0/applications/$objectId" `
        --headers Content-Type=application/json `
        --body $payload

    # Set the environment variables
    azd env set AZURE_CLIENT_ID $appId
} else {
    Write-Host "Skipping to register the application in Azure..."
}

# Run only if GITHUB_WORKSPACE is NOT set - this is NOT running in a GitHub Action workflow
if ([string]::IsNullOrEmpty($env:GITHUB_WORKSPACE)) {
    # Install the APIC Analyzer
    Write-Host "About to install the APIC Analyzer..."

    & "$REPOSITORY_ROOT/infra/hooks/install_apic_analyzer.ps1"
} else {
    Write-Host "Skipping to install the APIC Analyzer..."
}

# Run only if GITHUB_WORKSPACE is NOT set - this is NOT running in a GitHub Action workflow
if ([string]::IsNullOrEmpty($env:GITHUB_WORKSPACE)) {
    # Install the APIC Portal
    Write-Host "About to install the APIC Portal..."

    # azd env set AZURE_API_CENTER_PORTAL_DIRECTORY "$($AZURE_ENV_NAME)-portal"

    # & "$REPOSITORY_ROOT/infra/hooks/install_apic_portal.ps1"
} else {
    Write-Host "Skipping to install the APIC Portal..."
}

# Import the API definitions
Write-Host "About to import API definitions..."

& "$REPOSITORY_ROOT/infra/hooks/import_api_definitions.ps1"
