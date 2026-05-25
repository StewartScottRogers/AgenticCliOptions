@echo off
setlocal

REM ============================================================
REM  Mistral Vibe  --  LM Studio is NOT SUPPORTED
REM  ------------------------------------------------------------
REM  Mistral's 'vibe' CLI talks to console.mistral.ai using
REM  MISTRAL_API_KEY only. There is no OpenAI-compatible /
REM  LM Studio endpoint flag.
REM
REM  Mistral-family models are also available on OpenRouter; to
REM  use them through a local endpoint, drive them with an
REM  OpenAI-compatible CLI (e.g. the Qwen Code CLI in the Qwen
REM  folder).
REM
REM  This stub exists so every agent folder has a *--local-lmstudio.cmd
REM  for symmetry.
REM ============================================================

echo.
echo ============================================================
echo  Mistral Vibe cannot talk to LM Studio.
echo ============================================================
echo.
echo  Mistral's 'vibe' CLI is tied to Mistral's own API. The CLI
echo  has no OpenAI-compatible / LM Studio endpoint flag.
echo.
echo  To run a local model, try one of these instead:
echo      CodingAgents\Qwen\Qwen--local-lmstudio.cmd
echo      CodingAgents\Codex\Codex--local-lmstudio.cmd
echo      CodingAgents\Claude\Claude--local-lmstudio.cmd
echo.
pause
endlocal
