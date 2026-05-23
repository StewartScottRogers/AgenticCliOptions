@echo off
setlocal

REM ============================================================
REM  Run Nanocoder  --  native launcher
REM  ------------------------------------------------------------
REM  Launches Nanocoder against whatever provider you've
REM  configured (typically Ollama for local-first, or any of
REM  the cloud providers via agents.config.json). For an
REM  explicit OpenRouter launch, use Nanocoder--openrouter.cmd.
REM ============================================================

where nanocoder >nul 2>nul
if errorlevel 1 goto :notinstalled

call nanocoder
goto :end

:notinstalled
echo ERROR: 'nanocoder' was not found. Install with Nanocoder--install.cmd.
pause

:end
endlocal
