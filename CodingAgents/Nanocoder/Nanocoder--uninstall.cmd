@echo off
setlocal

REM ============================================================
REM  Uninstall Nanocoder  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the CLI itself (the npm global package).
REM  Leaves Node.js, npm, and any ~/.nanocoder config / project
REM  agents.config.json files alone, so reinstalling later
REM  restores everything as it was.
REM
REM  If you also want to delete saved settings, remove this by
REM  hand AFTER running this:
REM      %USERPROFILE%\.nanocoder
REM ============================================================

where npm >nul 2>nul
if errorlevel 1 (
    echo npm was not found - nothing to uninstall via npm.
    goto :end
)

echo.
echo Uninstalling the Nanocoder CLI globally...
echo     npm uninstall -g @nanocollective/nanocoder
echo.
call npm uninstall -g @nanocollective/nanocoder
if errorlevel 1 goto :failed

echo.
where nanocoder >nul 2>nul
if errorlevel 1 (
    echo Nanocoder CLI removed.
) else (
    echo NOTE: 'nanocoder' is still resolvable on PATH. It may
    echo be a stale shim or a second copy installed elsewhere.
    echo Run 'where nanocoder' to investigate.
)
echo.
echo Done. Your ~/.nanocoder config directory was NOT touched -
echo delete it manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If npm reports the package is not installed, that just means
echo Nanocoder was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
