# Sets the metadata for the API registered on API Center.
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
    $ApiId = "",

    [string]
    [Parameter(Mandatory=$false)]
    $MetadataKey = "",

    [string]
    [Parameter(Mandatory=$false)]
    $MetadataValue = "",

    [string]
    [Parameter(Mandatory=$false)]
    $ApiVersion = "2024-03-01",

    [switch]
    [Parameter(Mandatory=$false)]
    $Help
)

function Show-Usage {
    Write-Output "    This updates the metadata value of the API registered on API Center

    Usage: $(Split-Path $MyInvocation.ScriptName -Leaf) ``
            [-ResourceId        <Resource ID>] ``
            [-ResourceGroup     <Resource group>] ``
            [-ServiceName       <API Center instance name>] ``
            [-ApiId             <API ID registered to API Center>] ``
            [-MetadataKey       <Metadata key>] ``
            [-MetadataValue     <Metadata value>] ``
            [-ApiVersion        <API version>] ``

            [-Help]

    Options:
        -ResourceId         Resource ID. It must be provided unless `ResourceGroup` is provided.
        -ResourceGroup      Resource group. It must be provided unless `ResourceId` is provided.
        -ServiceName        API Center instance name. It must be provided unless `ResourceId` is provided.
        -ApiId              API ID registered to API Center.
        -MetadataKey        Metadata key.
        -MetadataValue      Metadata value.
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
    Write-Output "``ResourceId`` must be provided, or both ``ResourceGroup`` and ``ServiceName`` must be provided"
    Exit 0
}
if ($ApiId -eq "") {
    Write-Output "``ApiId`` must be provided"
    Exit 0
}
if ($MetadataKey -eq "" -or $MetadataValue -eq "") {
    Write-Output "Both ``MetadataKey`` and ``MetadataValue`` must be provided"
    Exit 0
}

$segments = $ResourceId.Split("/", [System.StringSplitOptions]::RemoveEmptyEntries)
if ($ResourceGroup -eq "") {
    $ResourceGroup = $segments[3]
}
if ($ServiceName -eq "") {
    $ServiceName = $segments[7]
}

$customProperties = @{ $MetadataKey = $MetadataValue } | ConvertTo-Json -Compress
if ($IsWindows) {
    $customProperties = $customProperties | ConvertTo-Json
}

$updated = az apic api update `
    -g $ResourceGroup `
    -s $ServiceName `
    --api-id $ApiId `
    --custom-properties $customProperties
