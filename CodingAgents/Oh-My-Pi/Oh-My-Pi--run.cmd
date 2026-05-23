@echo off
setlocal

REM ============================================================
REM  Run Oh-My-Pi (omp)  --  native launcher
REM  ------------------------------------------------------------
REM  Uses whatever provider you've configured in ~/.omp/agent.
REM  For OpenRouter, use Oh-My-Pi--openrouter.cmd instead.
REM ============================================================

call :prepend_path "%LOCALAPPDATA%\omp"

where omp >nul 2>nul
if errorlevel 1 goto :notinstalled

call omp
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
