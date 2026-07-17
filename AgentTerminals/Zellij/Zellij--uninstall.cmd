@echo off
setlocal

REM ============================================================
REM  Uninstall Zellij  --  matching uninstaller
REM  ------------------------------------------------------------
REM  This is a portable (zip) install, so removal is direct:
REM    1. stop any running clients (taskkill zellij.exe)
REM    2. delete the install dir %LOCALAPPDATA%\Programs\Zellij\
REM    3. prune %LOCALAPPDATA%\Programs\Zellij\bin from the User PATH
REM
REM  Your config/layouts at %APPDATA%\zellij are LEFT IN PLACE, so
REM  reinstalling later restores your setup. To wipe it too, delete
REM  that folder by hand AFTER running this script:
REM      %APPDATA%\zellij
REM ============================================================

set "ZJ_HOME=%LOCALAPPDATA%\Programs\Zellij"
set "ZJ_DIR=%ZJ_HOME%\bin"
set "ZJ_BIN=%ZJ_DIR%\zellij.exe"

REM  A running session locks the binary; stop clients first.
REM  Best-effort: a "not found" is fine and stays quiet.
taskkill /F /IM zellij.exe >nul 2>nul

if not exist "%ZJ_HOME%" (
    echo Zellij is not installed at %ZJ_HOME%.
    echo Nothing to remove.
    goto :prune_path
)

echo.
echo Removing Zellij install dir:
echo     %ZJ_HOME%
echo.
rmdir /s /q "%ZJ_HOME%" 2>nul
if exist "%ZJ_BIN%" (
    echo ERROR: Could not delete zellij.exe - is a 'zellij' session
    echo still running? Close every session and re-run this script.
    goto :failed
)
echo Zellij binary removed.

:prune_path
REM  Prune the exact bin dir we added from the User PATH so the
REM  stale entry does not linger after uninstall.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$needle=Join-Path $env:LOCALAPPDATA 'Programs\Zellij\bin'; $p=[Environment]::GetEnvironmentVariable('Path','User'); if ($p) { $parts = $p -split ';' | Where-Object { $_ -and ($_ -ne $needle) }; $new = ($parts -join ';'); if ($new -ne $p) { [Environment]::SetEnvironmentVariable('Path', $new, 'User'); Write-Host ('Pruned ' + $needle + ' from User PATH.') } else { Write-Host ('User PATH did not contain ' + $needle + ' - nothing to prune.') } }"

echo.
where zellij >nul 2>nul
if errorlevel 1 (
    echo Zellij removed.
) else (
    echo NOTE: 'zellij' is still resolvable on PATH. It may be a second
    echo copy (e.g. 'cargo install zellij' or a winget package). Run
    echo 'where zellij' to investigate.
)
echo.
echo Done. Your %%APPDATA%%\zellij config/layouts were NOT touched -
echo delete that folder manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
