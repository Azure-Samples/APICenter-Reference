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
    $ApiCenterService = "",

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
            [-ApiCenterService  <API Center instance name>] ``
            [-ApiId             <API ID registered to API Center>] ``
            [-MetadataKey       <Metadata key>] ``
            [-MetadataValue     <Metadata value>] ``
            [-ApiVersion        <API version>] ``

            [-Help]

    Options:
        -ResourceId         Resource ID. It must be provided unless `ResourceGroup` is provided.
        -ResourceGroup      Resource group. It must be provided unless `ResourceId` is provided.
        -ApiCenterService   API Center instance name. It must be provided unless `ResourceId` is provided.
        -ApiId              API ID registered to API Center. It must be provided unless `ResourceId` is provided.
        -MetadataKey        Metadata key.
        -MetadataValue      Metadata value.
        -ApiVersion         REST API version. Default is `2024-03-01`.

        -Help:          Show this message.
"

    Exit 0
}

# Show usage
$needHelp = $Help -eq $true
if ($needHelp -eq $true) {
    Show-Usage
    Exit 0
}

if (($ResourceId -eq "") -and ($ResourceGroup -eq "" -or $ApiCenterService -eq "" -or $ApiId -eq "")) {
    Write-Output "`ResourceId` must be provided, or all `ResourceGroup`, `ApiCenterService` and `ApiId` must be provided"
    Exit 0
}
if ($MetadataKey -eq "" -or $MetadataValue -eq "") {
    Write-Output "Both `MetadataKey` and `MetadataValue` must be provided"
    Exit 0
}

$segments = $ResourceId.Split("/", [System.StringSplitOptions]::RemoveEmptyEntries)
if ($ResourceGroup -eq "") {
    $ResourceGroup = $segments[3]
}
if ($ApiCenterService -eq "") {
    $ApiCenterService = $segments[7]
}
if ($ApiId -eq "") {
    $ApiId = $segments[11]
}

$customProperties = @{ $MetadataKey = $MetadataValue } | ConvertTo-Json -Compress | ConvertTo-Json

$updated = az apic api update `
    -g $ResourceGroup `
    -s $ApiCenterService `
    --api-id $ApiId `
    --custom-properties $customProperties
