@echo off
REM ============================================================
REM  Resolve LMSTUDIO_URL  (shared helper, CALL only)
REM  ------------------------------------------------------------
REM  Sets LMSTUDIO_URL to the first reachable LM Studio server
REM  it can find on this machine. Probes (in order):
REM     http://127.0.0.1:1234
REM     http://127.0.0.1:1235
REM     http://<each local IPv4>:1234
REM     http://<each local IPv4>:1235
REM  Skips loopback and link-local addresses. Sets the loopback
REM  default if nothing answered, so callers always have a value.
REM
REM  This file MUST be invoked via `call` from a parent .cmd; it
REM  deliberately omits `setlocal` so the variable persists.
REM  No-op if LMSTUDIO_URL is already defined.
REM ============================================================

if defined LMSTUDIO_URL exit /b 0

for /f "usebackq delims=" %%u in (`powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0_resolve-lmstudio-url.ps1"`) do set "LMSTUDIO_URL=%%u"

if not defined LMSTUDIO_URL set "LMSTUDIO_URL=http://127.0.0.1:1234"
exit /b 0
