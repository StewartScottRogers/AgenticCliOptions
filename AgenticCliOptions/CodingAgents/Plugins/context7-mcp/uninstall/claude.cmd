@echo off
setlocal

REM ============================================================
REM  context7-mcp -> Claude  (uninstall hook)
REM  ------------------------------------------------------------
REM  Removes the Context7 MCP server registration from Claude
REM  Code via `claude mcp remove`. Idempotent: if the marker is
REM  absent we skip; if the marker is present but the server is
REM  already gone, the CLI's nonzero exit is tolerated.
REM ============================================================

set "MARKER=%USERPROFILE%\.agentic-cli-plugins\context7-mcp.Claude.installed"

if not exist "%MARKER%" (
    echo   context7-mcp not registered with Claude ^(no marker^) - skipping.
    exit /b 0
)

where claude >nul 2>nul
if errorlevel 1 (
    echo   WARNING: 'claude' not on PATH - removing marker only.
    del /f /q "%MARKER%" 2>nul
    exit /b 0
)

echo   Removing context7 MCP server from Claude...
call claude mcp remove context7 --scope user 2>nul
REM  Don't fail the hook if the server entry was already gone -
REM  the user-facing goal (it is uninstalled now) is satisfied.
del /f /q "%MARKER%" 2>nul
echo   Done.
exit /b 0
