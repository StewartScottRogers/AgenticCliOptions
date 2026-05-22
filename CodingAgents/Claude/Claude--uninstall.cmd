@echo off
setlocal

REM ============================================================
REM  Uninstall the Claude Code CLI  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the CLI itself (the npm global package).
REM  Leaves Node.js, npm, and your ~/.claude config directory
REM  alone, so reinstalling later restores everything as it was.
REM
REM  If you also want to delete saved sessions, API keys and
REM  settings, remove this folder by hand AFTER running this:
REM      %USERPROFILE%\.claude
REM ============================================================

where npm >nul 2>nul
if errorlevel 1 (
    echo npm was not found - nothing to uninstall via npm.
    echo Claude Code is installed as an npm global package, so if
    echo npm is gone the CLI was likely already removed with it.
    goto :end
)

echo.
echo Uninstalling the Claude Code CLI globally...
echo     npm uninstall -g @anthropic-ai/claude-code
echo.
call npm uninstall -g @anthropic-ai/claude-code
if errorlevel 1 goto :failed

echo.
where claude >nul 2>nul
if errorlevel 1 (
    echo Claude Code CLI removed.
) else (
    echo NOTE: 'claude' is still resolvable on PATH. It may be a
    echo stale shim or a second copy installed elsewhere. Run
    echo 'where claude' to investigate.
)
echo.
echo Done. Your ~/.claude config directory was NOT touched -
echo delete it manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If npm reports the package is not installed, that just means
echo Claude Code was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
