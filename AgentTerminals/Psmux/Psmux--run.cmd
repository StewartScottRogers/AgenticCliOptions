@echo off
setlocal

REM ============================================================
REM  psmux  --  native-Windows tmux (ConPTY, speaks tmux)
REM  ------------------------------------------------------------
REM  Running 'psmux' starts a new session (or 'psmux attach' to
REM  re-attach). It speaks the tmux command language and reads your
REM  %USERPROFILE%\.tmux.conf, so tmux muscle-memory works:
REM      Ctrl+B  %  split pane vertically
REM      Ctrl+B  "  split pane horizontally
REM      Ctrl+B  arrows  move between panes
REM      Ctrl+B  d  detach
REM  (The bundled 'pmux' / 'tmux' commands are aliases for psmux.)
REM  Docs: https://github.com/psmux/psmux
REM
REM  Start your agents INSIDE psmux (run 'claude', 'codex', 'gemini'
REM  in separate panes) to work several at once - no WSL needed.
REM ============================================================

where psmux >nul 2>nul
if errorlevel 1 (
    if exist "%LOCALAPPDATA%\Programs\psmux\bin\psmux.exe" (
        set "PATH=%LOCALAPPDATA%\Programs\psmux\bin;%PATH%"
    ) else (
        echo psmux is not installed. Run Psmux--install.cmd first.
        echo.
        pause
        endlocal
        exit /b 1
    )
)

echo Launching psmux...
call psmux %*
endlocal
