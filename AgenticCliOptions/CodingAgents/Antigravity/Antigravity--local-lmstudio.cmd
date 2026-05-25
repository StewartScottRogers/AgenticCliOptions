@echo off
setlocal

REM ============================================================
REM  Antigravity CLI  --  LM Studio is NOT WIRED UP
REM  ------------------------------------------------------------
REM  Same situation as Antigravity--openrouter.cmd: the upstream
REM  config schema for pointing agy at a custom OpenAI-compatible
REM  base URL is not documented in a form we trust enough to
REM  script. Once it lands, this launcher should point agy at
REM  ${LMSTUDIO_URL}/v1 with auth token 'lmstudio' (the same
REM  pattern used by Codex / Qwen).
REM
REM  Drive local models through LM Studio with an already-wired
REM  launcher instead:
REM      CodingAgents\Qwen\Qwen--local-lmstudio.cmd
REM      CodingAgents\Codex\Codex--local-lmstudio.cmd
REM      CodingAgents\Claude\Claude--local-lmstudio.cmd
REM
REM  This stub exists so every agent folder has a *--local-lmstudio.cmd
REM  for symmetry.
REM ============================================================

echo.
echo ============================================================
echo  Antigravity CLI: LM Studio is not wired up in this repo.
echo ============================================================
echo.
echo  The upstream config schema for custom OpenAI-compatible
echo  endpoints is not yet documented. Use one of these wired
echo  agents for local-model launches today:
echo      CodingAgents\Qwen\Qwen--local-lmstudio.cmd
echo      CodingAgents\Codex\Codex--local-lmstudio.cmd
echo      CodingAgents\Claude\Claude--local-lmstudio.cmd
echo.
pause
endlocal
