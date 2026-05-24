@echo off
REM Amazon Q lives inside WSL Ubuntu, not on the Windows PATH.
where wsl >nul 2>nul
if errorlevel 1 exit /b 1
wsl -d Ubuntu -- bash -lc "command -v q" >nul 2>nul
exit /b %ERRORLEVEL%
