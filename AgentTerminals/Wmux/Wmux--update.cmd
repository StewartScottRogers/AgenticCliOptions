@echo off
setlocal

REM ============================================================
REM  Update wmux  --  in-place upgrade via winget
REM  ------------------------------------------------------------
REM  wmux ships an in-app AutoUpdater, but the supported CLI upgrade
REM  here is winget. Close any open wmux window first so files that
REM  are in use can be replaced.
REM ============================================================

where winget >nul 2>nul
if errorlevel 1 (
    echo winget was not found - cannot update. Install "App Installer"
    echo from the Microsoft Store, or use wmux's in-app updater, or
    echo grab the latest Setup.exe from
    echo https://github.com/openwong2kim/wmux/releases
    goto :end
)

winget list -e --id openwong2kim.wmux >nul 2>nul
if errorlevel 1 (
    where wmux >nul 2>nul
    if errorlevel 1 (
        echo wmux is not installed - nothing to update.
        echo Run Wmux--install.cmd first.
        goto :end
    )
)

echo.
echo Updating wmux via winget...
echo.
winget upgrade -e --id openwong2kim.wmux --accept-source-agreements --accept-package-agreements
REM  winget exits non-zero when there is simply nothing to upgrade;
REM  that is not an error for our purposes.
echo.
echo Update check complete.

:end
echo.
if not defined AGENTS_UPDATE_ALL pause
endlocal
