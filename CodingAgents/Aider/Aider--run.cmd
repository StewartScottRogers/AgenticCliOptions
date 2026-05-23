@echo off
setlocal

REM ============================================================
REM  Run Aider  --  native launcher
REM  ------------------------------------------------------------
REM  Launches Aider against whatever provider you've configured
REM  via env vars (OPENAI_API_KEY, ANTHROPIC_API_KEY, etc).
REM  For OpenRouter, use Aider--openrouter.cmd instead.
REM ============================================================

where aider >nul 2>nul
if errorlevel 1 goto :notinstalled

call aider
goto :end

:notinstalled
echo ERROR: 'aider' was not found. Install with Aider--install.cmd.
pause

:end
endlocal
