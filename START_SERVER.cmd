@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0local-tools\start-server.ps1" %*
if errorlevel 1 pause
