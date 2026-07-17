@echo off
setlocal

REM ============================================================
REM  Install psmux  --  turn-key installer
REM  ------------------------------------------------------------
REM  psmux is a NATIVE-Windows tmux, built from scratch in Rust. It
REM  drives Windows ConPTY directly, speaks the tmux command
REM  language, reads your .tmux.conf, and supports tmux themes -
REM  "stop using WSL just for tmux." Split panes to parallelize
REM  several AI coding agents in one console, no WSL/Cygwin/MSYS2.
REM  See https://github.com/psmux/psmux.
REM
REM  Install method: download the official prebuilt Windows binary
REM  from the latest GitHub release and drop it on the User PATH.
REM    * queries https://api.github.com/repos/psmux/psmux/releases/latest
REM    * downloads asset  psmux-<ver>-windows-x64.zip
REM    * extracts psmux.exe (+ pmux.exe and a tmux.exe compat alias)
REM      into %LOCALAPPDATA%\Programs\psmux\bin
REM    * adds that bin dir to the User PATH (persisted) and to this
REM      shell's PATH so 'psmux --version' resolves immediately.
REM
REM  No Rust toolchain needed (prebuilt binary, not 'cargo install').
REM  NOTE: the bundled tmux.exe is a psmux compat alias - it will
REM  shadow any other 'tmux' on PATH from this dir.
REM ============================================================

set "PS_DIR=%LOCALAPPDATA%\Programs\psmux\bin"
set "PS_BIN=%PS_DIR%\psmux.exe"

echo.
echo Installing psmux from the latest GitHub release into:
echo     %PS_DIR%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; $dir=Join-Path $env:LOCALAPPDATA 'Programs\psmux\bin'; New-Item -ItemType Directory -Force -Path $dir | Out-Null; $rel=Invoke-RestMethod 'https://api.github.com/repos/psmux/psmux/releases/latest' -Headers @{'User-Agent'='AgentTerminals'}; $asset=$rel.assets | Where-Object { $_.name -like '*windows-x64.zip' } | Select-Object -First 1; if(-not $asset){ throw 'A Windows x64 asset was not found in the latest release.' }; $tmp=Join-Path $env:TEMP $asset.name; Invoke-WebRequest $asset.browser_download_url -OutFile $tmp; Expand-Archive -Path $tmp -DestinationPath $dir -Force; Remove-Item $tmp -Force; $exe=Get-ChildItem -Path $dir -Filter 'psmux.exe' -Recurse | Select-Object -First 1; if(-not $exe){ throw 'psmux.exe was not present in the downloaded archive.' }; if($exe.DirectoryName -ne $dir){ Get-ChildItem -Path $exe.DirectoryName -Filter '*.exe' | ForEach-Object { Move-Item $_.FullName (Join-Path $dir $_.Name) -Force } }; $p=[Environment]::GetEnvironmentVariable('Path','User'); if(-not $p){ $p='' }; if(($p -split ';') -notcontains $dir){ [Environment]::SetEnvironmentVariable('Path', ($p.TrimEnd(';')+';'+$dir), 'User'); Write-Host ('Added ' + $dir + ' to the User PATH.') }; Write-Host ('Installed ' + $rel.tag_name + '.')"
if errorlevel 1 goto :failed

call :prepend_path "%PS_DIR%"

echo.
where psmux >nul 2>nul
if errorlevel 1 (
    if exist "%PS_BIN%" (
        echo psmux installed at:
        echo     %PS_BIN%
        echo NOTE: 'psmux' is not yet on PATH for this shell. Open a new
        echo terminal and run 'psmux --version' to verify.
    ) else (
        echo ERROR: Install reported success but psmux.exe was not
        echo found at %PS_BIN%. See the output above.
        goto :failed
    )
) else (
    echo psmux installed. Reported version:
    call psmux --version
)

echo.
echo Done. Launch it with Psmux--run.cmd, or run 'psmux' directly.
echo It reads your %%USERPROFILE%%\.tmux.conf if present; split panes
echo with the usual tmux prefix (Ctrl+B) and run one agent per pane.
goto :end


:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0


:failed
echo.
echo ERROR: Installation failed - see the output above.
echo Common causes:
echo   - No internet connection / GitHub API rate-limited
echo   - PowerShell execution policy blocked the download
echo   - Antivirus quarantined the extracted binary
echo   - Non-x64 platform (this script pulls the windows-x64 build)

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
