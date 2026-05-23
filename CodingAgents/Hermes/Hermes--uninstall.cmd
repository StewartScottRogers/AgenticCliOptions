@echo off
setlocal

REM ============================================================
REM  Uninstall Hermes Agent  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Hermes ships its own 'hermes uninstall' subcommand which
REM  removes the scheduled task, startup shortcuts and the
REM  hermes.cmd shim. We invoke it from the actual install
REM  location (%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts).
REM
REM  What this DOES NOT remove (on purpose):
REM    - %USERPROFILE%\.hermes  (config, sessions, API keys)
REM    - %LOCALAPPDATA%\hermes  (the agent codebase + tools)
REM  Delete both by hand if you want a fully clean slate.
REM ============================================================

call :prepend_path "%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts"

where hermes >nul 2>nul
if errorlevel 1 (
    echo Hermes is not on PATH - nothing to uninstall.
    goto :prunepath
)

echo.
echo Running Hermes' own uninstaller...
echo     hermes uninstall
echo.
call hermes uninstall
if errorlevel 1 (
    echo NOTE: 'hermes uninstall' returned a non-zero exit code.
    echo Continuing with PATH cleanup anyway.
)

:prunepath
REM  Prune the Hermes Scripts dir from the User PATH (the
REM  upstream installer adds it via setx, and 'hermes uninstall'
REM  does not always remove it on Windows).
echo.
echo Pruning Hermes from the User PATH ...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p=[Environment]::GetEnvironmentVariable('Path','User'); $needle='%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts'; $new=($p -split ';' | Where-Object {$_ -and ($_ -ne $needle)}) -join ';'; if ($new -ne $p) { [Environment]::SetEnvironmentVariable('Path',$new,'User'); Write-Host 'Removed PATH entry.' } else { Write-Host 'PATH entry not found - nothing to prune.' }"

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

:prepend_path_done
goto :end

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
