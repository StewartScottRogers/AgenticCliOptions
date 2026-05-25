@echo off
setlocal

REM ============================================================
REM  Uninstall Codebuff  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the CLI itself (the npm global package).
REM  Leaves Node.js, npm, Git, and any ~/.codebuff config dir
REM  alone, so reinstalling later restores everything as it was.
REM
REM  If you also want to delete saved sessions, API keys and
REM  settings, remove this folder by hand AFTER running this:
REM      %USERPROFILE%\.codebuff
REM ============================================================

REM  Tear down plugin entries BEFORE removing the CLI.
call "%~dp0..\Plugins\_apply-plugins.cmd" Codebuff uninstall

where npm >nul 2>nul
if errorlevel 1 (
    echo npm was not found - nothing to uninstall via npm.
    goto :end
)

echo.
echo Uninstalling the Codebuff CLI globally...
echo     npm uninstall -g codebuff
echo.
call npm uninstall -g codebuff
if errorlevel 1 goto :failed

echo.
where codebuff >nul 2>nul
if errorlevel 1 (
    echo Codebuff CLI removed.
) else (
    echo NOTE: 'codebuff' is still resolvable on PATH. It may be
    echo a stale shim or a second copy installed elsewhere. Run
    echo 'where codebuff' to investigate.
)
echo.
echo Done. Your ~/.codebuff config directory was NOT touched -
echo delete it manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If npm reports the package is not installed, that just means
echo Codebuff was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
