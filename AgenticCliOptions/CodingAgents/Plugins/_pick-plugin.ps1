# ============================================================
#  Interactive plugin picker for Install-Plugin / Uninstall-Plugin
#  ------------------------------------------------------------
#  Lists every plugin under -PluginsRoot with its description and
#  supported agents, prompts for a choice (number or name), and
#  writes the resolved plugin name to -OutFile so the calling
#  .cmd shim can pick it up.
#
#  Exit codes:
#    0 - selection written to -OutFile
#    1 - error (no plugins, bad input, manifest unreadable)
#    2 - user pressed Enter without picking (silent cancel)
# ============================================================
param(
    [Parameter(Mandatory=$true)][string]$PluginsRoot,
    [Parameter(Mandatory=$true)][string]$OutFile,
    [Parameter(Mandatory=$false)][ValidateSet('install','uninstall')][string]$Action = 'install'
)

$plugins = @(Get-ChildItem -Directory -Path $PluginsRoot -ErrorAction SilentlyContinue |
    Sort-Object Name |
    Where-Object { Test-Path (Join-Path $_.FullName 'plugin.json') })

if ($plugins.Count -eq 0) {
    Write-Host "  (no plugins found under $PluginsRoot)"
    exit 1
}

Write-Host ''
Write-Host "Available plugins (pick one to $Action):"

$i = 0
foreach ($p in $plugins) {
    $i++
    $manifest = Join-Path $p.FullName 'plugin.json'
    try {
        $m = Get-Content -Raw $manifest | ConvertFrom-Json
    } catch {
        Write-Host ''
        Write-Host ('  {0,2}) {1}' -f $i, $p.Name)
        Write-Host '       (manifest unreadable)'
        continue
    }

    $desc     = if ($m.description) { [string]$m.description } else { '(no description)' }
    $supports = if ($m.supports)    { ($m.supports -join ', ') }
                elseif ($m.agent)   { [string]$m.agent }
                else                { '(none)' }
    $version  = if ($m.version)     { [string]$m.version } else { '' }

    Write-Host ''
    if ($version) {
        Write-Host ('  {0,2}) {1}  (v{2})' -f $i, $p.Name, $version)
    } else {
        Write-Host ('  {0,2}) {1}' -f $i, $p.Name)
    }

    # Word-wrap the description at ~72 chars with a 7-space indent.
    $indent = '       '
    $maxW   = 72
    $line   = $indent
    foreach ($w in ($desc -split '\s+')) {
        if ($w.Length -eq 0) { continue }
        if ($line.Length -gt $indent.Length -and ($line.Length + 1 + $w.Length) -gt $maxW) {
            Write-Host $line
            $line = $indent + $w
        } elseif ($line.Length -eq $indent.Length) {
            $line += $w
        } else {
            $line += ' ' + $w
        }
    }
    if ($line.Length -gt $indent.Length) { Write-Host $line }
    Write-Host ($indent + 'Supports: ' + $supports)
}

Write-Host ''
$pick = Read-Host '  Plugin name or number'
if ([string]::IsNullOrWhiteSpace($pick)) { exit 2 }
$pick = $pick.Trim()

if ($pick -match '^\d+$') {
    $idx = [int]$pick
    if ($idx -lt 1 -or $idx -gt $plugins.Count) {
        Write-Host "  Invalid number: $pick"
        exit 1
    }
    $selected = $plugins[$idx - 1].Name
} else {
    $match = @($plugins | Where-Object { $_.Name -ieq $pick })
    if ($match.Count -eq 0) {
        Write-Host "  Unknown plugin: $pick"
        exit 1
    }
    $selected = $match[0].Name
}

# -NoNewline keeps the file a single bare token so CMD's for /f
# reads exactly the plugin name with no trailing whitespace games.
Set-Content -Path $OutFile -Value $selected -Encoding ASCII -NoNewline
exit 0
