@echo off
setlocal

REM ============================================================
REM  Run Junie CLI (JetBrains)  --  native launcher
REM  ------------------------------------------------------------
REM  Launches Junie against whatever provider you've configured
REM  via /account inside the TUI, or with a Junie subscription.
REM  For OpenRouter, use Junie--openrouter.cmd instead.
REM
REM  Default model is always passed via --model. Override by setting
REM  JUNIE_MODEL once (persists for new terminals). Junie uses its
REM  own alias registry (sonnet, opus, gpt, grok, ...) - it
REM  rejects raw OpenRouter slugs.
REM
REM      setx JUNIE_MODEL "opus"
REM ============================================================

if not defined JUNIE_MODEL set "JUNIE_MODEL=sonnet"

call :prepend_path "%USERPROFILE%\.local\bin"

where junie >nul 2>nul
if errorlevel 1 goto :notinstalled

echo Launching Junie CLI with model: %JUNIE_MODEL%
call junie --model "%JUNIE_MODEL%"
goto :end

:notinstalled
echo ERROR: 'junie' was not found. Install with Junie--install.cmd.
pause
goto :end

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0

:end
endlocal
