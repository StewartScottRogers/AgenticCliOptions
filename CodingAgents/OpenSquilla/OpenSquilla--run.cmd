@echo off
setlocal

REM ============================================================
REM  Run OpenSquilla  --  native launcher
REM  ------------------------------------------------------------
REM  Launches OpenSquilla chat against whatever provider you've
REM  configured via 'opensquilla onboard'. For OpenRouter, use
REM  OpenSquilla--openrouter.cmd instead.
REM ============================================================

where opensquilla >nul 2>nul
if errorlevel 1 goto :notinstalled

call opensquilla chat
goto :end

:notinstalled
echo ERROR: 'opensquilla' was not found. Install with OpenSquilla--install.cmd.
pause

:end
endlocal
