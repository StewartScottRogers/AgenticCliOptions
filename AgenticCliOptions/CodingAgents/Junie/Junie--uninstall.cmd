@echo off
setlocal

REM ============================================================
REM  Uninstall Junie CLI  --  matching uninstaller
REM  ------------------------------------------------------------
REM  The upstream installer ships no uninstall command. We
REM  delete the shim and the versioned binaries directory.
REM  %USERPROFILE%\.local\bin itself is NOT removed because
REM  other agents (Mistral, Trae) share that directory.
REM
REM  What this DOES NOT remove (on purpose):
REM    - %USERPROFILE%\.junie  (config, sessions, API keys -
REM      if Junie writes there)
REM  Delete by hand if you want a fully clean slate.
REM ============================================================

REM  Tear down plugin entries BEFORE removing the CLI.
call "%~dp0..\Plugins\_apply-plugins.cmd" Junie uninstall

set "JUNIE_SHIM=%USERPROFILE%\.local\bin\junie.bat"
set "JUNIE_DATA=%USERPROFILE%\.local\share\junie"

if exist "%JUNIE_SHIM%" (
    echo Removing %JUNIE_SHIM% ...
    del /f /q "%JUNIE_SHIM%"
) else (
    echo Shim %JUNIE_SHIM% not present.
)

if exist "%JUNIE_DATA%\" (
    echo Removing %JUNIE_DATA% ...
    rmdir /s /q "%JUNIE_DATA%"
) else (
    echo Data dir %JUNIE_DATA% not present.
)

echo.
where junie >nul 2>nul
if errorlevel 1 (
    echo Junie CLI removed.
) else (
    echo NOTE: 'junie' is still resolvable on PATH. It may be
    echo a stale copy installed elsewhere. Run 'where junie' to
    echo investigate.
)
echo.
echo Done. Any %%USERPROFILE%%\.junie config was NOT touched -
echo delete it manually if you want a fully clean slate.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
