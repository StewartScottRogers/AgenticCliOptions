@echo off
setlocal

REM ============================================================
REM  Qwen Code CLI (Qwen Coder) via OpenRouter
REM  ------------------------------------------------------------
REM  Requires the Qwen Code CLI. Install it with Qwen--install.cmd
REM  or:  npm install -g @qwen-code/qwen-code
REM
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM ============================================================

REM  Optional: choose which Qwen model OpenRouter routes to. This
REM  honours the environment if QWEN_MODEL is already set; otherwise
REM  the default below is used. Browse slugs at
REM  https://openrouter.ai/models
if not defined QWEN_MODEL  set "QWEN_MODEL=qwen/qwen3-coder"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

REM  Qwen Code speaks the OpenAI-compatible API. Point it at
REM  OpenRouter's /v1 endpoint using your OpenRouter key.
set "OPENAI_API_KEY=%OPENROUTER_API_KEY%"
set "OPENAI_BASE_URL=https://openrouter.ai/api/v1"
set "OPENAI_MODEL=%QWEN_MODEL%"

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching Qwen Code via OpenRouter model: %QWEN_MODEL%
call qwen --yolo --model "%QWEN_MODEL%"
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
