@echo off
setlocal

REM ============================================================
REM  Antigravity CLI  --  OpenRouter is NOT WIRED UP
REM  ------------------------------------------------------------
REM  Antigravity CLI ('agy') is multi-backend natively - Gemini
REM  3 Pro, Anthropic Claude Sonnet 4.5 and OpenAI GPT-OSS are
REM  built in - but at the time of writing the upstream config
REM  schema for adding a *custom* OpenAI-compatible provider
REM  (i.e. OpenRouter) is not documented in a form we trust
REM  enough to script.
REM
REM  Once Google publishes the agy config.toml / settings.json
REM  schema for custom providers, this launcher should:
REM      1. set OPENAI_API_KEY=%OPENROUTER_API_KEY%
REM      2. set OPENAI_BASE_URL=https://openrouter.ai/api/v1
REM      3. call  agy --model "%OPENROUTER_MODEL%"
REM  (verify each step against the upstream docs first).
REM
REM  Until then, drive your preferred model through OpenRouter
REM  with an already-wired OpenAI- or Anthropic-compatible CLI:
REM      CodingAgents\Qwen\Qwen--openrouter.cmd        (Gemini-CLI fork)
REM      CodingAgents\Codex\Codex--openrouter.cmd      (OpenAI-compatible)
REM      CodingAgents\Claude\Claude--openrouter.cmd    (Anthropic-compatible)
REM
REM  This stub exists so every agent folder has a *--openrouter.cmd
REM  for symmetry.
REM ============================================================

echo.
echo ============================================================
echo  Antigravity CLI: OpenRouter is not wired up in this repo.
echo ============================================================
echo.
echo  The upstream config schema for custom OpenAI-compatible
echo  providers is not yet documented. Use one of these wired
echo  agents to route via OpenRouter today:
echo      CodingAgents\Qwen\Qwen--openrouter.cmd       (Gemini fork)
echo      CodingAgents\Codex\Codex--openrouter.cmd     (OpenAI compat)
echo      CodingAgents\Claude\Claude--openrouter.cmd   (Anthropic compat)
echo.
pause
endlocal
