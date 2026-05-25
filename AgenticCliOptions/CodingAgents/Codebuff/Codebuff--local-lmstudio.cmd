@echo off
setlocal

REM ============================================================
REM  Codebuff  --  LM Studio is NOT SUPPORTED
REM  ------------------------------------------------------------
REM  Codebuff runs against its own managed platform (codebuff.com)
REM  which handles model orchestration internally. The CLI has no
REM  bring-your-own-endpoint flag - that is also why there is no
REM  Codebuff--openrouter.cmd in this folder.
REM
REM  This stub exists so every agent folder has a *--local-lmstudio.cmd
REM  for symmetry. To run a local model from this project, use a
REM  different agent (see the list below).
REM ============================================================

echo.
echo ============================================================
echo  Codebuff cannot talk to LM Studio.
echo ============================================================
echo.
echo  Codebuff is a managed platform; the CLI cannot be redirected
echo  to a local OpenAI-compatible endpoint.
echo.
echo  To run a local model, try one of these instead:
echo      CodingAgents\Qwen\Qwen--local-lmstudio.cmd
echo      CodingAgents\Codex\Codex--local-lmstudio.cmd
echo      CodingAgents\Claude\Claude--local-lmstudio.cmd
echo.
pause
endlocal
