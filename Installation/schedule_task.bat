@echo off
setlocal
title Steam Experience Task Installation
color 0B

:: =========================================================
:: 1. ADMINISTRATOR PRIVILEGES CHECK (Silent)
:: =========================================================
:: Validates elevated permissions before modifying system tasks
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"
if '%errorlevel%' NEQ '0' (
    echo [ERROR] This script must be run as Administrator.
    exit /B
)

echo.
echo =========================================================
echo    INSTALLING STEAM EXPERIENCE SCHEDULED TASKS
echo =========================================================
echo.

:: =========================================================
:: 2. AUTOMATED TASK DEPLOYMENT
:: =========================================================

:: Task 1: RestoreExplorer (Gateway to launch desktop in User mode)
:: Creates a limited-privilege trigger to restore Explorer functionality if needed.
echo [1/3] Creating "RestoreExplorer" gateway...
schtasks /create /tn "RestoreExplorer" /tr "explorer.exe" /sc ONCE /st 00:00 /rl LIMITED /f >nul 2>&1

:: Task 2: Shell (System Startup + Admin Rights + Current User)
:: Registers the main Shell script to launch at logon with high privileges.
echo [2/3] Creating "Steam Experience Shell" task...
schtasks /create /tn "Steam Experience Shell" /tr "C:\Scripts\shell_BigPicture.bat" /sc ONLOGON /rl HIGHEST /f >nul 2>&1

:: Task 3: Start (User Session + Admin Rights)
:: Registers the startup script to execute immediately upon user login.
echo [3/3] Creating "Steam Experience Start" task...
schtasks /create /tn "Steam Experience Start" /tr "C:\Scripts\start.bat" /sc ONLOGON /rl HIGHEST /f >nul 2>&1

echo.
echo =========================================================
echo    INSTALLATION COMPLETE
echo =========================================================
timeout /t 3
exit