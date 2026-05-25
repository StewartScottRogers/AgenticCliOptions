@echo off
where junie >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
if defined JUNIE_MODEL (
    set "_SRC="
) else (
    set "JUNIE_MODEL=sonnet"
    set "_SRC=  (built-in default; setx JUNIE_MODEL to override)"
)
if "%RC%"=="0" (
    echo Junie: installed
) else (
    echo Junie: not installed
)
echo   default model:    %JUNIE_MODEL%%_SRC%
if defined OPENROUTER_MODEL echo   OpenRouter model: %OPENROUTER_MODEL%
exit /b %RC%
