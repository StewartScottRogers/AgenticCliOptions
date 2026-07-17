@echo off
setlocal

REM ============================================================
REM  Update WezTerm  --  in-place upgrade via winget
REM  ------------------------------------------------------------
REM  WezTerm is installed from winget, so the supported upgrade is
REM  'winget upgrade'. If no newer version is available winget makes
REM  it a no-op. Close any open WezTerm windows first so the
REM  installer can replace files that are in use.
REM ============================================================

where winget >nul 2>nul
if errorlevel 1 (
    echo winget was not found - cannot update. Install "App Installer"
    echo from the Microsoft Store, or grab the latest build from
    echo https://wezterm.org/install/windows.html
    goto :end
)

call :is_present
if errorlevel 1 (
    echo WezTerm is not installed - nothing to update.
    echo Run WezTerm--install.cmd first.
    goto :end
)

echo.
echo Current version:
where wezterm >nul 2>nul && call wezterm -V
echo.
echo Updating WezTerm via winget...
echo.
winget upgrade -e --id wez.wezterm --accept-source-agreements --accept-package-agreements
REM  winget exits non-zero when there is simply nothing to upgrade;
REM  that is not an error for our purposes.

echo.
echo Now reporting:
where wezterm >nul 2>nul && call wezterm -V
goto :end

:is_present
winget list -e --id wez.wezterm >nul 2>nul
if not errorlevel 1 exit /b 0
where wezterm >nul 2>nul
exit /b %ERRORLEVEL%

:end
echo.
if not defined AGENTS_UPDATE_ALL pause
endlocal
