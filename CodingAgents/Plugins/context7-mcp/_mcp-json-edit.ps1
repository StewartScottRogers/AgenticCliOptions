# ============================================================
#  Idempotently add/remove an MCP server entry in a JSON
#  settings file shaped like Gemini's ~/.gemini/settings.json
#  (and the assumed Antigravity equivalent).
#
#  Shape created if missing:
#    {
#      "mcpServers": {
#        "<Name>": { "command": "...", "args": [ ... ] }
#      }
#    }
#
#  Preserves any other keys in the file. Creates the file (and
#  any missing parent directory) if it does not exist. Writes
#  UTF-8 without BOM via Set-Content -Encoding UTF8 so downstream
#  CLIs that assume LF-friendly UTF-8 parse cleanly.
# ============================================================
param(
    [Parameter(Mandatory=$true)][ValidateSet('add','remove')][string]$Op,
    [Parameter(Mandatory=$true)][string]$SettingsPath,
    [Parameter(Mandatory=$true)][string]$Name,
    [Parameter(Mandatory=$false)][string]$Command,
    [Parameter(Mandatory=$false)][string[]]$ArgsList
)
$ErrorActionPreference = 'Stop'

$dir = Split-Path -Parent $SettingsPath
if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

if (Test-Path $SettingsPath) {
    try {
        $obj = Get-Content $SettingsPath -Raw | ConvertFrom-Json
    } catch {
        # Malformed file - refuse to overwrite. The user almost
        # certainly wants to know rather than lose their settings.
        Write-Error "Existing settings at $SettingsPath are not valid JSON: $_"
        exit 1
    }
    if ($null -eq $obj) { $obj = [pscustomobject]@{} }
} else {
    $obj = [pscustomobject]@{}
}

# Ensure mcpServers exists as an object we can mutate.
if (-not ($obj.PSObject.Properties.Name -contains 'mcpServers')) {
    $obj | Add-Member -NotePropertyName 'mcpServers' -NotePropertyValue ([pscustomobject]@{})
}
$servers = $obj.mcpServers
if ($null -eq $servers) {
    $servers = [pscustomobject]@{}
    $obj.mcpServers = $servers
}

switch ($Op) {
    'add' {
        if (-not $Command) { Write-Error "add requires -Command"; exit 1 }
        $entry = [pscustomobject]@{
            command = $Command
            args    = @($ArgsList)
        }
        if ($servers.PSObject.Properties.Name -contains $Name) {
            $servers.$Name = $entry
        } else {
            $servers | Add-Member -NotePropertyName $Name -NotePropertyValue $entry
        }
    }
    'remove' {
        if ($servers.PSObject.Properties.Name -contains $Name) {
            $servers.PSObject.Properties.Remove($Name)
        }
    }
}

$json = $obj | ConvertTo-Json -Depth 20
Set-Content -Path $SettingsPath -Value $json -Encoding UTF8
