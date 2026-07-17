@echo off
REM  ConEmu install probe.
REM  Accept the default install dir (64- or 32-bit Program Files),
REM  OR winget reporting the package present, OR a PATH-resolvable
REM  'ConEmu64'.
set "RC=1"
if exist "%ProgramFiles%\ConEmu\ConEmu64.exe" set "RC=0"
if not "%RC%"=="0" (
    if exist "%ProgramFiles(x86)%\ConEmu\ConEmu.exe" set "RC=0"
)
if not "%RC%"=="0" (
    where ConEmu64 >nul 2>nul
    if not errorlevel 1 set "RC=0"
)
if not "%RC%"=="0" (
    winget list -e --id Maximus5.ConEmu >nul 2>nul
    if not errorlevel 1 set "RC=0"
)
if defined AGENTS_INSTALL_ALL exit /b %RC%
if "%RC%"=="0" (
    echo conemu: installed
) else (
    echo conemu: not installed
)
exit /b %RC%
