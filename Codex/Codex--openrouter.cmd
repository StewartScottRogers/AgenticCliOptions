@echo off
setlocal

REM ============================================================
REM  OpenAI Codex CLI via OpenRouter
REM  ------------------------------------------------------------
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM ============================================================

REM  Optional: choose which model OpenRouter routes to. Honours the
REM  environment if OPENROUTER_MODEL is already set; otherwise the
REM  default below is used. Browse slugs at
REM  https://openrouter.ai/models
if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=openai/gpt-5.1-codex"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Connecting Codex to OpenRouter model: %OPENROUTER_MODEL%

REM  Codex reads the OpenRouter key from the OPENROUTER_API_KEY env
REM  var (env_key). The -c overrides define an OpenRouter model
REM  provider on the fly, so nothing is written to the global
REM  ~/.codex/config.toml. wire_api=chat selects the OpenAI-style
REM  chat-completions protocol that OpenRouter exposes.
call codex ^
  -c model_provider=openrouter ^
  -c model_providers.openrouter.base_url=https://openrouter.ai/api/v1 ^
  -c model_providers.openrouter.env_key=OPENROUTER_API_KEY ^
  -c model_providers.openrouter.wire_api=chat ^
  --yolo --model "%OPENROUTER_MODEL%"
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
