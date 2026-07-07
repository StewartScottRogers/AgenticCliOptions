@echo off
setlocal

REM ============================================================
REM  Uninstall Tau  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the tool itself (the uv-managed install).
REM  Leaves uv, Python and your ~/.tau config directory alone,
REM  so reinstalling later restores everything as it was.
REM
REM  If you also want to delete saved sessions, credentials and
REM  your provider catalog, remove this folder by hand AFTER
REM  running this:
REM      %USERPROFILE%\.tau
REM ============================================================

REM  Tear down plugin entries BEFORE removing the CLI.
call "%~dp0..\Plugins\_apply-plugins.cmd" Tau uninstall

where uv >nul 2>nul
if errorlevel 1 (
    echo uv was not found - nothing to uninstall via uv.
    goto :end
)

call uv tool list 2>nul | findstr /I /B /C:"tau-ai" >nul
if errorlevel 1 (
    echo Tau is not installed as a uv tool - nothing to do.
    goto :end
)

echo.
echo Uninstalling Tau...
echo     uv tool uninstall tau-ai
echo.
call uv tool uninstall tau-ai
if errorlevel 1 goto :failed

echo.
where tau >nul 2>nul
if errorlevel 1 (
    echo Tau removed.
) else (
    echo NOTE: 'tau' is still resolvable on PATH. It may be a
    echo stale shim or a second copy installed elsewhere. Run
    echo 'where tau' to investigate.
)
echo.
echo Done. Your ~/.tau config directory was NOT touched -
echo delete it manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If uv reports the tool is not installed, that just means
echo Tau was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
