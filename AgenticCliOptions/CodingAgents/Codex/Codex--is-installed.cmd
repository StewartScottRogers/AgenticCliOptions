@echo off
where codex >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
if defined CODEX_MODEL (
    set "_SRC="
) else (
    set "CODEX_MODEL=gpt-5.5"
    set "_SRC=  (built-in default; setx CODEX_MODEL to override)"
)
if "%RC%"=="0" (
    echo Codex: installed
) else (
    echo Codex: not installed
)
echo   default model: %CODEX_MODEL%%_SRC%
exit /b %RC%
