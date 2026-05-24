@echo off
where claude >nul 2>nul
exit /b %ERRORLEVEL%
