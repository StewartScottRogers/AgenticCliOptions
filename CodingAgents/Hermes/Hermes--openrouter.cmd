@echo off
setlocal

REM ============================================================
REM  Hermes Agent (Nous Research) via OpenRouter
REM  ------------------------------------------------------------
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM
REM  Hermes recognises 'openrouter' as a first-class provider and
REM  reads OPENROUTER_API_KEY from the environment. This launcher
REM  passes --provider openrouter and --model on the command line.
REM  Browse model slugs at https://openrouter.ai/models
REM ============================================================

if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=anthropic/claude-sonnet-4.5"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

REM  Make 'hermes' resolvable even if this shell predates the
REM  install (PATH-refresh hint).
call :prepend_path "%LOCALAPPDATA%\hermes\bin"

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Connecting Hermes Agent to OpenRouter model: %OPENROUTER_MODEL%
call hermes chat --provider openrouter --model "%OPENROUTER_MODEL%"
popd
goto :end

:nokey
echo ERROR: Environment variable OPENROUTER_API_KEY is not set.
echo Set it once, then open a new terminal:
echo.
echo     setx OPENROUTER_API_KEY "sk-or-...your-key..."
echo.
echo Get a key at https://openrouter.ai/keys
pause
goto :end


:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0

:end
endlocal
