@echo off
setlocal EnableDelayedExpansion

REM ============================================================
REM  Install-All  --  pick one, several, or every coding agent
REM  ------------------------------------------------------------
REM  Usage:
REM    Install-All.cmd                       interactive menu
REM    Install-All.cmd all                   install every agent
REM    Install-All.cmd Claude Codex Gemini   install just those
REM    Install-All.cmd /?                    show usage and exit
REM
REM  In every mode the script first installs shared dependencies
REM  (Node.js LTS, uv, Git) via winget if they are missing, then
REM  runs each selected agent's own turn-key install script.
REM
REM  Amazon Q is always processed LAST because setting up WSL for
REM  the first time can force a Windows reboot. After rebooting,
REM  re-run this script (every step is safe to re-run).
REM
REM  A UAC elevation prompt may appear while dependencies install.
REM ============================================================

set "ROOT=%~dp0"

REM  Child install scripts read this variable and skip their own
REM  final 'pause', so the whole run is unattended.
set "AGENTS_INSTALL_ALL=1"

REM  Master agent list. Order matters: AmazonQ kept last on purpose.
set "ALL_AGENTS=Claude Codex Gemini Antigravity Pi Qwen Grok Mistral Trae Hermes Codebuff Oh-My-Pi OpenSquilla Aider Junie VTCode Opencode AmazonQ"

REM ---- Parse command line ---------------------------------------
set "INTERACTIVE="
set "DRYRUN="
set "STATUS_ONLY="
set "SELECTED="

:parse_args
if "%~1"=="" goto :after_args
if /I "%~1"=="/?"        goto :usage
if /I "%~1"=="-h"        goto :usage
if /I "%~1"=="--help"    goto :usage
if /I "%~1"=="-n"        (set "DRYRUN=1" & shift & goto :parse_args)
if /I "%~1"=="--dry-run" (set "DRYRUN=1" & shift & goto :parse_args)
if /I "%~1"=="-s"        (set "STATUS_ONLY=1" & shift & goto :parse_args)
if /I "%~1"=="--status"  (set "STATUS_ONLY=1" & shift & goto :parse_args)
if /I "%~1"=="all" (
    set "SELECTED=%ALL_AGENTS%"
    shift
    goto :parse_args
)
if not exist "%ROOT%%~1\%~1--install.cmd" (
    echo ERROR: unknown agent "%~1"
    echo Run "%~nx0 /?" for the full list.
    exit /b 1
)
set "SELECTED=!SELECTED! %~1"
shift
goto :parse_args

:after_args
if defined STATUS_ONLY goto :show_status
if not defined SELECTED (
    set "INTERACTIVE=1"
    goto :menu
)
goto :reorder

REM ---- Usage screen ---------------------------------------------
:usage
echo Usage: %~nx0 [--status ^| --dry-run] [agent ...] ^| all ^| /?
echo.
echo Available agents (case-insensitive):
for %%A in (%ALL_AGENTS%) do echo   %%A
echo.
echo Examples:
echo   %~nx0                              interactive menu
echo   %~nx0 --status                     print install-status table and exit
echo   %~nx0 all                          install every agent
echo   %~nx0 Claude Codex Gemini          install just those three
echo   %~nx0 --dry-run Claude Codex       show the plan, install nothing
exit /b 0

REM ---- Interactive menu -----------------------------------------
:menu
cls
echo ============================================================
echo  Install coding agents  --  choose what to install
echo ============================================================
echo.

set "IDX=0"
set "SKIPPED="
for %%A in (%ALL_AGENTS%) do (
    call :is_installed %%A
    if errorlevel 1 (
        set /a IDX+=1
        set "AGENT_!IDX!=%%A"
    ) else (
        set "SKIPPED=!SKIPPED! %%A"
    )
)
set "TOTAL=!IDX!"

