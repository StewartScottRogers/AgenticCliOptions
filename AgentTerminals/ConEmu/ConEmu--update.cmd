@echo off
setlocal

REM ============================================================
REM  Update ConEmu  --  in-place upgrade via winget
REM  ------------------------------------------------------------
REM  ConEmu also checks for updates in-app (Settings > Update), but
REM  the supported CLI upgrade here is winget. Close any open ConEmu
REM  window first so files that are in use can be replaced.
REM ============================================================

where winget >nul 2>nul
if errorlevel 1 (
    echo winget was not found - cannot update. Install "App Installer"
    echo from the Microsoft Store, or use ConEmu's Settings ^> Update.
    goto :end
)

winget list -e --id Maximus5.ConEmu >nul 2>nul
if errorlevel 1 (
    if not exist "%ProgramFiles%\ConEmu\ConEmu64.exe" (
        echo ConEmu is not installed - nothing to update.
        echo Run ConEmu--install.cmd first.
        goto :end
    )
)

echo.
echo Updating ConEmu via winget...
echo.
winget upgrade -e --id Maximus5.ConEmu --accept-source-agreements --accept-package-agreements
REM  winget exits non-zero when there is nothing to upgrade; not an error.
echo.
echo Update check complete.

:end
echo.
if not defined AGENTS_UPDATE_ALL pause
endlocal
