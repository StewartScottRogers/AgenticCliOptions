@echo off
setlocal

REM ============================================================
REM  Amazon Q Developer CLI (now "Kiro CLI") - install guidance
REM  ------------------------------------------------------------
REM  Amazon's CLI has no native Windows build - on Windows it
REM  runs inside WSL (Windows Subsystem for Linux). Because the
REM  install steps are AWS-account specific and change over time,
REM  this script does not auto-install; it checks for WSL and
REM  points you at the official instructions.
REM
REM  Docs:
REM  https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-installing.html
REM ============================================================

where wsl >nul 2>nul
if errorlevel 1 goto :nowsl

echo WSL was found. Install the Amazon Q / Kiro CLI from inside a
echo WSL shell by following the official guide:
echo.
echo   https://docs.aws.amazon.com/amazonq/latest/qdeveloper-ug/command-line-installing.html
echo.
echo Typical steps inside WSL (Ubuntu):
echo   1. Download the Linux build linked in the AWS docs above.
echo   2. Run its install.sh script.
echo   3. Sign in with:  q login
echo.
echo Opening a WSL shell now so you can run those steps
echo (type 'exit' to return). Then use AmazonQ--run.cmd to launch.
echo.
call wsl
goto :end

:nowsl
echo WSL was not found on your PATH.
echo Install it first from an elevated PowerShell:
echo.
echo     wsl --install
echo.
echo Then re-run this script.

:end
echo.
pause
endlocal
