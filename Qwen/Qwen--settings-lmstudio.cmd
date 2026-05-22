@echo off
setlocal

REM ============================================================
REM  Qwen Code CLI (Qwen Coder) via LM Studio
REM  ------------------------------------------------------------
REM  Runs Qwen Code against a local LM Studio server through its
REM  OpenAI-compatible API. Requires the Qwen Code CLI - install
REM  it with Qwen--install.cmd.
REM
REM  The endpoint and auth type live in .qwen\settings.json next
REM  to this script. Qwen Code discovers that file automatically
REM  because this launcher runs from its own folder - nothing in
REM  this file needs editing.
REM
REM  Before running: start LM Studio, load a model, and start its
REM  local server from the Developer tab.
REM ============================================================

REM  Optional: override the LM Studio server address. Honours the
REM  environment if LMSTUDIO_URL is already set; otherwise the
REM  default below is used. Keep this in sync with the OPENAI_BASE_URL
REM  in .qwen\settings.json.
if not defined LMSTUDIO_URL  set "LMSTUDIO_URL=http://192.168.12.174:1234"

REM ---- no edits needed below this line -----------------------

set "ORIG_DIR=%CD%"
pushd "%~dp0"

REM  Ask LM Studio which model is currently loaded, then launch
REM  Qwen Code pinned to that exact model id. Connection details
REM  come from .qwen\settings.json.
set "LMSTUDIO_MODEL="
for /f "delims=" %%i in ('powershell -command "try { (Invoke-RestMethod '%LMSTUDIO_URL%/v1/models').data[0].id } catch { '' }"') do set "LMSTUDIO_MODEL=%%i"

if not defined LMSTUDIO_MODEL goto :nomodel

echo Launching Qwen Code via LM Studio model: %LMSTUDIO_MODEL%
call qwen --yolo --model "%LMSTUDIO_MODEL%"
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
