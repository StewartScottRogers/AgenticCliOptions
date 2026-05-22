@echo off
setlocal

REM ============================================================
REM  Trae Agent (ByteDance) via OpenRouter
REM  ------------------------------------------------------------
REM  Requires the Trae Agent CLI - install it with
REM  Trae--install.cmd.
REM
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM
REM  Trae Agent is provider-agnostic. The default model below is
REM  one of ByteDance's own Seed models, but any OpenRouter slug
REM  works. Browse slugs at https://openrouter.ai/models
REM ============================================================

if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=bytedance/seed-oss-36b"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

REM  Trae speaks the OpenAI-compatible API. Point its 'openai'
REM  provider at OpenRouter's /v1 endpoint using your key.
set "OPENAI_API_KEY=%OPENROUTER_API_KEY%"
set "OPENAI_BASE_URL=https://openrouter.ai/api/v1"

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching Trae Agent via OpenRouter model: %OPENROUTER_MODEL%
call trae-cli interactive --provider openai --model "%OPENROUTER_MODEL%"
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
