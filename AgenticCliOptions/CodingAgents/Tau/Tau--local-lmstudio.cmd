@echo off
setlocal

REM ============================================================
REM  Tau via LM Studio  (local OpenAI-compatible inference)
REM  ------------------------------------------------------------
REM  Tau has no built-in LM Studio provider, but its 'tau setup'
REM  subcommand registers ANY OpenAI-compatible endpoint into
REM  ~/.tau/catalog.toml. This launcher (re)registers a provider
REM  named 'lmstudio' pointed at the local server, then runs Tau
REM  against it. The upsert is idempotent, so re-running is safe.
REM
REM  Default model for this agent: qwen3-coder-30b
REM  Override with:
REM      set LMSTUDIO_MODEL=<other-id>
REM  Override the URL (defaults to the LAN host used by the
REM  Install-lmstudio.cmd script):
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

REM  LM Studio ignores the key but the OpenAI client requires one.
set "OPENAI_API_KEY=lmstudio"

REM  NOTE: for 'tau setup' the options MUST precede the 'setup'
REM  token - options placed after it are swallowed as positional
REM  args and Tau drops into its interactive TUI instead.
echo Registering Tau provider 'lmstudio' -> %LMSTUDIO_URL%/v1
call tau --provider lmstudio --base-url "%LMSTUDIO_URL%/v1" --api-key-env OPENAI_API_KEY --no-set-default setup

echo Connecting Tau to LM Studio model: %LMSTUDIO_MODEL%
call tau --provider lmstudio --model "%LMSTUDIO_MODEL%"
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