if !TOTAL! EQU 0 (
    echo    Every agent in the catalogue is already installed:
    echo     !SKIPPED!
    echo.
    echo      S^) show install status       U^) uninstall everything       Q^) quit
    echo      L^) install LM Studio         X^) uninstall LM Studio
    echo      P^) install a plugin          Y^) uninstall a plugin
    echo.
    set "INPUT="
    set /p "INPUT=   Your choice: "
    if /I "!INPUT!"=="S" goto :show_status
    if /I "!INPUT!"=="L" goto :install_lmstudio
    if /I "!INPUT!"=="X" goto :uninstall_lmstudio
    if /I "!INPUT!"=="P" goto :install_plugin
    if /I "!INPUT!"=="Y" goto :uninstall_plugin
    if /I "!INPUT!"=="U" goto :uninstall_all
    if /I "!INPUT!"=="Q" (endlocal & exit /b 0)
    goto :menu
)

set /a HALF=(TOTAL+1)/2

if defined SKIPPED (
    echo    Already installed ^(hidden from list^):!SKIPPED!
    echo.
)
echo    +----+----------------+----+----------------+
echo    ^| #  ^| Agent          ^| #  ^| Agent          ^|
echo    +----+----------------+----+----------------+
for /l %%R in (1,1,!HALF!) do (
    set /a RIGHT=%%R+HALF
    set "LN=  %%R"
    set "LN=!LN:~-2!"
    set "LA=!AGENT_%%R!              "
    set "LA=!LA:~0,14!"
    if !RIGHT! GTR !TOTAL! (
        echo    ^| !LN! ^| !LA! ^|    ^|                ^|
    ) else (
        set "RN=  !RIGHT!"
        set "RN=!RN:~-2!"
        call set "RA=%%AGENT_!RIGHT!%%"
        set "RA=!RA!              "
        set "RA=!RA:~0,14!"
        echo    ^| !LN! ^| !LA! ^| !RN! ^| !RA! ^|
    )
)
echo    +----+----------------+----+----------------+
echo.
echo      A^) install all of the above   S^) show install status   U^) uninstall everything   Q^) quit
echo      L^) install LM Studio          X^) uninstall LM Studio
echo      P^) install a plugin           Y^) uninstall a plugin
echo.
echo    Enter numbers and/or names, separated by spaces or commas.
echo    Examples:   1 3 5      Claude Codex      1, Gemini, 7
echo.
set "INPUT="
set /p "INPUT=   Your choice: "
if not defined INPUT goto :menu
if /I "!INPUT!"=="Q" (
    echo    Cancelled - no agents installed.
    endlocal
    exit /b 0
)
if /I "!INPUT!"=="U" goto :uninstall_all
if /I "!INPUT!"=="S" goto :show_status
if /I "!INPUT!"=="L" goto :install_lmstudio
if /I "!INPUT!"=="X" goto :uninstall_lmstudio
if /I "!INPUT!"=="P" goto :install_plugin
if /I "!INPUT!"=="Y" goto :uninstall_plugin
if /I "!INPUT!"=="A" (
    set "SELECTED=%ALL_AGENTS%"
    goto :reorder
)

REM  Normalize commas to spaces so the for-loop can tokenize either.
set "INPUT=!INPUT:,= !"
set "SELECTED="
set "BAD="
for %%T in (!INPUT!) do (
    set "TOK=%%T"
    set "ISNUM=1"
    for /f "delims=0123456789" %%X in ("!TOK!") do set "ISNUM="
    set "RESOLVED="
    if defined ISNUM (
        if !TOK! GEQ 1 if !TOK! LEQ !TOTAL! call set "RESOLVED=%%AGENT_!TOK!%%"
    ) else (
        if exist "%ROOT%!TOK!\!TOK!--install.cmd" set "RESOLVED=!TOK!"
    )
    if defined RESOLVED (
        set "SELECTED=!SELECTED! !RESOLVED!"
    ) else (
        set "BAD=!BAD! !TOK!"
    )
)
if defined BAD (
    echo.
    echo   Ignoring invalid choices:!BAD!
)
if not defined SELECTED (
    echo.
    echo No valid agents selected. Press any key to try again.
    pause >nul
    goto :menu
)

