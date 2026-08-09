@echo off
setlocal

REM ============================================================
REM  Install superfile  --  turn-key installer
REM  ------------------------------------------------------------
REM  superfile is a modern TUI file manager written in Go. It is
REM  NOT a multiplexer and hosts no agent - it is a utility you
REM  run alongside your agents to browse, move, rename, preview
REM  and bulk-operate on the files an agent is about to touch (or
REM  just touched). Useful in a herdr/WezTerm pane next to a
REM  coding agent.
REM  See https://superfile.dev/ and https://github.com/yorukot/superfile.
REM
REM  NOTE: the executable is 'spf', NOT 'superfile'.
REM
REM  Install method: winget (official package 'yorukot.superfile').
REM      winget install -e --id yorukot.superfile
REM  winget drops a shim at
REM      %LOCALAPPDATA%\Microsoft\WinGet\Links\spf.exe
REM  which is already on the User PATH; this shell is refreshed
REM  below so 'spf --version' resolves immediately.
REM
REM  NO dependencies are needed - superfile is a single Go binary
REM  (no Node, no Python, no Go toolchain).
REM ============================================================

echo.
echo Installing superfile via winget (yorukot.superfile)...
echo.

where winget >nul 2>nul
if errorlevel 1 (
    echo ERROR: winget was not found. superfile is distributed through the
    echo Windows Package Manager. Install "App Installer" from the
    echo Microsoft Store [which provides winget], then re-run this script.
    echo Alternatively see https://superfile.dev/getting-started/installation/
    goto :failed
)

winget install -e --id yorukot.superfile --accept-source-agreements --accept-package-agreements
set "RC=%ERRORLEVEL%"
REM  winget returns a non-zero "no applicable upgrade / already installed"
REM  code in some cases; treat an already-present spf as success.
if not "%RC%"=="0" (
    where spf >nul 2>nul
    if errorlevel 1 goto :failed
)

REM  Refresh this shell's PATH from the machine + user registry so
REM  'spf' resolves without opening a new terminal.
call :refresh_path

echo.
where spf >nul 2>nul
if errorlevel 1 (
    echo superfile installed, but 'spf' is not yet on PATH for this
    echo shell. Open a new terminal and run 'spf --version' to verify.
) else (
    echo superfile installed. Reported version:
    call spf --version
)

echo.
echo Done. Launch it with Superfile--run.cmd, or run 'spf' directly.
echo Config is created on first run; 'spf path-list' prints every path.
goto :end


REM ============================================================
REM  Helper: rebuild this shell's PATH from the registry (machine
REM  then user) so a freshly-installed tool resolves immediately.
REM ============================================================
:refresh_path
for /f "skip=2 tokens=2,*" %%A in ('reg query "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" /v Path 2^>nul') do set "SYSPATH=%%B"
for /f "skip=2 tokens=2,*" %%A in ('reg query "HKCU\Environment" /v Path 2^>nul') do set "USRPATH=%%B"
set "PATH=%SYSPATH%;%USRPATH%"
exit /b 0


:failed
echo.
echo ERROR: Installation failed - see the output above.
echo Common causes:
echo   - winget not installed (install "App Installer" from the Store)
echo   - No internet connection / winget source unavailable
echo   - Package agreements not accepted

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
