@echo off
where claude >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
if defined CLAUDE_MODEL (
    set "_SRC="
) else (
    set "CLAUDE_MODEL=claude-sonnet-5"
    set "_SRC=  (built-in default; setx CLAUDE_MODEL to override)"
)
if "%RC%"=="0" (
    echo Claude Code: installed
) else (
    echo Claude Code: not installed
)
echo   default model:          %CLAUDE_MODEL%%_SRC%
if defined OPENROUTER_MODEL       echo   OpenRouter model:       %OPENROUTER_MODEL%
if defined OPENROUTER_SMALL_MODEL echo   OpenRouter small model: %OPENROUTER_SMALL_MODEL%
exit /b %RC%
