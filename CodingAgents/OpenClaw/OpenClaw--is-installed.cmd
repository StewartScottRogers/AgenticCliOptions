@echo off
where openclaw >nul 2>nul
exit /b %ERRORLEVEL%
