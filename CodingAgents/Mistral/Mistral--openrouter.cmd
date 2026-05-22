@echo off
setlocal

REM ============================================================
REM  Mistral Vibe via OpenRouter
REM  ------------------------------------------------------------
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM
REM  CAVEAT: this points Vibe at OpenRouter by overriding the
REM  Mistral API base URL. It works only if your Vibe version
REM  honours MISTRAL_BASE_URL. If Vibe ignores it, run Vibe
REM  natively with Mistral--run.cmd instead. Verify with a short
REM  test prompt before relying on this launcher.
REM ============================================================

REM  Optional: choose which model OpenRouter routes to. Browse
REM  slugs at https://openrouter.ai/models
if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=mistralai/devstral-2"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

REM  Reuse the Mistral SDK env vars, redirected to OpenRouter.
set "MISTRAL_API_KEY=%OPENROUTER_API_KEY%"
set "MISTRAL_BASE_URL=https://openrouter.ai/api/v1"

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Connecting Mistral Vibe to OpenRouter model: %OPENROUTER_MODEL%
call vibe --model "%OPENROUTER_MODEL%"
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
