@echo off
setlocal

REM ============================================================
REM  OpenAI Codex CLI via LM Studio
REM  ------------------------------------------------------------
REM  Runs Codex against a local LM Studio server through its
REM  OpenAI-compatible API. Install Codex with Codex--install.cmd.
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

REM  LM Studio does not require a real key, but Codex still needs
REM  the env var named by env_key to exist - give it a placeholder.
set "LMSTUDIO_API_KEY=lmstudio"

REM  Ask LM Studio which model is currently loaded, then launch
REM  Codex pinned to that exact model id.
set "LMSTUDIO_MODEL="
for /f "delims=" %%i in ('powershell -command "try { (Invoke-RestMethod '%LMSTUDIO_URL%/v1/models').data[0].id } catch { '' }"') do set "LMSTUDIO_MODEL=%%i"

if not defined LMSTUDIO_MODEL goto :nomodel

echo Connecting Codex to LM Studio model: %LMSTUDIO_MODEL%
call codex ^
  -c model_provider=lmstudio ^
  -c model_providers.lmstudio.base_url=%LMSTUDIO_URL%/v1 ^
  -c model_providers.lmstudio.env_key=LMSTUDIO_API_KEY ^
  -c model_providers.lmstudio.wire_api=chat ^
  --yolo --model "%LMSTUDIO_MODEL%"
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
