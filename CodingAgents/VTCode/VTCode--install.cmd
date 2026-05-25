@echo off
setlocal

REM ============================================================
REM  Install / update VT Code  --  turn-key installer
REM  ------------------------------------------------------------
REM  VT Code is an open-source coding agent with code-
REM  understanding tooling and shell safety. See
REM  https://github.com/vinhnx/vtcode for source.
REM
REM  Upstream marks Windows builds as "best-effort, may lag
REM  behind macOS/Linux" - in practice the most recent few
REM  releases often ship NO Windows asset at all (e.g. 0.108.x
REM  at the time of writing). The upstream PowerShell installer
REM  is also unreliable in non-TTY contexts: its HEAD-request
REM  probe (Invoke-WebRequest -Method Head) silently fails when
REM  invoked through 'irm | iex' from cmd, even on releases
REM  that do ship a Windows zip.
REM
REM  So we bypass the upstream installer entirely:
REM    1. Query the GitHub API for recent releases.
REM    2. Walk them newest-first; pick the first whose ASSETS
REM       list includes vtcode-<tag>-x86_64-pc-windows-msvc.zip.
REM    3. Download that zip directly to %TEMP% and extract to
REM       %USERPROFILE%\.local\bin (matching upstream's layout).
REM    4. Add %USERPROFILE%\.local\bin to the User PATH if it
REM       isn't already there. Other agents (Mistral, Trae,
REM       Junie) already use that dir, so this is usually a
REM       no-op.
REM
REM  Re-running this script reinstalls the same release if it
REM  is still the most recent Windows build, otherwise upgrades.
REM ============================================================

set "INSTALL_DIR=%USERPROFILE%\.local\bin"
set "API_URL=https://api.github.com/repos/vinhnx/vtcode/releases?per_page=20"

if not exist "%INSTALL_DIR%\" mkdir "%INSTALL_DIR%"

echo.
echo Querying GitHub for the latest VT Code Windows release...
set "VT_URL="
for /f "delims=" %%i in ('powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $rels=Invoke-RestMethod -Uri '%API_URL%' -TimeoutSec 30; foreach ($r in $rels) { $a = $r.assets | Where-Object { $_.name -like 'vtcode-*-x86_64-pc-windows-msvc.zip' } | Select-Object -First 1; if ($a) { Write-Output $a.browser_download_url; break } }"') do set "VT_URL=%%i"

if not defined VT_URL goto :nowin
echo Found: %VT_URL%

set "VT_ZIP=%TEMP%\vtcode-install.zip"
echo Downloading...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; $wc=New-Object Net.WebClient; $wc.DownloadFile('%VT_URL%', '%VT_ZIP%')"
if errorlevel 1 goto :failed

echo Extracting to %INSTALL_DIR% ...
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; Expand-Archive -Path '%VT_ZIP%' -DestinationPath '%INSTALL_DIR%' -Force"
set "RC=%ERRORLEVEL%"
del /q "%VT_ZIP%" >nul 2>nul
if not "%RC%"=="0" goto :failed

REM  Append %USERPROFILE%\.local\bin to the User PATH if missing.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p=[Environment]::GetEnvironmentVariable('Path','User'); $needle='%INSTALL_DIR%'; if (($p -split ';') -notcontains $needle) { [Environment]::SetEnvironmentVariable('Path', ($p.TrimEnd(';') + ';' + $needle), 'User'); Write-Host 'Added %INSTALL_DIR% to User PATH.' } else { Write-Host 'User PATH already contains %INSTALL_DIR%.' }"

call :prepend_path "%INSTALL_DIR%"

echo.
where vtcode >nul 2>nul
if errorlevel 1 (
    echo NOTE: 'vtcode' is not yet on PATH for this shell. Open a
    echo new terminal and run 'vtcode --version' to verify.
) else (
    echo VT Code installed. Reported version:
    call vtcode --version
)
echo.
echo Done. Launch it with VTCode--openrouter.cmd, or run
echo 'vtcode chat' directly.

REM  Fan plugin install hooks out to VTCode.
call "%~dp0..\Plugins\_apply-plugins.cmd" VTCode install
goto :end


REM ============================================================
REM  Helper routines
REM ============================================================

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0


:nowin
echo.
echo ERROR: No recent VT Code release (last 20) ships a Windows
echo asset. Upstream flags Windows builds as best-effort and
echo sometimes skips releases. Options:
echo   1. Wait for the next release with a Windows zip
echo   2. Install via cargo (needs Rust toolchain):
echo        cargo install vtcode
goto :end

:failed
echo.
echo ERROR: Installation failed - see the output above.

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
