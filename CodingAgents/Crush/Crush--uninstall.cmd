@echo off
setlocal

REM ============================================================
REM  Uninstall Crush (Charmbracelet)  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the CLI itself (the winget package). Leaves the
REM  %LOCALAPPDATA%\crush config directory alone so reinstalling
REM  later restores everything as it was.
REM
REM  If you also want to delete saved sessions, API keys and the
REM  crush.json config, remove this folder by hand AFTER running
REM  this:
REM      %LOCALAPPDATA%\crush
REM ============================================================

where winget >nul 2>nul
if errorlevel 1 (
    echo winget was not found - cannot uninstall via winget.
    goto :end
)

echo.
echo Uninstalling Crush via winget...
echo     winget uninstall --id charmbracelet.crush
echo.
winget uninstall --id charmbracelet.crush --exact --silent --disable-interactivity
if errorlevel 1 (
    echo NOTE: winget returned non-zero. If the package was not
    echo installed, that is expected - treating as success.
)

echo.
where crush >nul 2>nul
if errorlevel 1 (
    echo Crush removed.
) else (
    echo NOTE: 'crush' is still resolvable on PATH. It may be a
    echo scoop / homebrew copy. Run 'where crush' to investigate.
)
echo.
echo Done. Your %%LOCALAPPDATA%%\crush config directory was NOT
echo touched - delete it manually if you want a fully clean slate.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
