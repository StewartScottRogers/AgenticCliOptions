@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Update-All  --  update every INSTALLED agent tool
REM  ------------------------------------------------------------
REM  Runs each installed tool's own update script (which uses its
REM  native updater where one exists, otherwise 'winget upgrade').
REM  Tools that are not installed are skipped.
REM
REM  When launched from Install-All.cmd, AGENTS_UPDATE_ALL is
REM  already set so child scripts suppress their own pause.
REM ============================================================

set "ROOT=%~dp0"
set "ALL_TOOLS=Superfile"

if not defined AGENTS_UPDATE_ALL (
    set "AGENTS_UPDATE_ALL=1"
    set "SELF_SET=1"
)

echo.
for %%T in (%ALL_TOOLS%) do (
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
REM  Helper: is the given tool installed? Delegates to
REM  NAME\NAME--is-installed.cmd (exit 0 = installed, 1 = not).
REM ============================================================
:is_installed
if exist "%ROOT%%~1\%~1--is-installed.cmd" (
    call "%ROOT%%~1\%~1--is-installed.cmd" >nul 2>nul
    exit /b
)
exit /b 1
