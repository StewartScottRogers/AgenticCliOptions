@echo off
setlocal

REM ============================================================
REM  Install / update Mistral Vibe (CLI coding agent)
REM  ------------------------------------------------------------
REM  Mistral Vibe is a Python package (command: 'vibe'). This
REM  script installs it with uv if available, otherwise pip.
REM  Re-running updates an existing install.
REM
REM  Requires Python 3.12 or newer - https://python.org
REM  uv (https://docs.astral.sh/uv) is the recommended installer.
REM ============================================================

where uv >nul 2>nul
if not errorlevel 1 (
    echo Installing Mistral Vibe with uv...
    echo     uv tool install --upgrade mistral-vibe
    echo.
    call uv tool install --upgrade mistral-vibe
    if errorlevel 1 goto :failed
    goto :done
)

where pip >nul 2>nul
if errorlevel 1 goto :nopy

echo 'uv' not found - installing Mistral Vibe with pip...
echo     pip install --upgrade mistral-vibe
echo.
call pip install --upgrade mistral-vibe
if errorlevel 1 goto :failed

:done
echo.
echo Mistral Vibe installed. Reported version:
call vibe --version
echo.
echo Done. Launch it with Mistral--run.cmd, or run 'vibe' directly.
goto :end

:nopy
echo ERROR: Neither 'uv' nor 'pip' was found on your PATH.
echo Install Python 3.12 or newer first, then re-run this script:
echo.
echo     https://python.org
goto :end

:failed
echo.
echo ERROR: Installation failed - see the output above.

:end
echo.
pause
endlocal
