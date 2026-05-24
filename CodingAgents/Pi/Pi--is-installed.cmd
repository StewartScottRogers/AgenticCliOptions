@echo off
where pi >nul 2>nul
exit /b %ERRORLEVEL%
