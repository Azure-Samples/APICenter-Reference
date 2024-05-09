# Registers API to API Center.
Param(
    [string]
    [Parameter(Mandatory=$false)]
    $ResourceId = "",

    [string]
    [Parameter(Mandatory=$false)]
    $ResourceGroup = "",

    [string]
    [Parameter(Mandatory=$false)]
    $ApiCenterService = "",

    [string]
    [Parameter(Mandatory=$false)]
    $FileLocation = "",

    [string]
    [Parameter(Mandatory=$false)]
    $ApiManagementId = "",

    [string]
    [Parameter(Mandatory=$false)]
    $ApiVersion = "2024-03-01",

    [switch]
    [Parameter(Mandatory=$false)]
    $Help
)

function Show-Usage {
    Write-Host "    This registers API to API Center

    Usage: $(Split-Path $MyInvocation.ScriptName -Leaf) ``
            [-ResourceId        <Resource ID>] ``
            [-ResourceGroup     <Resource group>] ``
            [-ApiCenterService  <API Center instance name>] ``
            [-FileLocation      <File location to register>] ``
            [-ApiManagementId   <File location to register>] ``
            [-ApiVersion        <API version>] ``

            [-Help]

    Options:
        -ResourceId         Resource ID. It must be provided unless `ResourceGroup` is provided.
        -ResourceGroup      Resource group. It must be provided unless `ResourceId` is provided.
        -ApiCenterService   API Center instance name. It must be provided unless `ResourceId` is provided.
        -FileLocation       File location to register.
        -ApiManagementId    API Management resource ID. If provided, ``FileLocation`` will be ignored.
        -ApiVersion         REST API version. Default is `2024-03-01`.

        -Help:              Show this message.
"

    Exit 0
}

# Show usage
$needHelp = $Help -eq $true
if ($needHelp -eq $true) {
    Show-Usage
    Exit 0
}

if (($ResourceId -eq "") -and ($ResourceGroup -eq "" -or $ApiCenterService -eq "")) {
    Write-Host "`ResourceId` must be provided, or both `ResourceGroup` and `ApiCenterService` must be provided"
    Exit 0
}
if ($FileLocation -eq "" -and $ApiManagementId -eq "") {
    Write-Host "`FileLocation` must be provided"
    Exit 0
}
if ($ApiManagementId -notlike "/subscriptions/*") {
    Write-Host "`ApiManagementId` must be a valid resource ID"
    Exit 0
}

$segments = $ResourceId.Split("/", [System.StringSplitOptions]::RemoveEmptyEntries)
if ($ResourceGroup -eq "") {
    $ResourceGroup = $segments[3]
}
if ($ApiCenterService -eq "") {
    $ApiCenterService = $segments[7]
}

$REPOSITORY_ROOT = git rev-parse --show-toplevel

if ($ApiManagementId -eq "") {
    Write-Host "Registering API from a file: $FileLocation ..."

    $registered = az apic api register `
    -g $ResourceGroup `
    -s $ApiCenterService `
    --api-location "$REPOSITORY_ROOT/$($FileLocation.Replace("\", "/"))"
} else {
    Write-Host "Registering API from API Management: $ApiManagementId ..."

    $registered = az apic service import-from-apim `
    -g $ResourceGroup `
    -s $ApiCenterService `
    --source-resource-ids "$APIM_ID/apis/*"
}
