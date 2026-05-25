@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  opencode via LM Studio
REM  ------------------------------------------------------------
REM  Runs opencode against a local LM Studio server through its
REM  OpenAI-compatible API. Install opencode with Opencode--install.cmd.
REM
REM  opencode has NO --base-url CLI flag, so we generate a per-run
REM  config JSON in %TEMP% declaring a custom 'lmstudio' provider
REM  via the @ai-sdk/openai-compatible adapter, point OPENCODE_CONFIG
REM  at it, then launch with --model lmstudio/^<loaded-model^>.
REM  Nothing is written to the user's permanent opencode.json.
REM
REM  Default model id: qwen3-coder-30b
REM  Override with:
REM      set LMSTUDIO_MODEL=^<other-id^>
REM  Override the URL:
REM      set LMSTUDIO_URL=http://127.0.0.1:1234
REM ============================================================

call "%~dp0..\_resolve-lmstudio-url.cmd"
if not defined LMSTUDIO_MODEL  set "LMSTUDIO_MODEL=qwen3-coder-30b"

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
    echo       Falling back to the loaded model.
    set "LMSTUDIO_MODEL=%LMSTUDIO_ACTUAL%"
)

REM  Build the per-run config. PowerShell handles the JSON quoting;
REM  Set-Content writes UTF-8 without BOM (opencode parses cleanly).
set "OPENCODE_CONFIG=%TEMP%\opencode-lmstudio-config.json"
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$schema='https://opencode.ai/config.json';" ^
  "$cfg = [ordered]@{ '$schema'=$schema; provider=[ordered]@{ lmstudio=[ordered]@{ npm='@ai-sdk/openai-compatible'; name='LM Studio (local)'; options=[ordered]@{ baseURL='%LMSTUDIO_URL%/v1' }; models=[ordered]@{ '%LMSTUDIO_MODEL%'=[ordered]@{ name='LM Studio: %LMSTUDIO_MODEL%' } } } } };" ^
  "$cfg | ConvertTo-Json -Depth 10 | Set-Content -Path $env:OPENCODE_CONFIG -Encoding UTF8 -NoNewline"
if errorlevel 1 goto :nocfg

echo Connecting opencode to LM Studio model: %LMSTUDIO_MODEL%
call opencode --model "lmstudio/%LMSTUDIO_MODEL%"
popd
del /q "%OPENCODE_CONFIG%" >nul 2>nul
goto :end

:nomodel
popd
echo ERROR: No model is loaded at %LMSTUDIO_URL%.
echo Run ..\Install-lmstudio.cmd first, then make sure a model is loaded:
echo     lms load %LMSTUDIO_MODEL%
pause
goto :end

:nocfg
popd
echo ERROR: Could not write the temp opencode config at %OPENCODE_CONFIG%.
pause

:end
endlocal
