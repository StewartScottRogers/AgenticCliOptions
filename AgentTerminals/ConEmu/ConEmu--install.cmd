@echo off
setlocal

REM ============================================================
REM  Install ConEmu  --  turn-key installer
REM  ------------------------------------------------------------
REM  ConEmu (ConEmu-Maximus5) is the veteran customizable Windows
REM  console: one GUI window hosting many consoles as tabs, with
REM  free-grid SPLIT PANES. It can host any shell (cmd, PowerShell,
REM  pwsh) or console app, each pane a different shell / elevation -
REM  so you can run several AI coding agents in a tiled grid. Battle-
REM  tested for well over a decade. Cmder is built on top of ConEmu.
REM  See https://conemu.github.io/.
REM
REM  Install method: winget (official package 'Maximus5.ConEmu').
REM      winget install -e --id Maximus5.ConEmu
REM ============================================================

echo.
echo Installing ConEmu via winget (Maximus5.ConEmu)...
echo.

where winget >nul 2>nul
if errorlevel 1 (
    echo ERROR: winget was not found. ConEmu is distributed through the
    echo Windows Package Manager. Install "App Installer" from the
    echo Microsoft Store [which provides winget], then re-run this script.
    echo Alternatively grab the installer from https://conemu.github.io/.
    goto :failed
)

winget install -e --id Maximus5.ConEmu --accept-source-agreements --accept-package-agreements
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
    winget list -e --id Maximus5.ConEmu >nul 2>nul
    if errorlevel 1 goto :failed
)

echo.
if exist "%ProgramFiles%\ConEmu\ConEmu64.exe" (
    echo ConEmu installed at:
    echo     %ProgramFiles%\ConEmu\ConEmu64.exe
) else (
    echo ConEmu installed via winget.
)

echo.
echo Done. Launch it with ConEmu--run.cmd, or from the Start menu.
echo Split the active tab into panes with Ctrl+Shift+O / Ctrl+Shift+E
echo (or the [+] "New console" split menu) and run one agent per pane.
goto :end


:failed
echo.
echo ERROR: Installation failed - see the output above.
echo Common causes:
echo   - winget not installed (install "App Installer" from the Store)
echo   - No internet connection / winget source unavailable
echo   - Package agreements not accepted

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
