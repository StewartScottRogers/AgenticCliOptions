@echo off
setlocal

REM ============================================================
REM  context7-mcp -> Gemini  (uninstall hook)
REM  ------------------------------------------------------------
REM  Removes the context7 entry from Gemini's settings.json. Any
REM  other keys / other MCP servers in the file are preserved.
REM ============================================================

set "MARKER=%USERPROFILE%\.agentic-cli-plugins\context7-mcp.Gemini.installed"
set "SETTINGS=%USERPROFILE%\.gemini\settings.json"

if not exist "%MARKER%" if not exist "%SETTINGS%" (
    echo   context7-mcp not registered with Gemini - skipping.
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
