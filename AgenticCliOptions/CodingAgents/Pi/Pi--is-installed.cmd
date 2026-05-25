@echo off
where pi >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
if defined PI_MODEL (
    set "_SRC="
) else (
    set "PI_MODEL=anthropic/claude-sonnet-4.5"
    set "_SRC=  (built-in default; setx PI_MODEL to override)"
)
if "%RC%"=="0" (
    echo Pi: installed
) else (
    echo Pi: not installed
)
echo   default model:    %PI_MODEL%%_SRC%
if defined OPENROUTER_MODEL echo   OpenRouter model: %OPENROUTER_MODEL%
exit /b %RC%
