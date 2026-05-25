@echo off
REM  Antigravity CLI install probe.
REM  We accept either a working 'where agy' (PATH-resolvable) OR
REM  the binary existing at its known install dir - the User PATH
REM  entry added by the installer does not reach a shell that was
REM  already open when the installer ran.
where agy >nul 2>nul
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
    if exist "%LOCALAPPDATA%\agy\bin\agy.exe" set "RC=0"
)
if defined AGENTS_INSTALL_ALL exit /b %RC%
REM  Antigravity has no verified --model flag in this repo. The
REM  ANTIGRAVITY_MODEL env var is documented here so the status
REM  table has a column to display, and so a future run.cmd can
REM  pick it up once the upstream flag is confirmed.
if defined ANTIGRAVITY_MODEL (
    set "_SRC="
) else (
    set "ANTIGRAVITY_MODEL=antigravity-managed"
    set "_SRC=  (managed by the CLI; switch via /model after launch)"
)
if "%RC%"=="0" (
    echo Antigravity CLI: installed
) else (
    echo Antigravity CLI: not installed
)
echo   default model: %ANTIGRAVITY_MODEL%%_SRC%
exit /b %RC%
