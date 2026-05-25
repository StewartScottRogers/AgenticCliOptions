@echo off
setlocal

REM ============================================================
REM  Uninstall LM Studio  --  app-only, configuration preserved
REM  ------------------------------------------------------------
REM  Symmetric counterpart to Install-lmstudio.cmd. This script:
REM    - Detects the local server and asks you to stop it.
REM    - Stops the headless service via 'lms server stop' if the
REM      'lms' CLI is available.
REM    - Uninstalls the LM Studio app via winget.
REM
REM  Configuration and downloaded models are NEVER touched:
REM    - %USERPROFILE%\.lmstudio          (config, presets, 'lms' CLI)
REM    - %USERPROFILE%\.cache\lm-studio   (model cache, if present)
REM    - %APPDATA%\LMStudio               (app settings)
REM  Remove those folders by hand only if you really want to wipe
REM  saved sessions, presets, and downloaded weights.
REM ============================================================

if not defined LMSTUDIO_URL set "LMSTUDIO_URL=http://192.168.12.174:1234"
set "LMSTUDIO_LOCAL_URL=http://127.0.0.1:1234"
set "LMSTUDIO_WINGET_ID=ElementLabs.LMStudio"

echo.
echo Checking for a running LM Studio server...
call :probe_server "%LMSTUDIO_URL%"
if not defined LMSTUDIO_MODEL call :probe_server "%LMSTUDIO_LOCAL_URL%"

if defined LMSTUDIO_MODEL (
    echo.
    echo LM Studio server detected. Model loaded: %LMSTUDIO_MODEL%
    where lms >nul 2>nul || if exist "%USERPROFILE%\.lmstudio\bin\lms.exe" set "PATH=%USERPROFILE%\.lmstudio\bin;%PATH%"
    where lms >nul 2>nul && (
        echo Stopping the local server via 'lms server stop'...
        call lms server stop
    )
    echo If the server is still running, quit the LM Studio app
    echo manually before continuing.
) else (
    echo No LM Studio server reachable - nothing to stop.
)

echo.
echo Uninstalling the LM Studio app via winget (%LMSTUDIO_WINGET_ID%)...
echo (Your config and downloaded models will be preserved.)
where winget >nul 2>nul
if errorlevel 1 (
    echo WARNING: 'winget' not found - skipping app uninstall.
    echo Remove LM Studio via Settings ^> Apps if you want it gone.
    goto :end
)
winget uninstall --id %LMSTUDIO_WINGET_ID% --exact --silent --disable-interactivity
if errorlevel 1 (
    echo NOTE: winget reported a non-zero exit. The app may already
    echo have been uninstalled, or was installed outside winget.
)

echo.
echo Done. LM Studio app removed; configuration left intact at:
echo   %USERPROFILE%\.lmstudio
echo   %APPDATA%\LMStudio
goto :end


REM ============================================================
REM  Helper: probe an OpenAI-compatible /v1/models endpoint.
REM  Sets LMSTUDIO_MODEL to the first model id, or clears it.
REM ============================================================
:probe_server
set "LMSTUDIO_MODEL="
for /f "delims=" %%i in ('powershell -NoProfile -Command "try { (Invoke-RestMethod '%~1/v1/models' -TimeoutSec 3).data[0].id } catch { '' }"') do set "LMSTUDIO_MODEL=%%i"
exit /b 0


:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
