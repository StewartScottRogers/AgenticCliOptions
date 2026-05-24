@echo off
where hermes >nul 2>nul && exit /b 0
REM Upstream installer adds %LOCALAPPDATA%\hermes\bin to the User PATH
REM but the current shell's PATH does not refresh until reopened.
if exist "%LOCALAPPDATA%\hermes\bin\hermes.exe" exit /b 0
if exist "%LOCALAPPDATA%\hermes\bin\hermes.cmd" exit /b 0
if exist "%LOCALAPPDATA%\hermes\hermes-agent\venv\Scripts\hermes.exe" exit /b 0
exit /b 1
