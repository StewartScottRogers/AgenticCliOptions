@echo off
setlocal

REM ============================================================
REM  Run Aider  --  native launcher
REM  ------------------------------------------------------------
REM  Launches Aider against whatever provider you've configured
REM  via env vars (OPENAI_API_KEY, ANTHROPIC_API_KEY, etc).
REM  For OpenRouter, use Aider--openrouter.cmd instead.
REM
REM  Default model is always passed via --model. Override by setting
REM  AIDER_MODEL once (persists for new terminals):
REM
REM      setx AIDER_MODEL "gpt-5"
REM ============================================================

if not defined AIDER_MODEL set "AIDER_MODEL=openrouter/anthropic/claude-sonnet-4.5"

where aider >nul 2>nul
if errorlevel 1 goto :notinstalled

echo Launching Aider with model: %AIDER_MODEL%
call aider --model "%AIDER_MODEL%"
goto :end

:notinstalled
echo ERROR: 'aider' was not found. Install with Aider--install.cmd.
pause

:end
endlocal
