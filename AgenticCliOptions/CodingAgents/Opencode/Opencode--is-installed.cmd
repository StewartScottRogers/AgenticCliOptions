@echo off
where opencode >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
if defined OPENCODE_MODEL (
    set "_SRC="
) else (
    set "OPENCODE_MODEL=anthropic/claude-sonnet-5"
    set "_SRC=  (built-in default; setx OPENCODE_MODEL to override)"
)
if "%RC%"=="0" (
    echo Opencode: installed
) else (
    echo Opencode: not installed
)
echo   default model: %OPENCODE_MODEL%%_SRC%
exit /b %RC%
