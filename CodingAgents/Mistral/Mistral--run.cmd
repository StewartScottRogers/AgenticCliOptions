@echo off
setlocal

REM ============================================================
REM  Mistral Vibe - via the Mistral API
REM  ------------------------------------------------------------
REM  Set your Mistral API key once (persists for new terminals):
REM
REM      setx MISTRAL_API_KEY "...your-key..."
REM
REM  Get a key at https://console.mistral.ai
REM ============================================================

if not defined MISTRAL_API_KEY goto :nokey
if "%MISTRAL_API_KEY%"=="" goto :nokey

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching Mistral Vibe...
REM  Vibe asks before running commands by default. Check
REM  'vibe --help' for an auto-approve / unattended flag if you
REM  want to skip confirmations.
call vibe
popd
goto :end

:nokey
echo ERROR: Environment variable MISTRAL_API_KEY is not set.
echo Set it once, then open a new terminal:
echo.
echo     setx MISTRAL_API_KEY "...your-key..."
echo.
echo Get a key at https://console.mistral.ai
pause

:end
endlocal
