@echo off
setlocal

REM ============================================================
REM  Uninstall Autohand Code CLI  --  matching uninstaller
REM  ------------------------------------------------------------
REM  The upstream installer ships no uninstall command. We
REM  remove the install dir (%LOCALAPPDATA%\autohand), prune
REM  that entry from the User PATH, and leave everything else
REM  alone.
REM
REM  What this DOES NOT remove (on purpose):
REM    - %USERPROFILE%\.autohand  (config, sessions, API keys)
REM  Delete by hand if you want a fully clean slate.
REM ============================================================

set "AH_DIR=%LOCALAPPDATA%\autohand"

if exist "%AH_DIR%\" (
    echo Removing %AH_DIR% ...
    rmdir /s /q "%AH_DIR%"
) else (
    echo %AH_DIR% not present - nothing to remove.
)

echo.
echo Pruning %AH_DIR% from the User PATH ...
powershell -NoProfile -ExecutionPolicy Bypass -Command ^
  "$p=[Environment]::GetEnvironmentVariable('Path','User'); $needle='%AH_DIR%'; $new=($p -split ';' | Where-Object {$_ -and ($_ -ne $needle)}) -join ';'; if ($new -ne $p) { [Environment]::SetEnvironmentVariable('Path',$new,'User'); Write-Host 'Removed PATH entry.' } else { Write-Host 'PATH entry not found - nothing to prune.' }"

echo.
where autohand >nul 2>nul
if errorlevel 1 (
    echo Autohand Code CLI removed.
) else (
    echo NOTE: 'autohand' is still resolvable on PATH. It may be
    echo a stale copy installed elsewhere. Run 'where autohand'.
)
echo.
echo Done. Your ~/.autohand config dir was NOT touched - delete
echo it manually if you want a fully clean slate.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
