@echo off
setlocal

REM ============================================================
REM  cipher-mcp -> Gemini  (install hook)
REM  ------------------------------------------------------------
REM  Gemini CLI reads MCP server registrations from
REM      %USERPROFILE%\.gemini\settings.json
REM  under the top-level `mcpServers` key. We merge a cipher
REM  entry in via _mcp-json-edit.ps1, preserving any other
REM  settings the user has there.
REM
REM  Idempotent: re-running this rewrites the same entry. A
REM  marker file is also written so the dispatcher's verbose
REM  log can short-circuit on warm machines.
REM ============================================================

set "MARKER_DIR=%USERPROFILE%\.agentic-cli-plugins"
set "MARKER=%MARKER_DIR%\cipher-mcp.Gemini.installed"
set "SETTINGS=%USERPROFILE%\.gemini\settings.json"

if exist "%MARKER%" (
    echo   cipher-mcp already registered with Gemini ^(marker present^).
    exit /b 0
)

where npx >nul 2>nul
if errorlevel 1 (
    echo   WARNING: 'npx' not on PATH. Registration will proceed,
    echo   but Gemini will not be able to launch cipher until
    echo   Node.js is installed.
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
