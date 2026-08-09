@echo off
setlocal

REM ============================================================
REM  Oh-My-Pi (omp) via OpenRouter
REM  ------------------------------------------------------------
REM  The API key is read from the environment - nothing to edit
REM  in this file. Set it once (persists for new terminals):
REM
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  ...then open a new terminal. Get a key at
REM  https://openrouter.ai/keys
REM
REM  omp recognises OPENROUTER_API_KEY natively. The model is
REM  selected via the --model flag using a 'provider/modelId'
REM  pattern that bypasses omp's normal coalescing. Browse
REM  slugs at https://openrouter.ai/models
REM ============================================================

if not defined OPENROUTER_MODEL  set "OPENROUTER_MODEL=openrouter/anthropic/claude-sonnet-5"

REM ---- no edits needed below this line -----------------------

if not defined OPENROUTER_API_KEY goto :nokey
if "%OPENROUTER_API_KEY%"=="" goto :nokey

call :prepend_path "%LOCALAPPDATA%\omp"

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching Oh-My-Pi (omp) via OpenRouter model: %OPENROUTER_MODEL%
call omp --model "%OPENROUTER_MODEL%"
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
