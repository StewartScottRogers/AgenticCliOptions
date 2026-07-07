@echo off
setlocal

REM ============================================================
REM  Tau via OpenRouter
REM  ------------------------------------------------------------
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM
REM  Tau ships a built-in 'openrouter' provider (base URL
REM  https://openrouter.ai/api/v1, key OPENROUTER_API_KEY), so
REM  setting the key is enough - no 'tau setup' needed. This
REM  launcher pins the model to one OpenRouter slug for the
REM  session. Browse slugs at https://openrouter.ai/models
REM ============================================================

if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=anthropic/claude-sonnet-4.5"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Connecting Tau to OpenRouter model: %OPENROUTER_MODEL%
call tau --provider openrouter --model "%OPENROUTER_MODEL%"
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
