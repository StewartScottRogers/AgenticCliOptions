@echo off
setlocal

REM ============================================================
REM  xAI Grok Build (CLI coding agent)
REM  ------------------------------------------------------------
REM  First run: Grok Build opens a browser to sign in with a
REM  SuperGrok Heavy account. For headless / API-key use, set:
REM
REM      setx GROK_CODE_XAI_API_KEY "xai-...your-key..."
REM
REM  Get a key at https://console.x.ai
REM
REM  NOTE: there is no Grok--openrouter.cmd or
REM  Grok--settings-lmstudio.cmd. Grok Build talks to xAI's own
REM  API and is tied to a SuperGrok subscription. Grok models
REM  are on OpenRouter - to use them through OpenRouter, drive
REM  them with an OpenAI-compatible CLI instead (e.g. the Qwen
REM  Code CLI in the Qwen folder).
REM
REM  Grok Build is beta software; flags may change. See
REM  https://x.ai/cli
REM ============================================================

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching xAI Grok Build...
call grok
popd
endlocal
