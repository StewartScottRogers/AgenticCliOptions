@echo off
setlocal

REM ============================================================
REM  Uninstall Mistral Vibe  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the tool itself (the uv-managed install).
REM  Leaves uv, Python and any ~/.mistral / ~/.vibe config
REM  alone, so reinstalling later restores everything as it was.
REM
REM  If you also want to delete saved sessions, API keys and
REM  settings, remove these folders by hand AFTER running this:
REM      %USERPROFILE%\.mistral
REM      %USERPROFILE%\.vibe
REM ============================================================

where uv >nul 2>nul
if errorlevel 1 (
    echo uv was not found - nothing to uninstall via uv.
    echo Mistral Vibe is installed as a uv tool, so if uv is gone
    echo the tool was likely already removed with it.
    goto :end
)

echo.
echo Uninstalling Mistral Vibe...
echo     uv tool uninstall mistral-vibe
echo.
call uv tool uninstall mistral-vibe
if errorlevel 1 goto :failed

echo.
where vibe >nul 2>nul
if errorlevel 1 (
    echo Mistral Vibe removed.
) else (
    echo NOTE: 'vibe' is still resolvable on PATH. It may be a
    echo stale shim or a second copy installed elsewhere. Run
    echo 'where vibe' to investigate.
)
echo.
echo Done. Your Mistral config directories were NOT touched -
echo delete them manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If uv reports the tool is not installed, that just means
echo Mistral Vibe was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
