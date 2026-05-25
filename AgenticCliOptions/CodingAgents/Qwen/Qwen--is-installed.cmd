@echo off
where qwen >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
REM Qwen has no native run.cmd; only the OpenRouter launcher,
REM which honours QWEN_MODEL (not the shared OPENROUTER_MODEL).
if defined QWEN_MODEL (
    set "_SRC="
) else (
    set "QWEN_MODEL=qwen/qwen3-coder"
    set "_SRC=  (built-in default; setx QWEN_MODEL to override)"
)
if "%RC%"=="0" (
    echo Qwen Code: installed
) else (
    echo Qwen Code: not installed
)
echo   default model:   %QWEN_MODEL%%_SRC%
exit /b %RC%
