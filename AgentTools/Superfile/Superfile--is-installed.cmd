@echo off
REM  superfile install probe.
REM  The executable is 'spf', NOT 'superfile'. We accept either a
REM  working 'where spf' (PATH-resolvable) OR the winget shim
REM  existing at its known location - the User PATH entry does not
REM  reach a shell that was already open when winget ran.
where spf >nul 2>nul
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
    if exist "%LOCALAPPDATA%\Microsoft\WinGet\Links\spf.exe" set "RC=0"
)
if defined AGENTS_INSTALL_ALL exit /b %RC%
if "%RC%"=="0" (
    echo superfile: installed
) else (
    echo superfile: not installed
)
exit /b %RC%
