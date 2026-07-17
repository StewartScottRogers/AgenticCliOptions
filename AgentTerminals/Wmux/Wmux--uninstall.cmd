@echo off
setlocal

REM ============================================================
REM  Uninstall wmux  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes the winget package 'openwong2kim.wmux'. Any running
REM  wmux window is stopped first so files aren't locked.
REM
REM  Your wmux config/state (typically under %APPDATA%\wmux) is
REM  LEFT IN PLACE. Delete that folder by hand for a clean slate.
REM ============================================================

taskkill /F /IM wmux.exe >nul 2>nul

where winget >nul 2>nul
if errorlevel 1 (
    echo winget was not found. If wmux was installed some other way,
    echo remove it via Settings ^> Apps, then delete %%APPDATA%%\wmux.
    goto :end
)

winget list -e --id openwong2kim.wmux >nul 2>nul
if errorlevel 1 (
    echo wmux [openwong2kim.wmux] is not installed via winget.
    echo Nothing to remove.
    goto :verify
)

echo.
echo Removing wmux via winget...
echo.
winget uninstall -e --id openwong2kim.wmux
if errorlevel 1 (
    echo.
    echo ERROR: winget uninstall reported a problem - see above. If a
    echo wmux window is still open, close it and re-run this script.
    goto :end
)

:verify
echo.
where wmux >nul 2>nul
if errorlevel 1 (
    echo wmux removed.
) else (
    echo NOTE: 'wmux' is still resolvable on PATH - it may be a second
    echo copy installed outside winget. Run 'where wmux' to check.
)
echo.
echo Done. Your %%APPDATA%%\wmux config/state was NOT touched -
echo delete it manually if you want a fully clean slate.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
