@echo off
where opensquilla >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
if defined OPENSQUILLA_MODEL (
    set "_SRC="
) else (
    set "OPENSQUILLA_MODEL=anthropic/claude-sonnet-4.5"
    set "_SRC=  (built-in default; setx OPENSQUILLA_MODEL to override)"
)
if "%RC%"=="0" (
    echo OpenSquilla: installed
) else (
    echo OpenSquilla: not installed
)
echo   default model:    %OPENSQUILLA_MODEL%%_SRC%
if defined OPENROUTER_MODEL echo   OpenRouter model: %OPENROUTER_MODEL%
exit /b %RC%
