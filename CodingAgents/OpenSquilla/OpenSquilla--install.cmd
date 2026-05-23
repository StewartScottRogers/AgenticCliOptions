@echo off
setlocal

REM ============================================================
REM  Install / update OpenSquilla  --  turn-key installer
REM  ------------------------------------------------------------
REM  OpenSquilla is a token-efficient, microkernel AI agent
REM  (Web UI + CLI + chat) that ships with a built-in MCP client.
REM  See https://opensquilla.ai/ and the source repo at
REM  https://github.com/opensquilla/opensquilla
REM
REM  Checks for and installs EVERY dependency automatically:
REM    - uv (Astral's Python tool installer) - via winget if missing
REM    - CPython 3.12 - uv downloads it automatically
REM    - OpenSquilla itself - installed/updated via uv tool from
REM      the latest published .whl on GitHub Releases
REM  Re-running this script picks up the latest release.
REM
REM  OpenSquilla is NOT on PyPI and the upstream installer only
REM  accepts published wheels (not git URLs). We use the GitHub
REM  API to discover the latest .whl URL on every run, then
REM  install it with uv.
REM ============================================================

call :ensure_uv
if errorlevel 1 goto :failed

echo.
echo Querying GitHub for the latest OpenSquilla release...
for /f "delims=" %%i in ('powershell -NoProfile -Command "$ErrorActionPreference='Stop'; (Invoke-RestMethod 'https://api.github.com/repos/opensquilla/opensquilla/releases/latest').assets | Where-Object { $_.name -like '*.whl' } | Select-Object -First 1 -ExpandProperty browser_download_url"') do set "OS_WHL=%%i"
if not defined OS_WHL goto :nourl
echo Latest wheel: %OS_WHL%

set "OS_SPEC=opensquilla[recommended] @ %OS_WHL%"

echo.
echo Installing / updating OpenSquilla...
echo     uv tool install --python 3.12 --upgrade "%OS_SPEC%"
echo.
call uv tool install --python 3.12 --upgrade "%OS_SPEC%"
if errorlevel 1 goto :failed

call uv tool update-shell >nul 2>nul
call :refresh_path

echo.
echo OpenSquilla installed. Reported version:
call opensquilla --version
echo.
echo Done. Launch it with OpenSquilla--openrouter.cmd or
echo 'opensquilla chat' for the interactive TUI.
echo First run: 'opensquilla onboard' walks you through provider
echo + workspace setup.
goto :end


REM ============================================================
REM  Helper routines
REM ============================================================

:ensure_uv
where uv >nul 2>nul && exit /b 0
echo.
echo uv (the Python tool installer) was not found - installing it...
call :ensure_winget
if errorlevel 1 exit /b 1
winget install --id astral-sh.uv --exact --silent --accept-package-agreements --accept-source-agreements
call :refresh_path
where uv >nul 2>nul && exit /b 0
echo ERROR: uv was installed but is still not on PATH.
echo Close this window, open a new terminal, and re-run this script.
exit /b 1

:ensure_winget
where winget >nul 2>nul && exit /b 0
echo ERROR: 'winget' (Windows Package Manager) was not found.
echo Install "App Installer" from the Microsoft Store, then
echo re-run this script:  https://aka.ms/getwinget
exit /b 1

:refresh_path
call :prepend_path "%LOCALAPPDATA%\Microsoft\WinGet\Links"
call :prepend_path "%USERPROFILE%\.local\bin"
exit /b 0

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0


:nourl
echo.
echo ERROR: Could not find a .whl asset on the latest GitHub
echo release of opensquilla/opensquilla. Check
echo https://github.com/opensquilla/opensquilla/releases
echo and pass an explicit wheel URL by editing this script.
goto :end

:failed
echo.
echo ERROR: Installation failed - see the output above.
echo If a 'DLL load failed' error appears at runtime, install
echo the Visual C++ Redistributable (vc_redist.x64.exe).

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
