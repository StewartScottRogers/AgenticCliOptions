@echo off
setlocal

REM ============================================================
REM  Uninstall OpenClaw  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the CLI itself (the npm global package).
REM  Leaves Node.js, npm, and any ~/.openclaw config directory
REM  alone, so reinstalling later restores everything as it was.
REM
REM  If you also want to delete saved sessions, API keys and
REM  settings, remove this folder by hand AFTER running this:
REM      %USERPROFILE%\.openclaw
REM ============================================================

where npm >nul 2>nul
if errorlevel 1 (
    echo npm was not found - nothing to uninstall via npm.
    goto :end
)

echo.
echo Uninstalling the OpenClaw CLI globally...
echo     npm uninstall -g openclaw
echo.
call npm uninstall -g openclaw
if errorlevel 1 goto :failed

echo.
where openclaw >nul 2>nul
if errorlevel 1 (
    echo OpenClaw CLI removed.
) else (
    echo NOTE: 'openclaw' is still resolvable on PATH. It may be
    echo a stale shim or a second copy installed elsewhere. Run
    echo 'where openclaw' to investigate.
)
echo.
echo Done. Your ~/.openclaw config directory was NOT touched -
echo delete it manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If npm reports the package is not installed, that just means
echo OpenClaw was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
