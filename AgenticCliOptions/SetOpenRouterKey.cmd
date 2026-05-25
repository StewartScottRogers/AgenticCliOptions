@echo off
setlocal

REM ============================================================
REM  Set the OpenRouter API key (one key for every launcher)
REM  ------------------------------------------------------------
REM  Prompts for your OpenRouter API key, verifies it against
REM  the OpenRouter API, then stores it permanently in the
REM  OPENROUTER_API_KEY environment variable using 'setx'.
REM
REM  Every *--openrouter.cmd launcher in this project reads that
REM  single variable - Claude, Codex, Mistral, Qwen and Trae.
REM  Run this script once and they all work.
REM
REM  Get a key at https://openrouter.ai/keys
REM
REM  NOTE: the key is shown on screen as you paste it. Close this
REM  window when finished if that is a concern.
REM ============================================================

echo.
echo  This stores your OpenRouter API key in the OPENROUTER_API_KEY
echo  environment variable (persists for new terminals). It is
echo  shared by every --openrouter.cmd launcher in this project.
echo.

if not defined OPENROUTER_API_KEY goto :ask
echo  An OPENROUTER_API_KEY is already set.
set "REPLACE="
set /p "REPLACE=Replace it? [y/N]: "
if /i "%REPLACE%"=="y" goto :ask
goto :cancel

:ask
echo.
set "KEY="
set /p "KEY=Paste your OpenRouter API key (sk-or-...): "

REM  Strip surrounding double quotes if the user pasted them.
if defined KEY set "KEY=%KEY:"=%"
if not defined KEY goto :empty

REM  Quick sanity check - OpenRouter keys start with "sk-or-".
echo %KEY% | findstr /b /c:"sk-or-" >nul
if not errorlevel 1 goto :test
echo.
echo  WARNING: that does not look like an OpenRouter key
echo  (they normally start with "sk-or-").
set "ANYWAY="
set /p "ANYWAY=Continue anyway? [y/N]: "
if /i not "%ANYWAY%"=="y" goto :cancel

:test
echo.
where curl >nul 2>nul
if errorlevel 1 goto :nocurl

echo  Verifying the key with OpenRouter...
set "HTTP="
for /f "delims=" %%H in ('curl -s --max-time 20 -o nul -w "%%{http_code}" -H "Authorization: Bearer %KEY%" https://openrouter.ai/api/v1/key') do set "HTTP=%%H"

if "%HTTP%"=="200" goto :valid
if "%HTTP%"=="401" goto :unauth

echo  Could not verify the key (HTTP "%HTTP%" - network problem?).
set "ANYWAY="
set /p "ANYWAY=Save it anyway? [y/N]: "
if /i not "%ANYWAY%"=="y" goto :cancel
goto :save

:valid
echo  OK - the key is valid. OpenRouter reports:
echo.
curl -s --max-time 20 -H "Authorization: Bearer %KEY%" https://openrouter.ai/api/v1/key
echo.
echo.
goto :save

:unauth
echo  ERROR: OpenRouter rejected the key (HTTP 401 - unauthorized).
echo  Check that you copied the whole key with no spaces missing.
set "ANYWAY="
set /p "ANYWAY=Save it anyway? [y/N]: "
if /i not "%ANYWAY%"=="y" goto :cancel
goto :save

:nocurl
echo  NOTE: 'curl' was not found, so the key cannot be tested.
echo  It will be saved without verification.

:save
echo.
setx OPENROUTER_API_KEY "%KEY%" >nul
if errorlevel 1 goto :savefail
echo  Saved. OPENROUTER_API_KEY is stored permanently.
echo.
echo  Open a NEW terminal for it to take effect, then run any of
echo  the --openrouter.cmd launchers (Claude, Codex, Mistral,
echo  Qwen, Trae).
goto :end

:savefail
echo  ERROR: 'setx' failed - the key was NOT saved.
goto :end

:empty
echo  No key entered - nothing was changed.
goto :end

:cancel
echo.
echo  Cancelled - nothing was changed.
goto :end

:end
echo.
pause
endlocal
