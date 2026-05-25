@echo off
setlocal

REM ============================================================
REM  Uninstall Hermes Agent  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Hermes ships a 'hermes uninstall' subcommand, but it
REM  hard-requires a TTY (calls _require_tty before parsing
REM  any --yes flag), so it cannot be driven from a batch
REM  script. Instead we replicate what it does on Windows:
REM    - kill any running hermes processes
REM    - remove the install code under %LOCALAPPDATA%\hermes\
REM      (hermes-agent, plus bundled git/ and node/ if present)
REM    - strip Hermes-owned entries from the User PATH
REM    - clear HERMES_HOME and HERMES_GIT_BASH_PATH user env vars
REM    - remove the Hermes-Gateway scheduled task / startup shim
REM      if the installer registered them
REM
REM  What this DOES NOT remove (on purpose):
REM    - %USERPROFILE%\.hermes  (config, sessions, API keys)
REM    - User data under %LOCALAPPDATA%\hermes\ (config.yaml,
REM      .env, sessions, memories, logs, etc.) - only the code
REM      subdirs (hermes-agent, git, node) are removed so a
REM      reinstall finds your settings intact.
REM  Delete those by hand if you want a fully clean slate.
REM ============================================================

REM  Tear down plugin entries BEFORE removing the CLI.
call "%~dp0..\Plugins\_apply-plugins.cmd" Hermes uninstall

set "HERMES_ROOT=%LOCALAPPDATA%\hermes"

REM ------------------------------------------------------------
REM  Step 1: stop any running hermes processes so the .exe and
REM          .dll files under venv\Scripts can be deleted.
REM          taskkill returns errorlevel 128 when no matching
REM          process exists - that is fine, swallow it.
REM ------------------------------------------------------------
echo Stopping any running hermes processes ...
taskkill /f /im hermes.exe       >nul 2>nul
taskkill /f /im hermes-agent.exe >nul 2>nul
taskkill /f /im hermes-acp.exe   >nul 2>nul

REM ------------------------------------------------------------
REM  Step 2: remove the Scheduled Task and Startup shortcut
REM          the installer may have registered for the gateway.
REM          schtasks returns non-zero if the task does not
REM          exist; ignore that.
REM ------------------------------------------------------------
echo.
echo Removing any Hermes scheduled task / startup entry ...
schtasks /Delete /TN "Hermes-Gateway" /F >nul 2>nul
set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
if exist "%STARTUP%\Hermes-Gateway.cmd" del /q "%STARTUP%\Hermes-Gateway.cmd"
if exist "%STARTUP%\hermes-gateway.cmd" del /q "%STARTUP%\hermes-gateway.cmd"

REM ------------------------------------------------------------
REM  Step 3: delete the install code. We leave the sibling
REM          data dirs (config.yaml, sessions, etc.) alone so
REM          a reinstall finds the user's settings.
REM ------------------------------------------------------------
echo.
call :remove_dir "%HERMES_ROOT%\hermes-agent"
call :remove_dir "%HERMES_ROOT%\git"
call :remove_dir "%HERMES_ROOT%\node"

REM ------------------------------------------------------------
REM  Step 4: strip every Hermes-owned entry from the User PATH
REM          (the installer prepends venv\Scripts, git\cmd,
REM          git\bin, git\usr\bin and node). We match on any
REM          entry whose path starts with %LOCALAPPDATA%\hermes\
REM          so we catch all of them in one pass.
REM ------------------------------------------------------------
echo.
echo Pruning Hermes entries from the User PATH ...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$root=[System.Environment]::ExpandEnvironmentVariables('%HERMES_ROOT%').TrimEnd('\'); $p=[Environment]::GetEnvironmentVariable('Path','User'); if (-not $p) { Write-Host 'User PATH is empty - nothing to prune.'; exit 0 }; $entries = $p -split ';'; $kept = @(); $removed = @(); foreach ($e in $entries) { if (-not $e) { continue }; $expanded = [System.Environment]::ExpandEnvironmentVariables($e).TrimEnd('\'); if ($expanded -ieq $root -or $expanded.StartsWith($root + '\', [System.StringComparison]::OrdinalIgnoreCase)) { $removed += $e } else { $kept += $e } }; if ($removed.Count -gt 0) { [Environment]::SetEnvironmentVariable('Path', ($kept -join ';'), 'User'); Write-Host ('Removed ' + $removed.Count + ' PATH entry/entries:'); $removed | ForEach-Object { Write-Host ('  ' + $_) } } else { Write-Host 'No Hermes PATH entries found.' }"

REM ------------------------------------------------------------
REM  Step 5: clear the User-scope env vars the installer set.
REM ------------------------------------------------------------
echo.
echo Clearing HERMES_HOME and HERMES_GIT_BASH_PATH user env vars ...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "foreach ($name in 'HERMES_HOME','HERMES_GIT_BASH_PATH') { $v = [Environment]::GetEnvironmentVariable($name,'User'); if ($v) { [Environment]::SetEnvironmentVariable($name, $null, 'User'); Write-Host ('Cleared ' + $name) } else { Write-Host ($name + ' was not set.') } }"

REM ------------------------------------------------------------
REM  Step 6: final state. 'where hermes' may still resolve in
REM          *this* shell because the parent Install-All session
REM          prepended the venv dir to its in-memory PATH; that
REM          is harmless and disappears in a new terminal.
REM ------------------------------------------------------------
echo.
if exist "%HERMES_ROOT%\hermes-agent\" (
    echo NOTE: %HERMES_ROOT%\hermes-agent is still on disk.
    echo Remove it manually if the steps above failed.
) else (
    echo Hermes Agent removed.
)
echo.
echo Done. Your %%USERPROFILE%%\.hermes and any data dirs left
echo under %HERMES_ROOT% ^(config.yaml, sessions, memories,
echo logs, etc.^) were NOT touched - delete them manually for
echo a fully clean slate.
goto :end


REM ============================================================
REM  Helpers
REM ============================================================

:remove_dir
if exist "%~1\" (
    echo Removing %~1 ...
    rmdir /s /q "%~1"
    if exist "%~1\" (
        echo WARNING: %~1 could not be fully removed.
        echo Some files may be locked by a running process.
    )
) else (
    echo %~1 not present - skipped.
)
exit /b 0


:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
