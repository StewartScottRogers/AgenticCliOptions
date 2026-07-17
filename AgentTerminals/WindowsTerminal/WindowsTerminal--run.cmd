@echo off
setlocal

REM ============================================================
REM  Windows Terminal  --  Microsoft's native tabs + split panes
REM  ------------------------------------------------------------
REM  Running 'wt' opens a new Windows Terminal window. Multiplex
REM  within a tab:
REM      Alt+Shift++    split pane to the right
REM      Alt+Shift+-    split pane downward
REM      Alt+ArrowKey   move focus between panes
REM      Ctrl+Shift+T   new tab   /   Ctrl+Shift+W  close pane
REM  You can also open a pre-split layout from one command, e.g.:
REM      wt split-pane -H claude ; split-pane -V codex
REM  Config is settings.json (Ctrl+,). Docs:
REM      https://learn.microsoft.com/windows/terminal/
REM
REM  NOTE: Windows Terminal does NOT persist sessions - closing the
REM  window ends every pane's process. For detach/re-attach use
REM  Zellij, WezTerm, or psmux instead.
REM ============================================================

where wt >nul 2>nul
if errorlevel 1 (
    echo Windows Terminal is not installed. Run WindowsTerminal--install.cmd
    echo first, or install it from the Microsoft Store.
    echo.
    pause
    endlocal
    exit /b 1
)

echo Launching Windows Terminal...
start "" wt %*
endlocal
