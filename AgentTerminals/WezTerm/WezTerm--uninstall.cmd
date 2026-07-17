@echo off
setlocal

REM ============================================================
REM  Uninstall WezTerm  --  matching uninstaller
REM  ------------------------------------------------------------
REM  Removes the winget package 'wez.wezterm' (which also removes
REM  its PATH entry). Any running WezTerm windows / mux server are
REM  stopped first so files aren't locked.
REM
REM  Your config is LEFT IN PLACE - WezTerm reads a Lua config from
REM  one of:
REM      %USERPROFILE%\.wezterm.lua
REM      %USERPROFILE%\.config\wezterm\wezterm.lua
REM  Delete those by hand if you want a fully clean slate.
REM ============================================================

REM  Stop the GUI + background mux server so nothing is locked.
taskkill /F /IM wezterm-gui.exe >nul 2>nul
taskkill /F /IM wezterm.exe     >nul 2>nul
taskkill /F /IM wezterm-mux-server.exe >nul 2>nul

where winget >nul 2>nul
if errorlevel 1 (
    echo winget was not found. If WezTerm was installed some other way,
    echo remove it via Settings ^> Apps, then delete its config by hand.
    goto :end
)

winget list -e --id wez.wezterm >nul 2>nul
if errorlevel 1 (
    echo WezTerm (wez.wezterm) is not installed via winget.
    echo Nothing to remove.
    goto :verify
)

echo.
echo Removing WezTerm via winget...
echo.
winget uninstall -e --id wez.wezterm
if errorlevel 1 (
    echo.
    echo ERROR: winget uninstall reported a problem - see above. If a
    echo WezTerm window is still open, close it and re-run this script.
    goto :end
)

:verify
echo.
where wezterm >nul 2>nul
if errorlevel 1 (
    echo WezTerm removed.
) else (
    echo NOTE: 'wezterm' is still resolvable on PATH - it may be a second
    echo copy installed outside winget. Run 'where wezterm' to check.
)
echo.
echo Done. Your WezTerm Lua config was NOT touched - delete
echo %%USERPROFILE%%\.wezterm.lua (or .config\wezterm\) for a clean slate.

:end
echo.
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
