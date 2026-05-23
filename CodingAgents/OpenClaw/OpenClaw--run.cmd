@echo off
setlocal

REM ============================================================
REM  Run OpenClaw  --  native launcher
REM  ------------------------------------------------------------
REM  Launches OpenClaw against whatever provider you've
REM  configured via 'openclaw onboard'. For OpenRouter, use
REM  OpenClaw--openrouter.cmd instead.
REM ============================================================

where openclaw >nul 2>nul
if errorlevel 1 goto :notinstalled

call openclaw
goto :end

:notinstalled
echo ERROR: 'openclaw' was not found. Install with OpenClaw--install.cmd.
pause

:end
endlocal
