@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Uninstall-All  --  remove every agent terminal
REM  ------------------------------------------------------------
REM  Runs each terminal's own uninstall script. Per-terminal
REM  config/state dirs (e.g. %USERPROFILE%\.herdr) are LEFT IN
REM  PLACE - each uninstaller documents what it keeps. Delete
REM  those by hand for a fully clean slate.
REM
REM  When launched from Install-All.cmd, AGENTS_UNINSTALL_ALL is
REM  already set so child scripts suppress their own pause.
REM ============================================================

set "ROOT=%~dp0"
set "ALL_TERMINALS=Herdr Zellij WezTerm Mprocs Wmux Tabby ConEmu Psmux WindowsTerminal"

if not defined AGENTS_UNINSTALL_ALL (
    echo This removes every agent terminal in the catalogue:
    echo     %ALL_TERMINALS%
    echo Per-terminal config/state is preserved. Continue?
    set "GO="
    set /p "GO=   Uninstall everything? [y/N]: "
    set "G1=!GO:~0,1!"
    if /I not "!G1!"=="Y" (
        echo Cancelled - nothing uninstalled.
        endlocal
        exit /b 0
    )
    set "AGENTS_UNINSTALL_ALL=1"
    set "SELF_SET=1"
)

echo.
for %%T in (%ALL_TERMINALS%) do (
    echo ------------------------------------------------------------
    echo  %%T
    echo ------------------------------------------------------------
    if exist "%ROOT%%%T\%%T--uninstall.cmd" (
        call "%ROOT%%%T\%%T--uninstall.cmd"
    ) else (
        echo ERROR: uninstall script for %%T was not found.
    )
    echo.
)

if defined SELF_SET set "AGENTS_UNINSTALL_ALL="
echo Done.
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
