@echo off
setlocal

REM ============================================================
REM  cipher-mcp -> Claude  (uninstall hook)
REM  ------------------------------------------------------------
REM  Removes the Cipher MCP server registration from Claude
REM  Code via `claude mcp remove`. Idempotent: if the marker is
REM  absent we skip; if the marker is present but the server is
REM  already gone, the CLI's nonzero exit is tolerated.
REM ============================================================

set "MARKER=%USERPROFILE%\.agentic-cli-plugins\cipher-mcp.Claude.installed"

if not exist "%MARKER%" (
    echo   cipher-mcp not registered with Claude ^(no marker^) - skipping.
    exit /b 0
)

where claude >nul 2>nul
if errorlevel 1 (
    echo   WARNING: 'claude' not on PATH - removing marker only.
    del /f /q "%MARKER%" 2>nul
    exit /b 0
)

echo   Removing cipher MCP server from Claude...
call claude mcp remove cipher --scope user 2>nul
REM  Don't fail the hook if the server entry was already gone -
REM  the user-facing goal (it is uninstalled now) is satisfied.
del /f /q "%MARKER%" 2>nul
echo   Done.
exit /b 0
