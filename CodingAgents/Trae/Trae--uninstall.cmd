@echo off
setlocal

REM ============================================================
REM  Uninstall Trae Agent (ByteDance)  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the tool itself (the uv-managed install).
REM  Leaves uv, Python and any ~/.trae config directory alone,
REM  so reinstalling later restores everything as it was.
REM
REM  If you also want to delete saved sessions, API keys and
REM  settings, remove this folder by hand AFTER running this:
REM      %USERPROFILE%\.trae
REM ============================================================

where uv >nul 2>nul
if errorlevel 1 (
    echo uv was not found - nothing to uninstall via uv.
    echo Trae Agent is installed as a uv tool, so if uv is gone
    echo the tool was likely already removed with it.
    goto :end
)

echo.
echo Uninstalling Trae Agent...
echo     uv tool uninstall trae-agent
echo.
call uv tool uninstall trae-agent
if errorlevel 1 goto :failed

echo.
where trae-cli >nul 2>nul
if errorlevel 1 (
    echo Trae Agent removed.
) else (
    echo NOTE: 'trae-cli' is still resolvable on PATH. It may be
    echo a stale shim or a second copy installed elsewhere. Run
    echo 'where trae-cli' to investigate.
)
echo.
echo Done. Your ~/.trae config directory was NOT touched -
echo delete it manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If uv reports the tool is not installed, that just means
echo Trae Agent was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
