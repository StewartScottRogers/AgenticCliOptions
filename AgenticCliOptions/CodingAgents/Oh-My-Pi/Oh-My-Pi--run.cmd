@echo off
setlocal

REM ============================================================
REM  Run Oh-My-Pi (omp)  --  native launcher
REM  ------------------------------------------------------------
REM  Uses whatever provider you've configured in ~/.omp/agent.
REM  For OpenRouter, use Oh-My-Pi--openrouter.cmd instead.
REM
REM  Default model is always passed via --model. Override by setting
REM  OMP_MODEL once (persists for new terminals):
REM
REM      setx OMP_MODEL "openrouter/openai/gpt-5"
REM ============================================================

if not defined OMP_MODEL set "OMP_MODEL=openrouter/anthropic/claude-sonnet-5"

call :prepend_path "%LOCALAPPDATA%\omp"

where omp >nul 2>nul
if errorlevel 1 goto :notinstalled

echo Launching Oh-My-Pi (omp) with model: %OMP_MODEL%
call omp --model "%OMP_MODEL%"
goto :end

:notinstalled
echo ERROR: 'omp' was not found. Install with Oh-My-Pi--install.cmd.
pause
goto :end

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0

:end
endlocal
