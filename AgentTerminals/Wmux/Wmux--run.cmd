@echo off
setlocal

REM ============================================================
REM  wmux  --  native-Windows multiplexer for AI agents
REM  ------------------------------------------------------------
REM  Launches wmux in its own window. Split the window into panes
REM  (one agent per pane), and drive coordination from the side
REM  dock: message another agent, delegate a task to a pane, or
REM  fan a task out across git worktrees. Per-pane approval gates
REM  let you gate risky commands.
REM
REM  Start your agents INSIDE wmux (run 'claude', 'codex', 'gemini'
REM  in separate panes). Full docs / keybindings:
REM      https://github.com/openwong2kim/wmux
REM ============================================================

where wmux >nul 2>nul
if not errorlevel 1 (
    echo Launching wmux...
    start "" wmux %*
    endlocal
    exit /b 0
)

if exist "%LOCALAPPDATA%\Programs\wmux\wmux.exe" (
    echo Launching wmux...
    start "" "%LOCALAPPDATA%\Programs\wmux\wmux.exe" %*
) else if exist "%ProgramFiles%\wmux\wmux.exe" (
    echo Launching wmux...
    start "" "%ProgramFiles%\wmux\wmux.exe" %*
) else (
    echo wmux is not installed. Run Wmux--install.cmd first.
    echo [Or launch it from its Start-menu shortcut.]
    echo.
    pause
    endlocal
    exit /b 1
)
endlocal
