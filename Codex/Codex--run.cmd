@echo off
setlocal

REM ============================================================
REM  OpenAI Codex CLI - sign in with your OpenAI / ChatGPT account
REM  ------------------------------------------------------------
REM  First run: Codex opens a browser to sign in. Alternatively,
REM  set an API key once (persists for new terminals):
REM
REM      setx OPENAI_API_KEY "sk-...your-key..."
REM
REM  Get a key at https://platform.openai.com/api-keys
REM
REM  --yolo auto-approves every command and file edit (it is the
REM  short form of --dangerously-bypass-approvals-and-sandbox).
REM  Only run this in a repo you trust.
REM ============================================================

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching OpenAI Codex CLI...
call codex --yolo
popd
endlocal
