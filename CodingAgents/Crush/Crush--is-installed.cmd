@echo off
where crush >nul 2>nul
exit /b %ERRORLEVEL%
