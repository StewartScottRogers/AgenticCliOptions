@echo off
setlocal

REM ============================================================
REM  Google Antigravity CLI
REM  ------------------------------------------------------------
REM  First run: 'agy' opens a browser to sign in with a Google
REM  account. SSH / headless sessions are given an authorization
REM  URL plus a one-time code instead.
REM
REM  Antigravity is multi-backend out of the box - Gemini 3 Pro,
REM  Anthropic Claude Sonnet 4.5 and OpenAI GPT-OSS are all
REM  selectable from inside the CLI (no per-vendor API key in
REM  this repo). Switch models with the CLI's own /model slash
REM  command after launch.
REM
REM  NOTE: there is no Antigravity--openrouter.cmd or
REM  Antigravity--local-lmstudio.cmd. The upstream config schema
REM  for custom OpenAI-compatible providers is not yet documented
REM  in a form we trust enough to script. To drive Gemini /
REM  Claude / GPT-OSS through OpenRouter or LM Studio today,
REM  use one of:
REM      CodingAgents\Qwen\Qwen--openrouter.cmd          (Gemini-CLI fork)
REM      CodingAgents\Codex\Codex--openrouter.cmd        (OpenAI-compatible)
REM      CodingAgents\Claude\Claude--openrouter.cmd      (Anthropic-compatible)
REM
REM  CLI self-updates in the background; no need to re-run the
REM  installer to upgrade.
REM ============================================================

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching Google Antigravity CLI...
call agy
popd
endlocal
