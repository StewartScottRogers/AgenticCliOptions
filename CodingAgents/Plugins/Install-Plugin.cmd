@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Install-Plugin  --  install ONE plugin into every agent
REM                      that supports it AND is installed
REM  ------------------------------------------------------------
REM  Usage:
REM    Install-Plugin.cmd                    interactive picker
REM    Install-Plugin.cmd ^<plugin-name^>      install that plugin
REM    Install-Plugin.cmd /?                 show usage and exit
REM
REM  For scope=shared plugins, fans the install hook out to every
REM  agent named in the manifest's `supports` that is currently
REM  installed. For scope=per-agent plugins, installs only into
REM  the one declared agent (if installed).
REM
REM  An agent is considered "installed" if its
REM  <Agent>--is-installed.cmd probe (next to this folder) exits 0.
REM ============================================================

set "ROOT=%~dp0"
set "AGENTS_ROOT=%ROOT%.."

if /I "%~1"=="/?"     goto :usage
if /I "%~1"=="-h"     goto :usage
if /I "%~1"=="--help" goto :usage

if "%~1"=="" goto :pick
set "PLUGIN=%~1"
goto :run

:usage
echo Usage: %~nx0 [plugin-name] ^| /?
echo.
echo   No args         interactive picker
echo   plugin-name     install that plugin into every supporting,
echo                   currently-installed agent
exit /b 0

:pick
echo.
echo Available plugins:
set "IDX=0"
for /d %%P in ("%ROOT%*") do (
    if exist "%%~P\plugin.json" (
        set /a IDX+=1
        set "PLUGIN_!IDX!=%%~nxP"
        echo   !IDX!^) %%~nxP
    )
)
if !IDX! EQU 0 (
    echo   ^(no plugins found under %ROOT%^)
    endlocal & exit /b 1
)
echo.
set "PICK="
set /p "PICK=  Plugin name or number: "
if not defined PICK ( endlocal & exit /b 0 )
set "ISNUM=1"
for /f "delims=0123456789" %%X in ("!PICK!") do set "ISNUM="
if defined ISNUM call set "PICK=%%PLUGIN_!PICK!%%"
set "PLUGIN=!PICK!"

:run
if not exist "%ROOT%%PLUGIN%\plugin.json" (
    echo ERROR: plugin "%PLUGIN%" not found at %ROOT%%PLUGIN%\plugin.json
    endlocal & exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%_install-plugin.ps1" -Plugin "%PLUGIN%" -AgentsRoot "%AGENTS_ROOT%" -Action install
set "RC=%ERRORLEVEL%"
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal & exit /b %RC%
