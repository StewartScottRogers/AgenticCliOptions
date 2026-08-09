@echo off
where vibe >nul 2>nul
set "RC=%ERRORLEVEL%"
if defined AGENTS_INSTALL_ALL exit /b %RC%
REM Vibe has no --model flag; the native run uses the CLI's own
REM configured model. The OpenRouter launcher writes a private
REM config.toml from OPENROUTER_MODEL.
if defined OPENROUTER_MODEL (
    set "_OR=%OPENROUTER_MODEL%"
    set "_ORSRC="
) else (
    set "_OR=anthropic/claude-sonnet-5"
    set "_ORSRC=  (built-in default; setx OPENROUTER_MODEL to override)"
)
if "%RC%"=="0" (
    echo Mistral Vibe: installed
) else (
    echo Mistral Vibe: not installed
)
echo   default model:    mistral-managed  [Vibe picks; native run has no --model flag]
echo   OpenRouter model: %_OR%%_ORSRC%
exit /b %RC%
