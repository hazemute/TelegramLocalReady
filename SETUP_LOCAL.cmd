@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0local-tools\configure-local.ps1" %*
if errorlevel 1 pause
