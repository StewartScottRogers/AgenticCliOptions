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
REM  Delegate to the PS picker so the menu can render each plugin's
REM  description and supported agents (parsed from plugin.json). PS
REM  writes the chosen name to a temp file; we read it back and
REM  fall through to :run. Exit code 2 means the user pressed Enter
REM  without picking - treat as a silent cancel, same as before.
set "PICKFILE=%TEMP%\plugin-pick-%RANDOM%%RANDOM%.txt"
if exist "%PICKFILE%" del "%PICKFILE%" >nul 2>nul
REM  %ROOT% ends with a backslash; "%ROOT%" would render as
REM  "...\Plugins\" which PowerShell parses as an escaped quote and
REM  then swallows the next arg. Trim the trailing backslash.
set "PICKROOT=%ROOT:~0,-1%"
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%_pick-plugin.ps1" -PluginsRoot "%PICKROOT%" -OutFile "%PICKFILE%" -Action install
set "PICKRC=%ERRORLEVEL%"
if "%PICKRC%"=="2" (
    if exist "%PICKFILE%" del "%PICKFILE%" >nul 2>nul
    endlocal & exit /b 0
)
if not "%PICKRC%"=="0" (
    if exist "%PICKFILE%" del "%PICKFILE%" >nul 2>nul
    endlocal & exit /b %PICKRC%
)
set "PLUGIN="
for /f "usebackq delims=" %%L in ("%PICKFILE%") do set "PLUGIN=%%L"
del "%PICKFILE%" >nul 2>nul
if not defined PLUGIN ( endlocal & exit /b 1 )

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
