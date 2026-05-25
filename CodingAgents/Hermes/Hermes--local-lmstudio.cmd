@echo off
setlocal

REM ============================================================
REM  Hermes Agent (Nous Research) via LM Studio
REM  ------------------------------------------------------------
REM  Hermes recognises 'openai' as a provider. This launcher sets
REM  OPENAI_BASE_URL / OPENAI_API_KEY so Hermes talks to the local
REM  LM Studio server, and pins LMSTUDIO_MODEL to a Nous Research
REM  Hermes model so the agent's voice matches its vendor.
REM
REM  Default model for this agent: nousresearch/hermes-3-llama-3.1-8b
REM  Override with:
REM      set LMSTUDIO_MODEL=<other-id>
REM  Override the URL:
REM      set LMSTUDIO_URL=http://127.0.0.1:1234
REM
REM  If your hermes-cli version rejects '--provider openai', drop
REM  the flag - OPENAI_BASE_URL alone is enough for most builds.
REM ============================================================

REM ---- auto-detect LMSTUDIO_URL (loopback + this machine's LAN IPv4s, ports 1234/1235) ----
call "%~dp0..\_resolve-lmstudio-url.cmd"
if not defined LMSTUDIO_MODEL  set "LMSTUDIO_MODEL=nousresearch/hermes-3-llama-3.1-8b"

REM ---- no edits needed below this line -----------------------

set "ORIG_DIR=%CD%"
pushd "%~dp0"

REM  Make 'hermes' resolvable even if this shell predates the install.
call :prepend_path "%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts"

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

echo Launching Hermes Agent via LM Studio model: %LMSTUDIO_MODEL%
call hermes chat --provider openai --model "%LMSTUDIO_MODEL%"
popd
goto :end

:nomodel
popd
echo ERROR: No model is loaded at %LMSTUDIO_URL%.
echo Run ..\Install-lmstudio.cmd first, then make sure a model is loaded:
echo     lms load %LMSTUDIO_MODEL%
pause
goto :end

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0

:end
endlocal
