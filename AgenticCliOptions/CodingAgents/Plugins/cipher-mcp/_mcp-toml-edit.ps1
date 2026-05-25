# ============================================================
#  Idempotently add/remove an MCP server entry in Codex's
#  ~/.codex/config.toml, under [mcp_servers.<Name>].
#
#  Why a hand-rolled TOML editor instead of a library: Windows
#  PowerShell 5.1 ships with no TOML parser, and pulling in
#  Tomlyn/PSToml would bloat install. The entries Codex expects
#  are simple flat tables (`command`, `args`), so a marker-fenced
#  block approach is sufficient and easy to reason about.
#
#  The block is fenced with sentinels so add/remove can find and
#  replace it atomically without touching the rest of the file:
#      # >>> agentic-cli-plugins: cipher >>>
#      [mcp_servers.cipher]
#      command = "npx"
#      args = ["-y", "@byterover/cipher", "--mode", "mcp"]
#      # <<< agentic-cli-plugins: cipher <<<
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

$beginMark = "# >>> agentic-cli-plugins: $Name >>>"
$endMark   = "# <<< agentic-cli-plugins: $Name <<<"

$existing = if (Test-Path $ConfigPath) { Get-Content $ConfigPath -Raw } else { "" }
$pattern  = "(?ms)^" + [regex]::Escape($beginMark) + ".*?^" + [regex]::Escape($endMark) + "\s*"
$stripped = [regex]::Replace($existing, $pattern, '')
# Trim trailing blank lines we may have left behind.
$stripped = $stripped.TrimEnd("`r","`n") + "`r`n"

if ($Op -eq 'remove') {
    if ($stripped.Trim().Length -eq 0) {
        if (Test-Path $ConfigPath) { Remove-Item $ConfigPath -Force }
    } else {
        Set-Content -Path $ConfigPath -Value $stripped -Encoding UTF8 -NoNewline
    }
    return
}

if (-not $Command) { Write-Error "add requires -Command"; exit 1 }

$tomlArgs = ($ArgsList | ForEach-Object { '"' + ($_ -replace '"','\"') + '"' }) -join ', '
$block = @"
$beginMark
[mcp_servers.$Name]
command = "$Command"
args = [$tomlArgs]
$endMark
"@

$content = $stripped + $block + "`r`n"
Set-Content -Path $ConfigPath -Value $content -Encoding UTF8 -NoNewline
