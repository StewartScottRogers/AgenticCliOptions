@echo off
setlocal

REM ============================================================
REM  context7-mcp -> Opencode  (uninstall hook)
REM  ------------------------------------------------------------
REM  Removes the context7 entry from opencode's opencode.json
REM  (top-level `mcp` key). Other keys / other MCP servers in
REM  the file are preserved.
REM ============================================================

set "MARKER=%USERPROFILE%\.agentic-cli-plugins\context7-mcp.Opencode.installed"
set "CONFIG=%USERPROFILE%\.config\opencode\opencode.json"

if not exist "%MARKER%" if not exist "%CONFIG%" (
    echo   context7-mcp not registered with Opencode - skipping.
    exit /b 0
)

if exist "%CONFIG%" (
    echo   Removing context7 entry from %CONFIG% ...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\_mcp-opencode-edit.ps1" ^
        -Op remove ^
        -ConfigPath "%CONFIG%" ^
        -Name "context7"
)
del /f /q "%MARKER%" 2>nul
echo   Done.
exit /b 0
