@echo off
REM  herdr install probe.
REM  We accept either a working 'where herdr' (PATH-resolvable) OR
REM  the binary existing at its known install dir - the User PATH
REM  entry added by the installer does not reach a shell that was
REM  already open when the installer ran.
where herdr >nul 2>nul
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
    if exist "%LOCALAPPDATA%\Programs\Herdr\bin\herdr.exe" set "RC=0"
)
if defined AGENTS_INSTALL_ALL exit /b %RC%
if "%RC%"=="0" (
    echo herdr: installed
) else (
    echo herdr: not installed
)
exit /b %RC%
