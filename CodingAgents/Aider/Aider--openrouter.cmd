@echo off
setlocal

REM ============================================================
REM  Aider via OpenRouter
REM  ------------------------------------------------------------
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM
REM  Aider has first-class OpenRouter support. Set
REM  OPENROUTER_API_KEY and pass --model openrouter/<provider>/<model>.
REM  Browse model slugs at https://openrouter.ai/models
REM
REM  To list every OpenRouter model Aider knows about:
REM      aider --list-models openrouter/
REM ============================================================

if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=openrouter/anthropic/claude-sonnet-4.5"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching Aider via OpenRouter model: %OPENROUTER_MODEL%
call aider --model "%OPENROUTER_MODEL%"
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
