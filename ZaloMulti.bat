@echo off
title ZaloMulti Pro Launcher
set "SCRIPT_PATH=%~dp0ZaloMulti.ps1"
where pwsh >nul 2>nul
if %errorlevel% equ 0 (
    pwsh -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"
) else (
    powershell -ExecutionPolicy Bypass -File "%SCRIPT_PATH%"
)
exit

