@echo off
REM  Windows Terminal install probe.
REM  Accept a PATH-resolvable 'wt' (the WindowsApps alias) OR the
REM  winget/Store package being present.
where wt >nul 2>nul
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
    winget list -e --id Microsoft.WindowsTerminal >nul 2>nul
    if not errorlevel 1 set "RC=0"
)
if defined AGENTS_INSTALL_ALL exit /b %RC%
if "%RC%"=="0" (
    echo windows-terminal: installed
) else (
    echo windows-terminal: not installed
)
exit /b %RC%
