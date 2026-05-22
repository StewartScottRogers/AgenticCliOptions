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
REM  ~/.local/bin/grok (Git Bash default), ~/.x.ai/bin/grok, or
REM  ~/.grok/bin/grok. On Windows those map under %USERPROFILE%,
REM  so we can clean them up directly without invoking bash (which
REM  on stock Windows resolves to the WSL launcher and prints a
REM  spurious "system cannot find the path specified" warning when
REM  the current drive is not visible inside WSL).
echo.
echo Looking for an official-installer copy of Grok...
for %%P in (
    "%USERPROFILE%\.local\bin\grok"
    "%USERPROFILE%\.local\bin\grok.exe"
    "%USERPROFILE%\.x.ai\bin\grok"
    "%USERPROFILE%\.x.ai\bin\grok.exe"
    "%USERPROFILE%\.grok\bin\grok"
    "%USERPROFILE%\.grok\bin\grok.exe"
) do (
    if exist %%P (
        echo Removing %%~P
        del /f /q %%P
        set "REMOVED_SOMETHING=1"
    )
)
REM  Tidy up the now-empty ~/.x.ai install dir (rmdir without /s
REM  only succeeds if the dir is empty, so it is safe to call).
if exist "%USERPROFILE%\.x.ai\bin\" rmdir "%USERPROFILE%\.x.ai\bin" 2>nul
if exist "%USERPROFILE%\.x.ai\" rmdir "%USERPROFILE%\.x.ai" 2>nul

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
