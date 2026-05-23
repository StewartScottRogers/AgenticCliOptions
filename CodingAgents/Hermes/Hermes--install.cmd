@echo off
setlocal

REM ============================================================
REM  Install / update Hermes Agent (Nous Research)  --  turn-key
REM  ------------------------------------------------------------
REM  Hermes Agent is a terminal coding agent from Nous Research.
REM  See https://hermes-agent.nousresearch.com/ for docs.
REM
REM  Install method (native Windows, no admin needed):
REM    PowerShell one-liner that fetches install.ps1 from the
REM    official GitHub repo. The installer provisions Python (via
REM    uv), Node, PortableGit, ripgrep and ffmpeg under
REM    %LOCALAPPDATA%\hermes and adds 'hermes' to the User PATH.
REM
REM  Native Windows support is an EARLY BETA - expect rough edges.
REM  See https://hermes-agent.nousresearch.com/docs/user-guide/windows-native
REM
REM  Re-running this script reinstalls / updates Hermes via the
REM  same installer (idempotent).
REM ============================================================

set "INSTALL_URL=https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.ps1"

echo.
echo Installing / updating Hermes Agent via the official PowerShell
echo installer...
echo     iex (irm %INSTALL_URL%)
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; iex (irm '%INSTALL_URL%')"
if errorlevel 1 goto :failed

REM  The installer adds %LOCALAPPDATA%\hermes\bin to the User PATH,
REM  but this already-running shell still has the old PATH. Prepend
REM  it now so 'hermes' resolves immediately.
call :prepend_path "%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts"

echo.
where hermes >nul 2>nul
if errorlevel 1 (
    echo NOTE: 'hermes' is not yet on PATH for this shell. Open a
    echo new terminal and run 'hermes --version' to verify.
) else (
    echo Hermes Agent installed. Reported version:
    call hermes --version
)
echo.
echo Done. Launch it with Hermes--openrouter.cmd, or run
echo 'hermes' directly. First run will prompt you to configure
echo a provider - the OpenRouter launcher does that for you.
goto :end


REM ============================================================
REM  Helper routines
REM ============================================================

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0


:failed
echo.
echo ERROR: Installation failed - see the output above.
echo Native Windows is an early beta. If the installer keeps
echo failing, see the upstream guide:
echo   https://hermes-agent.nousresearch.com/docs/user-guide/windows-native

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
