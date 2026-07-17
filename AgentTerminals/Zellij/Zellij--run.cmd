@echo off
setlocal

REM ============================================================
REM  Zellij  --  terminal workspace / multiplexer (modern tmux)
REM  ------------------------------------------------------------
REM  Running 'zellij' starts a new session (or attach an existing
REM  one with 'zellij attach'). Panes and tabs keep your agents
REM  side by side; detach and the session's processes stay alive in
REM  the background for you to re-attach later.
REM
REM  Quick keys (Zellij is modal - no single tmux-style prefix):
REM      Ctrl+P   pane mode  (then n = new pane, arrows to move)
REM      Ctrl+T   tab mode   (then n = new tab)
REM      Ctrl+N   resize mode
REM      Ctrl+O   session mode (then d = detach)
REM      Ctrl+Q   quit
REM  The mode hints are shown along the bottom status bar. Full
REM  keybindings: https://zellij.dev/documentation/keybindings.html
REM
REM  Start your agents INSIDE zellij (run 'claude', 'codex',
REM  'gemini' in separate panes) to watch them work in parallel.
REM ============================================================

where zellij >nul 2>nul
if errorlevel 1 (
    if exist "%LOCALAPPDATA%\Programs\Zellij\bin\zellij.exe" (
        set "PATH=%LOCALAPPDATA%\Programs\Zellij\bin;%PATH%"
    ) else (
        echo Zellij is not installed. Run Zellij--install.cmd first.
        echo.
        pause
        endlocal
        exit /b 1
    )
)

echo Launching Zellij...
call zellij %*
endlocal
