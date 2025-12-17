@echo off
setlocal EnableDelayedExpansion
title Windows Update Blocker Installation
color 0B

:: --- 1. ADMINISTRATOR PRIVILEGES CHECK ---
:: Validates that the script is running with elevated permissions
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as Administrator!
    pause
    exit
)

:: --- 2. CONFIGURATION ---
:: Define local destination and remote source URL
set "TargetDir=C:\Scripts"
set "ExeName=Wub.exe"
set "ExePath=%TargetDir%\%ExeName%"

:: Direct link to the raw binary file for download
set "DownloadUrl=https://github.com/Hudrig0/Windows-Update-Blocker/raw/main/Wub.exe"

:: --- 3. DIRECTORY PREPARATION ---
:: Ensures the target directory exists before downloading
if not exist "%TargetDir%" (
    echo Creating directory %TargetDir%...
    mkdir "%TargetDir%"
)

:: --- 4. DOWNLOAD PHASE ---
:: Downloads the executable using curl into the target directory
cls
echo Downloading %ExeName% to %TargetDir%...
cd /d "%TargetDir%"

curl -L -o "%ExeName%" "%DownloadUrl%"

if not exist "%ExeName%" (
    echo [ERROR] File download failed.
    echo Please check your internet connection or the source URL.
    pause
    exit
)

:: --- 5. EXECUTION & PROCESS MONITORING ---
echo.
echo Launching application...
echo.
echo ========================================================
echo   SCRIPT STATUS: ON HOLD.
echo   Use Windows Update Blocker as needed.
echo   CLOSE THE PROGRAM TO FINALIZE THIS SCRIPT.
echo ========================================================

:: start /wait ensures the script execution flow pauses until the app is closed
start /wait "" "%ExePath%"

:: --- 6. TERMINATION ---
echo.
echo Application closed. Script execution complete.
exit