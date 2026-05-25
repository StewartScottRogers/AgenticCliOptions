# ============================================================
#  Idempotently add/remove an MCP server entry in opencode's
#  ~/.config/opencode/opencode.json, under the top-level `mcp` key.
#
#  opencode's MCP schema is different from Claude Desktop /
#  Gemini's `mcpServers` shape: the top-level key is `mcp` and
#  each server takes `type` ('local' | 'remote'), `command` as
#  a single array (bin + args combined), and `enabled`.
#
#  Shape created if missing (local stdio server):
#    {
#      "$schema": "https://opencode.ai/config.json",
#      "mcp": {
#        "<Name>": {
#          "type": "local",
#          "command": ["<bin>", "<arg1>", "<arg2>", ...],
#          "enabled": true
#        }
#      }
#    }
#
#  Preserves any other keys in the file. Creates the file (and
#  parent dir) if missing.
# ============================================================
param(
    [Parameter(Mandatory=$true)][ValidateSet('add','remove')][string]$Op,
    [Parameter(Mandatory=$true)][string]$ConfigPath,
    [Parameter(Mandatory=$true)][string]$Name,
    [Parameter(Mandatory=$false)][string]$Command,
    [Parameter(Mandatory=$false)][string[]]$ArgsList
)
$ErrorActionPreference = 'Stop'

# Recover the intended array when cmd.exe collapsed "a","b","c"
# into a single comma-joined token before powershell.exe saw it.
if ($ArgsList -and $ArgsList.Count -eq 1 -and $ArgsList[0] -match ',') {
    $ArgsList = $ArgsList[0] -split ','
}

$dir = Split-Path -Parent $ConfigPath
if ($dir -and -not (Test-Path $dir)) {
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
}

if (Test-Path $ConfigPath) {
    try {
        $obj = Get-Content $ConfigPath -Raw | ConvertFrom-Json
    } catch {
        Write-Error "Existing opencode config at $ConfigPath is not valid JSON: $_"
        exit 1
    }
    if ($null -eq $obj) {
        $obj = [pscustomobject]@{ '$schema' = 'https://opencode.ai/config.json' }
    }
} else {
    $obj = [pscustomobject]@{ '$schema' = 'https://opencode.ai/config.json' }
}

if (-not ($obj.PSObject.Properties.Name -contains 'mcp')) {
    $obj | Add-Member -NotePropertyName 'mcp' -NotePropertyValue ([pscustomobject]@{})
}
$servers = $obj.mcp
if ($null -eq $servers) {
    $servers = [pscustomobject]@{}
    $obj.mcp = $servers
}

switch ($Op) {
    'add' {
        if (-not $Command) { Write-Error "add requires -Command"; exit 1 }
        $cmdArray = @($Command) + @($ArgsList)
        $entry = [pscustomobject]@{
            type    = 'local'
            command = $cmdArray
            enabled = $true
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
Set-Content -Path $ConfigPath -Value $json -Encoding UTF8
