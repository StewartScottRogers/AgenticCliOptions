@echo off
setlocal

REM ============================================================
REM  Run Hermes Agent (Nous Research)  --  native launcher
REM  ------------------------------------------------------------
REM  Uses whatever provider you've configured via 'hermes model'
REM  or 'hermes setup --portal'. A Nous Portal subscription covers
REM  the model and built-in tools through one OAuth login.
REM
REM  For OpenRouter, use Hermes--openrouter.cmd instead.
REM ============================================================

call :prepend_path "%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts"

where hermes >nul 2>nul
if errorlevel 1 goto :notinstalled

call hermes
goto :end

:notinstalled
echo ERROR: 'hermes' was not found. Install with Hermes--install.cmd.
pause
goto :end


:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0

:end
endlocal
