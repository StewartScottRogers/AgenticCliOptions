@echo off
where gemini >nul 2>nul
exit /b %ERRORLEVEL%
