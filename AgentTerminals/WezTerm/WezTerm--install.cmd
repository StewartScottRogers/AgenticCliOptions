@echo off
setlocal

REM ============================================================
REM  Install WezTerm  --  turn-key installer
REM  ------------------------------------------------------------
REM  WezTerm is a GPU-accelerated cross-platform terminal emulator
REM  AND multiplexer, written in Rust. Unlike Herdr/Zellij it is a
REM  full terminal in its own right: tabs, split panes (its own
REM  multiplexer, no tmux needed), a background 'mux server' that
REM  keeps panes alive for detach/attach, and a Lua config + 'wezterm
REM  cli' for scripting panes. Great for running several AI coding
REM  agents in split panes inside one GPU-fast window.
REM  See https://wezterm.org/ and https://wezterm.org/multiplexing.html.
REM
REM  Install method: winget (official package 'wez.wezterm').
REM    winget install -e --id wez.wezterm
REM  winget adds WezTerm to the PATH; this shell is refreshed below
REM  so 'wezterm -V' resolves immediately.
REM ============================================================

echo.
echo Installing WezTerm via winget (wez.wezterm)...
echo.

where winget >nul 2>nul
if errorlevel 1 (
    echo ERROR: winget was not found. WezTerm is distributed through the
    echo Windows Package Manager. Install "App Installer" from the
    echo Microsoft Store (which provides winget), then re-run this script.
    echo Alternatively grab the installer from https://wezterm.org/install/windows.html
    goto :failed
)

winget install -e --id wez.wezterm --accept-source-agreements --accept-package-agreements
set "RC=%ERRORLEVEL%"
REM  winget returns a non-zero "no applicable upgrade / already installed"
REM  code in some cases; treat an already-present wezterm as success.
if not "%RC%"=="0" (
    where wezterm >nul 2>nul
    if errorlevel 1 goto :failed
)

REM  Refresh this shell's PATH from the machine + user registry so
REM  'wezterm' resolves without opening a new terminal.
call :refresh_path

echo.
where wezterm >nul 2>nul
if errorlevel 1 (
    echo WezTerm installed, but 'wezterm' is not yet on PATH for this
    echo shell. Open a new terminal and run 'wezterm -V' to verify.
) else (
    echo WezTerm installed. Reported version:
    call wezterm -V
)

echo.
echo Done. Launch it with WezTerm--run.cmd, or run 'wezterm' directly.
echo Split panes with the default keys (Ctrl+Shift+Alt+" / %%) and run
echo one agent per pane; the mux server keeps them alive across detach.
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
