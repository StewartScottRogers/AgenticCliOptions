@echo off
setlocal

REM ============================================================
REM  cipher-mcp -> Opencode  (uninstall hook)
REM  ------------------------------------------------------------
REM  Removes the cipher entry from opencode's opencode.json
REM  (top-level `mcp` key). Other keys / other MCP servers in
REM  the file are preserved.
REM ============================================================

set "MARKER=%USERPROFILE%\.agentic-cli-plugins\cipher-mcp.Opencode.installed"
set "CONFIG=%USERPROFILE%\.config\opencode\opencode.json"

if not exist "%MARKER%" if not exist "%CONFIG%" (
    echo   cipher-mcp not registered with Opencode - skipping.
    exit /b 0
)

if exist "%CONFIG%" (
    echo   Removing cipher entry from %CONFIG% ...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\_mcp-opencode-edit.ps1" ^
        -Op remove ^
        -ConfigPath "%CONFIG%" ^
        -Name "cipher"
)
del /f /q "%MARKER%" 2>nul
echo   Done.
exit /b 0
