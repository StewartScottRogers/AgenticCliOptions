@echo off
setlocal

REM ============================================================
REM  Run OpenSquilla  --  native launcher
REM  ------------------------------------------------------------
REM  Launches OpenSquilla chat against whatever provider you've
REM  configured via 'opensquilla onboard'. For OpenRouter, use
REM  OpenSquilla--openrouter.cmd instead.
REM
REM  Default model is always passed via --model. Override by setting
REM  OPENSQUILLA_MODEL once (persists for new terminals):
REM
REM      setx OPENSQUILLA_MODEL "anthropic/claude-opus-5"
REM ============================================================

if not defined OPENSQUILLA_MODEL set "OPENSQUILLA_MODEL=anthropic/claude-sonnet-5"

where opensquilla >nul 2>nul
if errorlevel 1 goto :notinstalled

echo Launching OpenSquilla chat with model: %OPENSQUILLA_MODEL%
call opensquilla chat --model "%OPENSQUILLA_MODEL%"
goto :end

:notinstalled
echo ERROR: 'opensquilla' was not found. Install with OpenSquilla--install.cmd.
pause

:end
endlocal
