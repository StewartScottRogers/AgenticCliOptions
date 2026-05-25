# ============================================================
#  Fan one plugin's install hook out to every supporting agent
#  ------------------------------------------------------------
#  Called by Install-Plugin.cmd. Reads the named plugin's
#  manifest, walks every agent in `supports` (or just the
#  declared `agent` for per-agent plugins), checks each agent
#  is actually installed via its <Agent>--is-installed.cmd
#  probe, and runs the install hook for the ones that are.
#
#  Action is parameterised so the symmetric uninstall flow can
#  reuse this script via Uninstall-Plugin.cmd.
# ============================================================
param(
    [Parameter(Mandatory=$true)][string]$Plugin,
    [Parameter(Mandatory=$true)][string]$AgentsRoot,
    [Parameter(Mandatory=$false)][ValidateSet('install','uninstall')][string]$Action = 'install'
)
$ErrorActionPreference = 'Continue'
$pluginDir    = Join-Path $PSScriptRoot $Plugin
$manifestPath = Join-Path $pluginDir 'plugin.json'

if (-not (Test-Path $manifestPath)) {
    Write-Error "Plugin '$Plugin' has no plugin.json at $manifestPath"
    exit 1
}

try {
    $m = Get-Content $manifestPath -Raw | ConvertFrom-Json
} catch {
    Write-Error "Plugin '$Plugin' manifest is not valid JSON: $_"
    exit 1
}

$targets = switch ($m.scope) {
    'per-agent' {
        if (-not $m.agent) {
            Write-Error "scope=per-agent but no 'agent' field in manifest"; exit 1
        }
        @($m.agent)
    }
    'shared' { @($m.supports) }
    default {
        Write-Error "Unknown scope '$($m.scope)' in plugin manifest"; exit 1
    }
}

Write-Host ""
Write-Host "$Action plugin '$($m.name)' (kind=$($m.kind), scope=$($m.scope))..."
$applied = 0
$skipped = 0

foreach ($agent in $targets) {
    $probe = Join-Path $AgentsRoot "$agent\$agent--is-installed.cmd"
    if (-not (Test-Path $probe)) {
        Write-Host "  [skip] $agent : probe missing ($probe)"
        $skipped++; continue
    }
    & cmd /c "`"$probe`"" 2>$null | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [skip] $agent : not installed"
        $skipped++; continue
    }
    $hook = Join-Path $pluginDir ("{0}\{1}.cmd" -f $Action, $agent.ToLower())
    if (-not (Test-Path $hook)) {
        Write-Host "  [skip] $agent : plugin has no $Action hook"
        $skipped++; continue
    }
    Write-Host "  [$Action] $agent"
    & cmd /c "`"$hook`""
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [warn] $agent : hook returned exit $LASTEXITCODE"
    } else {
        $applied++
    }
}

Write-Host ""
Write-Host ("Done. {0} agent(s) {1}ed, {2} skipped." -f $applied, $Action, $skipped)
exit 0
