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

REM  We delegate to a sibling .ps1 helper that downloads the upstream
REM  install.ps1, patches the single `npx playwright install chromium`
REM  call to first cd into a stub dir whose package.json declares
REM  `playwright`, then iex's it. That suppresses Playwright's
REM  misleading "without first installing your project's dependencies"
REM  warning box, which otherwise hides the real progress output. The
REM  patch is anchored on the exact upstream line -- if upstream
REM  reformats it, the helper warns and falls back to the unpatched
REM  install (still succeeds, warning reappears).
set "PATCH_SCRIPT=%~dp0_hermes-install-patched.ps1"

echo.
echo Installing / updating Hermes Agent via the official PowerShell
echo installer (with Playwright cwd patch)...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -File "%PATCH_SCRIPT%"
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
