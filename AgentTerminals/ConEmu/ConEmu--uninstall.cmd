@echo off
setlocal

REM ============================================================
REM  Uninstall ConEmu  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes the winget package 'Maximus5.ConEmu'. Any running
REM  ConEmu window is stopped first so files aren't locked.
REM
REM  Your ConEmu settings (ConEmu.xml, kept under %APPDATA%\ConEmu\
REM  or next to the exe) are LEFT IN PLACE where winget doesn't own
REM  them. Delete them by hand for a fully clean slate.
REM ============================================================

taskkill /F /IM ConEmu64.exe >nul 2>nul
taskkill /F /IM ConEmu.exe   >nul 2>nul
taskkill /F /IM ConEmuC64.exe >nul 2>nul

where winget >nul 2>nul
if errorlevel 1 (
    echo winget was not found. If ConEmu was installed some other way,
    echo remove it via Settings ^> Apps.
    goto :end
)

winget list -e --id Maximus5.ConEmu >nul 2>nul
if errorlevel 1 (
    echo ConEmu [Maximus5.ConEmu] is not installed via winget.
    echo Nothing to remove.
    goto :verify
)

echo.
echo Removing ConEmu via winget...
echo.
winget uninstall -e --id Maximus5.ConEmu
if errorlevel 1 (
    echo.
    echo ERROR: winget uninstall reported a problem - see above. If a
    echo ConEmu window is still open, close it and re-run this script.
    goto :end
)

:verify
echo.
if exist "%ProgramFiles%\ConEmu\ConEmu64.exe" (
    echo NOTE: ConEmu64.exe still present at %ProgramFiles%\ConEmu\ -
    echo it may be a second copy installed outside winget.
) else (
    echo ConEmu removed.
)
echo.
echo Done. Your ConEmu.xml settings were NOT touched - delete them
echo manually (%%APPDATA%%\ConEmu\ or next to the old exe) for a clean slate.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
