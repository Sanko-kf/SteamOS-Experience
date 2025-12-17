@echo off
setlocal EnableDelayedExpansion
title Kiosk Mode Setup (UAC, Notifications, Power)
color 0B

:: --- 1. ADMINISTRATOR PRIVILEGES CHECK ---
:: Ensures the script has the necessary permissions to modify registry keys
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as Administrator!
    pause
    exit
)

:: --- 2. DISABLE UAC (Security Prompts) ---
:: Disables "Admin Approval Mode" to prevent pop-up interruptions
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v EnableLUA /t REG_DWORD /d 0 /f >nul
:: Sets Administrator behavior to "Elevate without prompting"
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v ConsentPromptBehaviorAdmin /t REG_DWORD /d 0 /f >nul
:: Disables "Secure Desktop" (prevents screen dimming during prompts)
reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" /v PromptOnSecureDesktop /t REG_DWORD /d 0 /f >nul

:: --- 3. DISABLE NOTIFICATIONS (Visual Clutter) ---
:: Disables Toast Notifications for a clean kiosk interface
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications" /v ToastEnabled /t REG_DWORD /d 0 /f >nul
:: Completely disables the Action Center/Notification Center
reg add "HKCU\Software\Policies\Microsoft\Windows\Explorer" /v DisableNotificationCenter /t REG_DWORD /d 1 /f >nul
:: Disables legacy Balloon tips
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v EnableBalloonTips /t REG_DWORD /d 0 /f >nul

:: --- 4. CONFIGURE POWER BUTTON (Instant Shutdown) ---
:: Reconfigures the physical power button to trigger an immediate shutdown.
:: GUIDs target "Power buttons and lid" settings.
:: Value 3 = Shutdown (Standard for Kiosk hardware).

:: Apply setting for AC (Plugged In)
powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-995905f5771b 7648efa3-dd9c-4e3e-b566-50f929386280 3

:: Apply setting for DC (Battery)
powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-995905f5771b 7648efa3-dd9c-4e3e-b566-50f929386280 3

:: Commit changes immediately
powercfg -SetActive SCHEME_CURRENT

:: --- 5. INSTALL UTILITIES (AutoHideMouseCursor) ---
echo.
echo [INSTALLATION] Downloading AutoHideMouseCursor utility...

:: 1. Create target directory if it does not exist
if not exist "C:\Scripts" mkdir "C:\Scripts"

:: 2. Download ZIP archive using Curl
echo [INSTALLATION] Retrieving package from source...
curl -L "https://www.softwareok.com/Download/AutoHideMouseCursor_x64.zip" -o "C:\Scripts\temp_mouse.zip"

:: 3. Extraction via PowerShell (Silent & Forced)
echo [INSTALLATION] Extracting files to C:\Scripts...
powershell -Command "Expand-Archive -LiteralPath 'C:\Scripts\temp_mouse.zip' -DestinationPath 'C:\Scripts' -Force"

:: 4. Cleanup temporary files
if exist "C:\Scripts\temp_mouse.zip" del "C:\Scripts\temp_mouse.zip"

:: 5. AUTO-START CONFIGURATION
:: Adds the executable to the Current User Run key for persistence after login
echo [CONFIGURATION] Registering auto-start entry...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "HideMouseCursor" /t REG_SZ /d "C:\Scripts\AutoHideMouseCursor_x64.exe" /f >nul

:: --- 6. TERMINATION ---
echo.
echo Kiosk configuration and tool installation completed successfully.
timeout /t 3
exit