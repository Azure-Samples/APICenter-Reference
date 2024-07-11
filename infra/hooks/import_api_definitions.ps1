# Imports the API definitions to the APIC Analyzer as a part of post-provisioning process
# It does the following:
#   1. Gets the list of APIs registered in the API Center
#   2. Iterates over the APIs and imports the API definitions
#   3. Gets the list of APIs registered in the API Management
#   4. Iterates over the APIs and imports the APIs from API Management to API Center

# $REPOSITORY_ROOT = git rev-parse --show-toplevel
$REPOSITORY_ROOT = "$(Split-Path $MyInvocation.MyCommand.Path)/../.."

# Load the azd environment variables
& "$REPOSITORY_ROOT/infra/hooks/load_azd_env.ps1"

Write-Host "Importing API definitions..."

$RESOURCE_GROUP = "rg-$env:AZURE_ENV_NAME"
$APIC_NAME = $env:AZURE_API_CENTER
$DEFINITIONs = @(
    @{
        id = "pet-store-api";
        specification = @{ name = "openapi" };
        value = "petstore.yaml"
    },
    @{
        id = "star-wars-api";
        specification = @{ name = "graphql" };
        value = "star-wars-swapi.graphql"
    },
    @{
        id = "global-weather-api";
        specification = @{ name = "wsdl" };
        value = "globalweather.wsdl"
    }
)

# Get the list of APIs registered in the API Center
$API_IDs = az apic api list -g $RESOURCE_GROUP -n $APIC_NAME --query "[].name" | ConvertFrom-Json

# Iterate over the APIs and import the API definitions
$API_IDs | ForEach-Object {
    $API_ID = $_
    $VERSION_ID = az apic api version list -g $RESOURCE_GROUP -n $APIC_NAME --api-id $API_ID --query "[].name" -o tsv
    $DEFINITION_ID = az apic api definition list -g $RESOURCE_GROUP -n $APIC_NAME --api-id $API_ID --version-id $VERSION_ID --query "[].name" -o tsv

    $DEFINITION = $DEFINITIONs | Where-Object { $_.id -eq $DEFINITION_ID }
    $SPECIFICATION = $DEFINITION.specification | ConvertTo-Json -Depth 100 -Compress | ConvertTo-Json
    $VALUE = $DEFINITION.value

    az apic api definition import-specification `
        -g $RESOURCE_GROUP `
        -n $APIC_NAME `
        --api-id $API_ID `
        --version-id $VERSION_ID `
        --definition-id $DEFINITION_ID `
        --specification $SPECIFICATION `
        --format inline `
        --value `@./infra/apis/$VALUE
}

# Get the list of APIs registered in the API Management
$APIM_NAME = az resource list --namespace "Microsoft.ApiManagement" --resource-type "service" -g $RESOURCE_GROUP --query "[].name" -o tsv

# # Import APIs from API Management to API Center
# az apic import-from-apim -g $RESOURCE_GROUP -n $APIC_NAME --apim-name $APIM_NAME --apim-apis *

$API_IDs = az apim api list -g $RESOURCE_GROUP -n $APIM_NAME --query "[].name" | ConvertFrom-Json

# Iterate over the APIs and import the APIs from API Management to API Center
$API_IDs | ForEach-Object {
    $API_ID = $_

    az apic import-from-apim -g $RESOURCE_GROUP -n $APIC_NAME --apim-name $APIM_NAME --apim-apis $API_ID
}
