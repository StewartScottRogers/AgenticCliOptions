@echo off
setlocal

REM ============================================================
REM  context7-mcp -> Antigravity  (uninstall hook)
REM  ------------------------------------------------------------
REM  Removes the context7 entry from Antigravity's settings.json.
REM  See install\antigravity.cmd for the file shape rationale.
REM ============================================================

set "MARKER=%USERPROFILE%\.agentic-cli-plugins\context7-mcp.Antigravity.installed"
set "SETTINGS=%USERPROFILE%\.antigravity\settings.json"

if not exist "%MARKER%" if not exist "%SETTINGS%" (
    echo   context7-mcp not registered with Antigravity - skipping.
    exit /b 0
)

if exist "%SETTINGS%" (
    echo   Removing context7 entry from %SETTINGS% ...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\_mcp-json-edit.ps1" ^
        -Op remove ^
        -SettingsPath "%SETTINGS%" ^
        -Name "context7"
)
del /f /q "%MARKER%" 2>nul
echo   Done.
exit /b 0
