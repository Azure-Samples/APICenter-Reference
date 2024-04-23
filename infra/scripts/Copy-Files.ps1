# Copy client SDK related files to the web app project.
Param(
    [string]
    [Parameter(Mandatory=$false)]
    $Source = "dotnet/src/WebApp.Extensions/*",

    [string]
    [Parameter(Mandatory=$false)]
    $Target = "dotnet/src/WebApp",

    [switch]
    [Parameter(Mandatory=$false)]
    $Help
)

function Show-Usage {
    Write-Output "    This copies the client SDK related files to the web app project

    Usage: $(Split-Path $MyInvocation.ScriptName -Leaf) ``
            [-Source    <Source path>] ``
            [-Target    <Target path>] ``

            [-Help]

    Options:
        -Source     Source path. Default is `dotnet/src/WebApp.Extensions/*`.
        -Target     Target path. Default is `dotnet/src/WebApp`.

        -Help:      Show this message.
"

    Exit 0
}

# Show usage
$needHelp = $Help -eq $true
if ($needHelp -eq $true) {
    Show-Usage
    Exit 0
}

if (($Source -eq "") -or ($Target -eq "")) {
    Write-Output "`Both `Source` and `Target` must be provided"
    Exit 0
}

$REPOSITORY_ROOT = git rev-parse --show-toplevel

Copy-Item `
    -Path "$REPOSITORY_ROOT/$($Source.Replace("\", "/"))" `
    -Destination "$REPOSITORY_ROOT/$($Target.Replace("\", "/"))" `
    -Recurse -Force
