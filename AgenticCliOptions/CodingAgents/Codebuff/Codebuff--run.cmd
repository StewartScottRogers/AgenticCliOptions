@echo off
setlocal

REM ============================================================
REM  Run Codebuff  --  native launcher
REM  ------------------------------------------------------------
REM  Codebuff runs against its own platform (codebuff.com) which
REM  handles model orchestration internally. First run will
REM  prompt you to sign in.
REM
REM  Codebuff does NOT have a documented bring-your-own-OpenRouter
REM  CLI flag - the platform routes via OpenRouter under the hood
REM  rather than accepting your OPENROUTER_API_KEY. That is why
REM  there is no Codebuff--openrouter.cmd in this folder.
REM ============================================================

where codebuff >nul 2>nul
if errorlevel 1 goto :notinstalled

call codebuff
goto :end

:notinstalled
echo ERROR: 'codebuff' was not found. Install with Codebuff--install.cmd.
pause

:end
endlocal
