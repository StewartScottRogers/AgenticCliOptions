@echo off
setlocal
set "RC=1"
where grok >nul 2>nul && set "RC=0"
REM Upstream x.ai installer puts grok.exe in %USERPROFILE%\.grok\bin,
REM but only adds it to .bashrc (not the Windows User PATH).
if not "%RC%"=="0" if exist "%USERPROFILE%\.grok\bin\grok.exe" set "RC=0"

if defined AGENTS_INSTALL_ALL (
    endlocal & exit /b %RC%
)
if "%RC%"=="0" (
    echo Grok Build: installed
) else (
    echo Grok Build: not installed
)
echo   default model:   xai-managed  (Grok Build picks; CLI has no --model flag)
endlocal & exit /b %RC%
