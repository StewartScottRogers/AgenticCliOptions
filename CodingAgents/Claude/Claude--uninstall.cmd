@echo off
setlocal

REM ============================================================
REM  Uninstall the Claude Code CLI  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes the CLI itself, covering both supported install
REM  methods:
REM    - the npm global package (@anthropic-ai/claude-code)
REM    - the native installer binary at ~/.local/bin/claude.exe
REM  Leaves Node.js, npm, and your ~/.claude config directory
REM  alone, so reinstalling later restores everything as it was.
REM
REM  If you also want to delete saved sessions, API keys and
REM  settings, remove this folder by hand AFTER running this:
REM      %USERPROFILE%\.claude
REM ============================================================

set "REMOVED_SOMETHING=0"

REM ---- Path 1: npm global package -----------------------------
where npm >nul 2>nul
if errorlevel 1 (
    echo npm was not found - skipping the npm uninstall step.
    goto :native_path
)

echo.
echo Uninstalling the Claude Code CLI globally via npm...
echo     npm uninstall -g @anthropic-ai/claude-code
echo.
call npm uninstall -g @anthropic-ai/claude-code
if errorlevel 1 goto :failed
set "REMOVED_SOMETHING=1"

REM ---- Path 2: native installer binary ------------------------
REM  Anthropic's native installer drops a standalone claude.exe
REM  in ~/.local/bin. The npm uninstall above cannot see it, so
REM  remove it explicitly if present.
REM
REM  Caveat: if this script is being run from a live Claude Code
REM  session, the OS holds an exclusive lock on the running .exe
REM  and the delete will fail with "Access is denied". Detect
REM  that case and surface a helpful message instead of letting
REM  cmd print a bare error.
:native_path
if exist "%USERPROFILE%\.local\bin\claude.exe" (
    echo.
    echo Removing native-installer binary at:
    echo     %USERPROFILE%\.local\bin\claude.exe
    del /f /q "%USERPROFILE%\.local\bin\claude.exe" >nul 2>nul
    if exist "%USERPROFILE%\.local\bin\claude.exe" (
        echo WARNING: could not remove the native-installer binary.
        echo It is most likely locked because a Claude Code session
        echo is currently running it. Close every running 'claude'
        echo process and re-run this uninstaller to finish removal.
    ) else (
        set "REMOVED_SOMETHING=1"
    )
)

echo.
where claude >nul 2>nul
if errorlevel 1 (
    if "%REMOVED_SOMETHING%"=="1" (
        echo Claude Code CLI removed.
    ) else (
        echo Claude Code CLI was not installed - nothing to do.
    )
) else (
    echo NOTE: 'claude' is still resolvable on PATH. It may be a
    echo stale shim or a third copy installed elsewhere. Run
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
