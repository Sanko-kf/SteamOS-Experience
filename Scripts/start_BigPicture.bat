@echo off
title Launch Steam Big Picture & Terminate Shell
color 0B

:: ============================================================================
:: SCRIPT NAME: Launch Steam Big Picture & Shell Manager
:: ============================================================================

:: --- 1. PRE-LAUNCH CLEANUP (CLOSE OPEN APPS) ---
:: Closes non-essential windows to free up resources and ensure focus
echo Closing open applications...
taskkill /F /FI "WINDOWTITLE ne null" /FI "IMAGENAME ne steam.exe" /FI "IMAGENAME ne cmd.exe" /FI "IMAGENAME ne conhost.exe" /FI "IMAGENAME ne explorer.exe" /FI "IMAGENAME ne taskmgr.exe" >nul 2>&1

:: --- 2. SET WORKING DIRECTORY ---
cd /d "C:\Program Files (x86)\Steam"

:: --- 3. CHECK STEAM PROCESS STATUS ---
:: Verify if Steam is running to choose the correct launch protocol
tasklist /FI "IMAGENAME eq steam.exe" 2>NUL | find /I /N "steam.exe">NUL

if "%ERRORLEVEL%"=="0" (
    :: Steam is active: Trigger Big Picture mode via URI
    start "" "steam://open/bigpicture"
) else (
    :: Steam is closed: Cold boot directly into Big Picture mode
    start "" steam.exe -bigpicture
)

:: --- 4. INTERFACE BUFFER ---
:: Brief pause to let the UI initialize
timeout /t 5 /nobreak >nul

:: --- 5. TERMINATE WINDOWS SHELL ---
:: Kill explorer.exe to enter dedicated Kiosk mode
taskkill /F /IM explorer.exe >nul 2>&1

:: =========================================================
:: 6. ADDITIONAL INITIALIZATION DELAY (15 Seconds)
:: =========================================================
timeout /t 15 /nobreak >nul

:: =========================================================
:: 7. LAUNCH DESKTOP DETECTOR
:: =========================================================
:: Background watchdog to monitor session state
start "" "C:\Scripts\desktop_detector.exe"

:: =========================================================
:: 8. TOOL INITIALIZATION
:: =========================================================

:: A. Lossless Scaling (Start Minimized)
set "LosslessPath=C:\Program Files (x86)\Steam\steamapps\common\Lossless Scaling\LosslessScaling.exe"
if exist "%LosslessPath%" (
    start "" "%LosslessPath%" -StartMinimized
)

:: B. AutoHideMouseCursor (Background start)
start "" "C:\Scripts\AutoHideMouseCursor_x64.exe" -bg

:: =========================================================
:: 9. SETTLING PERIOD (10 Seconds)
:: =========================================================
:: Allow background processes to fully initialize...
timeout /t 10 /nobreak >nul

:: =========================================================
:: 10. FINAL TOOL MANAGEMENT
:: =========================================================

:: A. TERMINATE Mouse Hider (Prevents interference within Steam UI)
taskkill /F /IM "AutoHideMouseCursor_x64.exe" >nul 2>&1

:: B. MINIMIZE Lossless Scaling (Background operation)
:: Force state "6" (MINIMIZE) via PowerShell for a clean taskbar-free environment
powershell -command "$d='[DllImport(\"user32.dll\")] public static extern bool ShowWindow(int h, int s);';$t=Add-Type -MemberDefinition $d -Name W -PassThru;$p=Get-Process LosslessScaling -ErrorAction SilentlyContinue;if($p){$t::ShowWindow($p.MainWindowHandle, 6)}"

exit