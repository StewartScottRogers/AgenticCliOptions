@echo off
setlocal

REM ============================================================
REM  herdr + Claude (OpenRouter)  --  terminal+agent pair
REM  ------------------------------------------------------------
REM  Runs Claude Code INSIDE the herdr multiplexer, routed through
REM  OpenRouter's Anthropic-compatible endpoint - the herdr-hosted
REM  twin of CodingAgents\Claude\Claude--openrouter.cmd. Claude
REM  appears as a tracked "Claude" pane in herdr's sidebar; state
REM  comes from herdr's native Claude integration hook (installed
REM  on first run if missing).
REM
REM  Requires herdr (see AgentTerminals\Herdr\) and an OpenRouter
REM  API key. Set the key once, then open a new terminal:
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM  Optional model overrides (browse slugs at openrouter.ai/models):
REM      setx OPENROUTER_MODEL "anthropic/claude-sonnet-4.5"
REM      setx OPENROUTER_SMALL_MODEL "anthropic/claude-haiku-4.5"
REM ============================================================

if not defined OPENROUTER_MODEL       set "OPENROUTER_MODEL=anthropic/claude-sonnet-4.5"
if not defined OPENROUTER_SMALL_MODEL  set "OPENROUTER_SMALL_MODEL=anthropic/claude-haiku-4.5"

REM  Fail fast in THIS terminal (clearer than surfacing the error
REM  inside a herdr pane) if the key is missing.
if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

REM  Reuse the tested OpenRouter launcher as the in-pane command so
REM  the ANTHROPIC_BASE_URL / AUTH_TOKEN wiring stays in one place.
set "CLAUDE_CMD=%~dp0..\AgenticCliOptions\CodingAgents\Claude\Claude--openrouter.cmd"
for %%I in ("%CLAUDE_CMD%") do set "CLAUDE_CMD=%%~fI"
if not exist "%CLAUDE_CMD%" (
    echo ERROR: could not find Claude OpenRouter launcher at:
    echo     %CLAUDE_CMD%
    echo.
    pause
    endlocal
    exit /b 1
)

set "HP_LABEL=Claude"
set "HP_CWD=%~dp0.."
set "HP_INTEGRATION=claude"
REM  Forward the OpenRouter settings into the pane so the reused
REM  launcher sees the current key/models even when the herdr
REM  server's captured environment is older than this shell.
set "HP_ENV=--env OPENROUTER_API_KEY=%OPENROUTER_API_KEY% --env OPENROUTER_MODEL=%OPENROUTER_MODEL% --env OPENROUTER_SMALL_MODEL=%OPENROUTER_SMALL_MODEL%"
set "HP_CMD=cmd /c "%CLAUDE_CMD%""

call "%~dp0_hrdr-launch.cmd"
goto :end

:nokey
echo ERROR: Environment variable OPENROUTER_API_KEY is not set.
echo Set it once, then open a new terminal:
echo.
echo     setx OPENROUTER_API_KEY "sk-or-...your-key..."
echo.
echo Get a key at https://openrouter.ai/keys
pause

:end
endlocal
