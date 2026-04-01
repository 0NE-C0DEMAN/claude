@echo off
setlocal
REM Run from your React project root (where package.json is).
node "%~dp0bundle-artifact.cjs"
exit /b %ERRORLEVEL%
