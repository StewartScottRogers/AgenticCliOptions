@echo off
setlocal

REM ============================================================
REM  cipher-mcp -> Codex  (uninstall hook)
REM  ------------------------------------------------------------
REM  Removes the sentinel-fenced cipher block from Codex's
REM  config.toml. Any other [mcp_servers.*] entries are left in
REM  place.
REM ============================================================

set "MARKER=%USERPROFILE%\.agentic-cli-plugins\cipher-mcp.Codex.installed"
set "CONFIG=%USERPROFILE%\.codex\config.toml"

if not exist "%MARKER%" if not exist "%CONFIG%" (
    echo   cipher-mcp not registered with Codex - skipping.
    exit /b 0
)

if exist "%CONFIG%" (
    echo   Removing cipher block from %CONFIG% ...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\_mcp-toml-edit.ps1" ^
        -Op remove ^
        -ConfigPath "%CONFIG%" ^
        -Name "cipher"
)
del /f /q "%MARKER%" 2>nul
echo   Done.
exit /b 0
