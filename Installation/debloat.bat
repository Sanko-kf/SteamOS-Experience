@echo off
setlocal EnableDelayedExpansion
title Win11Debloat Launcher
color 0B

:: --- 1. ADMINISTRATOR PRIVILEGES CHECK ---
:: Ensures the script has the necessary permissions to modify system settings
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as Administrator!
    pause
    exit
)

:: --- 2. CONFIGURATION ---
:: Define the temporary workspace and the remote source URL
set "WorkDir=C:\Temp_Win11Debloat"
set "ScriptUrl=https://github.com/Raphire/Win11Debloat/releases/download/2025.11.30/Get.ps1"
set "ScriptFile=%WorkDir%\Get.ps1"

:: --- 3. ENVIRONMENT PREPARATION ---
:: Creates the work directory if it doesn't exist and switches to it
if not exist "%WorkDir%" mkdir "%WorkDir%"
cd /d "%WorkDir%"

:: --- 4. DOWNLOAD PHASE ---
:: Uses curl to retrieve the PowerShell script from the official repository
cls
echo Downloading Win11Debloat components...
curl -L -o "Get.ps1" "%ScriptUrl%"

if not exist "Get.ps1" (
    echo [ERROR] Download failed. Please check your internet connection.
    pause
    exit
)

:: --- 5. EXECUTION PHASE ---
:: Launches the PowerShell script with a Bypass policy to allow execution
echo Launching Win11Debloat utility...

:: The Batch script will wait here until the PowerShell process completes.
powershell -NoProfile -ExecutionPolicy Bypass -File "Get.ps1"

:: --- 6. CLEANUP & EXIT ---
:: Optional: Uncomment the following lines to delete the temp folder after execution
:: cd \
:: rd /s /q "%WorkDir%" >nul 2>&1

:: Closes the command prompt window
exit