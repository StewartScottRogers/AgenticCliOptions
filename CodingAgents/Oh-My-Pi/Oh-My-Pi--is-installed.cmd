@echo off
where omp >nul 2>nul
exit /b %ERRORLEVEL%
