@echo off
setlocal

REM ============================================================
REM  VT Code via OpenRouter
REM  ------------------------------------------------------------
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM
REM  VT Code reads OPENROUTER_API_KEY natively and accepts
REM  --provider openrouter --model <slug> in front of its chat
REM  subcommand. Browse model slugs at
REM  https://openrouter.ai/models
REM ============================================================

if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=qwen/qwen3-coder"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

call :prepend_path "%USERPROFILE%\.local\bin"

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching VT Code via OpenRouter model: %OPENROUTER_MODEL%
call vtcode --provider openrouter --model "%OPENROUTER_MODEL%" chat
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
