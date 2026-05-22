@echo off
setlocal

REM ============================================================
REM  Install xAI Grok Build (CLI coding agent)
REM  ------------------------------------------------------------
REM  Grok Build is in early beta (SuperGrok Heavy). The official
REM  installer is a shell script:
REM
REM      curl -fsSL https://x.ai/cli/install.sh ^| bash
REM
REM  That needs a bash shell. On Windows this script runs it via
REM  Git Bash or WSL if 'bash' is on PATH; otherwise it falls
REM  back to the npm package.
REM
REM  Grok Build is beta software - verify the current install
REM  steps at https://x.ai/cli
REM ============================================================

where bash >nul 2>nul
if not errorlevel 1 (
    echo Installing Grok Build via the official installer...
    echo     curl -fsSL https://x.ai/cli/install.sh ^| bash
    echo.
    call bash -lc "curl -fsSL https://x.ai/cli/install.sh | bash"
    if errorlevel 1 goto :failed
    goto :done
)

where npm >nul 2>nul
if errorlevel 1 goto :notools

echo 'bash' not found - falling back to the npm package...
echo     npm install -g grok-build@latest
echo.
call npm install -g grok-build@latest
if errorlevel 1 goto :failed

:done
echo.
echo Grok Build install step finished. Launch it with Grok--run.cmd,
echo or run 'grok' directly. If 'grok' is not found, open a new
echo terminal so PATH changes take effect.
goto :end

:notools
echo ERROR: Neither 'bash' nor 'npm' was found on your PATH.
echo Install Git for Windows (provides bash) or Node.js, or run
echo the official installer inside WSL:
echo.
echo     curl -fsSL https://x.ai/cli/install.sh ^| bash
goto :end

:failed
echo.
echo ERROR: Installation failed - see the output above.
echo Grok Build is beta software; check https://x.ai/cli for the
echo current install instructions.

:end
echo.
pause
endlocal
