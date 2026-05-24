@echo off
setlocal

REM ============================================================
REM  Google Gemini CLI  --  LM Studio is NOT SUPPORTED
REM  ------------------------------------------------------------
REM  The Gemini CLI talks to Google's own API and does not speak
REM  the OpenAI / LM Studio protocol. There is no
REM  --base-url / OPENAI_BASE_URL hook in this CLI.
REM
REM  To drive Gemini-family models through OpenAI-compatible
REM  endpoints, use an OpenAI-compatible CLI instead. The Qwen
REM  Code CLI in the Qwen folder is itself a Gemini-CLI fork and
REM  accepts an OpenAI-compatible base URL out of the box.
REM
REM  This stub exists so every agent folder has a *--lmstudio.cmd
REM  for symmetry.
REM ============================================================

echo.
echo ============================================================
echo  Gemini CLI cannot talk to LM Studio.
echo ============================================================
echo.
echo  Google's Gemini CLI has no OpenAI-compatible / LM Studio
echo  endpoint flag. Use the Qwen Code CLI (a Gemini-CLI fork) for
echo  local models instead:
echo      CodingAgents\Qwen\Qwen--lmstudio.cmd
echo.
echo  Other local-model launchers:
echo      CodingAgents\Codex\Codex--lmstudio.cmd
echo      CodingAgents\Claude\Claude--lmstudio.cmd
echo.
pause
endlocal
