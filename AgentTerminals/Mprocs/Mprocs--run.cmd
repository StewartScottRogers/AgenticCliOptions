@echo off
setlocal

REM ============================================================
REM  mprocs  --  run several commands (agents) in parallel panes
REM  ------------------------------------------------------------
REM  Running 'mprocs' with no args looks for an mprocs.yaml in the
REM  current directory and starts every command in it, each in its
REM  own pane. You can also pass commands directly:
REM      mprocs "claude" "codex" "gemini"
REM  starts three agents side by side.
REM
REM  Quick keys (default):
REM      Ctrl+A       enter command/focus mode
REM      j / k        select the previous / next process
REM      x            stop (kill) the selected process
REM      r            restart the selected process
REM      q            quit mprocs (asks to stop running procs)
REM  Config: put an mprocs.yaml in the project, or edit the global
REM      %APPDATA%\mprocs\mprocs.yaml
REM  Docs: https://github.com/pvolok/mprocs
REM ============================================================

where mprocs >nul 2>nul
if errorlevel 1 (
    if exist "%LOCALAPPDATA%\Programs\mprocs\bin\mprocs.exe" (
        set "PATH=%LOCALAPPDATA%\Programs\mprocs\bin;%PATH%"
    ) else (
        echo mprocs is not installed. Run Mprocs--install.cmd first.
        echo.
        pause
        endlocal
        exit /b 1
    )
)

echo Launching mprocs...
call mprocs %*
endlocal
