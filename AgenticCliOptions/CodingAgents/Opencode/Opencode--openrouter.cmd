@echo off
setlocal

REM ============================================================
REM  opencode via OpenRouter
REM  ------------------------------------------------------------
REM  OpenRouter is a first-class built-in provider in opencode.
REM  Two ways to authenticate:
REM    1. Set OPENROUTER_API_KEY env var (this launcher's path).
REM       Some opencode builds (via @ai-sdk/openrouter) auto-pick
REM       it up. If your build does not, see option 2.
REM    2. Run 'opencode auth login openrouter' ONCE interactively;
REM       opencode prompts for the key and persists it to
REM       %USERPROFILE%\.config\opencode\auth.json.
REM
REM  Set the env var once with:
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM ============================================================

REM  OpenRouter slug without the 'openrouter/' prefix - the launcher
REM  adds it below. Override per-session by setting OPENROUTER_MODEL
REM  before calling, or persistently with setx.
if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=anthropic/claude-sonnet-4.5"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Connecting opencode to OpenRouter model: %OPENROUTER_MODEL%
call opencode --model "openrouter/%OPENROUTER_MODEL%"
popd
goto :end

:nokey
echo ERROR: Environment variable OPENROUTER_API_KEY is not set.
echo Set it once and open a new terminal:
echo.
echo     setx OPENROUTER_API_KEY "sk-or-...your-key..."
echo.
echo Or, equivalently, run once interactively:
echo     opencode auth login openrouter
echo.
echo Get a key at https://openrouter.ai/keys
pause

:end
endlocal
