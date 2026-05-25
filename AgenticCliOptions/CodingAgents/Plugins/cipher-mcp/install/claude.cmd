@echo off
setlocal

REM ============================================================
REM  cipher-mcp -> Claude  (install hook)
REM  ------------------------------------------------------------
REM  Registers the Cipher (byterover) MCP server with Claude Code
REM  via its first-class `claude mcp add` subcommand. Scope=user
REM  so the registration follows the user across every project;
REM  switch to --scope local if you'd rather scope it to one repo.
REM
REM  Cipher needs an LLM provider configured at
REM      %USERPROFILE%\.cipher\cipher.yml
REM  before first use. The server registers fine without it, but
REM  memory writes/recalls will fail until credentials are set.
REM
REM  Idempotent via a marker file - re-running this is cheap and
REM  safe. `claude mcp add` itself is also idempotent for a given
REM  server name on current versions, but we guard with the marker
REM  so we don't shell out unnecessarily on warm machines.
REM ============================================================

set "MARKER_DIR=%USERPROFILE%\.agentic-cli-plugins"
set "MARKER=%MARKER_DIR%\cipher-mcp.Claude.installed"

if exist "%MARKER%" (
    echo   cipher-mcp already registered with Claude ^(marker present^).
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
    echo   but Claude will not be able to launch cipher until
    echo   Node.js is installed.
)

echo   Registering cipher MCP server with Claude...
call claude mcp add cipher --scope user -- npx -y @byterover/cipher --mode mcp
if errorlevel 1 (
    echo   ERROR: claude mcp add failed - see output above.
    exit /b 1
)

if not exist "%MARKER_DIR%" mkdir "%MARKER_DIR%" >nul 2>nul
echo registered via "claude mcp add" on %DATE% %TIME% > "%MARKER%"
echo   Done.
echo   NOTE: configure %USERPROFILE%\.cipher\cipher.yml with an LLM
echo         provider (OpenAI / Anthropic / etc.) before first use.
exit /b 0
