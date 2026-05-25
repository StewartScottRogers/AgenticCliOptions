@echo off
setlocal

REM ============================================================
REM  Uninstall the Qwen Code CLI  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes ONLY the CLI itself (the npm global package).
REM  Leaves Node.js, npm, and your ~/.qwen config directory
REM  alone, so reinstalling later restores everything as it was.
REM
REM  If you also want to delete saved sessions, API keys and
REM  settings, remove this folder by hand AFTER running this:
REM      %USERPROFILE%\.qwen
REM ============================================================

REM  Tear down plugin entries BEFORE removing the CLI.
call "%~dp0..\Plugins\_apply-plugins.cmd" Qwen uninstall

where npm >nul 2>nul
if errorlevel 1 (
    echo npm was not found - nothing to uninstall via npm.
    echo Qwen Code is installed as an npm global package, so if
    echo npm is gone the CLI was likely already removed with it.
    goto :end
)

echo.
echo Uninstalling the Qwen Code CLI globally...
echo     npm uninstall -g @qwen-code/qwen-code
echo.
call npm uninstall -g @qwen-code/qwen-code
if errorlevel 1 goto :failed

echo.
where qwen >nul 2>nul
if errorlevel 1 (
    echo Qwen Code CLI removed.
) else (
    echo NOTE: 'qwen' is still resolvable on PATH. It may be a
    echo stale shim or a second copy installed elsewhere. Run
    echo 'where qwen' to investigate.
)
echo.
echo Done. Your ~/.qwen config directory was NOT touched -
echo delete it manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.
echo If npm reports the package is not installed, that just means
echo Qwen Code was already absent - no action was needed.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
