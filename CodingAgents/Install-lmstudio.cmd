@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Install LM Studio  --  turn-key, unattended, idempotent
REM  ------------------------------------------------------------
REM  Brings up a LAN- or local-reachable LM Studio OpenAI-
REM  compatible server on port 1234. Every step is researched and
REM  safe to re-run.
REM
REM  Plan, top to bottom:
REM    1. If an OpenAI-compatible server is already reachable at
REM       LMSTUDIO_URL or http://127.0.0.1:1234, exit success.
REM    2. Install the LM Studio desktop app via winget
REM       (ElementLabs.LMStudio - confirmed correct id 2026).
REM    3. Bootstrap the 'lms' CLI onto PATH via 'lms bootstrap'.
REM       This is the official non-interactive PATH registration
REM       and works without launching the GUI (per-user install
REM       does NOT add PATH on its own - lmstudio-bug-tracker #1717).
REM    4. Start the headless server with 'lms server start
REM       --port 1234'. The command returns immediately; the
REM       daemon keeps running in the background.
REM    5. Probe /v1/models. The endpoint returns 200 with an
REM       empty data array even when no model is loaded, so it
REM       is the right liveness check. If a model is already
REM       cached/loaded, report it; otherwise hint the user how
REM       to fetch one with 'lms get'.
REM
REM  Notes:
REM    - Per-user install via NSIS /currentuser /S needs no UAC.
REM      We still let winget pick the scope it has registered
REM      (usually user) so re-runs do not create duplicate
REM      installs (lmstudio-bug-tracker #291).
REM    - LMSTUDIO_URL defaults to the LAN host used by the
REM      per-agent launchers; override by setting it before run.
REM    - AGENTS_INSTALL_ALL=1 suppresses the final pause so this
REM      slots cleanly into Install-All.cmd.
REM ============================================================

if not defined LMSTUDIO_URL set "LMSTUDIO_URL=http://192.168.12.174:1234"
set "LMSTUDIO_LOCAL_URL=http://127.0.0.1:1234"
set "LMSTUDIO_WINGET_ID=ElementLabs.LMStudio"
set "LMS_BIN=%USERPROFILE%\.lmstudio\bin"
set "LMS_EXE=%LMS_BIN%\lms.exe"
REM  The GUI app lives in %LOCALAPPDATA% on a per-user install.
REM  Detection MUST use this path, not LMS_EXE - the uninstaller
REM  preserves the .lmstudio config dir (including lms.exe),
REM  so lms.exe surviving says nothing about the app's presence.
set "LMSTUDIO_APP_EXE=%LOCALAPPDATA%\Programs\LM Studio\LM Studio.exe"

echo ============================================================
echo  LM Studio turn-key install
echo ============================================================

REM ---- Step 1: is anything already reachable? ----------------
call :probe_server "%LMSTUDIO_URL%"
if "%LMSTUDIO_REACHABLE%"=="1" (
    echo.
    echo LM Studio server already reachable at %LMSTUDIO_URL%.
    if defined LMSTUDIO_MODEL (
        echo Model loaded: %LMSTUDIO_MODEL%
    ) else (
        echo No model is loaded yet - run 'lms load ^<model^>' to enable chat.
    )
    goto :success
)

if /i not "%LMSTUDIO_URL%"=="%LMSTUDIO_LOCAL_URL%" (
    call :probe_server "%LMSTUDIO_LOCAL_URL%"
    if "!LMSTUDIO_REACHABLE!"=="1" (
        echo.
        echo LM Studio server already reachable at %LMSTUDIO_LOCAL_URL%.
        if defined LMSTUDIO_MODEL (
            echo Model loaded: !LMSTUDIO_MODEL!
        ) else (
            echo No model is loaded yet - run 'lms load ^<model^>' to enable chat.
        )
        set "LMSTUDIO_URL=%LMSTUDIO_LOCAL_URL%"
        goto :success
    )
)

echo.
echo No LM Studio server reachable yet - installing and starting one locally.

REM ---- Step 2: install the desktop app ------------------------
call :ensure_lmstudio_app
if errorlevel 1 goto :failed

REM ---- Step 3: bootstrap the lms CLI --------------------------
call :ensure_lms_cli
if errorlevel 1 goto :failed

REM ---- Step 4: start the local server -------------------------
echo.
echo Starting the LM Studio local server on port 1234...
call lms server start --port 1234
if errorlevel 1 (
    echo WARNING: 'lms server start' returned non-zero - probing anyway.
)

REM ---- Step 5: verify --------------------------------------
call :wait_for_server "%LMSTUDIO_LOCAL_URL%" 10
if "%LMSTUDIO_REACHABLE%"=="1" (
    set "LMSTUDIO_URL=%LMSTUDIO_LOCAL_URL%"
    echo.
    echo LM Studio server is up at %LMSTUDIO_LOCAL_URL%.
    if defined LMSTUDIO_MODEL (
        echo Model loaded: %LMSTUDIO_MODEL%
        goto :success
    )
    echo No model is loaded yet. Models on disk:
    call lms ls
    echo.
    echo Pick one and load it with for example:
    echo     lms get qwen3-4b@q4_k_m
    echo     lms load qwen3-4b --gpu max --ttl 3600
    echo Then re-run this script to verify the OpenAI-compatible API.
    goto :success
)

echo.
echo ERROR: server did not come up within 10s of 'lms server start'.
echo Try launching the LM Studio app once, then re-run this script.
goto :failed


:success
echo.
echo ============================================================
echo  Done. LM Studio reachable at %LMSTUDIO_URL%
echo  Use the per-agent launchers, e.g.:
echo      CodingAgents\Claude\Claude--settings-lmstudio.cmd
echo      CodingAgents\Codex\Codex--settings-lmstudio.cmd
echo.
echo  NOTE: this script may have started a headless LM Studio
echo  service. While it is running, clicking the LM Studio
echo  desktop icon does nothing (the headless processes hold
echo  the Electron single-instance lock). To use the GUI, run:
echo      lms server stop
echo      taskkill /F /IM "LM Studio.exe"
echo  then click the desktop icon again.
echo ============================================================
goto :end


REM ============================================================
REM  Helper: probe an OpenAI-compatible /v1/models endpoint.
REM  Sets:
REM    LMSTUDIO_REACHABLE = "1" if the endpoint responded 200,
REM                        else "0"
REM    LMSTUDIO_MODEL     = first model id if any, else empty.
REM  Arg 1: base URL, no trailing slash.
REM ============================================================
:probe_server
set "LMSTUDIO_REACHABLE=0"
set "LMSTUDIO_MODEL="
set "PROBE_RESULT="
echo.
echo Probing %~1/v1/models ...
for /f "delims=" %%i in ('powershell -NoProfile -Command "try { $r = Invoke-RestMethod '%~1/v1/models' -TimeoutSec 3 -ErrorAction Stop; if ($r.data.Count -gt 0) { 'OK:' + $r.data[0].id } else { 'OK:' } } catch { 'DOWN' }"') do set "PROBE_RESULT=%%i"
if /i "%PROBE_RESULT:~0,3%"=="OK:" (
    set "LMSTUDIO_REACHABLE=1"
    set "LMSTUDIO_MODEL=%PROBE_RESULT:~3%"
)
exit /b 0

REM ============================================================
REM  Helper: poll the probe until it succeeds or N seconds pass.
REM  Arg 1: base URL.  Arg 2: total seconds to wait.
REM ============================================================
:wait_for_server
set /a WAIT_LEFT=%~2
:wait_loop
call :probe_server "%~1"
if "%LMSTUDIO_REACHABLE%"=="1" exit /b 0
if %WAIT_LEFT% LEQ 0 exit /b 1
powershell -NoProfile -Command "Start-Sleep -Seconds 1" >nul 2>nul
set /a WAIT_LEFT-=1
goto :wait_loop

REM ============================================================
REM  Helper: install LM Studio desktop app idempotently.
REM ============================================================
:ensure_lmstudio_app
if exist "%LMSTUDIO_APP_EXE%" (
    echo.
    echo LM Studio app already installed at "%LMSTUDIO_APP_EXE%".
    exit /b 0
)
call :ensure_winget
if errorlevel 1 exit /b 1
echo.
echo Installing LM Studio via winget (%LMSTUDIO_WINGET_ID%)...
echo (UAC may prompt if winget chose a per-machine scope.)
winget install --id %LMSTUDIO_WINGET_ID% --exact --silent --accept-package-agreements --accept-source-agreements --disable-interactivity
set "WINGET_RC=%errorlevel%"
REM  winget exit code 0x8A15002B == "no applicable update" (already installed) - treat as success.
if "%WINGET_RC%"=="0" goto :app_installed_check
if "%WINGET_RC%"=="-1978335189" goto :app_installed_check
echo ERROR: winget reported rc=%WINGET_RC% while installing %LMSTUDIO_WINGET_ID%.
exit /b 1
:app_installed_check
if exist "%LMSTUDIO_APP_EXE%" exit /b 0
REM  Some scope choices put the per-user install under a slightly
REM  different folder. Do a best-effort search before giving up.
for /f "delims=" %%p in ('dir /b /s "%LOCALAPPDATA%\Programs\LM Studio.exe" 2^>nul') do (
    set "LMSTUDIO_APP_EXE=%%p"
    exit /b 0
)
echo ERROR: winget reported success but "%LMSTUDIO_APP_EXE%" is missing.
exit /b 1

REM ============================================================
REM  Helper: make the 'lms' CLI usable in this shell.
REM  Strategy:
REM    1. If already on PATH, done.
REM    2. Else add %USERPROFILE%\.lmstudio\bin to this session's
REM       PATH so we can call it immediately.
REM    3. Run 'lms bootstrap' so future shells inherit it from
REM       the user PATH (HKCU). This is the official LM Studio
REM       way and needs no admin (lmstudio.ai/docs/cli).
REM ============================================================
:ensure_lms_cli
where lms >nul 2>nul && goto :lms_bootstrap_if_needed
if not exist "%LMS_EXE%" (
    echo ERROR: 'lms.exe' not found at %LMS_EXE%.
    echo The installer may have placed it elsewhere - try launching
    echo the LM Studio app once, then re-run this script.
    exit /b 1
)
set "PATH=%LMS_BIN%;%PATH%"
where lms >nul 2>nul
if errorlevel 1 (
    echo ERROR: failed to add %LMS_BIN% to PATH for this session.
    exit /b 1
)
:lms_bootstrap_if_needed
echo.
echo Registering 'lms' on the user PATH (lms bootstrap)...
call lms bootstrap >nul 2>nul
exit /b 0

REM ============================================================
REM  Helper: ensure winget is available.
REM ============================================================
:ensure_winget
where winget >nul 2>nul && exit /b 0
echo ERROR: 'winget' (Windows Package Manager) was not found.
echo Install "App Installer" from the Microsoft Store, then
echo re-run this script:  https://aka.ms/getwinget
exit /b 1


:failed
echo.
echo ============================================================
echo  ERROR: LM Studio setup did not complete - see output above.
echo ============================================================
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
exit /b 1

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
exit /b 0
