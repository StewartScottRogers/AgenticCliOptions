@echo off
where grok >nul 2>nul && exit /b 0
REM Upstream x.ai installer puts grok.exe in %USERPROFILE%\.grok\bin,
REM but only adds it to .bashrc (not the Windows User PATH).
if exist "%USERPROFILE%\.grok\bin\grok.exe" exit /b 0
exit /b 1
