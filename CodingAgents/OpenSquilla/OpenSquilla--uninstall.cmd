@echo off
setlocal

REM ============================================================
REM  Uninstall OpenSquilla  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the tool itself (the uv-managed install).
REM  Leaves uv, Python and any ~/.opensquilla config dir alone,
REM  so reinstalling later restores everything as it was.
REM
REM  If you also want to delete saved sessions, API keys and
REM  settings, remove this folder by hand AFTER running this:
REM      %USERPROFILE%\.opensquilla
REM ============================================================

where uv >nul 2>nul
if errorlevel 1 (
    echo uv was not found - nothing to uninstall via uv.
    goto :end
)

call uv tool list 2>nul | findstr /I /B /C:"opensquilla" >nul
if errorlevel 1 (
    echo OpenSquilla is not installed as a uv tool - nothing to do.
    goto :end
)

echo.
echo Uninstalling OpenSquilla...
echo     uv tool uninstall opensquilla
echo.
call uv tool uninstall opensquilla
if errorlevel 1 goto :failed

echo.
where opensquilla >nul 2>nul
if errorlevel 1 (
    echo OpenSquilla removed.
) else (
    echo NOTE: 'opensquilla' is still resolvable on PATH. It may be
    echo a stale shim or a second copy installed elsewhere. Run
    echo 'where opensquilla' to investigate.
)
echo.
echo Done. Your ~/.opensquilla config directory was NOT touched -
echo delete it manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If uv reports the tool is not installed, that just means
echo OpenSquilla was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
