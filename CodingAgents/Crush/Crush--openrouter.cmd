@echo off
setlocal

REM ============================================================
REM  Crush (Charmbracelet) via OpenRouter
REM  ------------------------------------------------------------
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM
REM  Crush has first-class OpenRouter support: setting
REM  OPENROUTER_API_KEY enables the built-in provider with no
REM  config edits. Model selection happens INSIDE the Crush TUI -
REM  Crush does not yet accept a --model flag on the command
REM  line. Pick your OpenRouter model from the model picker once
REM  the TUI is running.
REM ============================================================

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching Crush with OpenRouter enabled (model picker in TUI)...
call crush
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
