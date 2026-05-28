@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Update-All  --  upgrade every INSTALLED coding agent CLI
REM  ------------------------------------------------------------
REM  Walks the same agent list Install-All uses (AmazonQ last) and
REM  re-runs each agent's own install script. Every per-agent
REM  install script is idempotent and installs the LATEST version
REM  (npm '@latest', 'uv tool --upgrade', GitHub-latest, etc.), so
REM  re-running it upgrades an existing install in place.
REM
REM  Only agents that are ALREADY installed are touched - missing
REM  ones are skipped (use Install-All.cmd to add them). The
REM  per-agent --is-installed.cmd probe decides what counts.
REM
REM  Two agents update differently and re-running install is a
REM  near no-op for them - that is expected:
REM    - Antigravity: 'agy' self-updates in the background; its
REM      installer refuses to overwrite an existing binary and
REM      just prints an "already installed" notice.
REM    - AmazonQ: the WSL-side installer skips when the CLI is
REM      already present. To force a newer Amazon Q / Kiro CLI,
REM      re-run AmazonQ--install.cmd after removing it inside WSL.
REM
REM  Shared deps (Node.js, uv, Git, WSL) are only (re)installed if
REM  missing - the child scripts never downgrade or remove them.
REM ============================================================

set "ROOT=%~dp0"

REM  Child install scripts read AGENTS_INSTALL_ALL and skip their
REM  own final 'pause', so the whole run is unattended.
set "AGENTS_INSTALL_ALL=1"

REM  Master agent list - same order as Install-All (AmazonQ last).
set "ALL_AGENTS=Claude Codex Gemini Antigravity Pi Qwen Grok Mistral Trae Hermes Codebuff Oh-My-Pi OpenSquilla Aider Junie VTCode Opencode AmazonQ"

echo ============================================================
echo  Updating every installed coding agent CLI in this project
echo ============================================================
echo.

set "UPDATED="
set "SKIPPED="
for %%A in (%ALL_AGENTS%) do call :update_agent %%A

echo.
echo ============================================================
echo  Update run complete.
echo.
if defined UPDATED echo  Updated (re-ran installer):!UPDATED!
if defined SKIPPED echo  Skipped (not installed):!SKIPPED!
if not defined UPDATED echo  Nothing was installed - run Install-All.cmd first.
echo.
echo  Shared deps (Node.js, uv, Git, WSL) were left in place. See
echo  this script's header for the Antigravity / AmazonQ notes.
echo ============================================================
echo.
REM  Self-pause only when run standalone (double-clicked). The
REM  Install-All menu sets AGENTS_UPDATE_ALL and pauses on return.
if not defined AGENTS_UPDATE_ALL pause
endlocal
goto :eof


REM ============================================================
REM  Helper: update one agent if it is installed
REM  ------------------------------------------------------------
REM  Re-runs the agent's install script, which doubles as its
REM  updater. Not-installed agents are skipped, not installed.
REM ============================================================
:update_agent
call :is_installed %~1
if errorlevel 1 (
    echo ------------------------------------------------------------
    echo  %~1  -  skipped ^(not installed^)
    echo ------------------------------------------------------------
    echo.
    set "SKIPPED=!SKIPPED! %~1"
    exit /b 0
)
echo ------------------------------------------------------------
echo  %~1  -  updating
echo ------------------------------------------------------------
if exist "%ROOT%%~1\%~1--install.cmd" (
    call "%ROOT%%~1\%~1--install.cmd"
    set "UPDATED=!UPDATED! %~1"
) else (
    echo ERROR: install/update script for %~1 was not found.
)
echo.
exit /b 0


REM ============================================================
REM  Helper: is the given agent installed?
REM  Delegates to <Agent>\<Agent>--is-installed.cmd, which returns
REM  0 if installed and 1 if not. Agents missing the probe file are
REM  reported as not installed.
REM ============================================================
:is_installed
if exist "%ROOT%%~1\%~1--is-installed.cmd" (
    call "%ROOT%%~1\%~1--is-installed.cmd"
    exit /b
)
exit /b 1
