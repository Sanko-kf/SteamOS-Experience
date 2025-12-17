@echo off
setlocal EnableDelayedExpansion
title Steam Installation and Authentication
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
:: Define temporary workspace and official Steam installer source
set "TempDir=C:\Temp_SteamSetup"
set "SteamPath=C:\Program Files (x86)\Steam\steam.exe"
set "SteamInstallerUrl=https://cdn.akamai.steamstatic.com/client/installer/SteamSetup.exe"

:: --- 3. STEAM INSTALLATION (CONDITIONAL) ---
:: Checks for existing installation before proceeding with download
if exist "%SteamPath%" (
    echo [INFO] Steam is already installed on this system.
) else (
    echo [INFO] Steam not found. Initializing download...
    
    if not exist "%TempDir%" mkdir "%TempDir%"
    cd /d "%TempDir%"
    
    :: Downloading official installer
    curl -L -o "SteamSetup.exe" "%SteamInstallerUrl%"
    
    if not exist "SteamSetup.exe" (
        echo [ERROR] Failed to download Steam installer.
        pause
        exit
    )
    
    echo Installing Steam...
    :: /S = Silent installation switch
    start /wait "" "SteamSetup.exe" /S
    
    echo Installation complete.
)

:: --- 4. LAUNCH AND AUTHENTICATION ---
:: Manual intervention required for user login
cls
echo ========================================================
echo   STEAM AUTHENTICATION REQUIRED
echo ========================================================
echo.
echo 1. Launching Steam...
echo 2. Please log in to your account (Check "Remember me").
echo 3. Wait until the main Store page is fully loaded.
echo.
echo ONCE LOGGED IN, RETURN TO THIS WINDOW AND PRESS ANY KEY.
echo.

:: Regular Steam launch
start "" "%SteamPath%"

:: Script pauses until user confirms login completion
pause

:: --- 5. TERMINATING STEAM PROCESS ---
:: Closing Steam to save session tokens and finalize configuration
echo.
echo Closing Steam to validate session data...
:: Forcefully terminating the process to ensure full closure
taskkill /F /IM steam.exe >nul 2>&1
timeout /t 3 /nobreak >nul

:: --- 6. TERMINATION ---
echo.
echo Operation successful.
echo Steam is installed and your account is configured.
:: Optional: Cleanup temporary directory
:: if exist "%TempDir%" rd /s /q "%TempDir%"

exit