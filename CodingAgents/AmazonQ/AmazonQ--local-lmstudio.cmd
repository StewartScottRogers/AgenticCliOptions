@echo off
setlocal

REM ============================================================
REM  Amazon Q  --  LM Studio is NOT SUPPORTED
REM  ------------------------------------------------------------
REM  Amazon Q (now "Kiro CLI") is tied to AWS Builder ID accounts
REM  and Amazon's own Nova models. The CLI does not speak the
REM  OpenAI / LM Studio protocol and has no bring-your-own-endpoint
REM  flag.
REM
REM  This stub exists so every agent folder has a *--local-lmstudio.cmd
REM  for symmetry. To run a local model from this project, use a
REM  different agent (see the list below).
REM ============================================================

echo.
echo ============================================================
echo  Amazon Q cannot talk to LM Studio.
echo ============================================================
echo.
echo  Amazon Q is tied to AWS accounts and Amazon's Nova models.
echo  Its CLI has no OpenAI-compatible / LM Studio endpoint flag.
echo.
echo  To run a local model, try one of these instead:
echo      CodingAgents\Qwen\Qwen--local-lmstudio.cmd
echo      CodingAgents\Codex\Codex--local-lmstudio.cmd
echo      CodingAgents\Claude\Claude--local-lmstudio.cmd
echo.
pause
endlocal
