@echo off
setlocal

REM ============================================================
REM  Install / update Oh-My-Pi (omp)  --  turn-key installer
REM  ------------------------------------------------------------
REM  Oh-My-Pi is a coding-first fork of Pi by Mario Zechner,
REM  rewritten in TypeScript with sessions, subagents, slash
REM  commands and extensions. See https://omp.sh/ for docs and
REM  https://github.com/can1357/oh-my-pi for source.
REM
REM  This script uses the upstream installer in BINARY mode
REM  (prebuilt EXE - no Bun required at install time):
REM      & ([scriptblock]::Create((irm omp.sh/install.ps1))) -Binary
REM
REM  After install:
REM    - omp.exe lives under %LOCALAPPDATA%\omp\
REM    - That dir is added to the User PATH
REM    - Settings + agent dir live under %USERPROFILE%\.omp
REM
REM  omp also needs a bash.exe at runtime (Git for Windows is
REM  fine); we install Git via winget if it is missing.
REM ============================================================

set "INSTALL_URL=https://omp.sh/install.ps1"

call :ensure_git

echo.
echo Installing / updating Oh-My-Pi (omp) via the official
echo PowerShell installer (binary mode)...
echo.

REM  The upstream installer accepts -Binary, but the
REM  scriptblock-from-irm pattern uses nested parens that cmd
REM  cannot parse safely. Stage the script to a temp .ps1 and
REM  invoke that instead.
REM
REM  Important: the upstream install.ps1 contains Unicode
REM  characters (check marks, warning signs) but ships without
REM  a BOM. Windows PowerShell 5.1 reads BOM-less files as
REM  Windows-1252, which mangles the multi-byte UTF-8 and
REM  breaks parsing. We download as UTF-8 text and rewrite the
REM  file with a UTF-8 BOM so PS 5.1 parses it correctly.
set "OMP_PS1=%TEMP%\omp-install.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProgressPreference='SilentlyContinue'; $wc=New-Object Net.WebClient; $raw=$wc.DownloadData('%INSTALL_URL%'); $text=[Text.Encoding]::UTF8.GetString($raw); $bom=[byte[]](0xEF,0xBB,0xBF); $bytes=$bom + [Text.Encoding]::UTF8.GetBytes($text); [IO.File]::WriteAllBytes('%OMP_PS1%', $bytes)"
if errorlevel 1 goto :failed
powershell -NoProfile -ExecutionPolicy Bypass -File "%OMP_PS1%" -Binary
set "RC=%ERRORLEVEL%"
del /q "%OMP_PS1%" >nul 2>nul
if not "%RC%"=="0" goto :failed

REM  The installer adds %LOCALAPPDATA%\omp to the User PATH but
REM  this shell still has the old PATH. Prepend it now so 'omp'
REM  resolves immediately.
call :prepend_path "%LOCALAPPDATA%\omp"

echo.
where omp >nul 2>nul
if errorlevel 1 (
    echo NOTE: 'omp' is not yet on PATH for this shell. Open a
    echo new terminal and run 'omp --version' to verify.
) else (
    echo Oh-My-Pi installed. Reported version:
    call omp --version
)
echo.
echo Done. Launch it with Oh-My-Pi--openrouter.cmd, or run
echo 'omp' directly.
goto :end


REM ============================================================
REM  Helper routines
REM ============================================================

:ensure_git
REM  omp needs bash at runtime; Git for Windows provides one.
where bash >nul 2>nul && exit /b 0
echo.
echo bash was not found - installing Git for Windows (provides
echo bash, which omp needs at runtime)...
call :ensure_winget
if errorlevel 1 exit /b 0
winget install --id Git.Git --exact --silent --accept-package-agreements --accept-source-agreements
call :refresh_path
exit /b 0

:ensure_winget
where winget >nul 2>nul && exit /b 0
echo NOTE: 'winget' was not found - skipping Git auto-install.
echo Install "App Installer" from https://aka.ms/getwinget if
echo Git/bash needs to be installed automatically.
exit /b 1

:refresh_path
call :prepend_path "%ProgramFiles%\Git\cmd"
call :prepend_path "%ProgramFiles%\Git\bin"
call :prepend_path "%LOCALAPPDATA%\Microsoft\WinGet\Links"
call :prepend_path "%LOCALAPPDATA%\omp"
exit /b 0

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0


:failed
echo.
echo ERROR: Installation failed - see the output above.
echo If the binary release is missing for the current omp
echo version, retry with the source installer (Bun required):
echo   powershell -Command "irm omp.sh/install.ps1 ^| iex"

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
