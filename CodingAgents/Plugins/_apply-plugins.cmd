@echo off
REM ============================================================
REM  Apply plugins for one agent  (shared helper, CALL only)
REM  ------------------------------------------------------------
REM  Usage:  call _apply-plugins.cmd ^<AgentName^> install
REM          call _apply-plugins.cmd ^<AgentName^> uninstall
REM
REM  Thin batch wrapper around _apply-plugins.ps1. Iterates
REM  every Plugins\<name>\plugin.json, filters by the manifest's
REM  scope / supports / agent fields, and runs the matching
REM  install\<agent>.cmd or uninstall\<agent>.cmd hook.
REM
REM  Always returns 0 - a missing or failing plugin must NOT
REM  break the host agent's install/uninstall flow. Per-plugin
REM  failures are surfaced as "[warn]" lines in the output.
REM
REM  Intended to be CALLed from each agent's *--install.cmd /
REM  *--uninstall.cmd, and from the top-level Install-Plugin.cmd
REM  picker. Designed to be cheap on a cold cache (no work if
REM  there are no plugins).
REM ============================================================
if "%~1"=="" exit /b 0
if "%~2"=="" exit /b 0
echo.
echo Applying plugins for %~1 (%~2)...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_apply-plugins.ps1" -Agent "%~1" -Action "%~2"
exit /b 0
