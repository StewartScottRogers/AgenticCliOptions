@echo off
setlocal

REM ============================================================
REM  superfile  --  modern TUI file manager
REM  ------------------------------------------------------------
REM  Running 'spf' with no arguments opens the file manager in the
REM  current directory. Pass one or more paths to open them in
REM  separate file panels:
REM      Superfile--run.cmd .
REM      Superfile--run.cmd C:\repos\AgenticCliOptions
REM
REM  Handy flags (see 'spf --help'):
REM      --print-last-dir, --pld   print the last dir on exit
REM      --chooser-file,   --cf    write the chosen file's path out
REM      --fix-config-file, --fch  add missing fields to config.toml
REM      --fix-hotkeys,     --fh   add missing hotkeys to hotkeys.toml
REM  'spf path-list' prints the config / hotkeys / log / data paths.
REM
REM  Useful next to a coding agent: browse and stage the files an
REM  agent is about to touch, or inspect what it just changed,
REM  without leaving the terminal.
REM ============================================================

where spf >nul 2>nul
if errorlevel 1 (
    if exist "%LOCALAPPDATA%\Microsoft\WinGet\Links\spf.exe" (
        set "PATH=%LOCALAPPDATA%\Microsoft\WinGet\Links;%PATH%"
    ) else (
        echo superfile is not installed. Run Superfile--install.cmd first.
        echo.
        pause
        endlocal
        exit /b 1
    )
)

echo Launching superfile...
call spf %*
endlocal
