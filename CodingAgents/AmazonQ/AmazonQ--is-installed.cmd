@echo off
REM Amazon Q lives inside WSL Ubuntu, not on the Windows PATH.
REM The CLI was rebranded from 'q' to 'kiro-cli'; accept either.
set "RC=1"
where wsl >nul 2>nul
if not errorlevel 1 (
    wsl -d Ubuntu -- bash -lc "command -v q >/dev/null 2>&1 || command -v kiro-cli >/dev/null 2>&1" >nul 2>nul
    if not errorlevel 1 set "RC=0"
)
if defined AGENTS_INSTALL_ALL exit /b %RC%
if "%RC%"=="0" (
    echo Amazon Q: installed
) else (
    echo Amazon Q: not installed
)
echo   default model:   aws-managed  (locked to AWS Nova; CLI has no --model flag)
exit /b %RC%
