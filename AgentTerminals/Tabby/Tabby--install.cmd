@echo off
setlocal

REM ============================================================
REM  Install Tabby  --  turn-key installer
REM  ------------------------------------------------------------
REM  Tabby (formerly Terminus) is a highly customizable, cross-
REM  platform GPU terminal for Windows/macOS/Linux with native
REM  tabs and split panes - so you can run several AI coding agents
REM  side by side in one window without tmux/zellij underneath.
REM  Rich plugin + theme ecosystem, SSH/serial client, portable
REM  mode. It is a general terminal (not agent-aware) - a GUI
REM  sibling to WezTerm.
REM  See https://tabby.sh/ and https://github.com/Eugeny/tabby.
REM
REM  Install method: winget (official package 'Eugeny.Tabby').
REM      winget install -e --id Eugeny.Tabby
REM ============================================================

echo.
echo Installing Tabby via winget (Eugeny.Tabby)...
echo.

where winget >nul 2>nul
if errorlevel 1 (
    echo ERROR: winget was not found. Tabby is distributed through the
    echo Windows Package Manager. Install "App Installer" from the
    echo Microsoft Store [which provides winget], then re-run this script.
    echo Alternatively grab the installer from https://tabby.sh/.
    goto :failed
)

winget install -e --id Eugeny.Tabby --accept-source-agreements --accept-package-agreements
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
    winget list -e --id Eugeny.Tabby >nul 2>nul
    if errorlevel 1 goto :failed
)

echo.
if exist "%LOCALAPPDATA%\Programs\Tabby\Tabby.exe" (
    echo Tabby installed at:
    echo     %LOCALAPPDATA%\Programs\Tabby\Tabby.exe
) else (
    echo Tabby installed via winget.
)

echo.
echo Done. Launch it with Tabby--run.cmd, or from the Start menu.
echo Split panes with Ctrl+Shift+D (down) / Ctrl+Shift+R (right) and
echo run one agent per pane.
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
