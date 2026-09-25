@echo off
setlocal
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0local-tools\build-client.ps1" %*
if errorlevel 1 pause
