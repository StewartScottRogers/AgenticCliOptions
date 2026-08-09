@echo off
setlocal

REM ============================================================
REM  Claude Code via OpenRouter
REM  ------------------------------------------------------------
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM ============================================================

REM  Optional: choose which models OpenRouter routes to. These also
REM  honour the environment if OPENROUTER_MODEL / OPENROUTER_SMALL_MODEL
REM  are already set; otherwise the defaults below are used.
REM  Browse slugs at https://openrouter.ai/models
if not defined OPENROUTER_MODEL       set "OPENROUTER_MODEL=anthropic/claude-sonnet-5"
if not defined OPENROUTER_SMALL_MODEL  set "OPENROUTER_SMALL_MODEL=anthropic/claude-haiku-4.5"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

REM  Point Claude Code at OpenRouter's Anthropic-compatible endpoint.
REM  Base URL must be ".../api" with no /v1 suffix. ANTHROPIC_API_KEY
REM  is cleared so the AUTH_TOKEN (your OpenRouter key) is used instead.
set "ANTHROPIC_BASE_URL=https://openrouter.ai/api"
set "ANTHROPIC_AUTH_TOKEN=%OPENROUTER_API_KEY%"
set "ANTHROPIC_API_KEY="
set "ANTHROPIC_SMALL_FAST_MODEL=%OPENROUTER_SMALL_MODEL%"

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Connecting to OpenRouter model: %OPENROUTER_MODEL%
call claude --verbose --dangerously-skip-permissions --model "%OPENROUTER_MODEL%"
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