REM ---- Show install status of every agent in the catalogue ----
:show_status
cls
echo ============================================================
echo  Install status  --  every agent in the catalogue
echo ============================================================
echo.
echo    +----+----------------+------------+--------------------------------+
echo    ^| #  ^| Agent          ^| Status     ^| Default model                  ^|
echo    +----+----------------+------------+--------------------------------+
set "N=0"
set "OK_COUNT=0"
set "MISS_COUNT=0"
for %%A in (%ALL_AGENTS%) do (
    set /a N+=1
    set "NP=  !N!"
    set "NP=!NP:~-2!"
    set "AP=%%A              "
    set "AP=!AP:~0,14!"
    set "MODEL="
    call :agent_model_var %%A
    if defined MV call set "MODEL=%%!MV!%%"
    if "!MODEL!"=="" (
        call :agent_default_model %%A
        set "MODEL=!DM!"
    )
    REM Clip long slugs (e.g. openrouter/anthropic/claude-sonnet-4.5)
    REM with an ellipsis so the table stays aligned at 30 chars.
    if not "!MODEL:~30,1!"=="" set "MODEL=!MODEL:~0,27!..."
    set "MP=!MODEL!                                "
    set "MP=!MP:~0,30!"
    call :is_installed %%A
    if errorlevel 1 (
        set /a MISS_COUNT+=1
        echo    ^| !NP! ^| !AP! ^| missing    ^| !MP! ^|
    ) else (
        set /a OK_COUNT+=1
        echo    ^| !NP! ^| !AP! ^| installed  ^| !MP! ^|
    )
)
echo    +----+----------------+------------+--------------------------------+
echo.
echo    Installed: !OK_COUNT!   Missing: !MISS_COUNT!   Total: !N!
echo.
echo    Default model = env var (if set) else the launcher's built-in
echo    default. For agents whose CLI has no --model flag (Mistral,
echo    Grok, AmazonQ, Codebuff) the "managed" labels mean the CLI
echo    picks the model internally.
echo    Override example:  setx AIDER_MODEL "openai/gpt-5"
echo.
if defined STATUS_ONLY (
    endlocal
    exit /b 0
)
pause
goto :menu

REM ---- Hand off to Uninstall-All.cmd ----------------------------
:uninstall_all
echo.
echo ============================================================
echo  Uninstall every coding agent CLI
echo ============================================================
echo.
if not exist "%ROOT%Uninstall-All.cmd" (
    echo    ERROR: Uninstall-All.cmd not found next to this script.
    echo    Looked in: %ROOT%
    endlocal
    exit /b 1
)
echo    This will run each agent's uninstall script in reverse order.
echo    Shared deps ^(Node.js, uv, Git, WSL^) and per-agent config dirs
echo    are LEFT IN PLACE - see Uninstall-All.cmd's header for details.
echo.
set "GO="
set /p "GO=   Uninstall everything? [y/N]: "
set "G1=!GO:~0,1!"
if /I not "!G1!"=="Y" (
    echo    Cancelled - nothing uninstalled.
    endlocal
    exit /b 0
)
echo.
endlocal
call "%~dp0Uninstall-All.cmd"
exit /b %ERRORLEVEL%

REM ---- Hand off to Install-lmstudio.cmd -------------------------
REM  LM Studio is a local OpenAI-compatible model server, not an
REM  agent CLI, so it lives outside the per-agent ALL_AGENTS list
REM  and uses the script-style sibling Install-lmstudio.cmd. The
REM  AGENTS_INSTALL_ALL flag (set above) suppresses the child's
REM  own pause; we pause once on return so the user can read the
REM  result before the menu is redrawn.
:install_lmstudio
echo.
echo ============================================================
echo  Install LM Studio  (local OpenAI-compatible model server)
echo ============================================================
echo.
if not exist "%ROOT%Install-lmstudio.cmd" (
    echo    ERROR: Install-lmstudio.cmd not found next to this script.
    echo    Looked in: %ROOT%
    echo.
    pause
    goto :menu
)
call "%ROOT%Install-lmstudio.cmd"
echo.
pause
goto :menu

