@echo off
setlocal

REM ============================================================
REM  Uninstall herdr  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Upstream has not (yet) shipped a 'herdr uninstall' subcommand,
REM  so we remove it directly:
REM    1. stop the background server + any clients (taskkill herdr.exe)
REM    2. delete the install dir %LOCALAPPDATA%\Programs\Herdr\
REM       (the 'current' junction + bin shim)
REM    3. delete the binary package cache %USERPROFILE%\.herdr\packages\
REM    4. prune %LOCALAPPDATA%\Programs\Herdr\bin from the User PATH
REM
REM  Your %USERPROFILE%\.herdr config/state (workspaces, settings,
REM  keybindings, layouts) is LEFT IN PLACE, so reinstalling later
REM  restores your setup. To wipe it too, delete this folder by hand
REM  AFTER running this script:
REM      %USERPROFILE%\.herdr
REM ============================================================

set "HERDR_HOME=%LOCALAPPDATA%\Programs\Herdr"
set "HERDR_DIR=%HERDR_HOME%\bin"
set "HERDR_BIN=%HERDR_DIR%\herdr.exe"
set "HERDR_PKGS=%USERPROFILE%\.herdr\packages"

REM  herdr keeps a background server alive; the binary can't be
REM  deleted while it (or a client) is running. Stop them first.
REM  Best-effort: a "not found" is fine and stays quiet.
taskkill /F /IM herdr.exe >nul 2>nul

if not exist "%HERDR_HOME%" (
    echo herdr is not installed at %HERDR_HOME%.
    echo Nothing to remove.
    goto :prune_path
)

echo.
echo Removing herdr install dir:
echo     %HERDR_HOME%
echo.
rmdir /s /q "%HERDR_HOME%" 2>nul
if exist "%HERDR_BIN%" (
    echo ERROR: Could not delete herdr.exe - is a 'herdr' process still
    echo running? Close every herdr pane/server and re-run this script.
    goto :failed
)

REM  Remove the cached release binaries. Best-effort; leaves the rest
REM  of %USERPROFILE%\.herdr (settings, workspaces) untouched.
if exist "%HERDR_PKGS%" (
    echo Removing cached release binaries:
    echo     %HERDR_PKGS%
    rmdir /s /q "%HERDR_PKGS%" 2>nul
)

echo herdr binaries removed.

:prune_path
REM  The installer added %LOCALAPPDATA%\Programs\Herdr\bin to the
REM  User PATH. Prune that exact entry from the registry so the
REM  stale dir does not linger on PATH after uninstall.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$needle=Join-Path $env:LOCALAPPDATA 'Programs\Herdr\bin'; $p=[Environment]::GetEnvironmentVariable('Path','User'); if ($p) { $parts = $p -split ';' | Where-Object { $_ -and ($_ -ne $needle) }; $new = ($parts -join ';'); if ($new -ne $p) { [Environment]::SetEnvironmentVariable('Path', $new, 'User'); Write-Host ('Pruned ' + $needle + ' from User PATH.') } else { Write-Host ('User PATH did not contain ' + $needle + ' - nothing to prune.') } }"

echo.
where herdr >nul 2>nul
if errorlevel 1 (
    echo herdr removed.
) else (
    echo NOTE: 'herdr' is still resolvable on PATH. It may be a stale
    echo shim or a second copy installed elsewhere. Run 'where herdr'
    echo to investigate.
)
echo.
echo Done. Your %%USERPROFILE%%\.herdr config/state was NOT touched -
echo delete it manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
