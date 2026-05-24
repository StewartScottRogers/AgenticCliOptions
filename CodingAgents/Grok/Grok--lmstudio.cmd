@echo off
setlocal

REM ============================================================
REM  xAI Grok Build  --  LM Studio is NOT SUPPORTED
REM  ------------------------------------------------------------
REM  Grok Build talks to xAI's own API and is tied to a SuperGrok
REM  subscription / xAI API key. The CLI has no OpenAI-compatible
REM  or LM Studio endpoint flag.
REM
REM  Grok-family models are also available on OpenRouter; to use
REM  them locally, drive them with an OpenAI-compatible CLI (e.g.
REM  the Qwen Code CLI in the Qwen folder).
REM
REM  This stub exists so every agent folder has a *--lmstudio.cmd
REM  for symmetry.
REM ============================================================

echo.
echo ============================================================
echo  Grok Build cannot talk to LM Studio.
echo ============================================================
echo.
echo  Grok Build is tied to xAI's own API. The CLI has no
echo  OpenAI-compatible / LM Studio endpoint flag.
echo.
echo  To run a local model, try one of these instead:
echo      CodingAgents\Qwen\Qwen--lmstudio.cmd
echo      CodingAgents\Codex\Codex--lmstudio.cmd
echo      CodingAgents\Claude\Claude--lmstudio.cmd
echo.
pause
endlocal
