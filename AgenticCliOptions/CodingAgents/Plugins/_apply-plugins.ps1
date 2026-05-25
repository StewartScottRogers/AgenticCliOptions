# ============================================================
#  Apply plugins for one agent  (shared dispatcher, PS sidecar)
#  ------------------------------------------------------------
#  Walks every Plugins\<name>\plugin.json, filters by manifest
#  scope + supports, and runs the matching install/uninstall
#  hook for the named agent.
#
#  Scope semantics:
#    shared    - manifest.supports must contain $Agent
#    per-agent - manifest.agent must equal $Agent
#
#  Hook lookup: <plugin>\<install|uninstall>\<agent-lower>.cmd
#  Missing hooks are skipped (not an error) so a "shared" plugin
#  can declare support for an agent it does not yet have a hook
#  for, without breaking the host install.
#
#  Always exits 0. A plugin failure must not break the host
#  agent's install/uninstall flow - we surface a warning and
#  move on. The caller stays in control of overall success.
# ============================================================
param(
    [Parameter(Mandatory=$true)][string]$Agent,
    [Parameter(Mandatory=$true)][ValidateSet('install','uninstall')][string]$Action
)
$ErrorActionPreference = 'Continue'
$pluginsRoot = $PSScriptRoot
$any = $false

foreach ($dir in Get-ChildItem -Path $pluginsRoot -Directory -ErrorAction SilentlyContinue) {
    $manifestPath = Join-Path $dir.FullName 'plugin.json'
    if (-not (Test-Path $manifestPath)) { continue }

    try {
        $m = Get-Content $manifestPath -Raw | ConvertFrom-Json
    } catch {
        Write-Host "  [skip] $($dir.Name): manifest is not valid JSON ($_)"
        continue
    }

    switch ($m.scope) {
        'per-agent' {
            if (-not $m.agent -or $m.agent -ne $Agent) { continue }
        }
        'shared' {
            if (-not ($m.supports -contains $Agent)) { continue }
        }
        default {
            Write-Host "  [skip] $($dir.Name): unknown scope '$($m.scope)'"
            continue
        }
    }

    $hook = Join-Path $dir.FullName ("{0}\{1}.cmd" -f $Action, $Agent.ToLower())
    if (-not (Test-Path $hook)) {
        # Quiet skip - a plugin can legitimately support an agent
        # in spirit but not yet ship a hook. The Install-Plugin
        # path is noisier about this when it is the user's intent.
        continue
    }

    $any = $true
    Write-Host "  [$Action] $($m.name) -> $Agent"
    & cmd /c "`"$hook`""
    if ($LASTEXITCODE -ne 0) {
        Write-Host "  [warn] $($m.name) $Action hook returned exit $LASTEXITCODE"
    }
}

if (-not $any) { Write-Host "  (no plugins applicable to $Agent)" }
exit 0
