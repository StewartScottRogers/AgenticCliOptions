@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Install-All  --  install one, several, or every terminal
REM  ------------------------------------------------------------
REM  Sibling of CodingAgents\Install-All.cmd, but for the agent
REM  TERMINALS catalogue (multiplexers / orchestrators that host
REM  the coding agents, rather than the agents themselves).
REM
REM  Usage:
REM    Install-All.cmd                 interactive menu
REM    Install-All.cmd all             install every terminal
REM    Install-All.cmd Herdr           install just those named
REM    Install-All.cmd --status        print install-status table
REM    Install-All.cmd /?              show usage and exit
REM
REM  Each child installer reads AGENTS_INSTALL_ALL and skips its own
REM  final 'pause', so an "all" run is unattended.
REM ============================================================

set "ROOT=%~dp0"
set "AGENTS_INSTALL_ALL=1"

REM  Master terminal catalogue. Add new terminals here (a folder
REM  NAME\ with NAME--install.cmd + NAME--is-installed.cmd).
set "ALL_TERMINALS=Herdr"

set "SELECTED="
set "STATUS_ONLY="

:parse_args
if "%~1"=="" goto :after_args
if /I "%~1"=="/?"       goto :usage
if /I "%~1"=="-h"       goto :usage
if /I "%~1"=="--help"   goto :usage
if /I "%~1"=="-s"       (set "STATUS_ONLY=1" & shift & goto :parse_args)
if /I "%~1"=="--status" (set "STATUS_ONLY=1" & shift & goto :parse_args)
if /I "%~1"=="all" (set "SELECTED=%ALL_TERMINALS%" & shift & goto :parse_args)
if not exist "%ROOT%%~1\%~1--install.cmd" (
    echo ERROR: unknown terminal "%~1"
    echo Run "%~nx0 /?" for the full list.
    exit /b 1
)
set "SELECTED=!SELECTED! %~1"
shift
goto :parse_args

:after_args
if defined STATUS_ONLY goto :show_status
if not defined SELECTED goto :menu
goto :run

:usage
echo Usage: %~nx0 [--status] [terminal ...] ^| all ^| /?
echo.
echo Available terminals (case-insensitive):
for %%T in (%ALL_TERMINALS%) do echo   %%T
echo.
echo Examples:
echo   %~nx0                 interactive menu
echo   %~nx0 --status        print install-status table and exit
echo   %~nx0 all             install every terminal
echo   %~nx0 Herdr           install just Herdr
exit /b 0

:menu
set "INTERACTIVE=1"
cls
echo ============================================================
echo  Install agent terminals  --  choose what to install
echo ============================================================
echo.
set "IDX=0"
for %%T in (%ALL_TERMINALS%) do (
    set /a IDX+=1
    set "T_!IDX!=%%T"
    call :is_installed %%T
    if errorlevel 1 (set "MARK=[ ]") else (set "MARK=[installed]")
    set "NP=  !IDX!"
    set "NP=!NP:~-2!"
    echo    !NP!^) %%T   !MARK!
)
set "TOTAL=!IDX!"
echo.
echo      A^) install all      S^) show status      Q^) quit
echo      U^) uninstall all    M^) update all installed
echo.
set "INPUT="
set /p "INPUT=   Your choice: "
if not defined INPUT goto :menu
if /I "!INPUT!"=="Q" (endlocal & exit /b 0)
if /I "!INPUT!"=="S" goto :show_status
if /I "!INPUT!"=="U" goto :uninstall_all
if /I "!INPUT!"=="M" goto :update_all
if /I "!INPUT!"=="A" (set "SELECTED=%ALL_TERMINALS%" & goto :run)

set "INPUT=!INPUT:,= !"
set "SELECTED="
for %%K in (!INPUT!) do (
    set "TOK=%%K"
    set "ISNUM=1"
    for /f "delims=0123456789" %%X in ("!TOK!") do set "ISNUM="
    set "RESOLVED="
    if defined ISNUM (
        if !TOK! GEQ 1 if !TOK! LEQ !TOTAL! call set "RESOLVED=%%T_!TOK!%%"
    ) else (
        if exist "%ROOT%!TOK!\!TOK!--install.cmd" set "RESOLVED=!TOK!"
    )
    if defined RESOLVED set "SELECTED=!SELECTED! !RESOLVED!"
)
if not defined SELECTED (
    echo.
    echo No valid terminals selected. Press any key to try again.
    pause >nul
    goto :menu
)
goto :run

:show_status
cls
echo ============================================================
echo  Install status  --  every terminal in the catalogue
echo ============================================================
echo.
set "OK=0"
set "MISS=0"
for %%T in (%ALL_TERMINALS%) do (
    call :is_installed %%T
    if errorlevel 1 (
        set /a MISS+=1
        echo    %%T : missing
    ) else (
        set /a OK+=1
        echo    %%T : installed
    )
)
echo.
echo    Installed: !OK!   Missing: !MISS!
echo.
if defined STATUS_ONLY (endlocal & exit /b 0)
pause
goto :menu

:uninstall_all
echo.
if not exist "%ROOT%Uninstall-All.cmd" (
    echo ERROR: Uninstall-All.cmd not found next to this script.
    echo.
    pause
    goto :menu
)
set "AGENTS_UNINSTALL_ALL=1"
call "%ROOT%Uninstall-All.cmd"
set "AGENTS_UNINSTALL_ALL="
echo.
pause
goto :menu

:update_all
echo.
if not exist "%ROOT%Update-All.cmd" (
    echo ERROR: Update-All.cmd not found next to this script.
    echo.
    pause
    goto :menu
)
set "AGENTS_UPDATE_ALL=1"
call "%ROOT%Update-All.cmd"
set "AGENTS_UPDATE_ALL="
echo.
pause
goto :menu

:run
echo.
echo Installing selected terminals...
echo.
for %%T in (!SELECTED!) do (
    echo ------------------------------------------------------------
    echo  %%T
    echo ------------------------------------------------------------
    if exist "%ROOT%%%T\%%T--install.cmd" (
        call "%ROOT%%%T\%%T--install.cmd"
    ) else (
        echo ERROR: install script for %%T was not found.
    )
    echo.
)
echo Done.
echo.
if not defined INTERACTIVE (endlocal & goto :eof)
pause
set "SELECTED="
goto :menu

REM ============================================================
REM  Helper: is the given terminal installed? Delegates to
REM  NAME\NAME--is-installed.cmd (exit 0 = installed, 1 = not).
REM ============================================================
:is_installed
if exist "%ROOT%%~1\%~1--is-installed.cmd" (
    call "%ROOT%%~1\%~1--is-installed.cmd"
    exit /b
)
exit /b 1
