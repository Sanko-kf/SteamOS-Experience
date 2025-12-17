@echo off
setlocal EnableDelayedExpansion
title CSSLoader Desktop Installation
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
:: Define temporary directory and the official GitHub release URL
set "TempDir=C:\Temp_CSSLoader"
set "MsiName=CSSLoader.msi"
set "DownloadUrl=https://github.com/DeckThemes/CSSLoader-Desktop/releases/download/v1.2.1/CSSLoader.Desktop_1.2.1.msi"

:: --- 3. DOWNLOAD PHASE ---
:: Retrieves the MSI installer using curl
echo.
echo [1/3] Downloading CSSLoader...
if not exist "%TempDir%" mkdir "%TempDir%"
cd /d "%TempDir%"

curl -L -o "%MsiName%" "%DownloadUrl%"

if not exist "%MsiName%" (
    echo [ERROR] Download failed. Please check your internet connection.
    pause
    exit
)

:: --- 4. INSTALLATION PHASE ---
:: Executes the MSI installer and waits for completion
cls
echo.
echo [2/3] Launching installer...
echo.
echo Please complete the installation in the window that just opened.
echo (The script will remain on hold until the installation is finished.)

:: msiexec /i triggers the installation
:: start /wait ensures the script pauses until the installer process terminates
start /wait msiexec /i "%MsiName%"

:: --- 5. VISUAL CONFIGURATION ---
:: Manual intervention for theme setup
cls
echo ========================================================
echo   VISUAL CONFIGURATION REQUIRED
echo ========================================================
echo.
echo 1. Installation is now complete.
echo 2. LAUNCH CSSLOADER (via desktop shortcut or Start menu).
echo    (Note: It may have launched automatically).
echo 3. Install your desired themes and finalize your visual setup.
echo.
echo ONCE ALL CONFIGURATIONS ARE DONE:
echo Press any key here to finalize this script.
echo ========================================================
echo.

pause

:: --- 6. TERMINATION ---
:: Optional: Cleanup temporary installation files
:: cd \
:: rd /s /q "%TempDir%"

exit