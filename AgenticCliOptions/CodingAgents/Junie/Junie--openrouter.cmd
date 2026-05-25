@echo off
setlocal

REM ============================================================
REM  Junie CLI (JetBrains) via OpenRouter
REM  ------------------------------------------------------------
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM
REM  Junie's BYOK flag for OpenRouter is --openrouter-api-key.
REM  Combined with --provider openrouter and --model <alias>,
REM  this bypasses Junie's default JetBrains-managed routing.
REM
REM  IMPORTANT: Junie has its own model registry and rejects
REM  raw OpenRouter slugs (e.g. "anthropic/claude-sonnet-4.5").
REM  Use Junie aliases instead: sonnet, opus, gpt, grok, or
REM  dated names like claude-sonnet-4-6, claude-opus-4-7,
REM  gpt-5.5, etc. Run 'junie --model invalid' once to see the
REM  full current list.
REM ============================================================

if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=sonnet"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

call :prepend_path "%USERPROFILE%\.local\bin"

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching Junie via OpenRouter model: %OPENROUTER_MODEL%
call junie --openrouter-api-key "%OPENROUTER_API_KEY%" --provider openrouter --model "%OPENROUTER_MODEL%"
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
goto :end

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0

:end
endlocal
