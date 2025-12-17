@echo off
setlocal EnableDelayedExpansion
title Custom Windows Setup (SteamOS Experience)
color 0B

:: ============================================================================
:: 1. ADMINISTRATOR PRIVILEGES CHECK
:: ============================================================================
:: Validates that the script is running with elevated permissions for registry and system changes
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] This script must be run as Administrator.
    pause
    exit
)

:: ============================================================================
:: 2. CORE INTERFACE SETUP (Dark Mode & Desktop Cleanup)
:: ============================================================================
echo.
echo [1/6] Applying Theme Settings and Desktop Cleanup...
:: Enable System and App Dark Mode
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v AppsUseLightTheme /t REG_DWORD /d 0 /f >nul
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v SystemUsesLightTheme /t REG_DWORD /d 0 /f >nul
:: Align Taskbar to the Left
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" /v TaskbarAl /t REG_DWORD /d 0 /f >nul
:: Clear Desktop shortcuts and files
del /F /Q "%USERPROFILE%\Desktop\*.*" >nul 2>&1
del /F /Q "C:\Users\Public\Desktop\*.*" >nul 2>&1

:: --- Wallpaper & Lock Screen Configuration ---
if not exist "C:\Assets" mkdir "C:\Assets"
if exist "C:\Assets\wallpaper.jpg" (
    echo    - Setting Desktop Wallpaper...
    powershell -Command "Add-Type -TypeDefinition 'using System; using System.Runtime.InteropServices; public class Wallpaper { [DllImport(\"user32.dll\", CharSet=CharSet.Auto)] public static extern int SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni); }'; [Wallpaper]::SystemParametersInfo(20, 0, 'C:\Assets\wallpaper.jpg', 3)"
)
if exist "C:\Assets\lock_screen.jpg" (
    echo    - Setting Lock Screen Image...
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" /v LockScreenImageStatus /t REG_DWORD /d 1 /f >nul
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" /v LockScreenImagePath /t REG_SZ /d "C:\Assets\lock_screen.jpg" /f >nul
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP" /v LockScreenImageUrl /t REG_SZ /d "C:\Assets\lock_screen.jpg" /f >nul
)

:: ============================================================================
:: 3. CURSOR DEPLOYMENT (Bibata Modern)
:: ============================================================================
echo.
echo [2/6] Preparing Bibata Ice Cursor...

if not exist "C:\Scripts" mkdir "C:\Scripts"

:: Download Cursor Package
curl -L "https://github.com/ful1e5/Bibata_Cursor/releases/download/v2.0.7/Bibata-Modern-Ice-Windows.zip" -o "C:\Assets\cursor.zip"

:: Extract and Cleanup Archive
powershell -Command "Expand-Archive -LiteralPath 'C:\Assets\cursor.zip' -DestinationPath 'C:\Assets' -Force"
del "C:\Assets\cursor.zip"

:: Execute Cursor Installation Script
if exist "C:\Scripts\cursor.ps1" (
    echo    - Running Cursor Installation script...
    powershell -NoProfile -ExecutionPolicy Bypass -File "C:\Scripts\cursor.ps1"
) else (
    echo    - CRITICAL ERROR: C:\Scripts\cursor.ps1 not found!
    pause
)

:: ============================================================================
:: 4. CLEANUP TEMPORARY ASSETS
:: ============================================================================
echo.
echo [3/6] Cleaning up extracted source files...
if exist "C:\Assets\Bibata-Modern-Ice-Windows" rd /s /q "C:\Assets\Bibata-Modern-Ice-Windows"

:: ============================================================================
:: 5. USER AVATAR & SYSTEM TOOLS
:: ============================================================================
echo.
echo [4/6] Configuring User Avatar...
if exist "C:\Assets\avatar.png" (
    set "SYS_PIC=C:\ProgramData\Microsoft\User Account Pictures"
    takeown /f "%SYS_PIC%" /r /d o >nul 2>&1
    icacls "%SYS_PIC%" /grant administrators:F /t >nul 2>&1
    copy /y "C:\Assets\avatar.png" "%SYS_PIC%\user.png" >nul
    copy /y "C:\Assets\avatar.png" "%SYS_PIC%\user-192.png" >nul
    copy /y "C:\Assets\avatar.png" "%SYS_PIC%\guest.png" >nul
    reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" /v UseDefaultTile /t REG_DWORD /d 1 /f >nul
)

echo.
echo [5/6] Deploying "Return to Big Picture" shortcut...
curl -L "https://github.com/Sanko-kf/SteamOS-Experience-Windows/raw/main/Builds/Return%20to%20Big%20Picture.exe" -o "%USERPROFILE%\Desktop\Return to Big Picture.exe"

echo.
echo [6/6] Installing Mozilla Firefox via WinGet...
winget install -e --id Mozilla.Firefox --silent --accept-source-agreements --accept-package-agreements

:: ============================================================================
:: 6. FINALIZING ENVIRONMENT
:: ============================================================================
echo.
echo Restarting Windows Explorer to apply all changes...
taskkill /F /IM explorer.exe >nul 2>&1
start explorer.exe
timeout /t 5 >nul
exit