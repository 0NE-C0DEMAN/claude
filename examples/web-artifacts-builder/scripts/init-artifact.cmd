@echo off
setlocal
REM Run from your project parent folder (same as bash). Components load from this script's directory.
node "%~dp0init-artifact.cjs" %*
exit /b %ERRORLEVEL%
