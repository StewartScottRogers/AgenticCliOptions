@echo off
where codex >nul 2>nul
exit /b %ERRORLEVEL%
