@echo off
setlocal

REM ============================================================
REM  Amazon Q Developer CLI (now "Kiro CLI") - chat session
REM  ------------------------------------------------------------
REM  Starts an Amazon Q chat session. The CLI authenticates with
REM  an AWS Builder ID / IAM Identity Center account - sign in
REM  once inside the CLI with 'q login'.
REM
REM  NOTE: there is no AmazonQ--openrouter.cmd or
REM  AmazonQ--settings-lmstudio.cmd. Amazon Q is tied to AWS
REM  accounts and Amazon's own (Nova) models and does not speak
REM  the OpenAI / OpenRouter or LM Studio protocol.
REM
REM  On Windows the CLI runs inside WSL (see AmazonQ--install.cmd).
REM ============================================================

set "ORIG_DIR=%CD%"
pushd "%~dp0"

REM  Prefer a native 'q' on PATH; otherwise run it through WSL.
where q >nul 2>nul
if not errorlevel 1 (
    echo Launching Amazon Q chat...
    call q chat
    goto :end
)

where wsl >nul 2>nul
if errorlevel 1 goto :notools

echo Launching Amazon Q chat through WSL...
REM  The CLI was rebranded from Amazon Q ('q') to Kiro CLI
REM  ('kiro-cli'); use whichever the WSL install produced.
call wsl -e bash -lc "if command -v q >/dev/null 2>&1; then q chat; else kiro-cli chat; fi"
goto :end

:notools
echo ERROR: The Amazon Q CLI was not found.
echo Run AmazonQ--install.cmd first, and make sure WSL is installed.

:end
popd
endlocal
