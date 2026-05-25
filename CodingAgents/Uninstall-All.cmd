@echo off
setlocal

REM ============================================================
REM  Uninstall-All  --  remove every coding agent CLI in one go
REM  ------------------------------------------------------------
REM  Runs each agent's matching uninstall script, in the same
REM  order Install-All installed them. Each child script removes
REM  ONLY the CLI it owns - no shared deps, no user config.
REM
REM  What is NOT removed (on purpose):
REM    - Shared deps installed by Install-All:
REM        Node.js LTS, uv, Git for Windows, WSL + Ubuntu.
REM      These are general-purpose tools other software on your
REM      machine may rely on. Remove via "Apps & features" or
REM      'winget uninstall ...' / 'wsl --uninstall' if you want.
REM    - Per-agent config directories (API keys, sessions):
REM        %USERPROFILE%\.claude, .codex, .gemini, .antigravity,
REM        .pi, .qwen, .grok, .mistral, .trae, plus the Amazon Q
REM        data inside WSL.
REM      Delete those by hand if you want a fully clean slate.
REM ============================================================

set "AGENTS_UNINSTALL_ALL=1"
set "ROOT=%~dp0"

echo ============================================================
echo  Uninstalling every coding agent CLI in this project
echo ============================================================
echo.

call :uninstall_agent AmazonQ
call :uninstall_agent VTCode
call :uninstall_agent Junie
call :uninstall_agent Aider
call :uninstall_agent OpenSquilla
call :uninstall_agent Oh-My-Pi
call :uninstall_agent Codebuff
call :uninstall_agent Hermes
call :uninstall_agent Trae
call :uninstall_agent Mistral
call :uninstall_agent Grok
call :uninstall_agent Qwen
call :uninstall_agent Pi
call :uninstall_agent Antigravity
call :uninstall_agent Gemini
call :uninstall_agent Codex
call :uninstall_agent Claude

echo.
echo ============================================================
echo  All agents processed.
echo.
echo  Shared dependencies (Node.js, uv, Git, WSL) and per-agent
echo  config directories were LEFT IN PLACE. See the header of
echo  this script for how to remove them manually.
echo ============================================================
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
goto :eof


REM ============================================================
REM  Helper: run one agent's uninstall script
REM ============================================================
:uninstall_agent
echo ------------------------------------------------------------
echo  %~1
echo ------------------------------------------------------------
if exist "%ROOT%%~1\%~1--uninstall.cmd" (
    call "%ROOT%%~1\%~1--uninstall.cmd"
) else (
    echo ERROR: uninstall script for %~1 was not found.
)
echo.
exit /b 0
