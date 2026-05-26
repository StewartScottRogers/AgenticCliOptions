# Wrapper around the upstream Hermes install.ps1 that suppresses a
# misleading Playwright warning.
#
# Upstream runs `npx --yes playwright install chromium` from $InstallDir,
# whose package.json does not list `playwright` as a direct dependency.
# Playwright's CLI then prints a multi-line "running npx playwright install
# without first installing your project's dependencies" warning box even
# though the install completes fine. The warning hides the real progress
# stream and looks alarming.
#
# We download the upstream script, replace the single npx call with a
# version that first cd's into a stub directory whose package.json declares
# `playwright`, then run the patched script. Playwright's cwd-package.json
# check sees itself listed and stays quiet. If upstream reformats the
# anchor line, the Replace no-ops, a notice is printed, and the original
# (noisy) install still runs to completion.

$ErrorActionPreference = 'Stop'
$ProgressPreference    = 'SilentlyContinue'

$url = 'https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1'
$src = Invoke-RestMethod -Uri $url -TimeoutSec 60

$find = '                    & $npxExe --yes playwright install chromium 2>&1 | ForEach-Object { "$_" } | Tee-Object -FilePath $pwLog'
$repl = @'
                    $pwStubDir = (New-Item -ItemType Directory -Force -Path "$env:TEMP\hermes-pw-stub").FullName
                    Set-Content -Path "$pwStubDir\package.json" -Value '{"name":"hermes-pw-stub","version":"1.0.0","dependencies":{"playwright":"*"}}' -Encoding utf8
                    Push-Location $pwStubDir
                    try { & $npxExe --yes playwright install chromium 2>&1 | ForEach-Object { "$_" } | Tee-Object -FilePath $pwLog } finally { Pop-Location }
'@

if ($src.Contains($find)) {
    $src = $src.Replace($find, $repl)
} else {
    Write-Warning "Could not locate Playwright-call anchor in upstream install.ps1 -- running unpatched. The 'npx playwright install without first installing project dependencies' warning may reappear, but the install still works."
}

Invoke-Expression $src
