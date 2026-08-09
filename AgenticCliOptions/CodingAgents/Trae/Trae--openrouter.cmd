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
REM  Trae requires a trae_config.yaml. This launcher writes
REM  one next to itself and points trae-cli at it via
REM  TRAE_CONFIG_FILE, so the user's home dir is never touched.
REM  Trae Agent is provider-agnostic - default below is Claude
REM  Sonnet 4.5 for consistency with the other launchers
REM  (ByteDance's Seed models have been delisted from OpenRouter).
REM  Browse slugs at https://openrouter.ai/models
REM ============================================================

if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=anthropic/claude-sonnet-5"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

REM  Trae's per-provider env-var lookup is {PROVIDER_UPPER}_API_KEY
REM  and {PROVIDER_UPPER}_BASE_URL - so for provider 'openai' it
REM  reads OPENAI_*. Point those at OpenRouter.
set "OPENAI_API_KEY=%OPENROUTER_API_KEY%"
set "OPENAI_BASE_URL=https://openrouter.ai/api/v1"

set "ORIG_DIR=%CD%"
pushd "%~dp0"

REM  Write a launcher-local trae_config.yaml. Rewritten every run
REM  so changing OPENROUTER_MODEL just takes effect on next launch.
set "TRAE_CONFIG_FILE=%~dp0trae_config.yaml"
>  "%TRAE_CONFIG_FILE%" echo agents:
>> "%TRAE_CONFIG_FILE%" echo     trae_agent:
>> "%TRAE_CONFIG_FILE%" echo         enable_lakeview: false
>> "%TRAE_CONFIG_FILE%" echo         model: trae_agent_model
>> "%TRAE_CONFIG_FILE%" echo         max_steps: 50
>> "%TRAE_CONFIG_FILE%" echo         tools:
>> "%TRAE_CONFIG_FILE%" echo             - bash
>> "%TRAE_CONFIG_FILE%" echo             - str_replace_based_edit_tool
>> "%TRAE_CONFIG_FILE%" echo             - sequentialthinking
>> "%TRAE_CONFIG_FILE%" echo             - task_done
>> "%TRAE_CONFIG_FILE%" echo allow_mcp_servers: []
>> "%TRAE_CONFIG_FILE%" echo mcp_servers: {}
>> "%TRAE_CONFIG_FILE%" echo model_providers:
>> "%TRAE_CONFIG_FILE%" echo     openai:
>> "%TRAE_CONFIG_FILE%" echo         api_key: placeholder
>> "%TRAE_CONFIG_FILE%" echo         provider: openai
>> "%TRAE_CONFIG_FILE%" echo         base_url: https://openrouter.ai/api/v1
>> "%TRAE_CONFIG_FILE%" echo models:
>> "%TRAE_CONFIG_FILE%" echo     trae_agent_model:
>> "%TRAE_CONFIG_FILE%" echo         model_provider: openai
>> "%TRAE_CONFIG_FILE%" echo         model: %OPENROUTER_MODEL%
>> "%TRAE_CONFIG_FILE%" echo         max_tokens: 4096
>> "%TRAE_CONFIG_FILE%" echo         temperature: 0.5
>> "%TRAE_CONFIG_FILE%" echo         top_p: 1
>> "%TRAE_CONFIG_FILE%" echo         top_k: 0
>> "%TRAE_CONFIG_FILE%" echo         max_retries: 5
>> "%TRAE_CONFIG_FILE%" echo         parallel_tool_calls: true

echo Launching Trae Agent via OpenRouter model: %OPENROUTER_MODEL%
call trae-cli interactive
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
