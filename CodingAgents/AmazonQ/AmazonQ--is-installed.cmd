@echo off
REM Amazon Q lives inside WSL Ubuntu, not on the Windows PATH.
REM The CLI was rebranded from 'q' to 'kiro-cli'; accept either.
where wsl >nul 2>nul
if errorlevel 1 exit /b 1
wsl -d Ubuntu -- bash -lc "command -v q >/dev/null 2>&1 || command -v kiro-cli >/dev/null 2>&1" >nul 2>nul
exit /b %ERRORLEVEL%
