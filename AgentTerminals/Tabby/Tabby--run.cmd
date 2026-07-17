@echo off
setlocal

REM ============================================================
REM  Tabby  --  customizable GPU terminal with tabs + split panes
REM  ------------------------------------------------------------
REM  Launches Tabby in its own window. Multiplex without tmux:
REM      Ctrl+Shift+D   split pane downward
REM      Ctrl+Shift+R   split pane to the right
REM      Ctrl+Shift+ArrowKey  move focus between panes
REM      Ctrl+Shift+T   new tab
REM  Config is a YAML file managed from Settings; plugins and themes
REM  install from the in-app store. Docs: https://tabby.sh/.
REM
REM  Start your agents INSIDE Tabby (run 'claude', 'codex',
REM  'gemini' in separate panes).
REM ============================================================

set "TABBY_EXE=%LOCALAPPDATA%\Programs\Tabby\Tabby.exe"
if not exist "%TABBY_EXE%" set "TABBY_EXE=%ProgramFiles%\Tabby\Tabby.exe"

if exist "%TABBY_EXE%" (
    echo Launching Tabby...
    start "" "%TABBY_EXE%" %*
    endlocal
    exit /b 0
)

where tabby >nul 2>nul
if not errorlevel 1 (
    echo Launching Tabby...
    start "" tabby %*
    endlocal
    exit /b 0
)

echo Tabby is not installed. Run Tabby--install.cmd first.
echo (Or launch it from its Start-menu shortcut.)
echo.
pause
endlocal
exit /b 1
