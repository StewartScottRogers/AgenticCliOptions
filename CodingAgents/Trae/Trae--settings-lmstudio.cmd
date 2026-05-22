@echo off
setlocal

REM ============================================================
REM  Trae Agent (ByteDance) via LM Studio
REM  ------------------------------------------------------------
REM  Runs Trae Agent against a local LM Studio server through its
REM  OpenAI-compatible API. Install Trae with Trae--install.cmd.
REM
REM  Before running: start LM Studio, load a model, and start its
REM  local server from the Developer tab.
REM ============================================================

REM  Optional: override the LM Studio server address. Honours the
REM  environment if LMSTUDIO_URL is already set; otherwise the
REM  default below is used.
if not defined LMSTUDIO_URL  set "LMSTUDIO_URL=http://192.168.12.174:1234"

REM ---- no edits needed below this line -----------------------

set "ORIG_DIR=%CD%"
pushd "%~dp0"

REM  Point Trae's OpenAI-compatible provider at LM Studio. The
REM  key is a placeholder - LM Studio does not check it.
set "OPENAI_API_KEY=lmstudio"
set "OPENAI_BASE_URL=%LMSTUDIO_URL%/v1"

REM  Ask LM Studio which model is currently loaded, then launch
REM  Trae Agent pinned to that exact model id.
set "LMSTUDIO_MODEL="
for /f "delims=" %%i in ('powershell -command "try { (Invoke-RestMethod '%LMSTUDIO_URL%/v1/models').data[0].id } catch { '' }"') do set "LMSTUDIO_MODEL=%%i"

if not defined LMSTUDIO_MODEL goto :nomodel

echo Launching Trae Agent via LM Studio model: %LMSTUDIO_MODEL%
call trae-cli interactive --provider openai --model "%LMSTUDIO_MODEL%"
popd
goto :end

:nomodel
popd
echo ERROR: Could not detect an LM Studio model at %LMSTUDIO_URL%
echo Make sure LM Studio is running, a model is loaded, and its
echo local server is started from the Developer tab.
pause

:end
endlocal
