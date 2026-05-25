@echo off
setlocal

REM ============================================================
REM  cipher-mcp -> Codex  (install hook)
REM  ------------------------------------------------------------
REM  Codex CLI reads MCP server registrations from
REM      %USERPROFILE%\.codex\config.toml
REM  under [mcp_servers.<name>]. We add a cipher block via
REM  _mcp-toml-edit.ps1, fenced with sentinels so we can find
REM  and replace exactly our block on re-install / uninstall
REM  without disturbing anything else in the user's config.
REM ============================================================

set "MARKER_DIR=%USERPROFILE%\.agentic-cli-plugins"
set "MARKER=%MARKER_DIR%\cipher-mcp.Codex.installed"
set "CONFIG=%USERPROFILE%\.codex\config.toml"

if exist "%MARKER%" (
    echo   cipher-mcp already registered with Codex ^(marker present^).
    exit /b 0
)

where npx >nul 2>nul
if errorlevel 1 (
    echo   WARNING: 'npx' not on PATH. Registration will proceed,
    echo   but Codex will not be able to launch cipher until
    echo   Node.js is installed.
)

echo   Registering cipher MCP server in %CONFIG% ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\_mcp-toml-edit.ps1" ^
    -Op add ^
    -ConfigPath "%CONFIG%" ^
    -Name "cipher" ^
    -Command "npx" ^
    -ArgsList "-y","@byterover/cipher","--mode","mcp"
if errorlevel 1 (
    echo   ERROR: failed to update %CONFIG% - see output above.
    exit /b 1
)

if not exist "%MARKER_DIR%" mkdir "%MARKER_DIR%" >nul 2>nul
echo registered via _mcp-toml-edit.ps1 on %DATE% %TIME% > "%MARKER%"
echo   Done.
echo   NOTE: configure %USERPROFILE%\.cipher\cipher.yml with an LLM
echo         provider (OpenAI / Anthropic / etc.) before first use.
exit /b 0
