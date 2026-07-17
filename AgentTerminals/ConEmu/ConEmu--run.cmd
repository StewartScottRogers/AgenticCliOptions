@echo off
setlocal

REM ============================================================
REM  ConEmu  --  customizable Windows console with tabs + splits
REM  ------------------------------------------------------------
REM  Launches ConEmu in its own window. Split panes:
REM      Ctrl+Shift+O   duplicate active shell into a pane (below)
REM      Ctrl+Shift+E   duplicate active shell into a pane (right)
REM      the [+] status-bar / tab menu -> "Split" for a new console
REM                     with any shell, credentials, or elevation
REM      Ctrl+Tab       cycle panes/consoles
REM  ConEmu can host cmd, PowerShell, pwsh, or any console app - run
REM  one AI agent per pane in a tiled grid. Docs:
REM      https://conemu.github.io/en/SplitScreen.html
REM ============================================================

set "CE_EXE=%ProgramFiles%\ConEmu\ConEmu64.exe"
if not exist "%CE_EXE%" set "CE_EXE=%ProgramFiles(x86)%\ConEmu\ConEmu.exe"

if exist "%CE_EXE%" (
    echo Launching ConEmu...
    start "" "%CE_EXE%" %*
    endlocal
    exit /b 0
)

where ConEmu64 >nul 2>nul
if not errorlevel 1 (
    echo Launching ConEmu...
    start "" ConEmu64 %*
    endlocal
    exit /b 0
)

echo ConEmu is not installed. Run ConEmu--install.cmd first.
echo (Or launch it from its Start-menu shortcut.)
echo.
pause
endlocal
exit /b 1