REM ---- Hand off to Uninstall-lmstudio.cmd -----------------------
REM  Uninstall-lmstudio.cmd pauses on its own (AGENTS_UNINSTALL_ALL
REM  is not set in this script), so we do not add a second pause.
:uninstall_lmstudio
echo.
echo ============================================================
echo  Uninstall LM Studio  (app removed, config preserved)
echo ============================================================
echo.
if not exist "%ROOT%Uninstall-lmstudio.cmd" (
    echo    ERROR: Uninstall-lmstudio.cmd not found next to this script.
    echo    Looked in: %ROOT%
    echo.
    pause
    goto :menu
)
call "%ROOT%Uninstall-lmstudio.cmd"
goto :menu

REM ---- Hand off to Plugins\Install-Plugin.cmd -------------------
REM  Plugins live under CodingAgents\Plugins\ and ride alongside
REM  the per-agent installers. Install-Plugin.cmd picks ONE plugin
REM  and fans its install hook out to every supporting agent that
REM  is currently installed. Its picker is interactive; we just
REM  forward into it and return to this menu on exit.
:install_plugin
echo.
echo ============================================================
echo  Install a plugin into every supporting agent
echo ============================================================
echo.
if not exist "%ROOT%Plugins\Install-Plugin.cmd" (
    echo    ERROR: Plugins\Install-Plugin.cmd not found.
    echo    Looked in: %ROOT%Plugins\
    echo.
    pause
    goto :menu
)
call "%ROOT%Plugins\Install-Plugin.cmd"
goto :menu

REM ---- Hand off to Plugins\Uninstall-Plugin.cmd -----------------
:uninstall_plugin
echo.
echo ============================================================
echo  Uninstall a plugin from every supporting agent
echo ============================================================
echo.
if not exist "%ROOT%Plugins\Uninstall-Plugin.cmd" (
    echo    ERROR: Plugins\Uninstall-Plugin.cmd not found.
    echo    Looked in: %ROOT%Plugins\
    echo.
    pause
    goto :menu
)
call "%ROOT%Plugins\Uninstall-Plugin.cmd"
goto :menu

REM ---- Re-order so AmazonQ runs last ----------------------------
:reorder
set "MAIN="
set "HAS_AMAZONQ="
for %%A in (%SELECTED%) do (
    if /I "%%A"=="AmazonQ" (
        set "HAS_AMAZONQ=1"
    ) else (
        set "MAIN=!MAIN! %%A"
    )
)

REM ---- Confirm the plan -----------------------------------------
echo.
echo ============================================================
echo  Ready to install:
echo ============================================================
echo.
echo    +----+----------------+
echo    ^| #  ^| Agent          ^|
echo    +----+----------------+
set "N=0"
for %%A in (!MAIN!) do (
    set /a N+=1
    set "NP=  !N!"
    set "NP=!NP:~-2!"
    set "AP=%%A              "
    set "AP=!AP:~0,14!"
    echo    ^| !NP! ^| !AP! ^|
)
if defined HAS_AMAZONQ (
    set /a N+=1
    set "NP=  !N!"
    set "NP=!NP:~-2!"
    echo    ^| !NP! ^| AmazonQ        ^|
)
echo    +----+----------------+
if defined HAS_AMAZONQ (
    echo      Note: AmazonQ runs last and may require a Windows reboot.
)
echo.
if defined DRYRUN (
    echo    Dry run - no agents were installed.
    endlocal
    exit /b 0
)
if defined INTERACTIVE (
    set "GO="
    set /p "GO=   Proceed? [Y/n]: "
    set "G1=!GO:~0,1!"
    if /I "!G1!"=="N" (
        echo    Cancelled.
        endlocal
        exit /b 0
    )
)

