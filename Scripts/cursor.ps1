# Assuming Admin privileges as this is launched by the Admin Batch wrapper.
Write-Host ">>> Installing Bibata Modern Ice Cursor..." -ForegroundColor Cyan

# --- 1. CONFIGURATION ---
# Target the specific extracted folder for the "Regular" version
$SourcePath = "C:\Assets\Bibata-Modern-Ice-Regular-Windows"
$DestPath = "C:\Windows\Cursors\Bibata-Modern-Ice"

# --- 2. ROBUST FILE COPY ---
if (-not (Test-Path $DestPath)) {
    New-Item -Path $DestPath -ItemType Directory -Force | Out-Null
}

Write-Host "Copying cursor files to C:\Windows\Cursors..." -ForegroundColor Yellow
# Using robocopy for reliable system folder deployment
$null = robocopy $SourcePath $DestPath /E /IS /IT /NJH /NJS /NFL

# --- 3. REGISTRY MAPPING ---
# Maps Windows cursor roles (Keys) to specific Bibata filenames (Values)
$CursorMap = @{
    "Arrow"       = "Pointer.cur"
    "Help"        = "Help.cur"
    "AppStarting" = "Work.ani"
    "Wait"        = "Busy.ani"
    "Crosshair"   = "Cross.cur"
    "IBeam"       = "Text.cur"
    "NWPen"       = "Handwriting.cur"
    "No"          = "Unavailable.cur"
    "SizeNS"      = "Vert.cur"
    "SizeWE"      = "Horz.cur"
    "SizeNWSE"    = "Dgn1.cur"
    "SizeNESW"    = "Dgn2.cur"
    "SizeAll"     = "Move.cur"
    "UpArrow"     = "Alternate.cur"
    "Hand"        = "Link.cur"
}

$RegBase = "HKCU:\Control Panel\Cursors"

# Apply paths to the current user registry
foreach ($key in $CursorMap.Keys) {
    $fileName = $CursorMap[$key]
    $fullPath = "$DestPath\$fileName"
    
    # Security check: verify file existence before registry write
    if (Test-Path $fullPath) {
        Set-ItemProperty -Path $RegBase -Name $key -Value $fullPath
    } else {
        Write-Warning "Missing file: $fileName"
    }
}

# Define the scheme name
Set-ItemProperty -Path $RegBase -Name "(Default)" -Value "Bibata-Modern-Ice"
Set-ItemProperty -Path $RegBase -Name "Scheme Source" -Value 1

# --- 4. SCHEME REGISTRATION ---
# Allows the scheme to appear in the Windows Mouse Properties menu
$SchemeReg = "HKCU:\Control Panel\Cursors\Schemes"
if (-not (Test-Path $SchemeReg)) { New-Item -Path $SchemeReg -Force | Out-Null }

$SchemeValue = ""
# Strict Windows order required for the 'Schemes' registry key
$Order = @("Arrow", "Help", "AppStarting", "Wait", "Crosshair", "IBeam", "NWPen", "No", "SizeNS", "SizeWE", "SizeNWSE", "SizeNESW", "SizeAll", "UpArrow", "Hand")

foreach ($o in $Order) {
    $f = $CursorMap[$o]
    $SchemeValue += "$DestPath\$f,"
}
$SchemeValue = $SchemeValue.TrimEnd(",")

# Write the scheme definition
Set-ItemProperty -Path $SchemeReg -Name "Bibata-Modern-Ice" -Value $SchemeValue

# --- 5. SYSTEM REFRESH ---
Write-Host "Applying changes immediately..." -ForegroundColor Green

# Refresh the system cursor via User32 API to avoid logout/reboot
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class User32 {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@

# SPI_SETCURSORS = 0x0057, UpdateIniFile | SendChange = 0x03
[User32]::SystemParametersInfo(0x0057, 0, $null, 0x03) | Out-Null

Write-Host "Installation successful!" -ForegroundColor Green