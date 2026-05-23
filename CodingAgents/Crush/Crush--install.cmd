@echo off
setlocal

REM ============================================================
REM  Install / update Crush (Charmbracelet)  --  turn-key installer
REM  ------------------------------------------------------------
REM  Crush is Charmbracelet's terminal-native coding agent. It is
REM  a single Go binary with first-class winget support, which is
REM  the cleanest Windows install story of any agent in this repo.
REM  See https://github.com/charmbracelet/crush for source.
REM
REM  Install method: 'winget install charmbracelet.crush'.
REM  Re-running this script upgrades in place.
REM
REM  winget (Windows Package Manager) ships with Windows 11 and
REM  current Windows 10.
REM ============================================================

call :ensure_winget
if errorlevel 1 goto :failed

echo.
echo Installing / updating Crush via winget...
echo     winget install --id charmbracelet.crush
echo.
winget install --id charmbracelet.crush --exact --silent --accept-package-agreements --accept-source-agreements
set "RC=%ERRORLEVEL%"
REM  winget returns nonzero ALSO when the package is already
REM  current ("No applicable upgrade found" / "already installed"
REM  paths). Tolerate that by checking if the binary is present.
call :refresh_path
where crush >nul 2>nul
if errorlevel 1 (
    if not "%RC%"=="0" goto :failed
)

echo.
echo Crush installed. Reported version:
call crush --version
echo.
echo Done. Launch it with Crush--openrouter.cmd, or run 'crush'
echo directly. First run will prompt for provider/auth.
goto :end


REM ============================================================
REM  Helper routines
REM ============================================================

:ensure_winget
where winget >nul 2>nul && exit /b 0
echo ERROR: 'winget' (Windows Package Manager) was not found.
echo Install "App Installer" from the Microsoft Store, then
echo re-run this script:  https://aka.ms/getwinget
exit /b 1

:refresh_path
call :prepend_path "%LOCALAPPDATA%\Microsoft\WinGet\Links"
call :prepend_path "%LOCALAPPDATA%\Microsoft\WinGet\Packages\charmbracelet.crush_Microsoft.Winget.Source_8wekyb3d8bbwe"
exit /b 0

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0


:failed
echo.
echo ERROR: Installation failed - see the output above.
echo If winget reports it cannot find charmbracelet.crush, try
echo the alternate channel:
echo   scoop bucket add charm https://github.com/charmbracelet/scoop-bucket.git
echo   scoop install crush

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