REM ---- Step 1: shared dependencies ------------------------------
echo.
echo [1/3] Installing shared dependencies via winget...
echo.
where winget >nul 2>nul
if errorlevel 1 goto :nowinget

where npm >nul 2>nul
if errorlevel 1 (
    echo Installing Node.js LTS for Claude, Codex, Gemini, Pi and Qwen...
    winget install --id OpenJS.NodeJS.LTS --exact --silent --accept-package-agreements --accept-source-agreements
) else (
    call :ensure_node_22
)

where uv >nul 2>nul || (
    echo Installing uv for Mistral and Trae...
    winget install --id astral-sh.uv --exact --silent --accept-package-agreements --accept-source-agreements
)

where bash >nul 2>nul || (
    echo Installing Git for Windows for Grok...
    winget install --id Git.Git --exact --silent --accept-package-agreements --accept-source-agreements
)

call :refresh_path
echo.
echo Shared dependencies ready.
goto :run_agents

:nowinget
echo WARNING: winget was not found - shared dependencies cannot be
echo pre-installed here. Each agent script will still try on its
echo own and report what is missing. Install "App Installer" from
echo the Microsoft Store to enable winget:  https://aka.ms/getwinget
echo.

REM ---- Step 2: run the selected agent installers ----------------
:run_agents
echo.
echo [2/3] Installing selected agent CLIs...
echo.
for %%A in (!MAIN!) do (
    call :install_agent %%A
    call :is_installed %%A
    if errorlevel 1 (set "RESULT_%%A=failed") else (set "RESULT_%%A=installed")
)

if defined HAS_AMAZONQ (
    echo.
    echo [3/3] Amazon Q  -  installed last; WSL setup may need a reboot.
    echo.
    call :install_agent AmazonQ
    call :is_installed AmazonQ
    if errorlevel 1 (set "RESULT_AmazonQ=reboot?") else (set "RESULT_AmazonQ=installed")
)

REM ---- Results table --------------------------------------------
echo.
echo ============================================================
echo  Run complete
echo ============================================================
echo.
echo    +----+----------------+--------------+
echo    ^| #  ^| Agent          ^| Result       ^|
echo    +----+----------------+--------------+
set "N=0"
set "ANY_FAIL="
set "ANY_REBOOT="
for %%A in (!MAIN!) do (
    set /a N+=1
    set "NP=  !N!"
    set "NP=!NP:~-2!"
    set "AP=%%A              "
    set "AP=!AP:~0,14!"
    call set "R=%%RESULT_%%A%%"
    if "!R!"=="failed" set "ANY_FAIL=1"
    set "RP=!R!            "
    set "RP=!RP:~0,12!"
    echo    ^| !NP! ^| !AP! ^| !RP! ^|
)
if defined HAS_AMAZONQ (
    set /a N+=1
    set "NP=  !N!"
    set "NP=!NP:~-2!"
    set "R=!RESULT_AmazonQ!"
    if "!R!"=="failed"  set "ANY_FAIL=1"
    if "!R!"=="reboot?" set "ANY_REBOOT=1"
    set "RP=!R!            "
    set "RP=!RP:~0,12!"
    echo    ^| !NP! ^| AmazonQ        ^| !RP! ^|
)
echo    +----+----------------+--------------+
echo.
if defined ANY_REBOOT (
    echo    Note: "reboot?" means AmazonQ's WSL setup may need a
    echo    Windows reboot. Reboot, then re-run to finish.
)
if defined ANY_FAIL (
    echo    Note: "failed" agents did not appear on PATH after install.
    echo    Scroll back to their per-agent log for the reason.
)
echo    Tip: run ..\SetOpenRouterKey.cmd (in the project root) once
echo         to enable every *--openrouter.cmd launcher.
echo.

if not defined INTERACTIVE (
    endlocal
    goto :eof
)

set "AGAIN="
set /p "AGAIN=   Back to the menu to install more? [Y/n]: "
set "A1=!AGAIN:~0,1!"
if /I "!A1!"=="N" (
    echo    Bye.
    endlocal
    exit /b 0
)

