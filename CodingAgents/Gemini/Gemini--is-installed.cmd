@echo off
where gemini >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
if defined GEMINI_MODEL (
    set "_SRC="
) else (
    set "GEMINI_MODEL=gemini-2.5-pro"
    set "_SRC=  (built-in default; setx GEMINI_MODEL to override)"
)
if "%RC%"=="0" (
    echo Gemini CLI: installed
) else (
    echo Gemini CLI: not installed
)
echo   default model: %GEMINI_MODEL%%_SRC%
exit /b %RC%
