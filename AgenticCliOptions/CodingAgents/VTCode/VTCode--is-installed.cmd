@echo off
where vtcode >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
if defined VTCODE_MODEL (
    set "_SRC="
) else (
    set "VTCODE_MODEL=qwen/qwen3-coder"
    set "_SRC=  (built-in default; setx VTCODE_MODEL to override)"
)
if "%RC%"=="0" (
    echo VT Code: installed
) else (
    echo VT Code: not installed
)
echo   default model:    %VTCODE_MODEL%%_SRC%
if defined OPENROUTER_MODEL echo   OpenRouter model: %OPENROUTER_MODEL%
exit /b %RC%
