@echo off
setlocal

REM ============================================================
REM  Run Crush (Charmbracelet)  --  native launcher
REM  ------------------------------------------------------------
REM  Launches Crush against whatever provider you've configured.
REM  For OpenRouter, use Crush--openrouter.cmd instead.
REM ============================================================

where crush >nul 2>nul
if errorlevel 1 goto :notinstalled

call crush
goto :end

:notinstalled
echo ERROR: 'crush' was not found. Install with Crush--install.cmd.
pause

:end
endlocal
