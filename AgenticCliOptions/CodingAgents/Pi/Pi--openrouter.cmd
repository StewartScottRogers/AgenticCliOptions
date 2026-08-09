@echo off
setlocal

REM ============================================================
REM  Pi coding agent via OpenRouter
REM  ------------------------------------------------------------
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM
REM  Pi has built-in OpenRouter support; setting OPENROUTER_API_KEY
REM  is enough for Pi to discover the provider. This launcher then
REM  pins the model to one OpenRouter slug for the session.
REM ============================================================

REM  Optional: choose which model OpenRouter routes to. Honours the
REM  environment if OPENROUTER_MODEL is already set; otherwise the
REM  default below is used. Browse slugs at
REM  https://openrouter.ai/models
if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=anthropic/claude-sonnet-5"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Connecting Pi to OpenRouter model: %OPENROUTER_MODEL%
call pi --provider openrouter --model "%OPENROUTER_MODEL%"
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
