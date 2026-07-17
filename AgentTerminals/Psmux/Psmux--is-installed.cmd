@echo off
REM  psmux install probe.
REM  Accept either a working 'where psmux' (PATH-resolvable) OR the
REM  binary existing at its known install dir - the User PATH entry
REM  added by the installer does not reach a shell that was already
REM  open when the installer ran.
where psmux >nul 2>nul
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
    if exist "%LOCALAPPDATA%\Programs\psmux\bin\psmux.exe" set "RC=0"
)
if defined AGENTS_INSTALL_ALL exit /b %RC%
if "%RC%"=="0" (
    echo psmux: installed
) else (
    echo psmux: not installed
)
exit /b %RC%
