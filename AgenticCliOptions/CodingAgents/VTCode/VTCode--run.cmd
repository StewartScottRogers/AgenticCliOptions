@echo off
setlocal

REM ============================================================
REM  Run VT Code  --  native launcher
REM  ------------------------------------------------------------
REM  Launches VT Code chat against whatever provider you've
REM  configured in vtcode.toml or via env vars. For an explicit
REM  OpenRouter launch, use VTCode--openrouter.cmd.
REM
REM  Default model is always passed via --model. Override by setting
REM  VTCODE_MODEL once (persists for new terminals):
REM
REM      setx VTCODE_MODEL "anthropic/claude-sonnet-5"
REM ============================================================

if not defined VTCODE_MODEL set "VTCODE_MODEL=qwen/qwen3-coder"

call :prepend_path "%USERPROFILE%\.local\bin"

where vtcode >nul 2>nul
if errorlevel 1 goto :notinstalled

echo Launching VT Code with model: %VTCODE_MODEL%
call vtcode --model "%VTCODE_MODEL%" chat
goto :end

:notinstalled
echo ERROR: 'vtcode' was not found. Install with VTCode--install.cmd.
pause
goto :end

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0

:end
endlocal