REM Clear per-run state and re-render the menu (it will now hide
REM whatever we just installed successfully).
set "SELECTED="
set "MAIN="
set "HAS_AMAZONQ="
set "BAD="
set "INPUT="
set "ANY_FAIL="
set "ANY_REBOOT="
for %%A in (%ALL_AGENTS%) do set "RESULT_%%A="
goto :menu


REM ============================================================
REM  Helper: run one agent's install script
REM ============================================================
:install_agent
echo ------------------------------------------------------------
echo  %~1
echo ------------------------------------------------------------
if exist "%ROOT%%~1\%~1--install.cmd" (
    call "%ROOT%%~1\%~1--install.cmd"
) else (
    echo ERROR: install script for %~1 was not found.
)
echo.
exit /b 0

REM ============================================================
REM  Helper: is the given agent installed?
REM  Delegates to <Agent>\<Agent>--is-installed.cmd next to this
REM  script, which returns 0 if installed and 1 if not. Unknown
REM  agents (or ones missing the probe file) are reported as
REM  not installed.
REM ============================================================
:is_installed
if exist "%ROOT%%~1\%~1--is-installed.cmd" (
    call "%ROOT%%~1\%~1--is-installed.cmd"
    exit /b
)
exit /b 1

REM ============================================================
REM  Helper: map agent name -> name of the env var that holds
REM  its default model. Returns the var name in MV (or unset MV
REM  if the agent has no native --model flag). Used by
REM  :show_status to display each agent's configured default.
REM ============================================================
:agent_model_var
set "MV="
if /I "%~1"=="Aider"        set "MV=AIDER_MODEL"       & exit /b 0
if /I "%~1"=="Antigravity"  set "MV=ANTIGRAVITY_MODEL" & exit /b 0
if /I "%~1"=="Claude"       set "MV=CLAUDE_MODEL"      & exit /b 0
if /I "%~1"=="Codex"        set "MV=CODEX_MODEL"       & exit /b 0
if /I "%~1"=="Gemini"       set "MV=GEMINI_MODEL"      & exit /b 0
if /I "%~1"=="Hermes"       set "MV=HERMES_MODEL"      & exit /b 0
if /I "%~1"=="Junie"        set "MV=JUNIE_MODEL"       & exit /b 0
if /I "%~1"=="Oh-My-Pi"     set "MV=OMP_MODEL"         & exit /b 0
if /I "%~1"=="Opencode"     set "MV=OPENCODE_MODEL"    & exit /b 0
if /I "%~1"=="OpenSquilla"  set "MV=OPENSQUILLA_MODEL" & exit /b 0
if /I "%~1"=="Pi"           set "MV=PI_MODEL"          & exit /b 0
if /I "%~1"=="VTCode"       set "MV=VTCODE_MODEL"      & exit /b 0
REM Qwen has no native run.cmd but its OpenRouter launcher reads
REM QWEN_MODEL (not the shared OPENROUTER_MODEL).
if /I "%~1"=="Qwen"         set "MV=QWEN_MODEL"        & exit /b 0
REM Trae and Mistral only have OpenRouter launchers, both keyed
REM on the shared OPENROUTER_MODEL.
if /I "%~1"=="Trae"         set "MV=OPENROUTER_MODEL"  & exit /b 0
if /I "%~1"=="Mistral"      set "MV=OPENROUTER_MODEL"  & exit /b 0
REM Grok, AmazonQ, Codebuff: CLI has no --model flag; leave MV unset.
exit /b 0

