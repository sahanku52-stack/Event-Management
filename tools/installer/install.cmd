@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0install.ps1"
set "JM_EXIT=%ERRORLEVEL%"
if not "%JM_EXIT%"=="0" pause
exit /b %JM_EXIT%
