@echo off
setlocal

REM ============================================================
REM  Qwen Code CLI (Qwen Coder) via LM Studio
REM  ------------------------------------------------------------
REM  Qwen Code talks to LM Studio's OpenAI-compatible API and
REM  auto-discovers .qwen\settings.json from cwd. The launcher
REM  renders .qwen\settings.template.json with the auto-detected
REM  LMSTUDIO_URL substituted in, drops it into a temp dir, and
REM  runs qwen from there so it picks up the per-run settings.
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

REM Render a per-run .qwen\settings.json from the template into a temp dir, then run qwen from there
set "QWEN_LMSTUDIO_TMP=%TEMP%\qwen-lmstudio-%RANDOM%"
if not exist "%QWEN_LMSTUDIO_TMP%\.qwen" mkdir "%QWEN_LMSTUDIO_TMP%\.qwen"
powershell -NoProfile -Command "(Get-Content -Raw '%~dp0.qwen\settings.template.json') -replace '__LMSTUDIO_URL__', $env:LMSTUDIO_URL | Set-Content -Path (Join-Path $env:QWEN_LMSTUDIO_TMP '.qwen\settings.json') -Encoding ASCII"

set "ORIG_DIR=%CD%"
pushd "%QWEN_LMSTUDIO_TMP%"

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

echo Launching Qwen Code via LM Studio model: %LMSTUDIO_MODEL%
call qwen --yolo --model "%LMSTUDIO_MODEL%"
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
