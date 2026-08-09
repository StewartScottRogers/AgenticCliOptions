@echo off
where tau >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
if defined TAU_MODEL (
    set "_SRC="
) else (
    set "TAU_MODEL=claude-sonnet-5"
    set "_SRC=  (built-in default; setx TAU_MODEL to override)"
)
if "%RC%"=="0" (
    echo Tau: installed
) else (
    echo Tau: not installed
)
echo   default model:    %TAU_MODEL%%_SRC%
if defined OPENROUTER_MODEL echo   OpenRouter model: %OPENROUTER_MODEL%
exit /b %RC%
