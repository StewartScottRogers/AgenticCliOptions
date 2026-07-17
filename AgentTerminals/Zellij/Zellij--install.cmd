@echo off
setlocal

REM ============================================================
REM  Install Zellij  --  turn-key installer
REM  ------------------------------------------------------------
REM  Zellij is a terminal workspace / multiplexer written in Rust
REM  - "a modern tmux". You run several AI coding agents in parallel
REM  panes (or tabs), with layouts, floating panes, session
REM  persistence, and a plugin system. As of 0.44.0 (Mar 2026) it
REM  runs NATIVELY on Windows (no WSL required).
REM  See https://zellij.dev/ and https://zellij.dev/documentation/.
REM
REM  Install method: download the official prebuilt Windows binary
REM  from the latest GitHub release and drop it on the User PATH.
REM    * queries https://api.github.com/repos/zellij-org/zellij/releases/latest
REM    * downloads asset  zellij-x86_64-pc-windows-msvc.zip
REM    * extracts zellij.exe into
REM      %LOCALAPPDATA%\Programs\Zellij\bin
REM    * adds that bin dir to the User PATH (persisted) and to this
REM      shell's PATH so 'zellij --version' resolves immediately.
REM
REM  No Rust toolchain needed (this uses the prebuilt binary, not
REM  'cargo install zellij'). x86_64 only; ARM64 runs it emulated.
REM
REM  Re-running is safe: it just re-fetches the current latest
REM  build and overwrites the binary. To upgrade later use
REM  Zellij--update.cmd (same fetch, but only when a newer tag ships).
REM ============================================================

set "ZJ_DIR=%LOCALAPPDATA%\Programs\Zellij\bin"
set "ZJ_BIN=%ZJ_DIR%\zellij.exe"

echo.
echo Installing Zellij (native Windows build) from the latest
echo GitHub release into:
echo     %ZJ_DIR%
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; $dir=Join-Path $env:LOCALAPPDATA 'Programs\Zellij\bin'; New-Item -ItemType Directory -Force -Path $dir | Out-Null; $rel=Invoke-RestMethod 'https://api.github.com/repos/zellij-org/zellij/releases/latest' -Headers @{'User-Agent'='AgentTerminals'}; $asset=$rel.assets | Where-Object { $_.name -eq 'zellij-x86_64-pc-windows-msvc.zip' } | Select-Object -First 1; if(-not $asset){ throw 'Windows asset zellij-x86_64-pc-windows-msvc.zip not found in the latest release.' }; $tmp=Join-Path $env:TEMP $asset.name; Invoke-WebRequest $asset.browser_download_url -OutFile $tmp; Expand-Archive -Path $tmp -DestinationPath $dir -Force; Remove-Item $tmp -Force; $exe=Get-ChildItem -Path $dir -Filter 'zellij.exe' -Recurse | Select-Object -First 1; if(-not $exe){ throw 'zellij.exe was not present in the downloaded archive.' }; if($exe.DirectoryName -ne $dir){ Move-Item $exe.FullName (Join-Path $dir 'zellij.exe') -Force }; $p=[Environment]::GetEnvironmentVariable('Path','User'); if(-not $p){ $p='' }; if(($p -split ';') -notcontains $dir){ [Environment]::SetEnvironmentVariable('Path', ($p.TrimEnd(';')+';'+$dir), 'User'); Write-Host ('Added ' + $dir + ' to the User PATH.') }; Write-Host ('Installed ' + $rel.tag_name + '.')"
if errorlevel 1 goto :failed

REM  Make 'zellij' resolve in THIS already-open shell too.
call :prepend_path "%ZJ_DIR%"

echo.
where zellij >nul 2>nul
if errorlevel 1 (
    if exist "%ZJ_BIN%" (
        echo Zellij installed at:
        echo     %ZJ_BIN%
        echo NOTE: 'zellij' is not yet on PATH for this shell. Open a new
        echo terminal and run 'zellij --version' to verify.
    ) else (
        echo ERROR: Install reported success but zellij.exe was not
        echo found at %ZJ_BIN%. See the output above.
        goto :failed
    )
) else (
    echo Zellij installed. Reported version:
    call zellij --version
)

echo.
echo Done. Launch it with Zellij--run.cmd, or run 'zellij' directly.
echo Start your agents inside separate panes/tabs and keep the
echo session alive with detach (Ctrl+O d) / re-attach.
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
echo   - Non-x64 platform (only the x86_64 Windows build is published;
echo     ARM64 must run it under emulation)

:end
echo.
if not defined AGENTS_INSTALL_ALL pause
endlocal
