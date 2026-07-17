@echo off
REM  WezTerm install probe.
REM  Accept a PATH-resolvable 'wezterm', OR winget reporting the
REM  package present, OR the binary at its default install dir (a
REM  shell opened before install won't have the refreshed PATH).
where wezterm >nul 2>nul
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
    if exist "%ProgramFiles%\WezTerm\wezterm.exe" set "RC=0"
)
if not "%RC%"=="0" (
    if exist "%LOCALAPPDATA%\Programs\WezTerm\wezterm.exe" set "RC=0"
)
if not "%RC%"=="0" (
    winget list -e --id wez.wezterm >nul 2>nul
    if not errorlevel 1 set "RC=0"
)
if defined AGENTS_INSTALL_ALL exit /b %RC%
if "%RC%"=="0" (
    echo wezterm: installed
) else (
    echo wezterm: not installed
)
exit /b %RC%
