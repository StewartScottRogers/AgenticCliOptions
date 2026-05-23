@echo off
setlocal

REM ============================================================
REM  Uninstall the Pi coding agent CLI  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the CLI itself (the npm global package).
REM  Leaves Node.js, npm, and your ~/.pi config directory alone,
REM  so reinstalling later restores everything as it was.
REM
REM  If you also want to delete saved sessions, API keys and
REM  settings, remove this folder by hand AFTER running this:
REM      %USERPROFILE%\.pi
REM ============================================================

where npm >nul 2>nul
if errorlevel 1 (
    echo npm was not found - nothing to uninstall via npm.
    echo Pi is installed as an npm global package, so if npm is
    echo gone the CLI was likely already removed with it.
    goto :end
)

echo.
echo Uninstalling the Pi coding agent CLI globally...
echo     npm uninstall -g @earendil-works/pi-coding-agent
echo.
call npm uninstall -g @earendil-works/pi-coding-agent
if errorlevel 1 goto :failed

echo.
where pi >nul 2>nul
if errorlevel 1 (
    echo Pi coding agent CLI removed.
) else (
    echo NOTE: 'pi' is still resolvable on PATH. It may be a
    echo stale shim or a second copy installed elsewhere. Run
    echo 'where pi' to investigate.
)
echo.
echo Done. Your ~/.pi config directory was NOT touched -
echo delete it manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If npm reports the package is not installed, that just means
echo Pi was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
