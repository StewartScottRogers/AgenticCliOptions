@echo off
setlocal

REM ============================================================
REM  Uninstall Windows Terminal  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes the winget/Store package 'Microsoft.WindowsTerminal'.
REM  Any running window is stopped first.
REM
REM  CAUTION: Windows Terminal is the default terminal host on many
REM  Windows 11 setups. Removing it can revert your default console
REM  to the legacy conhost. Your settings.json (under
REM  %LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\)
REM  is left in place by the package removal.
REM ============================================================

taskkill /F /IM WindowsTerminal.exe >nul 2>nul

where winget >nul 2>nul
if errorlevel 1 (
    echo winget was not found. Remove Windows Terminal from
    echo Settings ^> Apps ^> Installed apps instead.
    goto :end
)

winget list -e --id Microsoft.WindowsTerminal >nul 2>nul
if errorlevel 1 (
    echo Windows Terminal [Microsoft.WindowsTerminal] is not tracked by
    echo winget on this system. If it is a provisioned Store app, remove
    echo it from Settings ^> Apps. Nothing to do here.
    goto :verify
)

echo.
echo Removing Windows Terminal via winget...
echo.
winget uninstall -e --id Microsoft.WindowsTerminal
if errorlevel 1 (
    echo.
    echo ERROR: winget uninstall reported a problem - see above. A
    echo provisioned Store copy may need removal via Settings ^> Apps.
    goto :end
)

:verify
echo.
where wt >nul 2>nul
if errorlevel 1 (
    echo Windows Terminal removed.
) else (
    echo NOTE: 'wt' still resolves - a provisioned Store copy may remain.
    echo Remove it from Settings ^> Apps if you want it fully gone.
)
echo.
echo Done. Your settings.json was NOT deleted by the package removal.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
