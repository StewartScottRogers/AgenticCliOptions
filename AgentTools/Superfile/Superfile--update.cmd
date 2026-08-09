@echo off
setlocal

REM ============================================================
REM  Update superfile  --  in-place upgrade via winget
REM  ------------------------------------------------------------
REM  superfile has no built-in self-updater (unlike herdr's
REM  'herdr update'), so the supported upgrade path is winget:
REM      winget upgrade -e --id yorukot.superfile
REM
REM  Config, hotkeys and themes under %LOCALAPPDATA%\superfile are
REM  preserved across upgrades. If a new release adds config fields
REM  or hotkeys, run:
REM      spf --fix-config-file
REM      spf --fix-hotkeys
REM  to append the missing entries to your existing files.
REM ============================================================

where winget >nul 2>nul
if errorlevel 1 (
    echo ERROR: winget was not found - cannot update superfile.
    goto :end
)

call "%~dp0Superfile--is-installed.cmd" >nul 2>nul
if errorlevel 1 (
    echo superfile is not installed - nothing to update.
    echo Run Superfile--install.cmd first.
    goto :end
)

call :refresh_path

echo.
echo Current version:
call spf --version
echo.
echo Updating superfile via 'winget upgrade'...
echo.

winget upgrade -e --id yorukot.superfile --accept-source-agreements --accept-package-agreements
set "RC=%ERRORLEVEL%"
REM  winget exits non-zero when there is simply nothing to upgrade;
REM  that is not an error for our purposes.
if not "%RC%"=="0" (
    echo.
    echo No update applied - superfile is already current, or winget
    echo reported a non-fatal condition. See the output above.
)

call :refresh_path
echo.
echo Installed version:
call spf --version
goto :end


REM ============================================================
REM  Helper: rebuild this shell's PATH from the registry (machine
REM  then user) so a freshly-updated tool resolves immediately.
REM ============================================================
:refresh_path
for /f "skip=2 tokens=2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYSPATH=%%B"
for /f "skip=2 tokens=2,*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USRPATH=%%B"
set "PATH=%SYSPATH%;%USRPATH%"
exit /b 0

:end
echo.
if not defined AGENTS_UPDATE_ALL pause
endlocal
