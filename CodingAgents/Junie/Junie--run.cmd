@echo off
setlocal

REM ============================================================
REM  Run Junie CLI (JetBrains)  --  native launcher
REM  ------------------------------------------------------------
REM  Launches Junie against whatever provider you've configured
REM  via /account inside the TUI, or with a Junie subscription.
REM  For OpenRouter, use Junie--openrouter.cmd instead.
REM ============================================================

call :prepend_path "%USERPROFILE%\.local\bin"

where junie >nul 2>nul
if errorlevel 1 goto :notinstalled

call junie
goto :end

:notinstalled
echo ERROR: 'junie' was not found. Install with Junie--install.cmd.
pause
goto :end

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0

:end
endlocal
