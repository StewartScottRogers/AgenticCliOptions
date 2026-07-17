@echo off
setlocal

REM ============================================================
REM  Update Tabby  --  in-place upgrade via winget
REM  ------------------------------------------------------------
REM  Tabby also self-updates in-app, but the supported CLI upgrade
REM  here is winget. Close any open Tabby window first so files
REM  that are in use can be replaced.
REM ============================================================

where winget >nul 2>nul
if errorlevel 1 (
    echo winget was not found - cannot update. Install "App Installer"
    echo from the Microsoft Store, or use Tabby's in-app updater.
    goto :end
)

winget list -e --id Eugeny.Tabby >nul 2>nul
if errorlevel 1 (
    if not exist "%LOCALAPPDATA%\Programs\Tabby\Tabby.exe" (
        echo Tabby is not installed - nothing to update.
        echo Run Tabby--install.cmd first.
        goto :end
    )
)

echo.
echo Updating Tabby via winget...
echo.
winget upgrade -e --id Eugeny.Tabby --accept-source-agreements --accept-package-agreements
REM  winget exits non-zero when there is nothing to upgrade; not an error.
echo.
echo Update check complete.

:end
echo.
if not defined AGENTS_UPDATE_ALL pause
endlocal
