@echo off
setlocal

REM ============================================================
REM  Uninstall opencode  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the npm install. Leaves Node.js, npm, and the
REM  %USERPROFILE%\.config\opencode\ config directory alone, so
REM  reinstalling later restores provider auth, sessions and
REM  custom providers exactly as they were.
REM
REM  opencode ships its own 'opencode uninstall' subcommand, but
REM  that targets the curl-installer binary path - it does not
REM  remove an npm-installed shim. For our npm install,
REM  'npm uninstall -g opencode-ai' is the canonical path.
REM
REM  If you also want to delete saved sessions, provider auth and
REM  settings, remove this folder by hand AFTER running this:
REM      %USERPROFILE%\.config\opencode
REM ============================================================

REM  Tear down plugin entries BEFORE removing the CLI so hooks
REM  that edit ~/.config/opencode/opencode.json see the live config.
call "%~dp0..\Plugins\_apply-plugins.cmd" Opencode uninstall

where npm >nul 2>nul
if errorlevel 1 (
    echo npm was not found - nothing to uninstall via npm.
    echo opencode is installed as an npm global package, so if
    echo npm is gone the CLI was likely already removed with it.
    goto :end
)

echo.
echo Uninstalling the opencode CLI globally...
echo     npm uninstall -g opencode-ai
echo.
call npm uninstall -g opencode-ai
if errorlevel 1 goto :failed

echo.
where opencode >nul 2>nul
if errorlevel 1 (
    echo opencode CLI removed.
) else (
    echo NOTE: 'opencode' is still resolvable on PATH. It may be a
    echo scoop / choco / curl-installer copy. Try:
    echo     scoop uninstall opencode
    echo     choco uninstall opencode
    echo     opencode uninstall --force
)
echo.
echo Done. Your %%USERPROFILE%%\.config\opencode directory was
echo NOT touched - delete it manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If npm reports the package is not installed, that just means
echo opencode was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
