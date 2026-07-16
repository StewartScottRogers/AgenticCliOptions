@echo off
REM ============================================================
REM  _hrdr-launch  --  shared herdr plumbing for terminal+agent pairs
REM  ------------------------------------------------------------
REM  Runs a coding agent INSIDE the herdr multiplexer as a tracked
REM  pane, so it shows up in herdr's sidebar with blocked/working/
REM  done/idle state and survives detach. This is the common engine
REM  behind the hrdr<Agent><Backend>.cmd pair launchers.
REM
REM  The caller sets these variables, then  call  s this script:
REM    HP_LABEL        agent label shown in herdr (e.g. Claude)   [required]
REM    HP_CMD          command line to run in the pane            [required]
REM                    e.g.  cmd /c "...\Claude--run.cmd"
REM    HP_CWD          pane working directory  [optional; default repo root]
REM    HP_ENV          pre-formatted --env K=V tokens             [optional]
REM    HP_INTEGRATION  herdr integration to ensure installed      [optional]
REM                    (e.g. claude -> installs the state hook)
REM
REM  herdr is REQUIRED here (these are herdr pairings) - there is no
REM  plain fallback; that is what the standalone CodingAgents
REM  launchers are for. Behaviour:
REM    server running -> inject the pane + attach this console
REM    no server yet  -> open a herdr session, wait, then inject
REM ============================================================
setlocal EnableDelayedExpansion

if not defined HP_LABEL set "HP_LABEL=agent"
if not defined HP_CMD (
    echo _hrdr-launch: HP_CMD is not set - nothing to run.
    goto :fail
)
if not defined HP_CWD set "HP_CWD=%~dp0.."
for %%I in ("%HP_CWD%") do set "HP_CWD=%%~fI"

REM ---- Locate herdr: PATH first, then its known install dir ----
set "HERDR="
where herdr >nul 2>nul && set "HERDR=herdr"
if not defined HERDR if exist "%LOCALAPPDATA%\Programs\Herdr\bin\herdr.exe" set "HERDR=%LOCALAPPDATA%\Programs\Herdr\bin\herdr.exe"
if not defined HERDR (
    echo herdr is not installed. This pairing runs %HP_LABEL% INSIDE herdr.
    echo Install it first:
    echo     "%~dp0..\AgentTerminals\Herdr\Herdr--install.cmd"
    goto :fail
)

REM ---- Ensure herdr's native integration for accurate state ----
REM  'integration status' prints one line per agent, e.g.
REM     claude: not installed (...path...)      <- absent
REM     claude: current (v7) (...path...)       <- installed
REM  So we (re)install only when the line says "not installed";
REM  an already-installed hook is left alone (no reinstall churn).
if defined HP_INTEGRATION (
    "%HERDR%" integration status 2>nul | findstr /I /C:"%HP_INTEGRATION%: not installed" >nul
    if not errorlevel 1 (
        echo Installing herdr native integration: %HP_INTEGRATION% ...
        "%HERDR%" integration install %HP_INTEGRATION%
    )
)

REM ---- Ensure a herdr server + a workspace to host the pane ----
"%HERDR%" status server 2>nul | findstr /I /C:"status: running" >nul
if not errorlevel 1 goto :ready
echo No herdr server running - starting a herdr session...
start "herdr" "%HERDR%"
set "STARTED_HERDR=1"
for /l %%i in (1,1,20) do (
    "%HERDR%" status server 2>nul | findstr /I /C:"status: running" >nul
    if not errorlevel 1 (
        "%HERDR%" pane list 2>nul | findstr /I /C:"pane_id" >nul
        if not errorlevel 1 goto :ready
    )
    timeout /t 1 /nobreak >nul 2>&1
)
echo ERROR: herdr did not become ready in time.
goto :fail

REM ---- Pick a free agent name -----------------------------------
REM  herdr requires agent names to be unique: 'agent start' fails
REM  with agent_name_taken if one is already running (e.g. you ran
REM  this pair before, or launched a different backend). Probe with
REM  'agent get' (exit 0 = taken) and add a numeric suffix until a
REM  free name is found, so the launcher is always re-runnable.
:ready
set "HP_NAME=%HP_LABEL%"
set "N=1"
:namecheck
"%HERDR%" agent get "!HP_NAME!" >nul 2>nul
if not errorlevel 1 (
    set /a N+=1
    set "HP_NAME=%HP_LABEL% !N!"
    goto :namecheck
)

REM ---- Inject the agent as a tracked pane, then attach ----
:inject
echo Launching !HP_NAME! inside herdr...
"%HERDR%" agent start "!HP_NAME!" --focus --cwd "%HP_CWD%" %HP_ENV% -- %HP_CMD%
if errorlevel 1 (
    echo ERROR: herdr could not start the !HP_NAME! pane.
    goto :fail
)
if defined STARTED_HERDR (
    echo !HP_NAME! is running in the new herdr window - switch to it.
    goto :ok
)
echo Attaching to the herd ^(detach with the herdr prefix, Ctrl+B then d^)...
"%HERDR%"
goto :ok

:fail
endlocal
exit /b 1

:ok
endlocal
exit /b 0
