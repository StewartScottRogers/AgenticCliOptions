@echo off
setlocal

REM ============================================================
REM  Uninstall Oh-My-Pi (omp)  --  matching uninstaller
REM  ------------------------------------------------------------
REM  The upstream installer does NOT ship an uninstall command.
REM  We remove the install dir (%LOCALAPPDATA%\omp), prune that
REM  entry from the User PATH, and leave everything else alone.
REM
REM  What this DOES NOT remove (on purpose):
REM    - %USERPROFILE%\.omp  (config, sessions, API keys)
REM  Delete it by hand if you want a fully clean slate.
REM ============================================================

REM  Tear down plugin entries BEFORE removing the CLI.
call "%~dp0..\Plugins\_apply-plugins.cmd" Oh-My-Pi uninstall

set "OMP_DIR=%LOCALAPPDATA%\omp"

if exist "%OMP_DIR%\" (
    echo Removing %OMP_DIR% ...
    rmdir /s /q "%OMP_DIR%"
) else (
    echo %OMP_DIR% not present - nothing to remove.
)

REM  Prune %LOCALAPPDATA%\omp from the User PATH (registry).
echo.
echo Pruning %OMP_DIR% from the User PATH ...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p=[Environment]::GetEnvironmentVariable('Path','User'); $needle='%OMP_DIR%'; $new=($p -split ';' | Where-Object {$_ -and ($_ -ne $needle)}) -join ';'; if ($new -ne $p) { [Environment]::SetEnvironmentVariable('Path',$new,'User'); Write-Host 'Removed PATH entry.' } else { Write-Host 'PATH entry not found - nothing to prune.' }"

echo.
where omp >nul 2>nul
if errorlevel 1 (
    echo Oh-My-Pi removed.
) else (
    echo NOTE: 'omp' is still resolvable on PATH. It may be
    echo a stale shim or a second copy installed elsewhere. Run
    echo 'where omp' to investigate.
)
echo.
echo Done. Your ~/.omp config directory was NOT touched -
echo delete it manually if you want a fully clean slate.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
