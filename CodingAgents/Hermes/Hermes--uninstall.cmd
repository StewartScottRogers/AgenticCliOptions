@echo off
setlocal

REM ============================================================
REM  Uninstall Hermes Agent  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Hermes ships its own 'hermes uninstall' subcommand which
REM  removes the scheduled task, startup shortcuts and the
REM  hermes.cmd shim. We use that, then fall back to deleting
REM  %LOCALAPPDATA%\hermes\bin\hermes.cmd if the shim is left
REM  behind.
REM
REM  What this DOES NOT remove (on purpose):
REM    - %USERPROFILE%\.hermes  (config, sessions, API keys)
REM    - %LOCALAPPDATA%\hermes  (the agent codebase + tools)
REM  Delete both by hand if you want a fully clean slate.
REM ============================================================

call :prepend_path "%LOCALAPPDATA%\hermes\bin"

where hermes >nul 2>nul
if errorlevel 1 (
    echo Hermes is not on PATH - nothing to uninstall.
    goto :stripleftovers
)

echo.
echo Running Hermes' own uninstaller...
echo     hermes uninstall
echo.
call hermes uninstall
if errorlevel 1 (
    echo NOTE: 'hermes uninstall' returned a non-zero exit code.
    echo Continuing with shim cleanup anyway.
)

:stripleftovers
if exist "%LOCALAPPDATA%\hermes\bin\hermes.cmd" (
    echo Removing stray hermes.cmd shim...
    del /q "%LOCALAPPDATA%\hermes\bin\hermes.cmd" >nul 2>nul
)

echo.
where hermes >nul 2>nul
if errorlevel 1 (
    echo Hermes Agent removed.
) else (
    echo NOTE: 'hermes' is still resolvable on PATH. It may be
    echo a stale shim or a second copy installed elsewhere. Run
    echo 'where hermes' to investigate.
)
echo.
echo Done. Your %%USERPROFILE%%\.hermes and %%LOCALAPPDATA%%\hermes
echo directories were NOT touched - delete them manually for a
echo fully clean slate.
goto :end


REM ============================================================
REM  Helper routines
REM ============================================================

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0


:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
