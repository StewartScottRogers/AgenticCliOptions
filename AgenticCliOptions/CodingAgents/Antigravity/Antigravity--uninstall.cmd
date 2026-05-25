@echo off
setlocal

REM ============================================================
REM  Uninstall Google Antigravity CLI  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the agy.exe binary and its install dir
REM  (%LOCALAPPDATA%\agy\). Leaves your %USERPROFILE%\.antigravity
REM  config directory alone, so reinstalling later restores your
REM  signed-in account, plugins, skills and hooks exactly as they
REM  were.
REM
REM  Upstream has not (yet) shipped an 'agy uninstall' subcommand,
REM  so we delete the binary directly. The installer's User PATH
REM  entry for %LOCALAPPDATA%\agy\bin is pruned from the registry.
REM
REM  If you also want to delete saved sessions, sign-in tokens and
REM  settings, remove these folders by hand AFTER running this:
REM      %USERPROFILE%\.antigravity
REM      %LOCALAPPDATA%\antigravity
REM ============================================================

REM  Tear down plugin entries BEFORE removing the CLI so hooks
REM  that edit ~/.antigravity/settings.json see the live config.
call "%~dp0..\Plugins\_apply-plugins.cmd" Antigravity uninstall

set "AGY_DIR=%LOCALAPPDATA%\agy"
set "AGY_BIN=%AGY_DIR%\bin\agy.exe"
set "AGY_STAGING=%LOCALAPPDATA%\antigravity\staging"

if not exist "%AGY_BIN%" (
    echo Antigravity CLI is not installed at %AGY_BIN%.
    echo Nothing to remove.
    goto :prune_path
)

echo.
echo Removing Antigravity CLI binary at:
echo     %AGY_BIN%
echo.
del /f /q "%AGY_BIN%" 2>nul
if exist "%AGY_BIN%" (
    echo ERROR: Could not delete agy.exe - is an 'agy' process still
    echo running? Close it and re-run this script.
    goto :failed
)

REM  Remove the install dir and any leftover staging artifacts. The
REM  rmdir calls are best-effort: they fail silently if the dir is
REM  not empty (e.g. user-added files we should not delete).
rmdir "%AGY_DIR%\bin" 2>nul
rmdir "%AGY_DIR%"     2>nul
if exist "%AGY_STAGING%" rmdir /s /q "%AGY_STAGING%" 2>nul

echo Antigravity CLI binary removed.

:prune_path
REM  The installer added %LOCALAPPDATA%\agy\bin to the User PATH.
REM  Prune that entry from the registry so the stale dir does not
REM  linger on PATH after uninstall. Only the exact match is removed.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$needle=Join-Path $env:LOCALAPPDATA 'agy\bin'; $p=[Environment]::GetEnvironmentVariable('Path','User'); if ($p) { $parts = $p -split ';' | Where-Object { $_ -and ($_ -ne $needle) }; $new = ($parts -join ';'); if ($new -ne $p) { [Environment]::SetEnvironmentVariable('Path', $new, 'User'); Write-Host ('Pruned ' + $needle + ' from User PATH.') } else { Write-Host ('User PATH did not contain ' + $needle + ' - nothing to prune.') } }"

echo.
where agy >nul 2>nul
if errorlevel 1 (
    echo Antigravity CLI removed.
) else (
    echo NOTE: 'agy' is still resolvable on PATH. It may be a stale
    echo shim or a second copy installed elsewhere. Run 'where agy'
    echo to investigate.
)
echo.
echo Done. Your %%USERPROFILE%%\.antigravity config directory was
echo NOT touched - delete it manually if you want a fully clean
echo slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
