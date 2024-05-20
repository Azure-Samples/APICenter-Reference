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
    $ServiceName = "",

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
            [-ServiceName  <API Center instance name>] ``
            [-FileLocation      <File location to register>] ``
            [-ApiManagementId   <File location to register>] ``
            [-ApiVersion        <API version>] ``

            [-Help]

    Options:
        -ResourceId         Resource ID. It must be provided unless `ResourceGroup` is provided.
        -ResourceGroup      Resource group. It must be provided unless `ResourceId` is provided.
        -ServiceName        API Center instance name. It must be provided unless `ResourceId` is provided.
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

if (($ResourceId -eq "") -and ($ResourceGroup -eq "" -or $ServiceName -eq "")) {
    Write-Host "``ResourceId`` must be provided, or both ``ResourceGroup`` and ``ServiceName`` must be provided"
    Exit 0
}
if (($FileLocation -eq "") -and ($ApiManagementId -eq "")) {
    Write-Host "``FileLocation`` must be provided"
    Exit 0
}
if (($FileLocation -eq "") -and ($ApiManagementId -notlike "/subscriptions/*")) {
    Write-Host "``ApiManagementId`` must be a valid resource ID"
    Exit 0
}

$segments = $ResourceId.Split("/", [System.StringSplitOptions]::RemoveEmptyEntries)
if ($ResourceGroup -eq "") {
    $ResourceGroup = $segments[3]
}
if ($ServiceName -eq "") {
    $ServiceName = $segments[7]
}

$REPOSITORY_ROOT = git rev-parse --show-toplevel

if ($ApiManagementId -eq "") {
    Write-Host "Registering API from a file: $FileLocation ..."

    $registered = az apic api register `
    -g $ResourceGroup `
    -s $ServiceName `
    --api-location "$REPOSITORY_ROOT/$($FileLocation.Replace("\", "/"))"
} else {
    Write-Host "Registering API from API Management: $ApiManagementId ..."

    $segments = $ApiManagementId.Split("/", [System.StringSplitOptions]::RemoveEmptyEntries)

    $ApiIds = az apim api list -g $segments[3] -n $segments[7] --query "[].id" | ConvertFrom-Json
    $ApiIds | ForEach-Object {
        $ApiId = $_

        $registered = az apic service import-from-apim `
            -g $ResourceGroup `
            -s $ServiceName `
            --source-resource-ids $ApiId
    }
}
