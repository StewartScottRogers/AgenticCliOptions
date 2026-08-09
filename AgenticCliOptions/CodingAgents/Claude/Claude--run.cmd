@echo off
setlocal

REM ============================================================
REM  Run Claude Code  --  native launcher
REM  ------------------------------------------------------------
REM  Default model is always passed via --model. Override by setting
REM  CLAUDE_MODEL once (persists for new terminals):
REM
REM      setx CLAUDE_MODEL "claude-opus-5"
REM ============================================================

if not defined CLAUDE_MODEL set "CLAUDE_MODEL=claude-sonnet-5"

pushd "%~dp0"
echo Launching Claude Code with model: %CLAUDE_MODEL%
call claude --dangerously-skip-permissions --verbose --model "%CLAUDE_MODEL%"
popd
endlocal