REM ============================================================
REM  Helper: per-agent built-in default model. Used by show_status
REM  when the env var (from :agent_model_var) is not set. Keep in
REM  sync with the fallbacks baked into each <Agent>--run.cmd and
REM  <Agent>--is-installed.cmd.
REM ============================================================
:agent_default_model
set "DM="
if /I "%~1"=="Aider"        set "DM=openrouter/anthropic/claude-sonnet-4.5" & exit /b 0
if /I "%~1"=="Antigravity"  set "DM=antigravity-managed"                   & exit /b 0
if /I "%~1"=="Claude"       set "DM=claude-sonnet-4-5"                      & exit /b 0
if /I "%~1"=="Codex"        set "DM=gpt-5.5"                                & exit /b 0
if /I "%~1"=="Gemini"       set "DM=gemini-2.5-pro"                         & exit /b 0
if /I "%~1"=="Hermes"       set "DM=Hermes-4-405B"                          & exit /b 0
if /I "%~1"=="Junie"        set "DM=sonnet"                                 & exit /b 0
if /I "%~1"=="Oh-My-Pi"     set "DM=openrouter/anthropic/claude-sonnet-4.5" & exit /b 0
if /I "%~1"=="Opencode"     set "DM=anthropic/claude-sonnet-4-5"            & exit /b 0
if /I "%~1"=="OpenSquilla"  set "DM=anthropic/claude-sonnet-4.5"            & exit /b 0
if /I "%~1"=="Pi"           set "DM=anthropic/claude-sonnet-4.5"            & exit /b 0
if /I "%~1"=="VTCode"       set "DM=qwen/qwen3-coder"                       & exit /b 0
if /I "%~1"=="Qwen"         set "DM=qwen/qwen3-coder"                       & exit /b 0
if /I "%~1"=="Trae"         set "DM=anthropic/claude-sonnet-4.5"            & exit /b 0
if /I "%~1"=="Mistral"      set "DM=mistral-managed"                        & exit /b 0
if /I "%~1"=="Grok"         set "DM=xai-managed"                            & exit /b 0
if /I "%~1"=="AmazonQ"      set "DM=aws-managed"                            & exit /b 0
if /I "%~1"=="Codebuff"     set "DM=codebuff-managed"                       & exit /b 0
exit /b 0

REM ============================================================
REM  Helper: ensure Node.js is at least v22 (Qwen's requirement).
REM  If an older Node is present, uninstall the old winget package
REM  and install the current LTS. Needs UAC; we let winget prompt.
REM ============================================================
:ensure_node_22
REM  'node --version' prints e.g. v20.18.1 - split on 'v' and '.'
REM  to grab the major version (token 2; token 1 is empty).
set "NODE_MAJOR="
for /f "tokens=2 delims=v." %%a in ('node --version 2^>nul') do set "NODE_MAJOR=%%a"
if not defined NODE_MAJOR exit /b 0
if %NODE_MAJOR% GEQ 22 exit /b 0
echo.
echo Node.js v%NODE_MAJOR% is installed but Qwen requires v22+.
echo Upgrading to the current Node.js LTS via winget...
echo (You may see a UAC prompt - accept it to allow the upgrade.)
echo.
REM  Strip any legacy versioned package id (e.g. OpenJS.NodeJS.20)
REM  so the LTS install does not collide with it. Each line is
REM  best-effort; missing packages just exit nonzero and are OK.
for %%V in (16 18 20 22) do (
    winget uninstall --id OpenJS.NodeJS.%%V --exact --silent --disable-interactivity >nul 2>nul
)
winget install --id OpenJS.NodeJS.LTS --exact --silent --accept-package-agreements --accept-source-agreements
exit /b 0

REM ============================================================
REM  Helper: make freshly winget-installed tools visible now,
REM  without needing to open a new terminal.
REM ============================================================
:refresh_path
call :prepend_path "%ProgramFiles%\nodejs"
call :prepend_path "%ProgramW6432%\nodejs"
call :prepend_path "%ProgramFiles%\Git\cmd"
call :prepend_path "%ProgramFiles%\Git\bin"
call :prepend_path "%LOCALAPPDATA%\Microsoft\WinGet\Links"
call :prepend_path "%USERPROFILE%\.local\bin"
exit /b 0

:prepend_path
if exist "%~1\" set "PATH=%~1;%PATH%"
exit /b 0
