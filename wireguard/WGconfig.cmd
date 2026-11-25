@echo off
setlocal
title WireGuard Standard User Configuration

powershell -NoProfile -ExecutionPolicy Bypass -Command "$raw = Get-Content -LiteralPath '%~f0' -Raw; $marker = '#PSCODE#'; $idx = $raw.IndexOf($marker); if ($idx -lt 0) { exit 1 }; $code = $raw.Substring($idx + $marker.Length); Invoke-Expression $code"

echo.
pause
exit /b

#PSCODE#

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " WireGuard Standard User Configuration" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# Check Administrator
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)

$isAdmin = $principal.IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator
)

if (-not $isAdmin) {
    Write-Host "[ERROR] Please run as Administrator." -ForegroundColor Red
    exit
}

Write-Host "[OK] Administrator privilege detected." -ForegroundColor Green

# Check WireGuard installation
$wgExe = Join-Path $env:ProgramFiles "WireGuard\wireguard.exe"

if (-not (Test-Path $wgExe)) {
    Write-Host "[ERROR] WireGuard is not installed." -ForegroundColor Red
    Write-Host "Please install WireGuard for Windows first." -ForegroundColor Yellow
    exit
}

Write-Host "[OK] WireGuard installation detected." -ForegroundColor Green

# Configure Registry
$regPath = "HKLM:\SOFTWARE\WireGuard"

if (-not (Test-Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

New-ItemProperty `
    -Path $regPath `
    -Name "LimitedOperatorUI" `
    -PropertyType DWord `
    -Value 1 `
    -Force | Out-Null

Write-Host "[OK] LimitedOperatorUI configured." -ForegroundColor Green

# Detect interactive user
$interactiveUser = (Get-CimInstance Win32_ComputerSystem).UserName

if ($interactiveUser) {
    Write-Host "[INFO] Interactive user: $interactiveUser" -ForegroundColor Cyan
}
else {
    Write-Host "[WARNING] Interactive user could not be detected." -ForegroundColor Yellow
}

# Check Network Configuration Operators
try {
    $group = Get-LocalGroup -SID "S-1-5-32-556"

    $members = Get-LocalGroupMember -Group $group.Name -ErrorAction Stop

    Write-Host ""
    Write-Host "Network Configuration Operators:" -ForegroundColor Cyan

    if ($members) {
        $members | ForEach-Object {
            Write-Host "  $($_.Name)"
        }
    }
    else {
        Write-Host "  No members found."
    }

    Write-Host ""
    Write-Host "[INFO] Group membership was not changed." -ForegroundColor Yellow
}
catch {
    Write-Host "[WARNING] Could not inspect group membership." -ForegroundColor Yellow
    Write-Host $_.Exception.Message
}

# Create Public Desktop shortcut
$publicDesktop = [Environment]::GetFolderPath("CommonDesktopDirectory")

$shortcutPath = Join-Path $publicDesktop "WireGuard.lnk"

$ws = New-Object -ComObject WScript.Shell
$shortcut = $ws.CreateShortcut($shortcutPath)

$shortcut.TargetPath = $wgExe
$shortcut.WorkingDirectory = Split-Path $wgExe
$shortcut.Description = "WireGuard"

$shortcut.Save()

Write-Host "[OK] Public Desktop shortcut created." -ForegroundColor Green

# Verify Registry
$regValue = Get-ItemProperty `
    -Path $regPath `
    -Name "LimitedOperatorUI"

if ($regValue.LimitedOperatorUI -eq 1) {
    Write-Host "[OK] Registry verification successful." -ForegroundColor Green
}
else {
    Write-Host "[ERROR] Registry verification failed." -ForegroundColor Red
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " Configuration completed." -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Please restart Windows or sign out/in." -ForegroundColor Yellow