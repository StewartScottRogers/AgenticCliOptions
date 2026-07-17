@echo off
setlocal

REM ============================================================
REM  Uninstall Tabby  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes the winget package 'Eugeny.Tabby'. Any running Tabby
REM  window is stopped first so files aren't locked.
REM
REM  Your Tabby config (YAML) at %APPDATA%\tabby is LEFT IN PLACE.
REM  Delete that folder by hand for a fully clean slate.
REM ============================================================

taskkill /F /IM Tabby.exe >nul 2>nul

where winget >nul 2>nul
if errorlevel 1 (
    echo winget was not found. If Tabby was installed some other way,
    echo remove it via Settings ^> Apps, then delete %%APPDATA%%\tabby.
    goto :end
)

winget list -e --id Eugeny.Tabby >nul 2>nul
if errorlevel 1 (
    echo Tabby [Eugeny.Tabby] is not installed via winget.
    echo Nothing to remove.
    goto :verify
)

echo.
echo Removing Tabby via winget...
echo.
winget uninstall -e --id Eugeny.Tabby
if errorlevel 1 (
    echo.
    echo ERROR: winget uninstall reported a problem - see above. If a
    echo Tabby window is still open, close it and re-run this script.
    goto :end
)

:verify
echo.
if exist "%LOCALAPPDATA%\Programs\Tabby\Tabby.exe" (
    echo NOTE: Tabby.exe still present at %LOCALAPPDATA%\Programs\Tabby\ -
    echo it may be a second copy installed outside winget.
) else (
    echo Tabby removed.
)
echo.
echo Done. Your %%APPDATA%%\tabby config was NOT touched -
echo delete it manually if you want a fully clean slate.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
