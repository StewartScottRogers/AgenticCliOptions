@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Install LM Studio  --  turn-key installer + server bring-up
REM  ------------------------------------------------------------
REM  Dependencies installed/started by this script:
REM    - LM Studio desktop app (winget id ElementLabs.LMStudio)
REM    - The 'lms' CLI it ships with (under %USERPROFILE%\.lmstudio\bin)
REM    - The LM Studio local OpenAI-compatible server on port 1234
REM
REM  Detection order for an already-running server:
REM    1) LMSTUDIO_URL (default http://192.168.12.174:1234 - LAN host)
REM    2) http://127.0.0.1:1234 (local fallback)
REM  If neither is reachable, this script installs LM Studio (if
REM  missing), bootstraps the 'lms' CLI, then starts the local
REM  server with 'lms server start' and re-checks.
REM
REM  Re-running this script is safe; every step is idempotent.
REM  A UAC elevation prompt may appear while winget installs.
REM ============================================================

if not defined LMSTUDIO_URL set "LMSTUDIO_URL=http://192.168.12.174:1234"
set "LMSTUDIO_LOCAL_URL=http://127.0.0.1:1234"
set "LMSTUDIO_WINGET_ID=ElementLabs.LMStudio"

call :probe_server "%LMSTUDIO_URL%"
if defined LMSTUDIO_MODEL (
    echo.
    echo LM Studio server detected at %LMSTUDIO_URL%.
    echo Model loaded: %LMSTUDIO_MODEL%
    goto :success
)

call :probe_server "%LMSTUDIO_LOCAL_URL%"
if defined LMSTUDIO_MODEL (
    echo.
    echo LM Studio server detected at %LMSTUDIO_LOCAL_URL%.
    echo Model loaded: %LMSTUDIO_MODEL%
    set "LMSTUDIO_URL=%LMSTUDIO_LOCAL_URL%"
    goto :success
)

echo.
echo No LM Studio server reachable yet - bringing one up locally.

call :ensure_lmstudio_app
if errorlevel 1 goto :failed

call :ensure_lms_cli
if errorlevel 1 goto :failed

echo.
echo Starting the LM Studio local server on port 1234...
call lms server start
if errorlevel 1 (
    echo WARNING: 'lms server start' returned a non-zero exit code.
    echo Will probe the server anyway in case it is already up.
)

REM  Give the service a moment to bind the port.
call :sleep 2
call :probe_server "%LMSTUDIO_LOCAL_URL%"
if not defined LMSTUDIO_MODEL (
    call :sleep 3
    call :probe_server "%LMSTUDIO_LOCAL_URL%"
)

if defined LMSTUDIO_MODEL (
    echo.
    echo LM Studio server is now up at %LMSTUDIO_LOCAL_URL%.
    echo Model loaded: %LMSTUDIO_MODEL%
    set "LMSTUDIO_URL=%LMSTUDIO_LOCAL_URL%"
    goto :success
)

echo.
echo Server started but no model is loaded yet.
echo Listing models available on disk:
call lms ls
echo.
echo Load a chat model (one-time, ~GB download) with for example:
echo     lms get qwen2.5-7b-instruct
echo     lms load qwen2.5-7b-instruct
echo Then re-run this script to verify the OpenAI-compatible API.
goto :end

:success
echo.
echo Done. LM Studio is installed and the local server is reachable.
echo Use it from the per-agent launchers, e.g.:
echo     CodingAgents\Claude\Claude--settings-lmstudio.cmd
echo     CodingAgents\Codex\Codex--settings-lmstudio.cmd
goto :end


REM ============================================================
REM  Helper: probe an OpenAI-compatible /v1/models endpoint.
REM  Sets LMSTUDIO_MODEL to the first model id, or clears it.
REM  Arg 1: base URL (no trailing slash).
REM ============================================================
:probe_server
set "LMSTUDIO_MODEL="
echo.
echo Checking for LM Studio server at %~1 ...
for /f "delims=" %%i in ('powershell -NoProfile -Command "try { (Invoke-RestMethod '%~1/v1/models' -TimeoutSec 3).data[0].id } catch { '' }"') do set "LMSTUDIO_MODEL=%%i"
exit /b 0

REM ============================================================
REM  Helper: ensure the LM Studio desktop app is installed.
REM ============================================================
:ensure_lmstudio_app
if exist "%USERPROFILE%\.lmstudio\bin\lms.exe" exit /b 0
call :ensure_winget
if errorlevel 1 exit /b 1
echo.
echo Installing LM Studio via winget (%LMSTUDIO_WINGET_ID%)...
winget install --id %LMSTUDIO_WINGET_ID% --exact --silent --accept-package-agreements --accept-source-agreements
if errorlevel 1 (
    echo ERROR: winget failed to install %LMSTUDIO_WINGET_ID%.
    exit /b 1
)
exit /b 0

REM ============================================================
REM  Helper: make the 'lms' CLI usable in this shell. LM Studio
REM  ships it inside %USERPROFILE%\.lmstudio\bin, but that folder
REM  is not on PATH until LM Studio has been launched at least
REM  once. We add it manually so this script stays unattended.
REM ============================================================
:ensure_lms_cli
where lms >nul 2>nul && exit /b 0
if exist "%USERPROFILE%\.lmstudio\bin\lms.exe" (
    set "PATH=%USERPROFILE%\.lmstudio\bin;%PATH%"
    where lms >nul 2>nul && exit /b 0
)
echo ERROR: 'lms' CLI not found under %USERPROFILE%\.lmstudio\bin.
echo Launch the LM Studio app once so it provisions the CLI, then
echo re-run this script.
exit /b 1

REM ============================================================
REM  Helper: ensure winget is available.
REM ============================================================
:ensure_winget
where winget >nul 2>nul && exit /b 0
echo ERROR: 'winget' (Windows Package Manager) was not found.
echo Install "App Installer" from the Microsoft Store, then
echo re-run this script:  https://aka.ms/getwinget
exit /b 1

REM ============================================================
REM  Helper: short sleep (seconds) without needing 'timeout' to
REM  be interactive-friendly.
REM ============================================================
:sleep
powershell -NoProfile -Command "Start-Sleep -Seconds %~1" >nul 2>nul
exit /b 0


:failed
echo.
echo ERROR: LM Studio setup failed - see the output above.

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
