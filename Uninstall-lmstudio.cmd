@echo off
setlocal

REM ============================================================
REM  Uninstall LM Studio helper
REM  ------------------------------------------------------------
REM  This script does not uninstall the LM Studio application
REM  (which is OS-specific). It offers guidance to stop the local
REM  server and remove per-user config or cache directories that
REM  some LM Studio installs may create.
REM ============================================================

if not defined LMSTUDIO_URL  set "LMSTUDIO_URL=http://192.168.12.174:1234"

echo.
echo This helper will attempt to contact the LM Studio local
echo server at %LMSTUDIO_URL% and, if reachable, ask you to stop
echo the server from the LM Studio app. It can also suggest files
echo and directories you may safely remove to reclaim space.

echo.
echo Checking for LM Studio local server at %LMSTUDIO_URL% ...
set "LMSTUDIO_MODEL="
for /f "delims=" %%i in ('powershell -command "try { (Invoke-RestMethod '%LMSTUDIO_URL%/v1/models').data[0].id } catch { '' }"') do set "LMSTUDIO_MODEL=%%i"

if defined LMSTUDIO_MODEL (
	echo.
	echo LM Studio local server detected. Model loaded: %LMSTUDIO_MODEL%
	echo Please stop the local server from LM Studio's Developer tab,
	echo or quit the LM Studio application before removing files.
) else (
	echo.
	echo No LM Studio local server was detected at %LMSTUDIO_URL%.
)

echo.
echo The following locations are common per-user data folders. Remove
echo them only if you want to delete saved sessions, caches, or settings:
echo.
echo  - %USERPROFILE%\AppData\Roaming\LMStudio
echo  - %USERPROFILE%\.lmstudio
echo  - %USERPROFILE%\.cache\lmstudio
echo.
choice /C YN /N /M "Delete these folders now? (Y deletes, N exits)"
if errorlevel 2 goto :end

echo Removing folders (if they exist)...
if exist "%USERPROFILE%\AppData\Roaming\LMStudio" (
	rmdir /s /q "%USERPROFILE%\AppData\Roaming\LMStudio"
	echo Deleted %USERPROFILE%\AppData\Roaming\LMStudio
)
if exist "%USERPROFILE%\.lmstudio" (
	rmdir /s /q "%USERPROFILE%\.lmstudio"
	echo Deleted %USERPROFILE%\.lmstudio
)
if exist "%USERPROFILE%\.cache\lmstudio" (
	rmdir /s /q "%USERPROFILE%\.cache\lmstudio"
	echo Deleted %USERPROFILE%\.cache\lmstudio
)

echo.
echo Done. If you want to fully uninstall the LM Studio application,
echo use the OS-specific application removal UI (Add/Remove Programs or
echo the equivalent on your platform).

:end
if not defined AGENTS_UNINSTALL_ALL pause
endlocal
