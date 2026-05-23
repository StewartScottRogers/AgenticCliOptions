@echo off
setlocal

REM ============================================================
REM  Run Autohand Code CLI  --  native launcher
REM  ------------------------------------------------------------
REM  Launches Autohand against whatever provider you've
REM  configured. OpenRouter is the default; for an explicit
REM  OpenRouter launch with model pinning, use
REM  Autohand--openrouter.cmd instead.
REM ============================================================

call :prepend_path "%LOCALAPPDATA%\autohand"

where autohand >nul 2>nul
if errorlevel 1 goto :notinstalled

call autohand
goto :end

:notinstalled
echo ERROR: 'autohand' was not found. Install with Autohand--install.cmd.
pause
goto :end

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0

:end
endlocal
