@echo off
setlocal

REM ============================================================
REM  Uninstall superfile
REM  ------------------------------------------------------------
REM  Removes the winget package 'yorukot.superfile' (and with it
REM  the %LOCALAPPDATA%\Microsoft\WinGet\Links\spf.exe shim).
REM
REM  NOT removed - delete by hand for a fully clean slate:
REM      %LOCALAPPDATA%\superfile\    config.toml, hotkeys.toml,
REM                                   superfile.log, theme\
REM  Keeping it means a later re-install picks up your existing
REM  config, hotkeys and themes unchanged.
REM ============================================================

where winget >nul 2>nul
if errorlevel 1 (
    echo ERROR: winget was not found - cannot uninstall superfile.
    goto :end
)

call "%~dp0Superfile--is-installed.cmd" >nul 2>nul
if errorlevel 1 (
    echo superfile is not installed - nothing to uninstall.
    goto :end
)

echo.
echo Uninstalling superfile via winget...
echo.

winget uninstall -e --id yorukot.superfile --disable-interactivity
if errorlevel 1 (
    echo.
    echo ERROR: Uninstall failed - see the output above.
    goto :end
)

echo.
echo superfile removed.
echo Config kept at: %LOCALAPPDATA%\superfile
echo Delete that folder by hand if you want a clean slate.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
