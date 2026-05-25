@echo off
setlocal

REM ============================================================
REM  cipher-mcp -> Antigravity  (install hook)
REM  ------------------------------------------------------------
REM  Antigravity CLI ('agy') is new (Gemini CLI's successor) and
REM  its MCP-registration surface is still evolving. The most
REM  common shape so far is a settings.json with a top-level
REM  `mcpServers` key, mirroring Gemini CLI. We follow that
REM  convention; if upstream ships an `agy mcp add` subcommand
REM  later this hook should switch to it (same way Claude's
REM  hook calls `claude mcp add` rather than editing files).
REM
REM  Target file:
REM      %USERPROFILE%\.antigravity\settings.json
REM ============================================================

set "MARKER_DIR=%USERPROFILE%\.agentic-cli-plugins"
set "MARKER=%MARKER_DIR%\cipher-mcp.Antigravity.installed"
set "SETTINGS=%USERPROFILE%\.antigravity\settings.json"

if exist "%MARKER%" (
    echo   cipher-mcp already registered with Antigravity ^(marker present^).
    exit /b 0
)

where npx >nul 2>nul
if errorlevel 1 (
    echo   WARNING: 'npx' not on PATH. Registration will proceed,
    echo   but Antigravity will not be able to launch cipher
    echo   until Node.js is installed.
)

echo   Registering cipher MCP server in %SETTINGS% ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\_mcp-json-edit.ps1" ^
    -Op add ^
    -SettingsPath "%SETTINGS%" ^
    -Name "cipher" ^
    -Command "npx" ^
    -ArgsList "-y","@byterover/cipher","--mode","mcp"
if errorlevel 1 (
    echo   ERROR: failed to update %SETTINGS% - see output above.
    exit /b 1
)

if not exist "%MARKER_DIR%" mkdir "%MARKER_DIR%" >nul 2>nul
echo registered via _mcp-json-edit.ps1 on %DATE% %TIME% > "%MARKER%"
echo   Done.
echo   NOTE: configure %USERPROFILE%\.cipher\cipher.yml with an LLM
echo         provider (OpenAI / Anthropic / etc.) before first use.
exit /b 0
