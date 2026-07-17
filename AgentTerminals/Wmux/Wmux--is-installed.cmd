@echo off
REM  wmux install probe.
REM  Accept a PATH-resolvable 'wmux', OR the winget package present,
REM  OR the binary at a common per-user / machine install dir (a
REM  shell opened before install won't have the refreshed PATH).
where wmux >nul 2>nul
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
    if exist "%LOCALAPPDATA%\Programs\wmux\wmux.exe" set "RC=0"
)
if not "%RC%"=="0" (
    if exist "%ProgramFiles%\wmux\wmux.exe" set "RC=0"
)
if not "%RC%"=="0" (
    winget list -e --id openwong2kim.wmux >nul 2>nul
    if not errorlevel 1 set "RC=0"
)
if defined AGENTS_INSTALL_ALL exit /b %RC%
if "%RC%"=="0" (
    echo wmux: installed
) else (
    echo wmux: not installed
)
exit /b %RC%
