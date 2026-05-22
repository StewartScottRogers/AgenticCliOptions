@echo off
setlocal

REM ============================================================
REM  Uninstall the OpenAI Codex CLI  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the CLI itself (the npm global package).
REM  Leaves Node.js, npm, and your ~/.codex config directory
REM  alone, so reinstalling later restores everything as it was.
REM
REM  If you also want to delete saved sessions, API keys and
REM  settings, remove this folder by hand AFTER running this:
REM      %USERPROFILE%\.codex
REM ============================================================

where npm >nul 2>nul
if errorlevel 1 (
    echo npm was not found - nothing to uninstall via npm.
    echo Codex is installed as an npm global package, so if
    echo npm is gone the CLI was likely already removed with it.
    goto :end
)

echo.
echo Uninstalling the OpenAI Codex CLI globally...
echo     npm uninstall -g @openai/codex
echo.
call npm uninstall -g @openai/codex
if errorlevel 1 goto :failed

echo.
where codex >nul 2>nul
if errorlevel 1 (
    echo OpenAI Codex CLI removed.
) else (
    echo NOTE: 'codex' is still resolvable on PATH. It may be a
    echo stale shim or a second copy installed elsewhere. Run
    echo 'where codex' to investigate.
)
echo.
echo Done. Your ~/.codex config directory was NOT touched -
echo delete it manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If npm reports the package is not installed, that just means
echo Codex was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
