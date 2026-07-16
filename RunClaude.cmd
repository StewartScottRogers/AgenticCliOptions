@echo off
setlocal EnableDelayedExpansion
pushd "%~dp0"

REM ============================================================
REM  RunClaude  --  launch Claude Code, inside herdr if available
REM  ------------------------------------------------------------
REM  If the herdr terminal multiplexer is installed, Claude is
REM  launched as a tracked agent pane INSIDE herdr (so it shows up
REM  in the sidebar with blocked/working/done/idle state and
REM  survives detach). Otherwise Claude is launched normally.
REM
REM    herdr not installed              -> plain 'claude'
REM    herdr installed + server running -> inject into the herd,
REM                                        then attach this console
REM    herdr installed + no server yet  -> start a herdr session,
REM                                        inject, else plain 'claude'
REM
REM  See AgentTerminals\Herdr\ for herdr's own install/run scripts.
REM ============================================================

set "CLAUDE_ARGS=--dangerously-skip-permissions --verbose"

REM ---- Locate herdr: PATH first, then its known install dir ----
set "HERDR="
where herdr >nul 2>nul && set "HERDR=herdr"
if not defined HERDR if exist "%LOCALAPPDATA%\Programs\Herdr\bin\herdr.exe" set "HERDR=%LOCALAPPDATA%\Programs\Herdr\bin\herdr.exe"

if not defined HERDR goto :plain

REM ---- Is a herdr server already running? ----
"%HERDR%" status server 2>nul | findstr /I /C:"status: running" >nul
if not errorlevel 1 goto :inject

REM ---- No server: open a herdr session in a new window, then wait
REM      for the server + a workspace to come up so we can inject. ----
echo No herdr server running - starting a herdr session...
start "herdr" "%HERDR%"
set "STARTED_HERDR=1"
for /l %%i in (1,1,20) do (
    "%HERDR%" status server 2>nul | findstr /I /C:"status: running" >nul
    if not errorlevel 1 (
        REM  Server is up; make sure a workspace/pane exists to host
        REM  the injected pane before we try to start the agent.
        "%HERDR%" pane list 2>nul | findstr /I /C:"pane_id" >nul
        if not errorlevel 1 goto :inject
    )
    timeout /t 1 /nobreak >nul 2>&1
)
echo herdr did not become ready in time - launching Claude normally.
goto :plain

REM ---- Inject Claude as a tracked agent pane in the live herd ----
:inject
echo Launching Claude inside herdr (tracked as agent "Claude")...
"%HERDR%" agent start Claude --focus --cwd "%~dp0" -- cmd /c claude %CLAUDE_ARGS%
if errorlevel 1 (
    echo herdr could not start the Claude pane - launching normally.
    goto :plain
)
if defined STARTED_HERDR (
    REM  We opened a fresh herdr window; Claude is now running there.
    echo Claude is running in the new herdr window - switch to it.
    goto :done
)
REM  A server was already running: attach this console to the herd so
REM  you land on the Claude pane. Detach with the herdr prefix + d.
echo Attaching to the herd (detach with Ctrl+B then d)...
"%HERDR%"
goto :done

REM ---- Fallback: launch Claude directly ----
:plain
call claude %CLAUDE_ARGS%

:done
popd
endlocal
