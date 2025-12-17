@echo off
setlocal EnableDelayedExpansion
title Kiosk Configuration + Reboot Tool
color 0B

:: --- 1. ADMINISTRATOR PRIVILEGES CHECK ---
:: Ensures the script is running with elevated privileges
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo [ERROR] This script must be run as Administrator!
    pause
    exit
)

:: --- 2. USER INPUT ---
:: Collects credentials for the new kiosk administrative account
cls
echo ========================================================
echo     ADMIN CREATION + AUTOLOGON + REBOOT TOOL
echo ========================================================
echo.
set /p NewUser="Enter Username: "
echo.
echo Note: Password must meet complexity requirements (Uppercase + Numbers)
set /p NewPass="Enter Password: "

if "%NewUser%"=="" goto errorInput
if "%NewPass%"=="" goto errorInput

:: --- 3. USER ACCOUNT CREATION ---
:: Creates the local user account with specified parameters
echo.
echo [1/6] Creating user account...
net user "%NewUser%" "%NewPass%" /add /comment:"Admin Kiosk" /passwordchg:no

if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Failed to create user account.
    echo Please ensure the password meets the system complexity policy.
    pause
    exit
)

:: --- 4. ACCOUNT SETTINGS & PRIVILEGES ---
:: Sets password to never expire and adds user to the local Administrators group
wmic useraccount where "Name='%NewUser%'" set PasswordExpires=FALSE >nul 2>&1
net localgroup Administrateurs "%NewUser%" /add >nul 2>&1
:: Fallback for English-based Windows versions
if %errorlevel% neq 0 ( net localgroup Administrators "%NewUser%" /add >nul 2>&1 )
echo [OK] Administrative user created successfully.

:: --- 5. DEPENDENCY DOWNLOAD ---
:: Retrieves the Sysinternals Autologon utility
echo.
echo [4/6] Downloading Autologon utility...
set "TempDir=C:\Temp_Autologon"
if not exist "%TempDir%" mkdir "%TempDir%"
cd /d "%TempDir%"
curl -L -o AutoLogon.zip "https://download.sysinternals.com/files/AutoLogon.zip"

:: --- 6. ARCHIVE EXTRACTION ---
:: Extracts the downloaded ZIP file using PowerShell
echo.
echo [5/6] Extracting files...
powershell -command "Expand-Archive -Path 'AutoLogon.zip' -DestinationPath '.' -Force"

:: --- 7. UTILITY EXECUTION ---
:: Launches the appropriate architecture version of Autologon
echo.
echo [6/6] Launching utility...
echo.
echo ========================================================
echo   ACTION REQUIRED:
echo   1. Configure Autologon (Enter User/Pass/Domain and click Enable).
echo   2. CLOSE THE UTILITY WINDOW to trigger the system reboot.
echo ========================================================

if exist "%SystemRoot%\SysWOW64" (
    start /wait "" "Autologon64.exe"
) else (
    start /wait "" "Autologon.exe"
)

:: --- 8. SYSTEM REBOOT ---
:: Finalizes the process by forcing a system restart
cls
color 4F
echo.
echo ========================================================
echo   CONFIGURATION COMPLETE.
echo   SYSTEM REBOOTING IN 5 SECONDS...
echo ========================================================
echo.

:: Shutdown flags: /r (reboot), /t 5 (5sec delay), /f (force close apps)
shutdown /r /t 5 /f

pause
exit

:errorInput
echo [ERROR] Invalid input. Please try again.
pause