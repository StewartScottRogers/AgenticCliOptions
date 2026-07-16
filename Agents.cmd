@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Agents  --  single entry point for the whole repo
REM  ------------------------------------------------------------
REM  One launcher to reach both catalogues:
REM    1) Coding Agents  -> AgenticCliOptions\CodingAgents\Install-All.cmd
REM         Claude, Codex, Gemini, Pi, Qwen ... (the agents)
REM    2) Agent Terminals -> AgentTerminals\Install-All.cmd
REM         Herdr ... (the multiplexers that host the agents)
REM
REM  Each choice hands off to that catalogue's own interactive
REM  Install-All menu (install / uninstall / update / status).
REM  This launcher just routes; it holds no logic of its own, so
REM  the per-catalogue menus stay the single source of truth.
REM ============================================================

set "ROOT=%~dp0"
set "AGENTS_MENU=%ROOT%AgenticCliOptions\CodingAgents\Install-All.cmd"
set "TERMINALS_MENU=%ROOT%AgentTerminals\Install-All.cmd"

:menu
cls
echo ============================================================
echo   AgenticCliOptions  --  what do you want to manage?
echo ============================================================
echo.
echo     1^) Coding Agents     Claude, Codex, Gemini, Pi, Qwen, ...
echo     2^) Agent Terminals   Herdr, ... (multiplexers for agents)
echo.
echo     Q^) quit
echo.
set "INPUT="
set /p "INPUT=   Your choice: "
if not defined INPUT goto :menu
if /I "!INPUT!"=="Q" (endlocal & exit /b 0)
if "!INPUT!"=="1" goto :coding_agents
if "!INPUT!"=="2" goto :terminals
goto :menu

:coding_agents
if not exist "%AGENTS_MENU%" (
    echo.
    echo ERROR: Coding Agents menu not found at:
    echo     %AGENTS_MENU%
    echo.
    pause
    goto :menu
)
call "%AGENTS_MENU%"
goto :menu

:terminals
if not exist "%TERMINALS_MENU%" (
    echo.
    echo ERROR: Agent Terminals menu not found at:
    echo     %TERMINALS_MENU%
    echo.
    pause
    goto :menu
)
call "%TERMINALS_MENU%"
goto :menu
