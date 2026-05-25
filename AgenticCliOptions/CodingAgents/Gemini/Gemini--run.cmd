@echo off
setlocal

REM ============================================================
REM  Google Gemini CLI
REM  ------------------------------------------------------------
REM  First run: Gemini CLI opens a browser to sign in with a
REM  Google account (generous free tier). Alternatively, set an
REM  API key once (persists for new terminals):
REM
REM      setx GEMINI_API_KEY "...your-key..."
REM
REM  Get a key at https://aistudio.google.com/apikey
REM
REM  --yolo auto-approves every command and file edit. Only run
REM  this in a repo you trust.
REM
REM  NOTE: there is no Gemini--openrouter.cmd or
REM  Gemini--settings-lmstudio.cmd. The Gemini CLI talks to
REM  Google's own API and does not natively speak the OpenAI /
REM  OpenRouter or LM Studio protocol. To drive Gemini models
REM  through OpenRouter, use an OpenAI-compatible CLI instead -
REM  the Qwen Code CLI in the Qwen folder is itself a Gemini CLI
REM  fork and accepts an OpenAI-compatible base URL.
REM
REM  Default model is always passed via --model. Override by setting
REM  GEMINI_MODEL once (persists for new terminals):
REM
REM      setx GEMINI_MODEL "gemini-2.5-pro"
REM ============================================================

if not defined GEMINI_MODEL set "GEMINI_MODEL=gemini-2.5-pro"

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching Google Gemini CLI with model: %GEMINI_MODEL%
call gemini --yolo --model "%GEMINI_MODEL%"
popd
endlocal
