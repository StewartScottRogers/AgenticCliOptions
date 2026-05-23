@echo off
setlocal

REM ============================================================
REM  OpenSquilla via OpenRouter
REM  ------------------------------------------------------------
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM
REM  OpenSquilla supports OpenRouter as a first-class provider.
REM  We ensure onboarding has been done for the openrouter provider
REM  (idempotent), then launch the chat. Browse model slugs at
REM  https://openrouter.ai/models
REM ============================================================

if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=anthropic/claude-sonnet-4.5"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Configuring OpenSquilla for OpenRouter (idempotent)...
REM  Persist the provider+model into the OpenSquilla config so
REM  every subsequent 'opensquilla chat' run uses OpenRouter.
REM  Errors are suppressed because 'configure' will fail noisily
REM  if the workspace has not yet been initialised - in which
REM  case opensquilla chat will prompt for init below.
call opensquilla configure --section provider --provider openrouter --api-key-env OPENROUTER_API_KEY --model "%OPENROUTER_MODEL%" >nul 2>nul

echo Launching OpenSquilla chat with model: %OPENROUTER_MODEL%
call opensquilla chat --model "%OPENROUTER_MODEL%"
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
