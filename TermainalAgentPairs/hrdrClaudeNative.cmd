@echo off
setlocal

REM ============================================================
REM  herdr + Claude (native)  --  terminal+agent pair
REM  ------------------------------------------------------------
REM  Runs Claude Code INSIDE the herdr multiplexer using Claude's
REM  native (Anthropic) backend - the herdr-hosted twin of
REM  CodingAgents\Claude\Claude--run.cmd. Claude appears as a
REM  tracked "Claude" pane in herdr's sidebar; state comes from
REM  herdr's native Claude integration hook (installed on first
REM  run if missing).
REM
REM  Requires herdr (see AgentTerminals\Herdr\). Model override:
REM      setx CLAUDE_MODEL "claude-opus-5"
REM  (default: claude-sonnet-5)
REM ============================================================

if not defined CLAUDE_MODEL set "CLAUDE_MODEL=claude-sonnet-5"

REM  Reuse the tested native launcher as the in-pane command so the
REM  Anthropic backend/model handling stays in one place.
set "CLAUDE_CMD=%~dp0..\AgenticCliOptions\CodingAgents\Claude\Claude--run.cmd"
for %%I in ("%CLAUDE_CMD%") do set "CLAUDE_CMD=%%~fI"
if not exist "%CLAUDE_CMD%" (
    echo ERROR: could not find Claude native launcher at:
    echo     %CLAUDE_CMD%
    echo.
    pause
    endlocal
    exit /b 1
)

set "HP_LABEL=Claude"
set "HP_CWD=%~dp0.."
set "HP_INTEGRATION=claude"
REM  Forward the chosen model into the pane so it is honoured even if
REM  the herdr server's captured environment predates a CLAUDE_MODEL
REM  change in this shell.
set "HP_ENV=--env CLAUDE_MODEL=%CLAUDE_MODEL%"
set "HP_CMD=cmd /c "%CLAUDE_CMD%""

call "%~dp0_hrdr-launch.cmd"
endlocal
