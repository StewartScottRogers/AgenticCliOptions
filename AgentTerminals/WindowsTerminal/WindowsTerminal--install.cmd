@echo off
setlocal

REM ============================================================
REM  Install Windows Terminal  --  turn-key installer
REM  ------------------------------------------------------------
REM  Windows Terminal is Microsoft's native terminal: tabs plus
REM  split panes, GPU text rendering, and profiles for cmd,
REM  PowerShell, pwsh, WSL, etc. You can tile several AI coding
REM  agents in panes within one tab. It has no detach/session-
REM  persist (close the window and the panes are gone) - it is the
REM  simplest, most ubiquitous option here, and ships on most
REM  Windows 11 machines already.
REM  See https://github.com/microsoft/terminal.
REM
REM  Install method: winget (official package 'Microsoft.WindowsTerminal').
REM      winget install -e --id Microsoft.WindowsTerminal
REM  (On most Windows 11 systems it is already present - this is a
REM  no-op / repair in that case.)
REM ============================================================

echo.
echo Installing Windows Terminal via winget (Microsoft.WindowsTerminal)...
echo.

where winget >nul 2>nul
if errorlevel 1 (
    echo ERROR: winget was not found. Windows Terminal is distributed via
    echo the Windows Package Manager / Microsoft Store. Install "App
    echo Installer" from the Store [which provides winget], or install
    echo Windows Terminal directly from the Store, then re-run this script.
    goto :failed
)

REM  Already present? (common on Win11) Treat as success.
where wt >nul 2>nul
if not errorlevel 1 (
    echo Windows Terminal is already installed ^(wt is on PATH^).
    goto :done
)

winget install -e --id Microsoft.WindowsTerminal --accept-source-agreements --accept-package-agreements
set "RC=%ERRORLEVEL%"
if not "%RC%"=="0" (
    where wt >nul 2>nul
    if errorlevel 1 (
        winget list -e --id Microsoft.WindowsTerminal >nul 2>nul
        if errorlevel 1 goto :failed
    )
)

:done
echo.
echo Done. Launch it with WindowsTerminal--run.cmd, or run 'wt'.
echo Split panes with Alt+Shift+Plus (right) / Alt+Shift+Minus (down)
echo and run one agent per pane.
goto :end


:failed
echo.
echo ERROR: Installation failed - see the output above.
echo Common causes:
echo   - winget not installed (install "App Installer" from the Store)
echo   - No internet connection / winget source unavailable
echo   - Older Windows without Store access (grab the MSIX from
echo     https://github.com/microsoft/terminal/releases)

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
