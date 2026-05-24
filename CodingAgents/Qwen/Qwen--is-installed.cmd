@echo off
where qwen >nul 2>nul
exit /b %ERRORLEVEL%
