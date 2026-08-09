@echo off
where aider >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
if defined AIDER_MODEL (
    set "_SRC="
) else (
    set "AIDER_MODEL=openrouter/anthropic/claude-sonnet-5"
    set "_SRC=  (built-in default; setx AIDER_MODEL to override)"
)
if "%RC%"=="0" (
    echo Aider: installed
) else (
    echo Aider: not installed
)
echo   default model:    %AIDER_MODEL%%_SRC%
if defined OPENROUTER_MODEL echo   OpenRouter model: %OPENROUTER_MODEL%
exit /b %RC%
