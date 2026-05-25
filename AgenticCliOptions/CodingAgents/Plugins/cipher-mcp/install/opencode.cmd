@echo off
setlocal

REM ============================================================
REM  cipher-mcp -> Opencode  (install hook)
REM  ------------------------------------------------------------
REM  opencode reads MCP server registrations from
REM      %USERPROFILE%\.config\opencode\opencode.json
REM  under the top-level `mcp` key (NOT `mcpServers` like Claude
REM  Desktop / Gemini). opencode also expects `command` as a
REM  single array combining bin + args, plus `type: "local"`
REM  and `enabled: true` per entry. We merge via the opencode-
REM  specific helper _mcp-opencode-edit.ps1.
REM ============================================================

set "MARKER_DIR=%USERPROFILE%\.agentic-cli-plugins"
set "MARKER=%MARKER_DIR%\cipher-mcp.Opencode.installed"
set "CONFIG=%USERPROFILE%\.config\opencode\opencode.json"

if exist "%MARKER%" (
    echo   cipher-mcp already registered with Opencode ^(marker present^).
    exit /b 0
)

where npx >nul 2>nul
if errorlevel 1 (
    echo   WARNING: 'npx' not on PATH. Registration will proceed,
    echo   but opencode will not be able to launch cipher until
    echo   Node.js is installed.
)

echo   Registering cipher MCP server in %CONFIG% ...
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0..\_mcp-opencode-edit.ps1" ^
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
echo registered via _mcp-opencode-edit.ps1 on %DATE% %TIME% > "%MARKER%"
echo   Done.
echo   NOTE: configure %USERPROFILE%\.cipher\cipher.yml with an LLM
echo         provider (OpenAI / Anthropic / etc.) before first use.
exit /b 0
