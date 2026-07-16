@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Update-All  --  update every INSTALLED agent terminal
REM  ------------------------------------------------------------
REM  Runs each installed terminal's own update script (which uses
REM  its native self-updater, e.g. 'herdr update'). Terminals that
REM  are not installed are skipped.
REM
REM  When launched from Install-All.cmd, AGENTS_UPDATE_ALL is
REM  already set so child scripts suppress their own pause.
REM ============================================================

set "ROOT=%~dp0"
set "ALL_TERMINALS=Herdr"

if not defined AGENTS_UPDATE_ALL (
    set "AGENTS_UPDATE_ALL=1"
    set "SELF_SET=1"
)

echo.
for %%T in (%ALL_TERMINALS%) do (
    call :is_installed %%T
    if errorlevel 1 (
        echo -- %%T : not installed, skipping.
    ) else (
        echo ------------------------------------------------------------
        echo  %%T
        echo ------------------------------------------------------------
        if exist "%ROOT%%%T\%%T--update.cmd" (
            call "%ROOT%%%T\%%T--update.cmd"
        ) else (
            echo ERROR: update script for %%T was not found.
        )
        echo.
    )
)

if defined SELF_SET set "AGENTS_UPDATE_ALL="
echo Done.
echo.
if not defined AGENTS_UPDATE_ALL pause
endlocal
goto :eof

REM ============================================================
REM  Helper: is the given terminal installed? Delegates to
REM  NAME\NAME--is-installed.cmd (exit 0 = installed, 1 = not).
REM ============================================================
:is_installed
if exist "%ROOT%%~1\%~1--is-installed.cmd" (
    call "%ROOT%%~1\%~1--is-installed.cmd" >nul 2>nul
    exit /b
)
exit /b 1
