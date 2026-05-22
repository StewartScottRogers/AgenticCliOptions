@echo off
setlocal
set "ORIG_DIR=%CD%"
pushd "%~dp0"
for /f "delims=" %%i in ('powershell -command "(Invoke-RestMethod http://192.168.12.174:1234/v1/models).data[0].id"') do set LMSTUDIO_MODEL=%%i
if "%LMSTUDIO_MODEL%"=="" (
    echo ERROR: Could not detect LMStudio model. Is LMStudio running with a model loaded?
    pause
    goto :end
)
echo Connecting to LMStudio model: %LMSTUDIO_MODEL%
call claude --verbose --dangerously-skip-permissions --settings LMStudio.Settings.json --model %LMSTUDIO_MODEL%
:end
popd
endlocal
