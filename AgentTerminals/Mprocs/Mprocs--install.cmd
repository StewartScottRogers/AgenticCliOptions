@echo off
setlocal

REM ============================================================
REM  Install mprocs  --  turn-key installer
REM  ------------------------------------------------------------
REM  mprocs is a small TUI that runs multiple long-lived commands
REM  in parallel, each in its own pane, and lets you interact with
REM  any of them (you can even run vim/an agent inside a pane).
REM  You list the commands in an mprocs.yaml and 'mprocs' starts
REM  them all at once with keyboard-driven pane switching - a
REM  lightweight, declarative way to bring up a fixed set of AI
REM  coding agents together.
REM  See https://github.com/pvolok/mprocs.
REM
REM  Install method: download the official prebuilt Windows binary
REM  from the latest GitHub release and drop it on the User PATH.
REM    * queries https://api.github.com/repos/pvolok/mprocs/releases/latest
REM    * downloads asset  mprocs-<ver>-windows-x86_64.zip
REM    * extracts mprocs.exe into
REM      %LOCALAPPDATA%\Programs\mprocs\bin
REM    * adds that bin dir to the User PATH (persisted) and to this
REM      shell's PATH so 'mprocs --version' resolves immediately.
REM
REM  No Rust toolchain needed (prebuilt binary, not 'cargo install').
REM  Re-running is safe: it re-fetches the current latest build.
REM ============================================================

set "MP_DIR=%LOCALAPPDATA%\Programs\mprocs\bin"
set "MP_BIN=%MP_DIR%\mprocs.exe"

echo.
echo Installing mprocs from the latest GitHub release into:
echo     %MP_DIR%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; $dir=Join-Path $env:LOCALAPPDATA 'Programs\mprocs\bin'; New-Item -ItemType Directory -Force -Path $dir | Out-Null; $rel=Invoke-RestMethod 'https://api.github.com/repos/pvolok/mprocs/releases/latest' -Headers @{'User-Agent'='AgentTerminals'}; $asset=$rel.assets | Where-Object { $_.name -like '*windows-x86_64.zip' } | Select-Object -First 1; if(-not $asset){ throw 'A Windows x86_64 asset was not found in the latest release.' }; $tmp=Join-Path $env:TEMP $asset.name; Invoke-WebRequest $asset.browser_download_url -OutFile $tmp; Expand-Archive -Path $tmp -DestinationPath $dir -Force; Remove-Item $tmp -Force; $exe=Get-ChildItem -Path $dir -Filter 'mprocs.exe' -Recurse | Select-Object -First 1; if(-not $exe){ throw 'mprocs.exe was not present in the downloaded archive.' }; if($exe.DirectoryName -ne $dir){ Move-Item $exe.FullName (Join-Path $dir 'mprocs.exe') -Force }; $p=[Environment]::GetEnvironmentVariable('Path','User'); if(-not $p){ $p='' }; if(($p -split ';') -notcontains $dir){ [Environment]::SetEnvironmentVariable('Path', ($p.TrimEnd(';')+';'+$dir), 'User'); Write-Host ('Added ' + $dir + ' to the User PATH.') }; Write-Host ('Installed ' + $rel.tag_name + '.')"
if errorlevel 1 goto :failed

REM  Make 'mprocs' resolve in THIS already-open shell too.
call :prepend_path "%MP_DIR%"

echo.
where mprocs >nul 2>nul
if errorlevel 1 (
    if exist "%MP_BIN%" (
        echo mprocs installed at:
        echo     %MP_BIN%
        echo NOTE: 'mprocs' is not yet on PATH for this shell. Open a new
        echo terminal and run 'mprocs --version' to verify.
    ) else (
        echo ERROR: Install reported success but mprocs.exe was not
        echo found at %MP_BIN%. See the output above.
        goto :failed
    )
) else (
    echo mprocs installed. Reported version:
    call mprocs --version
)

echo.
echo Done. Launch it with Mprocs--run.cmd, or run 'mprocs' directly.
echo Put an mprocs.yaml (one entry per agent) in your project and
echo 'mprocs' will bring them all up in parallel panes.
goto :end


REM ============================================================
REM  Helper routines
REM ============================================================

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
echo   - Non-x64 platform (only the x86_64 Windows build is published)

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
