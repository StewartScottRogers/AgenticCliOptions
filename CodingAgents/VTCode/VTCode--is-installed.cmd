@echo off
where vtcode >nul 2>nul
exit /b %ERRORLEVEL%
