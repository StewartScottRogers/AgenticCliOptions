@echo off
setlocal

REM ============================================================
REM  Update psmux  --  in-place upgrade to the latest release
REM  ------------------------------------------------------------
REM  psmux has no built-in self-updater, so this re-fetches the
REM  latest prebuilt Windows binary from GitHub (the same path the
REM  installer uses) but only when the published tag differs from
REM  the version already on disk. If they match, it is a no-op.
REM ============================================================

set "PS_DIR=%LOCALAPPDATA%\Programs\psmux\bin"
set "PS_BIN=%PS_DIR%\psmux.exe"

if not exist "%PS_BIN%" (
    where psmux >nul 2>nul
    if errorlevel 1 (
        echo psmux is not installed - nothing to update.
        echo Run Psmux--install.cmd first.
        goto :end
    )
)

set "PATH=%PS_DIR%;%PATH%"
echo.
echo Current version:
call psmux --version
echo.
echo Checking GitHub for a newer release...
echo.

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ErrorActionPreference='Stop'; $ProgressPreference='SilentlyContinue'; $dir=Join-Path $env:LOCALAPPDATA 'Programs\psmux\bin'; $bin=Join-Path $dir 'psmux.exe'; $cur=''; if(Test-Path $bin){ try{ $cur=((& $bin --version) -replace '[^0-9\.]','') }catch{} }; $rel=Invoke-RestMethod 'https://api.github.com/repos/psmux/psmux/releases/latest' -Headers @{'User-Agent'='AgentTerminals'}; $tag=$rel.tag_name -replace '[^0-9\.]',''; if($cur -and ($cur -eq $tag)){ Write-Host ('Already on the latest release (' + $rel.tag_name + '). Nothing to do.'); exit 0 }; Write-Host ('Updating ' + $cur + ' -> ' + $rel.tag_name + ' ...'); $asset=$rel.assets | Where-Object { $_.name -like '*windows-x64.zip' } | Select-Object -First 1; if(-not $asset){ throw 'A Windows x64 asset was not found in the latest release.' }; $tmp=Join-Path $env:TEMP $asset.name; Invoke-WebRequest $asset.browser_download_url -OutFile $tmp; Expand-Archive -Path $tmp -DestinationPath $dir -Force; Remove-Item $tmp -Force; $exe=Get-ChildItem -Path $dir -Filter 'psmux.exe' -Recurse | Select-Object -First 1; if($exe -and ($exe.DirectoryName -ne $dir)){ Get-ChildItem -Path $exe.DirectoryName -Filter '*.exe' | ForEach-Object { Move-Item $_.FullName (Join-Path $dir $_.Name) -Force } }; Write-Host 'Update complete.'"
if errorlevel 1 (
    echo.
    echo ERROR: Update failed - see the output above.
    goto :end
)

echo.
echo Now reporting:
call psmux --version

:end
echo.
if not defined AGENTS_UPDATE_ALL pause
endlocal
