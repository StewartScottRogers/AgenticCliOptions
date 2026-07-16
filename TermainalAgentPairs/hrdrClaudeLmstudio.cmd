@echo off
setlocal

REM ============================================================
REM  herdr + Claude (LM Studio)  --  terminal+agent pair
REM  ------------------------------------------------------------
REM  Runs Claude Code INSIDE the herdr multiplexer, talking to a
REM  local LM Studio server (Anthropic-shaped endpoint) - the
REM  herdr-hosted twin of
REM  CodingAgents\Claude\Claude--local-lmstudio.cmd. Claude appears
REM  as a tracked "Claude" pane in herdr's sidebar; state comes from
REM  herdr's native Claude integration hook (installed on first run
REM  if missing).
REM
REM  Requires herdr (see AgentTerminals\Herdr\) and a running LM
REM  Studio server with a model loaded (install it via
REM  CodingAgents\Install-lmstudio.cmd). The reused launcher auto-
REM  detects the server URL (loopback + this machine's LAN IPv4s on
REM  ports 1234/1235) and defaults the model to qwen3-coder-30b.
REM
REM  Overrides (optional) - set before running; forwarded into the
REM  herdr pane so they win over the auto-detected defaults:
REM      set LMSTUDIO_URL=http://your-host:1234
REM      set LMSTUDIO_MODEL=<other-model-id>
REM ============================================================

REM  Reuse the tested LM Studio launcher as the in-pane command so
REM  the URL auto-detection, model pinning and per-run settings JSON
REM  stay in one place.
set "CLAUDE_CMD=%~dp0..\AgenticCliOptions\CodingAgents\Claude\Claude--local-lmstudio.cmd"
for %%I in ("%CLAUDE_CMD%") do set "CLAUDE_CMD=%%~fI"
if not exist "%CLAUDE_CMD%" (
    echo ERROR: could not find Claude LM Studio launcher at:
    echo     %CLAUDE_CMD%
    echo.
    pause
    endlocal
    exit /b 1
)

set "HP_LABEL=Claude"
set "HP_CWD=%~dp0.."
set "HP_INTEGRATION=claude"
REM  Forward LM Studio overrides into the pane only when the user set
REM  them; otherwise the reused launcher auto-detects the URL and
REM  defaults the model itself. This also insulates against a stale
REM  herdr-server environment (server captured before these were set).
set "HP_ENV="
if defined LMSTUDIO_URL   set "HP_ENV=%HP_ENV% --env LMSTUDIO_URL=%LMSTUDIO_URL%"
if defined LMSTUDIO_MODEL set "HP_ENV=%HP_ENV% --env LMSTUDIO_MODEL=%LMSTUDIO_MODEL%"
set "HP_CMD=cmd /c "%CLAUDE_CMD%""

call "%~dp0_hrdr-launch.cmd"
endlocal
