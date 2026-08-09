@echo off
where omp >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
if defined OMP_MODEL (
    set "_SRC="
) else (
    set "OMP_MODEL=openrouter/anthropic/claude-sonnet-5"
    set "_SRC=  (built-in default; setx OMP_MODEL to override)"
)
if "%RC%"=="0" (
    echo Oh-My-Pi (omp): installed
) else (
    echo Oh-My-Pi (omp): not installed
)
echo   default model:    %OMP_MODEL%%_SRC%
if defined OPENROUTER_MODEL echo   OpenRouter model: %OPENROUTER_MODEL%
exit /b %RC%
