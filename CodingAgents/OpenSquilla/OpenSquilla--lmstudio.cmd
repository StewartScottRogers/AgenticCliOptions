@echo off
setlocal

REM ============================================================
REM  OpenSquilla via LM Studio
REM  ------------------------------------------------------------
REM  OpenSquilla supports custom providers via its 'configure'
REM  subcommand. We register LM Studio as a generic 'openai'
REM  provider pointing at the local server, then launch chat.
REM
REM  Default model for this agent: qwen3-coder-30b
REM  Override with:
REM      set LMSTUDIO_MODEL=<other-id>
REM  Override the URL:
REM      set LMSTUDIO_URL=http://127.0.0.1:1234
REM
REM  If your opensquilla version does not accept --provider openai,
REM  drop the configure call - OPENAI_BASE_URL / OPENAI_API_KEY in
REM  the environment are enough for most builds.
REM ============================================================

if not defined LMSTUDIO_URL    set "LMSTUDIO_URL=http://192.168.12.174:1234"
if not defined LMSTUDIO_MODEL  set "LMSTUDIO_MODEL=qwen3-coder-30b"

REM ---- no edits needed below this line -----------------------

set "ORIG_DIR=%CD%"
pushd "%~dp0"

if exist "%USERPROFILE%\.lmstudio\bin\lms.exe" set "PATH=%USERPROFILE%\.lmstudio\bin;%PATH%"
where lms >nul 2>nul && call lms load "%LMSTUDIO_MODEL%" --gpu max --ttl 3600 >nul 2>nul

set "LMSTUDIO_ACTUAL="
for /f "delims=" %%i in ('powershell -NoProfile -Command "try { (Invoke-RestMethod '%LMSTUDIO_URL%/v1/models' -TimeoutSec 3).data[0].id } catch { '' }"') do set "LMSTUDIO_ACTUAL=%%i"
if not defined LMSTUDIO_ACTUAL goto :nomodel

if /I not "%LMSTUDIO_ACTUAL%"=="%LMSTUDIO_MODEL%" (
    echo NOTE: hard-pin requested "%LMSTUDIO_MODEL%" but LM Studio
    echo       at %LMSTUDIO_URL% has "%LMSTUDIO_ACTUAL%" loaded.
    echo       Falling back to the loaded model. To switch on this
    echo       host, run:  lms load %LMSTUDIO_MODEL%
    set "LMSTUDIO_MODEL=%LMSTUDIO_ACTUAL%"
)

set "LMSTUDIO_API_KEY=lmstudio"
set "OPENAI_API_KEY=lmstudio"
set "OPENAI_BASE_URL=%LMSTUDIO_URL%/v1"

echo Configuring OpenSquilla for LM Studio (idempotent)...
call opensquilla configure --section provider --provider openai --api-key-env LMSTUDIO_API_KEY --base-url "%LMSTUDIO_URL%/v1" --model "%LMSTUDIO_MODEL%" >nul 2>nul

echo Launching OpenSquilla chat with model: %LMSTUDIO_MODEL%
call opensquilla chat --model "%LMSTUDIO_MODEL%"
popd
goto :end

:nomodel
popd
echo ERROR: No model is loaded at %LMSTUDIO_URL%.
echo Run ..\Install-lmstudio.cmd first, then make sure a model is loaded:
echo     lms load %LMSTUDIO_MODEL%
pause

:end
endlocal
