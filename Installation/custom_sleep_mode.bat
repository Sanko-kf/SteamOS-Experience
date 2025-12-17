@echo off
setlocal EnableDelayedExpansion
title Power Config + VLC Installation + Directory Setup
color 0B

:: --- 1. ADMINISTRATOR PRIVILEGES CHECK ---
:: Validates that the script is running with elevated permissions
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as Administrator!
    pause
    exit
)

:: --- 2. POWER MANAGEMENT CONFIGURATION (NO SLEEP) ---
:: Sets the system to High Performance and disables all sleep timers
cls
echo ========================================================
echo    POWER CONFIGURATION (PERFORMANCE MODE)
echo ========================================================
echo.
echo [POWER] Disabling system sleep and hibernation...

:: Set active scheme to High Performance
powercfg -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c >nul 2>&1

:: On AC Power (Plugged in) -> 0 = Never
powercfg -change -monitor-timeout-ac 0
powercfg -change -standby-timeout-ac 0
powercfg -change -disk-timeout-ac 0
powercfg -change -hibernate-timeout-ac 0

:: On DC Power (Battery)
powercfg -change -monitor-timeout-dc 0
powercfg -change -standby-timeout-dc 0
powercfg -change -disk-timeout-dc 0

:: Disable Hibernation entirely
powercfg -h off

echo [OK] Sleep settings disabled (Monitor/System/Disk).

:: --- 3. VLC MEDIA PLAYER INSTALLATION ---
:: Downloads and installs VLC with silent switches
echo.
echo ========================================================
echo    VLC MEDIA PLAYER INSTALLATION
echo ========================================================
echo.

set "TempDir=C:\Temp_VLC"
set "VlcUrl=https://get.videolan.org/vlc/3.0.21/win64/vlc-3.0.21-win64.exe"
set "VlcInstaller=vlc-setup.exe"

if not exist "%TempDir%" mkdir "%TempDir%"
cd /d "%TempDir%"

echo [1/2] Downloading VLC...
curl -L -o "%VlcInstaller%" "%VlcUrl%"

if not exist "%VlcInstaller%" (
    echo [ERROR] Failed to download VLC.
    pause
    exit
)

echo.
echo [2/2] Running silent installation...
:: /L=1033 is for English (1036 was French), /S for Silent
start /wait "" "%VlcInstaller%" /L=1033 /S
echo [OK] VLC installation complete.

:: --- 4. CONTENT DIRECTORY CREATION ---
:: Creates a specific folder for media assets
echo.
echo ========================================================
echo    CONTENT DIRECTORY SETUP
echo ========================================================
echo.

:: %USERPROFILE% targets C:\Users\CurrentUserName
set "TargetFolder=%USERPROFILE%\Videos\SleepVideos"

if not exist "%TargetFolder%" (
    mkdir "%TargetFolder%"
    echo [OK] Directory created: "%TargetFolder%"
) else (
    echo [INFO] Directory already exists: "%TargetFolder%"
)

:: --- 5. TERMINATION ---
echo.
echo Configuration successful.
:: Cleanup
:: cd \
:: rd /s /q "%TempDir%"

exit