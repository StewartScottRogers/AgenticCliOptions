@echo off
setlocal

REM ============================================================
REM  OpenClaw via OpenRouter
REM  ------------------------------------------------------------
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM
REM  OpenClaw recognises OPENROUTER_API_KEY natively and uses
REM  refs of the form 'openrouter/<provider>/<model>'. Inside
REM  the chat you can also switch with:
REM      /model openrouter/<provider>/<model>
REM
REM  First run? Complete the onboarding flow first:
REM      openclaw onboard
REM ============================================================

if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=openrouter/anthropic/claude-sonnet-4.5"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Connecting OpenClaw to OpenRouter model: %OPENROUTER_MODEL%
REM  Persist the model selection, then launch the interactive
REM  agent. 'openclaw models set' is idempotent.
call openclaw models set "%OPENROUTER_MODEL%" >nul 2>nul
call openclaw
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

:end
endlocal
