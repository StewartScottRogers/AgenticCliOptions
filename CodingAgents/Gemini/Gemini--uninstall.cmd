@echo off
setlocal

REM ============================================================
REM  Uninstall the Google Gemini CLI  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the CLI itself (the npm global package).
REM  Leaves Node.js, npm, and your ~/.gemini config directory
REM  alone, so reinstalling later restores everything as it was.
REM
REM  If you also want to delete saved sessions, API keys and
REM  settings, remove this folder by hand AFTER running this:
REM      %USERPROFILE%\.gemini
REM ============================================================

REM  Tear down plugin entries BEFORE removing the CLI so hooks
REM  that edit ~/.gemini/settings.json see the live config.
call "%~dp0..\Plugins\_apply-plugins.cmd" Gemini uninstall

where npm >nul 2>nul
if errorlevel 1 (
    echo npm was not found - nothing to uninstall via npm.
    echo Gemini CLI is installed as an npm global package, so if
    echo npm is gone the CLI was likely already removed with it.
    goto :end
)

echo.
echo Uninstalling the Google Gemini CLI globally...
echo     npm uninstall -g @google/gemini-cli
echo.
call npm uninstall -g @google/gemini-cli
if errorlevel 1 goto :failed

echo.
where gemini >nul 2>nul
if errorlevel 1 (
    echo Google Gemini CLI removed.
) else (
    echo NOTE: 'gemini' is still resolvable on PATH. It may be a
    echo stale shim or a second copy installed elsewhere. Run
    echo 'where gemini' to investigate.
)
echo.
echo Done. Your ~/.gemini config directory was NOT touched -
echo delete it manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If npm reports the package is not installed, that just means
echo Gemini CLI was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
