@echo off
setlocal

REM ============================================================
REM  Pi coding agent
REM  ------------------------------------------------------------
REM  First run: use Pi's /login slash command for subscription
REM  providers, or set a provider API key once (persists for new
REM  terminals) before launching:
REM
REM      setx ANTHROPIC_API_KEY "...your-key..."
REM      setx OPENAI_API_KEY    "...your-key..."
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  Switch models in-session with /model or Ctrl+L.
REM
REM  Pi has no auto-approve/yolo flag by design - it intentionally
REM  omits built-in permission popups, so it just runs the tools
REM  it is asked to run. See https://pi.dev/ for details.
REM
REM  NOTE: there is no Pi--settings-lmstudio.cmd. Pi reaches LM
REM  Studio via its models.json config rather than CLI flags, so
REM  LM Studio integration belongs in a Pi extension. Use
REM  Codex--settings-lmstudio.cmd or Claude--settings-lmstudio.cmd
REM  to drive an LM Studio model meanwhile.
REM ============================================================

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching Pi coding agent...
call pi
popd
endlocal
