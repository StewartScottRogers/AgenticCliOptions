@echo off
setlocal
set "RC=1"
where hermes >nul 2>nul && set "RC=0"
REM Upstream installer adds %LOCALAPPDATA%\hermes\bin to the User PATH
REM but the current shell's PATH does not refresh until reopened.
if not "%RC%"=="0" if exist "%LOCALAPPDATA%\hermes\bin\hermes.exe" set "RC=0"
if not "%RC%"=="0" if exist "%LOCALAPPDATA%\hermes\bin\hermes.cmd" set "RC=0"
if not "%RC%"=="0" if exist "%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts\hermes.exe" set "RC=0"

if defined AGENTS_INSTALL_ALL (
    endlocal & exit /b %RC%
)
if defined HERMES_MODEL (
    set "_SRC="
) else (
    set "HERMES_MODEL=Hermes-4-405B"
    set "_SRC=  (built-in default; setx HERMES_MODEL to override)"
)
if "%RC%"=="0" (
    echo Hermes: installed
) else (
    echo Hermes: not installed
)
echo   default model:    %HERMES_MODEL%%_SRC%
if defined OPENROUTER_MODEL echo   OpenRouter model: %OPENROUTER_MODEL%
endlocal & exit /b %RC%
