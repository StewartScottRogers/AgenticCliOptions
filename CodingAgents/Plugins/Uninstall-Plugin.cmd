@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Uninstall-Plugin  --  remove ONE plugin from every agent
REM                        that has it AND is installed
REM  ------------------------------------------------------------
REM  Usage:
REM    Uninstall-Plugin.cmd                  interactive picker
REM    Uninstall-Plugin.cmd ^<plugin-name^>    uninstall that plugin
REM    Uninstall-Plugin.cmd /?               show usage and exit
REM
REM  Mirror of Install-Plugin.cmd. Calls the same PS sidecar with
REM  -Action uninstall, which walks the manifest's supports list
REM  (or `agent` for per-agent plugins) and runs each plugin's
REM  uninstall\<agent>.cmd hook for every currently-installed
REM  agent. Plugins should make their uninstall hooks idempotent
REM  (no-op if not installed) since we cannot reliably detect
REM  partial installs from outside the plugin.
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
echo   plugin-name     uninstall that plugin from every supporting,
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
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%_install-plugin.ps1" -Plugin "%PLUGIN%" -AgentsRoot "%AGENTS_ROOT%" -Action uninstall
set "RC=%ERRORLEVEL%"
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal & exit /b %RC%
