@echo off
setlocal

REM ============================================================
REM  Update herdr  --  supported in-place upgrade
REM  ------------------------------------------------------------
REM  herdr ships its own updater: 'herdr update' fetches the newest
REM  build on the current channel (preview on Windows), installs it
REM  into a fresh versioned release dir, and repoints the 'current'
REM  junction. Older releases are pruned automatically (the last 3
REM  are retained).
REM
REM  If the update changes herdr's client/server protocol, herdr
REM  asks whether to stop the old background server so the new
REM  client can talk to a matching server. Answer as prompted; any
REM  running agents in existing panes are torn down when the old
REM  server stops, so detach or finish critical work first.
REM
REM  Falls back to re-running the official installer if the 'herdr
REM  update' subcommand is unavailable (older builds).
REM ============================================================

set "HERDR_DIR=%LOCALAPPDATA%\Programs\Herdr\bin"
set "HERDR_BIN=%HERDR_DIR%\herdr.exe"

where herdr >nul 2>nul
if errorlevel 1 (
    if exist "%HERDR_BIN%" (
        set "PATH=%HERDR_DIR%;%PATH%"
    ) else (
        echo herdr is not installed - nothing to update.
        echo Run Herdr--install.cmd first.
        goto :end
    )
)

echo.
echo Current version:
call herdr --version
echo.
echo Updating herdr via 'herdr update'...
echo.
call herdr update
if errorlevel 1 goto :fallback

echo.
echo Updated. New version:
call herdr --version
goto :end


:fallback
echo.
echo 'herdr update' was not available or failed - falling back to
echo the official installer (which upgrades in place)...
echo     irm https://herdr.dev/install.ps1 ^| iex
echo.
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; iex (irm 'https://herdr.dev/install.ps1')"
if errorlevel 1 (
    echo.
    echo ERROR: Update failed - see the output above.
    goto :end
)
call :prepend_path "%HERDR_DIR%"
echo.
echo Updated. New version:
call herdr --version
goto :end

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0

:end
echo.
if not defined AGENTS_UPDATE_ALL pause
endlocal
