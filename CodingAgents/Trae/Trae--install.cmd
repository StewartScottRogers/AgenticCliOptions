@echo off
setlocal

REM ============================================================
REM  Install / update Trae Agent (ByteDance CLI coding agent)
REM  ------------------------------------------------------------
REM  Trae Agent is a Python tool (command: 'trae-cli'). This
REM  script installs it with uv if available, otherwise pip.
REM
REM  Requires Python 3.12 or newer - https://python.org
REM
REM  If the package install fails, install from source instead:
REM      git clone https://github.com/bytedance/trae-agent.git
REM      cd trae-agent
REM      uv sync --all-extras
REM ============================================================

where uv >nul 2>nul
if not errorlevel 1 (
    echo Installing Trae Agent with uv...
    echo     uv tool install --upgrade trae-agent
    echo.
    call uv tool install --upgrade trae-agent
    if errorlevel 1 goto :failed
    goto :done
)

where pip >nul 2>nul
if errorlevel 1 goto :nopy

echo 'uv' not found - installing Trae Agent with pip...
echo     pip install --upgrade trae-agent
echo.
call pip install --upgrade trae-agent
if errorlevel 1 goto :failed

:done
echo.
echo Trae Agent installed. Reported version:
call trae-cli --version
echo.
echo Done. Launch it with Trae--openrouter.cmd or
echo Trae--settings-lmstudio.cmd.
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
echo If the 'trae-agent' package cannot be found, install from
echo source - see the note at the top of this script.

:end
echo.
pause
endlocal
