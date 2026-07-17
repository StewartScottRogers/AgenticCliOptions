@echo off
setlocal

REM ============================================================
REM  WezTerm  --  GPU terminal + built-in multiplexer
REM  ------------------------------------------------------------
REM  Running 'wezterm' (or wezterm-gui) opens the terminal window.
REM  WezTerm multiplexes on its own - no tmux/zellij needed:
REM      Ctrl+Shift+Alt+"   split pane vertically (top/bottom)
REM      Ctrl+Shift+Alt+%%  split pane horizontally (left/right)
REM      Ctrl+Shift+ArrowKey move between panes
REM      Ctrl+Shift+T        new tab
REM  A background "mux server" keeps panes/processes alive so you
REM  can detach and re-attach (locally or over SSH). You can also
REM  drive panes programmatically with 'wezterm cli spawn/split-pane'.
REM  Config lives in a Lua file; see https://wezterm.org/config/.
REM
REM  Start your agents INSIDE WezTerm (run 'claude', 'codex',
REM  'gemini' in separate panes) to work several at once.
REM ============================================================

where wezterm >nul 2>nul
if errorlevel 1 (
    if exist "%ProgramFiles%\WezTerm\wezterm.exe" (
        set "PATH=%ProgramFiles%\WezTerm;%PATH%"
    ) else if exist "%LOCALAPPDATA%\Programs\WezTerm\wezterm.exe" (
        set "PATH=%LOCALAPPDATA%\Programs\WezTerm;%PATH%"
    ) else (
        echo WezTerm is not installed. Run WezTerm--install.cmd first.
        echo.
        pause
        endlocal
        exit /b 1
    )
)

echo Launching WezTerm...
REM  'wezterm start' opens the GUI; pass through any extra args.
start "" wezterm start %*
endlocal
