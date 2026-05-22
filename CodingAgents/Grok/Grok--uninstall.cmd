@echo off
setlocal

REM ============================================================
REM  Uninstall the xAI Grok CLI  --  matching uninstaller
REM  ------------------------------------------------------------
REM  The installer has two paths (official bash installer first,
REM  npm 'grok-build' fallback second), so this uninstaller tries
REM  both - whichever one is actually present gets removed.
REM
REM  Leaves Git for Windows, Node.js / npm, and your ~/.grok
REM  config directory alone, so reinstalling later restores
REM  everything as it was.
REM
REM  If you also want to delete saved sessions, API keys and
REM  settings, remove this folder by hand AFTER running this:
REM      %USERPROFILE%\.grok
REM ============================================================

set "REMOVED_SOMETHING=0"

REM ---- Path 1: official installer leaves a binary in either ----
REM  ~/.local/bin/grok (Git Bash default) or ~/.x.ai/bin/grok.
REM  Use bash so we hit the same filesystem the installer wrote to.
where bash >nul 2>nul
if errorlevel 1 goto :npm_path

echo.
echo Looking for an official-installer copy of Grok...
call bash -lc "for p in \"$HOME/.local/bin/grok\" \"$HOME/.x.ai/bin/grok\" \"$HOME/.grok/bin/grok\"; do if [ -e \"$p\" ]; then echo \"Removing $p\"; rm -f \"$p\"; fi; done; if [ -d \"$HOME/.x.ai\" ] && [ -z \"$(ls -A \"$HOME/.x.ai\" 2>/dev/null)\" ]; then rmdir \"$HOME/.x.ai\"; fi"
if not errorlevel 1 set "REMOVED_SOMETHING=1"

:npm_path
REM ---- Path 2: npm fallback package 'grok-build' ---------------
where npm >nul 2>nul
if errorlevel 1 goto :report

echo.
echo Uninstalling the npm fallback package (grok-build)...
echo     npm uninstall -g grok-build
call npm uninstall -g grok-build
if not errorlevel 1 set "REMOVED_SOMETHING=1"

:report
echo.
where grok >nul 2>nul
if errorlevel 1 (
    if "%REMOVED_SOMETHING%"=="1" (
        echo Grok CLI removed.
    ) else (
        echo Grok CLI was not installed - nothing to do.
    )
) else (
    echo NOTE: 'grok' is still resolvable on PATH. It may be a
    echo stale shim or a copy installed somewhere else - run
    echo 'where grok' to find it.
)
echo.
echo Done. Your ~/.grok config directory was NOT touched -
echo delete it manually if you want a fully clean slate.
goto :end


:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
