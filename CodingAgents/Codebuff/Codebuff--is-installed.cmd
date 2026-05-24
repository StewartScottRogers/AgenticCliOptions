@echo off
where codebuff >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
if "%RC%"=="0" (
    echo Codebuff: installed
) else (
    echo Codebuff: not installed
)
echo   default model:   codebuff-managed  (platform routes; CLI has no --model flag)
exit /b %RC%
