@echo off
where trae-cli >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
REM Trae has no native run.cmd; only the OpenRouter launcher,
REM which honours the shared OPENROUTER_MODEL env var.
if defined OPENROUTER_MODEL (
    set "_MODEL=%OPENROUTER_MODEL%"
    set "_SRC="
) else (
    set "_MODEL=anthropic/claude-sonnet-5"
    set "_SRC=  (built-in default; setx OPENROUTER_MODEL to override)"
)
if "%RC%"=="0" (
    echo Trae Agent: installed
) else (
    echo Trae Agent: not installed
)
echo   default model:   %_MODEL%%_SRC%
exit /b %RC%
