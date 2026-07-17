@echo off
setlocal

REM ============================================================
REM  Update Windows Terminal  --  in-place upgrade via winget
REM  ------------------------------------------------------------
REM  Windows Terminal usually updates itself through the Microsoft
REM  Store; the CLI upgrade here is winget. If the Store owns the
REM  package, winget may report nothing to do - that's expected.
REM ============================================================

where winget >nul 2>nul
if errorlevel 1 (
    echo winget was not found - cannot update from the CLI. Windows
    echo Terminal updates automatically via the Microsoft Store.
    goto :end
)

winget list -e --id Microsoft.WindowsTerminal >nul 2>nul
if errorlevel 1 (
    where wt >nul 2>nul
    if errorlevel 1 (
        echo Windows Terminal is not installed - nothing to update.
        echo Run WindowsTerminal--install.cmd first.
        goto :end
    )
    echo Windows Terminal appears installed via the Store, not winget.
    echo It updates through the Store; nothing to do here.
    goto :end
)

echo.
echo Updating Windows Terminal via winget...
echo.
winget upgrade -e --id Microsoft.WindowsTerminal --accept-source-agreements --accept-package-agreements
REM  Non-zero simply means nothing to upgrade (or Store-managed); not an error.
echo.
echo Update check complete.

:end
echo.
if not defined AGENTS_UPDATE_ALL pause
endlocal
