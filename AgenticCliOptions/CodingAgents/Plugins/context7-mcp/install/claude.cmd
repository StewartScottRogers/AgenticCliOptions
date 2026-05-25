@echo off
setlocal

REM ============================================================
REM  context7-mcp -> Claude  (install hook)
REM  ------------------------------------------------------------
REM  Registers the Context7 MCP server with Claude Code via its
REM  first-class `claude mcp add` subcommand. Scope=user so the
REM  registration follows the user across every project; switch
REM  to --scope local if you'd rather scope it to one repo.
REM
REM  Idempotent via a marker file - re-running this is cheap and
REM  safe. `claude mcp add` itself is also idempotent for a given
REM  server name on current versions, but we guard with the marker
REM  so we don't shell out unnecessarily on warm machines.
REM ============================================================

set "MARKER_DIR=%USERPROFILE%\.agentic-cli-plugins"
set "MARKER=%MARKER_DIR%\context7-mcp.Claude.installed"

if exist "%MARKER%" (
    echo   context7-mcp already registered with Claude ^(marker present^).
    exit /b 0
)

where claude >nul 2>nul
if errorlevel 1 (
    echo   ERROR: 'claude' not on PATH - cannot register MCP server.
    exit /b 1
)

REM  npx is required to actually launch the MCP server. If Node /
REM  npm is missing the registration would succeed but the server
REM  would fail to start on first use. Warn now rather than later.
where npx >nul 2>nul
if errorlevel 1 (
    echo   WARNING: 'npx' not on PATH. Registration will proceed,
    echo   but Claude will not be able to launch context7 until
    echo   Node.js is installed.
)

echo   Registering context7 MCP server with Claude...
call claude mcp add context7 --scope user -- npx -y @upstash/context7-mcp
if errorlevel 1 (
    echo   ERROR: claude mcp add failed - see output above.
    exit /b 1
)

if not exist "%MARKER_DIR%" mkdir "%MARKER_DIR%" >nul 2>nul
echo registered via "claude mcp add" on %DATE% %TIME% > "%MARKER%"
echo   Done.
exit /b 0
