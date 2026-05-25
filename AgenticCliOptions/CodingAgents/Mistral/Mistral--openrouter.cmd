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
REM  Vibe has no --model CLI flag and no MISTRAL_BASE_URL env
REM  override. The supported way to point Vibe at OpenRouter is
REM  via a config.toml that declares an OpenRouter provider and
REM  one model. This launcher writes that config into a private
REM  VIBE_HOME ('.vibe-home' next to this script) and points
REM  vibe at it, so the launcher is fully self-contained and
REM  never touches the user's ~/.vibe/config.toml.
REM ============================================================

REM  Optional: choose which model OpenRouter routes to. Browse
REM  slugs at https://openrouter.ai/models
if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=mistralai/devstral-medium"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

set "ORIG_DIR=%CD%"
pushd "%~dp0"

REM  Use a launcher-local VIBE_HOME so the user's ~/.vibe is
REM  preserved. The config is rewritten every run, so changing
REM  OPENROUTER_MODEL just takes effect on next launch.
set "VIBE_HOME=%~dp0.vibe-home"
if not exist "%VIBE_HOME%\" mkdir "%VIBE_HOME%"
>  "%VIBE_HOME%\config.toml" echo active_model = "openrouter"
>> "%VIBE_HOME%\config.toml" echo.
>> "%VIBE_HOME%\config.toml" echo [[providers]]
>> "%VIBE_HOME%\config.toml" echo name = "openrouter"
>> "%VIBE_HOME%\config.toml" echo api_base = "https://openrouter.ai/api/v1"
>> "%VIBE_HOME%\config.toml" echo api_key_env_var = "OPENROUTER_API_KEY"
>> "%VIBE_HOME%\config.toml" echo api_style = "openai"
>> "%VIBE_HOME%\config.toml" echo backend = "generic"
>> "%VIBE_HOME%\config.toml" echo.
>> "%VIBE_HOME%\config.toml" echo [[models]]
>> "%VIBE_HOME%\config.toml" echo name = "%OPENROUTER_MODEL%"
>> "%VIBE_HOME%\config.toml" echo provider = "openrouter"
>> "%VIBE_HOME%\config.toml" echo alias = "openrouter"

echo Connecting Mistral Vibe to OpenRouter model: %OPENROUTER_MODEL%
call vibe
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
