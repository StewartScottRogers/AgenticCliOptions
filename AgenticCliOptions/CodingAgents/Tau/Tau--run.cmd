@echo off
setlocal

REM ============================================================
REM  Tau coding agent
REM  ------------------------------------------------------------
REM  First run: use Tau's /login slash command for subscription
REM  providers, or set a provider API key once (persists for new
REM  terminals) before launching:
REM
REM      setx ANTHROPIC_API_KEY  "...your-key..."
REM      setx OPENAI_API_KEY     "...your-key..."
REM      setx OPENROUTER_API_KEY "sk-or-...your-key..."
REM
REM  Switch providers/models in-session with /login and /model.
REM
REM  This launcher pins one provider + model for the session. The
REM  built-in default is Anthropic's claude-sonnet-4-6. Override by
REM  setting either once (persists for new terminals):
REM
REM      setx TAU_PROVIDER "openrouter"
REM      setx TAU_MODEL    "anthropic/claude-sonnet-4.5"
REM
REM  Model IDs are provider-scoped - see the provider's catalog
REM  entry (run 'tau providers' to list what's configured).
REM ============================================================

if not defined TAU_PROVIDER set "TAU_PROVIDER=anthropic"
if not defined TAU_MODEL    set "TAU_MODEL=claude-sonnet-4-6"

where tau >nul 2>nul
if errorlevel 1 goto :notinstalled

set "ORIG_DIR=%CD%"
pushd "%~dp0"
echo Launching Tau with provider %TAU_PROVIDER%, model: %TAU_MODEL%
call tau --provider "%TAU_PROVIDER%" --model "%TAU_MODEL%"
popd
goto :end

:notinstalled
echo ERROR: 'tau' was not found. Install with Tau--install.cmd.
pause

:end
endlocal
