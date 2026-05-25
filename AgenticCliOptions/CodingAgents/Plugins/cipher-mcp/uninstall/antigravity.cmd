@echo off
setlocal

REM ============================================================
REM  cipher-mcp -> Antigravity  (uninstall hook)
REM  ------------------------------------------------------------
REM  Removes the cipher entry from Antigravity's settings.json.
REM  See install\antigravity.cmd for the file shape rationale.
REM ============================================================

set "MARKER=%USERPROFILE%\.agentic-cli-plugins\cipher-mcp.Antigravity.installed"
set "SETTINGS=%USERPROFILE%\.antigravity\settings.json"

if not exist "%MARKER%" if not exist "%SETTINGS%" (
    echo   cipher-mcp not registered with Antigravity - skipping.
    exit /b 0
)

if exist "%SETTINGS%" (
    echo   Removing cipher entry from %SETTINGS% ...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\_mcp-json-edit.ps1" ^
        -Op remove ^
        -SettingsPath "%SETTINGS%" ^
        -Name "cipher"
)
del /f /q "%MARKER%" 2>nul
echo   Done.
exit /b 0
