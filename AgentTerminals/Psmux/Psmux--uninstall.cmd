@echo off
setlocal

REM ============================================================
REM  Uninstall psmux  --  matching uninstaller
REM  ------------------------------------------------------------
REM  This is a portable (zip) install, so removal is direct:
REM    1. stop any running instance (taskkill psmux/pmux)
REM    2. delete the install dir %LOCALAPPDATA%\Programs\psmux\
REM       (this also removes the bundled tmux.exe compat alias)
REM    3. prune %LOCALAPPDATA%\Programs\psmux\bin from the User PATH
REM
REM  Your %USERPROFILE%\.tmux.conf is NOT touched (psmux reads it but
REM  does not own it) - it stays for real tmux / a reinstall.
REM ============================================================

set "PS_HOME=%LOCALAPPDATA%\Programs\psmux"
set "PS_DIR=%PS_HOME%\bin"
set "PS_BIN=%PS_DIR%\psmux.exe"

REM  A running server/client locks the binaries; stop them first.
taskkill /F /IM psmux.exe >nul 2>nul
taskkill /F /IM pmux.exe  >nul 2>nul

if not exist "%PS_HOME%" (
    echo psmux is not installed at %PS_HOME%.
    echo Nothing to remove.
    goto :prune_path
)

echo.
echo Removing psmux install dir:
echo     %PS_HOME%
echo.
rmdir /s /q "%PS_HOME%" 2>nul
if exist "%PS_BIN%" (
    echo ERROR: Could not delete psmux.exe - is a 'psmux' process still
    echo running? Close every session and re-run this script.
    goto :failed
)
echo psmux binaries removed.

:prune_path
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$needle=Join-Path $env:LOCALAPPDATA 'Programs\psmux\bin'; $p=[Environment]::GetEnvironmentVariable('Path','User'); if ($p) { $parts = $p -split ';' | Where-Object { $_ -and ($_ -ne $needle) }; $new = ($parts -join ';'); if ($new -ne $p) { [Environment]::SetEnvironmentVariable('Path', $new, 'User'); Write-Host ('Pruned ' + $needle + ' from User PATH.') } else { Write-Host ('User PATH did not contain ' + $needle + ' - nothing to prune.') } }"

echo.
where psmux >nul 2>nul
if errorlevel 1 (
    echo psmux removed.
) else (
    echo NOTE: 'psmux' is still resolvable on PATH. It may be a second
    echo copy [e.g. 'cargo install psmux' or a scoop package]. Run
    echo 'where psmux' to investigate.
)
echo.
echo Done. Your %%USERPROFILE%%\.tmux.conf was NOT touched.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
