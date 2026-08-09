@echo off
setlocal

REM ============================================================
REM  opencode - sign in with your provider account
REM  ------------------------------------------------------------
REM  First run: 'opencode auth login ^<provider^>' signs you in.
REM  Supported providers include anthropic, openai, google,
REM  openrouter, and any OpenAI-compatible endpoint (LM Studio,
REM  Ollama, etc. - configured via opencode.json).
REM
REM  Default model is always passed via --model. opencode requires
REM  the 'provider/model' slug form. Override by setting
REM  OPENCODE_MODEL once (persists for new terminals):
REM
REM      setx OPENCODE_MODEL "anthropic/claude-sonnet-5"
REM ============================================================

if not defined OPENCODE_MODEL set "OPENCODE_MODEL=anthropic/claude-sonnet-5"

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching opencode with model: %OPENCODE_MODEL%
call opencode --model "%OPENCODE_MODEL%"
popd
endlocal
