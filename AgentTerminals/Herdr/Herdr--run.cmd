@echo off
setlocal

REM ============================================================
REM  herdr  --  terminal multiplexer for AI coding agents
REM  ------------------------------------------------------------
REM  Running 'herdr' with no arguments attaches to (or starts) the
REM  background server and opens the multiplexer. The server keeps
REM  every pane and agent process alive after you detach or close
REM  the terminal, so re-running this re-attaches exactly where you
REM  left off - including over SSH.
REM
REM  Quick keys (tmux-compatible; prefix is Ctrl+B by default):
REM      Ctrl+B  %  split pane vertically
REM      Ctrl+B  "  split pane horizontally
REM      Ctrl+B  arrows  move between panes
REM      Ctrl+B  d  detach (server keeps running in the background)
REM  It is also mouse-first: click panes, drag borders, right-click
REM  for split/switch menus. Full keymap: https://herdr.dev/docs/.
REM
REM  Start your agents INSIDE herdr (e.g. run 'claude', 'codex',
REM  'gemini' in separate panes) and the sidebar tracks each one's
REM  state: blocked / working / done / idle.
REM ============================================================

where herdr >nul 2>nul
if errorlevel 1 (
    if exist "%LOCALAPPDATA%\Programs\Herdr\bin\herdr.exe" (
        set "PATH=%LOCALAPPDATA%\Programs\Herdr\bin;%PATH%"
    ) else (
        echo herdr is not installed. Run Herdr--install.cmd first.
        echo.
        pause
        endlocal
        exit /b 1
    )
)

echo Launching herdr...
call herdr %*
endlocal
