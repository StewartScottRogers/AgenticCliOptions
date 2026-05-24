@echo off
setlocal

REM ============================================================
REM  Junie (JetBrains)  --  LM Studio is NOT SUPPORTED
REM  ------------------------------------------------------------
REM  Junie has its own model registry and only accepts a small
REM  set of aliases (sonnet, opus, gpt, grok, claude-sonnet-4-6,
REM  ...). Those aliases map to JetBrains-managed backend routing
REM  rather than arbitrary OpenAI-compatible endpoints - there is
REM  no way to point Junie at an LM Studio server today.
REM
REM  This stub exists so every agent folder has a *--local-lmstudio.cmd
REM  for symmetry.
REM ============================================================

echo.
echo ============================================================
echo  Junie cannot talk to LM Studio.
echo ============================================================
echo.
echo  Junie's model registry only accepts its own aliases (e.g.
echo  sonnet, opus, gpt) which route through JetBrains-managed
echo  infrastructure. Arbitrary OpenAI-compatible endpoints are
echo  not supported.
echo.
echo  To run a local model, try one of these instead:
echo      CodingAgents\Qwen\Qwen--local-lmstudio.cmd
echo      CodingAgents\Codex\Codex--local-lmstudio.cmd
echo      CodingAgents\Claude\Claude--local-lmstudio.cmd
echo.
pause
endlocal
