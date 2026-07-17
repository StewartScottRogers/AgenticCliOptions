@echo off
setlocal

REM ============================================================
REM  Uninstall mprocs  --  matching uninstaller
REM  ------------------------------------------------------------
REM  This is a portable (zip) install, so removal is direct:
REM    1. stop any running instance (taskkill mprocs.exe)
REM    2. delete the install dir %LOCALAPPDATA%\Programs\mprocs\
REM    3. prune %LOCALAPPDATA%\Programs\mprocs\bin from the User PATH
REM
REM  Your global config at %APPDATA%\mprocs\mprocs.yaml is LEFT IN
REM  PLACE. Delete it by hand if you want a fully clean slate:
REM      %APPDATA%\mprocs
REM  (Per-project mprocs.yaml files live in your repos and are never
REM  touched by this script.)
REM ============================================================

set "MP_HOME=%LOCALAPPDATA%\Programs\mprocs"
set "MP_DIR=%MP_HOME%\bin"
set "MP_BIN=%MP_DIR%\mprocs.exe"

REM  A running instance locks the binary; stop it first.
REM  Best-effort: a "not found" is fine and stays quiet.
taskkill /F /IM mprocs.exe >nul 2>nul

if not exist "%MP_HOME%" (
    echo mprocs is not installed at %MP_HOME%.
    echo Nothing to remove.
    goto :prune_path
)

echo.
echo Removing mprocs install dir:
echo     %MP_HOME%
echo.
rmdir /s /q "%MP_HOME%" 2>nul
if exist "%MP_BIN%" (
    echo ERROR: Could not delete mprocs.exe - is a 'mprocs' process
    echo still running? Close it and re-run this script.
    goto :failed
)
echo mprocs binary removed.

:prune_path
REM  Prune the exact bin dir we added from the User PATH.
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$needle=Join-Path $env:LOCALAPPDATA 'Programs\mprocs\bin'; $p=[Environment]::GetEnvironmentVariable('Path','User'); if ($p) { $parts = $p -split ';' | Where-Object { $_ -and ($_ -ne $needle) }; $new = ($parts -join ';'); if ($new -ne $p) { [Environment]::SetEnvironmentVariable('Path', $new, 'User'); Write-Host ('Pruned ' + $needle + ' from User PATH.') } else { Write-Host ('User PATH did not contain ' + $needle + ' - nothing to prune.') } }"

echo.
where mprocs >nul 2>nul
if errorlevel 1 (
    echo mprocs removed.
) else (
    echo NOTE: 'mprocs' is still resolvable on PATH. It may be a second
    echo copy (e.g. 'cargo install mprocs' or a scoop package). Run
    echo 'where mprocs' to investigate.
)
echo.
echo Done. Your %%APPDATA%%\mprocs config was NOT touched -
echo delete that folder manually if you want a fully clean slate.
goto :end


:failed
echo.
echo ERROR: Uninstall failed - see the output above.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
