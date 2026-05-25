@echo off
setlocal

REM ============================================================
REM  Uninstall Aider  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the tool itself (the uv-managed install).
REM  Leaves uv, Python, Git and any ~/.aider* config files alone,
REM  so reinstalling later restores everything as it was.
REM
REM  If you also want to delete saved settings and the tag cache,
REM  remove these by hand AFTER running this:
REM      %USERPROFILE%\.aider.conf.yml
REM      %USERPROFILE%\.aider.tags.cache.v3
REM ============================================================

REM  Tear down plugin entries BEFORE removing the CLI.
call "%~dp0..\Plugins\_apply-plugins.cmd" Aider uninstall

where uv >nul 2>nul
if errorlevel 1 (
    echo uv was not found - nothing to uninstall via uv.
    goto :end
)

call uv tool list 2>nul | findstr /I /B /C:"aider-chat" >nul
if errorlevel 1 (
    echo Aider is not installed as a uv tool - nothing to do.
    goto :end
)

echo.
echo Uninstalling Aider...
echo     uv tool uninstall aider-chat
echo.
call uv tool uninstall aider-chat
if errorlevel 1 goto :failed

echo.
where aider >nul 2>nul
if errorlevel 1 (
    echo Aider removed.
) else (
    echo NOTE: 'aider' is still resolvable on PATH. It may be
    echo a stale shim or a second copy installed elsewhere. Run
    echo 'where aider' to investigate.
)
echo.
echo Done. Your ~/.aider.conf.yml and tag cache were NOT
echo touched - delete them manually if you want a fully clean
echo slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If uv reports the tool is not installed, that just means
echo Aider was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
