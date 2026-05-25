@echo off
setlocal

REM ============================================================
REM  Trae Agent (ByteDance) via LM Studio
REM  ------------------------------------------------------------
REM  Trae's 'openai' provider accepts OPENAI_BASE_URL and
REM  OPENAI_API_KEY for any OpenAI-compatible endpoint. This
REM  launcher points it at the local LM Studio server.
REM
REM  Default model for this agent: qwen3-coder-30b
REM  Override with:
REM      set LMSTUDIO_MODEL=<other-id>
REM  Override the URL:
REM      set LMSTUDIO_URL=http://127.0.0.1:1234
REM ============================================================

REM ---- auto-detect LMSTUDIO_URL (loopback + this machine's LAN IPv4s, ports 1234/1235) ----
call "%~dp0..\_resolve-lmstudio-url.cmd"
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

set "OPENAI_API_KEY=lmstudio"
set "OPENAI_BASE_URL=%LMSTUDIO_URL%/v1"

echo Launching Trae Agent via LM Studio model: %LMSTUDIO_MODEL%
call trae-cli interactive --provider openai --model "%LMSTUDIO_MODEL%"
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
