@echo off
REM  Tabby install probe.
REM  Accept the per-user or machine install dir, OR winget reporting
REM  the package present, OR a PATH-resolvable 'tabby'.
set "RC=1"
if exist "%LOCALAPPDATA%\Programs\Tabby\Tabby.exe" set "RC=0"
if not "%RC%"=="0" (
    if exist "%ProgramFiles%\Tabby\Tabby.exe" set "RC=0"
)
if not "%RC%"=="0" (
    where tabby >nul 2>nul
    if not errorlevel 1 set "RC=0"
)
if not "%RC%"=="0" (
    winget list -e --id Eugeny.Tabby >nul 2>nul
    if not errorlevel 1 set "RC=0"
)
if defined AGENTS_INSTALL_ALL exit /b %RC%
if "%RC%"=="0" (
    echo tabby: installed
) else (
    echo tabby: not installed
)
exit /b %RC%
