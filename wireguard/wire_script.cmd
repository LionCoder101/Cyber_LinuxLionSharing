@echo off
setlocal
title WireGuard Standard User Configuration

:: ---- Auto-elevate: ask for Administrator permission (UAC) if not already admin ----
fltmc >nul 2>&1
if not errorlevel 1 goto :run_as_admin
if /i "%~1"=="elevated" goto :run_as_admin

echo Requesting Administrator permission...
set "WG_SELF=%~f0"
powershell -NoProfile -Command "try { Start-Process -FilePath $env:WG_SELF -ArgumentList 'elevated' -Verb RunAs -ErrorAction Stop } catch { Write-Host '[ERROR] Administrator permission was not granted.' -ForegroundColor Red; exit 1 }"
if errorlevel 1 (
    echo.
    pause
)
exit /b

:run_as_admin
powershell -NoProfile -ExecutionPolicy Bypass -Command "$raw = Get-Content -LiteralPath '%~f0' -Raw; $marker = '#PSCODE#'; $idx = $raw.LastIndexOf($marker); if ($idx -lt 0) { exit 1 }; $code = $raw.Substring($idx + $marker.Length); Invoke-Expression $code"

echo.
pause
exit /b

#PSCODE#

$ErrorActionPreference = "Stop"
$ProgressPreference    = "SilentlyContinue"   # makes Invoke-WebRequest downloads much faster

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " PC Setup (Apps + Language + WireGuard)" -ForegroundColor Cyan
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

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# =====================================================================
# STEP A: Change computer name (asked first, so the rest can run unattended)
# =====================================================================
$csInfo = Get-CimInstance Win32_ComputerSystem
Write-Host ""
Write-Host "Current computer name: $env:COMPUTERNAME" -ForegroundColor Cyan

while ($true) {
    $newName = Read-Host "Enter NEW computer name (press Enter to keep the current name)"
    $newName = "$newName".Trim()

    if (-not $newName -or $newName -ieq $env:COMPUTERNAME) {
        Write-Host "[INFO] Computer name not changed." -ForegroundColor Yellow
        break
    }
    # Rules: 1-15 chars, letters / numbers / hyphen, not only numbers, no hyphen at start or end
    if ($newName -notmatch '^(?=.{1,15}$)(?!\d+$)[A-Za-z0-9]([A-Za-z0-9-]*[A-Za-z0-9])?$') {
        Write-Host "[ERROR] Invalid name. Use 1-15 letters, numbers or '-' (not only numbers, no '-' at start/end)." -ForegroundColor Red
        continue
    }

    try {
        if ($csInfo.PartOfDomain) {
            # AD domain-joined PCs need a domain account to rename the computer object
            $domainCred = Get-Credential -Message "Domain account to rename this computer in $($csInfo.Domain)"
            Rename-Computer -NewName $newName -DomainCredential $domainCred -Force -ErrorAction Stop -WarningAction SilentlyContinue
        }
        else {
            Rename-Computer -NewName $newName -Force -ErrorAction Stop -WarningAction SilentlyContinue
        }
        Write-Host "[OK] Computer name will change to '$newName' after restart." -ForegroundColor Green
        break
    }
    catch {
        Write-Host "[ERROR] Rename failed: $($_.Exception.Message)" -ForegroundColor Red
        if ((Read-Host "Try again? (Y/N)") -notmatch '^[Yy]') { break }
    }
}

# Office suite choice (asked now, so the rest can run unattended)
Write-Host ""
Write-Host "Which Office suite do you want to install?" -ForegroundColor Cyan
Write-Host "  1 = WPS Office"
Write-Host "  2 = Microsoft 365 (Office 365: Word, Excel, PowerPoint, Outlook, OneNote)"
Write-Host "  3 = None (skip)"
while ($true) {
    $officeChoice = "$(Read-Host 'Enter 1, 2 or 3')".Trim()
    if ($officeChoice -in "1", "2", "3") { break }
    Write-Host "[ERROR] Please enter 1, 2 or 3." -ForegroundColor Red
}
switch ($officeChoice) {
    "1" { Write-Host "[INFO] WPS Office will be installed." -ForegroundColor Cyan }
    "2" { Write-Host "[INFO] Microsoft 365 will be installed." -ForegroundColor Cyan }
    "3" { Write-Host "[INFO] No Office suite will be installed." -ForegroundColor Yellow }
}

# =====================================================================
# STEP B: Install apps (only if they are NOT already installed)
# =====================================================================
Write-Host ""
Write-Host "---- Installing apps ----" -ForegroundColor Cyan

# Is an app installed? Checks machine-wide and every loaded user profile.
function Test-AppInstalled([string[]]$DisplayNamePatterns) {
    $keys = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
        "Registry::HKEY_USERS\*\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )
    $names = Get-ItemProperty -Path $keys -ErrorAction SilentlyContinue | ForEach-Object { $_.DisplayName }
    foreach ($p in $DisplayNamePatterns) {
        if ($names | Where-Object { $_ -like $p }) { return $true }
    }
    return $false
}

# Download a file and check that it is signed by the expected publisher
function Get-SignedDownload([string]$Url, [string]$FileName, [string]$SignerPattern) {
    $dir = Join-Path $env:TEMP ("pcsetup-" + [guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $dir -Force | Out-Null
    $path = Join-Path $dir $FileName
    Invoke-WebRequest -Uri $Url -OutFile $path -UseBasicParsing
    $sig = Get-AuthenticodeSignature -FilePath $path
    if ($sig.Status -ne "Valid" -or $sig.SignerCertificate.Subject -notmatch $SignerPattern) {
        Remove-Item $dir -Recurse -Force -ErrorAction SilentlyContinue
        throw "Signature check failed for $FileName."
    }
    return $path
}

# Find winget.exe (also works when running as a different admin account)
function Get-WingetPath {
    $cmd = Get-Command winget.exe -ErrorAction SilentlyContinue
    if ($cmd) { return $cmd.Source }
    $found = Resolve-Path "$env:ProgramFiles\WindowsApps\Microsoft.DesktopAppInstaller_*__8wekyb3d8bbwe\winget.exe" -ErrorAction SilentlyContinue |
        Sort-Object Path -Descending | Select-Object -First 1
    if ($found) { return $found.Path }
    return $null
}
$winget = Get-WingetPath

# Install with winget for all users (machine scope); falls back to the package's default scope
function Install-WithWinget([string]$Id) {
    if (-not $winget) { throw "winget is not available on this PC." }
    $common = @("install", "--id", $Id, "--exact", "--source", "winget", "--silent",
                "--accept-package-agreements", "--accept-source-agreements", "--disable-interactivity")
    & $winget @common --scope machine | Out-Null
    if ($LASTEXITCODE -eq 0) { return }
    & $winget @common | Out-Null
    if ($LASTEXITCODE -ne 0) { throw "winget failed (exit code $LASTEXITCODE)." }
}

$archIsX86 = -not [Environment]::Is64BitOperatingSystem

$apps = @(
    @{
        Name    = "Google Chrome"
        Check   = { (Test-Path "$env:ProgramFiles\Google\Chrome\Application\chrome.exe") -or
                    (Test-Path "${env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe") -or
                    (Test-AppInstalled "Google Chrome") }
        Install = {
            $msiFile = if ($archIsX86) { "googlechromestandaloneenterprise.msi" } else { "googlechromestandaloneenterprise64.msi" }
            $msi = Get-SignedDownload "https://dl.google.com/dl/chrome/install/$msiFile" $msiFile "Google"
            $p = Start-Process msiexec.exe -ArgumentList "/i `"$msi`" /qn /norestart" -Wait -PassThru
            Remove-Item (Split-Path $msi) -Recurse -Force -ErrorAction SilentlyContinue
            if ($p.ExitCode -notin 0, 3010) { throw "msiexec exit code $($p.ExitCode)" }
        }
    },
    @{
        Name    = "7-Zip"
        Check   = { Test-AppInstalled "7-Zip*" }
        Install = { Install-WithWinget "7zip.7zip" }
    },
    @{
        Name    = "Microsoft Teams"
        Check   = {
            $found = Test-AppInstalled "Microsoft Teams*", "Teams Machine-Wide Installer"
            if (-not $found) {
                try { $found = [bool](Get-AppxPackage -AllUsers -Name "MSTeams" -ErrorAction Stop) } catch { }
            }
            if (-not $found) {
                try { $found = [bool](Get-AppxProvisionedPackage -Online -ErrorAction Stop | Where-Object DisplayName -eq "MSTeams") } catch { }
            }
            if (-not $found) {
                try { $found = [bool](Get-AppxPackage -Name "MSTeams" -ErrorAction Stop) } catch { }
            }
            $found
        }
        Install = {
            # Official Teams bootstrapper; "-p" installs (provisions) Teams for all users
            $exe = Get-SignedDownload "https://go.microsoft.com/fwlink/?linkid=2243204&clcid=0x409" "teamsbootstrapper.exe" "Microsoft Corporation"
            $p = Start-Process $exe -ArgumentList "-p" -Wait -PassThru -WindowStyle Hidden
            Remove-Item (Split-Path $exe) -Recurse -Force -ErrorAction SilentlyContinue
            if ($p.ExitCode -ne 0) { throw "Teams bootstrapper exit code $($p.ExitCode)" }
        }
    },
    @{
        Name    = "Foxit PDF Reader"
        Check   = { Test-AppInstalled "Foxit PDF Reader*", "Foxit Reader*" }
        Install = { Install-WithWinget "Foxit.FoxitReader" }
    }
)

if ($officeChoice -eq "1") {
    $apps += @{
        Name    = "WPS Office"
        Check   = { Test-AppInstalled "WPS Office*" }
        Install = { Install-WithWinget "Kingsoft.WPSOffice" }
    }
}
elseif ($officeChoice -eq "2") {
    $apps += @{
        Name    = "Microsoft 365"
        Check   = {
            $c2r = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Office\ClickToRun\Configuration" -ErrorAction SilentlyContinue
            ($c2r -and $c2r.ProductReleaseIds -match "O365|365") -or (Test-AppInstalled "Microsoft 365*", "Microsoft Office 365*")
        }
        Install = {
            # Official Office Deployment Tool (ODT) with a silent configuration
            $setup = Get-SignedDownload "https://officecdn.microsoft.com/pr/wsus/setup.exe" "setup.exe" "Microsoft Corporation"
            $odtDir = Split-Path $setup
            $odtBits = if ($archIsX86) { "32" } else { "64" }
            $xml = @"
<Configuration>
  <Add OfficeClientEdition="$odtBits" Channel="Current">
    <Product ID="O365ProPlusRetail">
      <Language ID="MatchOS" Fallback="en-us" />
      <ExcludeApp ID="Groove" />
      <ExcludeApp ID="Lync" />
      <ExcludeApp ID="Teams" />
    </Product>
  </Add>
  <Property Name="SharedComputerLicensing" Value="0" />
  <Property Name="FORCEAPPSHUTDOWN" Value="TRUE" />
  <Updates Enabled="TRUE" />
  <Display Level="None" AcceptEULA="TRUE" />
</Configuration>
"@
            $xmlPath = Join-Path $odtDir "config.xml"
            Set-Content -Path $xmlPath -Value $xml -Encoding UTF8
            Write-Host "       (Microsoft 365 download is about 3 GB - this can take a long time)" -ForegroundColor Yellow
            $p = Start-Process $setup -ArgumentList "/configure `"$xmlPath`"" -Wait -PassThru -WindowStyle Hidden
            Remove-Item $odtDir -Recurse -Force -ErrorAction SilentlyContinue
            if ($p.ExitCode -ne 0) { throw "Office setup exit code $($p.ExitCode)" }
        }
    }
}

$appResults = @()
foreach ($app in $apps) {
    if (& $app.Check) {
        Write-Host "[SKIP] $($app.Name) is already installed." -ForegroundColor Green
        $appResults += "$($app.Name): already installed"
        continue
    }
    Write-Host "[INFO] Installing $($app.Name) ..." -ForegroundColor Cyan
    try {
        & $app.Install
        if (& $app.Check) {
            Write-Host "[OK] $($app.Name) installed." -ForegroundColor Green
            $appResults += "$($app.Name): installed"
        }
        else {
            Write-Host "[WARNING] $($app.Name) installer finished, but the app was not detected." -ForegroundColor Yellow
            $appResults += "$($app.Name): NOT detected after install"
        }
    }
    catch {
        Write-Host "[ERROR] $($app.Name) install failed: $($_.Exception.Message)" -ForegroundColor Red
        $appResults += "$($app.Name): FAILED"
    }
}

# =====================================================================
# STEP C: Japanese + Myanmar language / fonts / keyboards
# =====================================================================
Write-Host ""
Write-Host "---- Languages (Japanese / Myanmar) ----" -ForegroundColor Cyan

# Japanese language features (typing, fonts, etc.) - downloads from Windows Update, may take several minutes
try {
    if (Get-Command Install-Language -ErrorAction SilentlyContinue) {
        if (Get-InstalledLanguage -Language "ja-JP" -ErrorAction SilentlyContinue) {
            Write-Host "[SKIP] Japanese language is already installed." -ForegroundColor Green
        }
        else {
            Write-Host "[INFO] Installing Japanese language (this can take several minutes)..." -ForegroundColor Cyan
            Install-Language -Language "ja-JP" -ErrorAction Stop | Out-Null
            Write-Host "[OK] Japanese language installed." -ForegroundColor Green
        }
    }
    else {
        foreach ($capName in "Language.Basic~~~ja-JP~0.0.1.0") {
            $cap = Get-WindowsCapability -Online -Name $capName
            if ($cap.State -ne "Installed") { Add-WindowsCapability -Online -Name $capName | Out-Null }
        }
        Write-Host "[OK] Japanese language (basic typing) installed." -ForegroundColor Green
    }
}
catch {
    Write-Host "[WARNING] Japanese language install failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Japanese supplemental fonts + any Myanmar language features offered by Windows
try {
    $fontCaps = @(Get-WindowsCapability -Online | Where-Object {
        $_.Name -like "Language.Fonts.Jpan*" -or $_.Name -like "Language.*~my-MM~*" -or $_.Name -like "Language.Fonts.Mymr*"
    })
    foreach ($cap in $fontCaps) {
        if ($cap.State -ne "Installed") {
            Write-Host "[INFO] Installing $($cap.Name) ..." -ForegroundColor Cyan
            Add-WindowsCapability -Online -Name $cap.Name | Out-Null
        }
    }
    Write-Host "[OK] Japanese fonts ready." -ForegroundColor Green
}
catch {
    Write-Host "[WARNING] Font install failed: $($_.Exception.Message)" -ForegroundColor Yellow
}

# Myanmar font ("Myanmar Text") is built into Windows 10/11
if (Test-Path "$env:windir\Fonts\mmrtext.ttf") {
    Write-Host "[OK] Myanmar font (Myanmar Text) is available." -ForegroundColor Green
}
else {
    Write-Host "[WARNING] Myanmar font (Myanmar Text) not found." -ForegroundColor Yellow
}

# Keyboards are per-user settings. This script runs as the admin account, so a small
# logon task adds Japanese + Myanmar keyboards for each user when they sign in.
try {
    $langCmd = '$l = Get-WinUserLanguageList; $c = $false; ' +
               'foreach ($t in "ja-JP","my-MM") { if (-not ($l | Where-Object LanguageTag -eq $t)) { $l.Add($t); $c = $true } }; ' +
               'if ($c) { Set-WinUserLanguageList $l -Force }'
    $langEnc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($langCmd))
    $usersGroup = (New-Object Security.Principal.SecurityIdentifier("S-1-5-32-545")).Translate([Security.Principal.NTAccount]).Value

    Register-ScheduledTask -TaskName "Add Japanese and Myanmar keyboards" -Force `
        -Action (New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-NoProfile -WindowStyle Hidden -EncodedCommand $langEnc") `
        -Trigger (New-ScheduledTaskTrigger -AtLogOn) `
        -Principal (New-ScheduledTaskPrincipal -GroupId $usersGroup -RunLevel Limited) | Out-Null
    Write-Host "[OK] Japanese + Myanmar keyboards will be added for each user at sign-in." -ForegroundColor Green
}
catch {
    Write-Host "[WARNING] Could not create keyboard logon task: $($_.Exception.Message)" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "---- WireGuard ----" -ForegroundColor Cyan

# ===== WireGuard: download -> uninstall old -> clean install =====
$wgExe     = Join-Path $env:ProgramFiles "WireGuard\wireguard.exe"
$wgConfDir = Join-Path $env:ProgramFiles "WireGuard\Data\Configurations"

# Find installed WireGuard MSI products
$uninstallKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)
$wgProducts = @(Get-ItemProperty -Path $uninstallKeys -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -eq "WireGuard" -and $_.PSChildName -match "^\{.+\}$" })
$wgInstalled = ($wgProducts.Count -gt 0) -or (Test-Path $wgExe)

if ($wgInstalled) {
    Write-Host "[INFO] Existing WireGuard found. It will be uninstalled and reinstalled." -ForegroundColor Yellow
}
else {
    Write-Host "[INFO] WireGuard is not installed. Installing automatically..." -ForegroundColor Yellow
}

# Step 1: Download the installer FIRST (so we never uninstall without a new installer ready)
$arch = $env:PROCESSOR_ARCHITEW6432
if (-not $arch) { $arch = $env:PROCESSOR_ARCHITECTURE }
switch ($arch) {
    "AMD64" { $msiArch = "amd64" }
    "ARM64" { $msiArch = "arm64" }
    default { $msiArch = "x86" }
}

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$baseUrl = "https://download.wireguard.com/windows-client/"

$msiName = "wireguard-$msiArch-0.5.3.msi"   # fallback version
try {
    $listing = (Invoke-WebRequest -Uri $baseUrl -UseBasicParsing).Content
    $found = [regex]::Matches($listing, "wireguard-$msiArch-([0-9.]+)\.msi") |
        Sort-Object { [version]$_.Groups[1].Value } -Descending |
        Select-Object -First 1
    if ($found) { $msiName = $found.Value }
}
catch {
    Write-Host "[WARNING] Could not read version list. Using fallback: $msiName" -ForegroundColor Yellow
}

$msiPath = Join-Path $env:TEMP $msiName
$msiReady = $false

try {
    Write-Host "[INFO] Downloading $msiName ..." -ForegroundColor Cyan
    Invoke-WebRequest -Uri ($baseUrl + $msiName) -OutFile $msiPath -UseBasicParsing

    $sig = Get-AuthenticodeSignature -FilePath $msiPath
    if ($sig.Status -eq "Valid" -and $sig.SignerCertificate.Subject -match "WireGuard LLC") {
        Write-Host "[OK] Installer signature verified (WireGuard LLC)." -ForegroundColor Green
        $msiReady = $true
    }
    else {
        Write-Host "[ERROR] Installer signature check failed." -ForegroundColor Red
        Remove-Item $msiPath -Force -ErrorAction SilentlyContinue
    }
}
catch {
    Write-Host "[ERROR] Download failed: $($_.Exception.Message)" -ForegroundColor Red
}

if (-not $msiReady) {
    if ($wgInstalled) {
        Write-Host "[WARNING] Keeping the existing WireGuard (no reinstall)." -ForegroundColor Yellow
    }
    else {
        Write-Host "Check internet connection, or install WireGuard manually from https://www.wireguard.com/install/" -ForegroundColor Yellow
        exit
    }
}
else {
    # Step 2: Back up tunnel configs (uninstall deletes them)
    $backupDir = $null
    if (Test-Path $wgConfDir) {
        $backupDir = Join-Path $env:ProgramData ("WireGuard-Backup\" + (Get-Date -Format "yyyyMMdd-HHmmss"))
        New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        # Only SYSTEM and Administrators can access the backup
        & icacls.exe $backupDir /inheritance:r /grant:r "*S-1-5-18:(OI)(CI)F" "*S-1-5-32-544:(OI)(CI)F" | Out-Null

        & robocopy.exe $wgConfDir $backupDir /E /B /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -lt 8) {
            Write-Host "[OK] Tunnel configs backed up to: $backupDir" -ForegroundColor Green
        }
        else {
            Write-Host "[ERROR] Tunnel config backup failed (robocopy code $LASTEXITCODE). Uninstall cancelled." -ForegroundColor Red
            exit
        }
    }

    # Step 3: Uninstall existing WireGuard
    foreach ($p in $wgProducts) {
        Write-Host "[INFO] Uninstalling WireGuard $($p.DisplayVersion) ..." -ForegroundColor Cyan
        $u = Start-Process -FilePath "msiexec.exe" `
            -ArgumentList "/x $($p.PSChildName) /qn /norestart" -Wait -PassThru
        if ($u.ExitCode -in 0, 1605, 3010) {
            Write-Host "[OK] Old WireGuard uninstalled." -ForegroundColor Green
        }
        else {
            Write-Host "[ERROR] Uninstall failed. (msiexec exit code: $($u.ExitCode))" -ForegroundColor Red
            exit
        }
    }

    # Step 4: Clean install
    Write-Host "[INFO] Installing WireGuard (silent)..." -ForegroundColor Cyan
    $proc = Start-Process -FilePath "msiexec.exe" `
        -ArgumentList "/i `"$msiPath`" /qn /norestart DO_NOT_LAUNCH=1" `
        -Wait -PassThru

    Remove-Item $msiPath -Force -ErrorAction SilentlyContinue

    if (($proc.ExitCode -ne 0 -and $proc.ExitCode -ne 3010) -or -not (Test-Path $wgExe)) {
        Write-Host "[ERROR] WireGuard installation failed. (msiexec exit code: $($proc.ExitCode))" -ForegroundColor Red
        if ($backupDir) { Write-Host "Tunnel config backup is kept at: $backupDir" -ForegroundColor Yellow }
        exit
    }
    Write-Host "[OK] WireGuard installed successfully." -ForegroundColor Green

    # Step 5: Restore tunnel configs
    if ($backupDir) {
        New-Item -ItemType Directory -Path $wgConfDir -Force | Out-Null
        & robocopy.exe $backupDir $wgConfDir /E /B /R:1 /W:1 /NFL /NDL /NJH /NJS /NP | Out-Null
        if ($LASTEXITCODE -lt 8) {
            Write-Host "[OK] Tunnel configs restored." -ForegroundColor Green
        }
        else {
            Write-Host "[WARNING] Could not restore tunnel configs. Backup is at: $backupDir" -ForegroundColor Yellow
        }
    }
}

# ===== Detect device join type (Entra ID / Hybrid / AD Domain / Workgroup) =====
$cs = Get-CimInstance Win32_ComputerSystem
$entraJoined = $false
try {
    $dsreg = & "$env:SystemRoot\System32\dsregcmd.exe" /status 2>$null
    if ($dsreg -match "AzureAdJoined\s*:\s*YES") { $entraJoined = $true }
}
catch { }

if ($entraJoined -and $cs.PartOfDomain) { $joinType = "Hybrid (Entra ID + AD Domain)" }
elseif ($entraJoined)                   { $joinType = "Entra ID joined" }
elseif ($cs.PartOfDomain)               { $joinType = "AD Domain joined ($($cs.Domain))" }
else                                    { $joinType = "Workgroup (not joined)" }

Write-Host "[INFO] Device join type: $joinType" -ForegroundColor Cyan

# ===== Detect the logged-on user of THIS desktop session =====
# When a standard user uses "Run as administrator" with an admin password, the script runs
# as the admin account but in the standard user's session, so this still finds the standard user.
$interactiveUser = $null
$interactiveSid  = $null
try {
    $mySession = (Get-Process -Id $PID).SessionId
    $explorer = Get-CimInstance Win32_Process -Filter "Name='explorer.exe' AND SessionId=$mySession" |
        Select-Object -First 1
    if ($explorer) {
        $interactiveSid = (Invoke-CimMethod -InputObject $explorer -MethodName GetOwnerSid).Sid
        $owner = Invoke-CimMethod -InputObject $explorer -MethodName GetOwner
        if ($owner.User) { $interactiveUser = "$($owner.Domain)\$($owner.User)" }
    }
}
catch { }

if (-not $interactiveSid) {
    Write-Host "[ERROR] Could not detect the logged-on user." -ForegroundColor Red
    Write-Host "        Sign in as the user who will use WireGuard, then run this script again." -ForegroundColor Yellow
    exit
}
Write-Host "[INFO] Logged-on user: $interactiveUser ($interactiveSid)" -ForegroundColor Cyan

# ===== Add the user to the local Administrators group (S-1-5-32-544) =====
# Members of Administrators get the full WireGuard UI (add / edit / delete / import / export tunnels).
# The user is added by SID, so this works for local, AD and Entra ID accounts.
$adminGroupSid  = "S-1-5-32-544"
$adminGroupName = (New-Object Security.Principal.SecurityIdentifier($adminGroupSid)).Translate(
    [Security.Principal.NTAccount]).Value.Split("\")[-1]

# Read member SIDs with ADSI (Get-LocalGroupMember can fail on Entra-joined PCs)
function Get-GroupMemberSids([string]$Name) {
    $group = [ADSI]"WinNT://$env:COMPUTERNAME/$Name,group"
    foreach ($m in @($group.Invoke("Members"))) {
        $sidBytes = $m.GetType().InvokeMember("objectSid", "GetProperty", $null, $m, $null)
        (New-Object Security.Principal.SecurityIdentifier($sidBytes, 0)).Value
    }
}

if (@(Get-GroupMemberSids $adminGroupName) -contains $interactiveSid) {
    Write-Host "[OK] $interactiveUser is already in the Administrators group." -ForegroundColor Green
}
else {
    Write-Host "[INFO] Adding $interactiveUser to the Administrators group..." -ForegroundColor Cyan
    try {
        Add-LocalGroupMember -SID $adminGroupSid `
            -Member (New-Object Security.Principal.SecurityIdentifier($interactiveSid)) -ErrorAction Stop
    }
    catch {
        # Fallback for Entra ID users (Add-LocalGroupMember can fail on cloud SIDs)
        try { ([ADSI]"WinNT://$env:COMPUTERNAME/$adminGroupName,group").Add("WinNT://$interactiveSid") }
        catch { }
    }

    if (@(Get-GroupMemberSids $adminGroupName) -contains $interactiveSid) {
        Write-Host "[OK] $interactiveUser added to the Administrators group." -ForegroundColor Green
    }
    else {
        Write-Host "[ERROR] Could not add $interactiveUser to the Administrators group." -ForegroundColor Red
        Write-Host "        Add the user manually, then restart:" -ForegroundColor Yellow
        if ($entraJoined -and -not $cs.PartOfDomain) {
            Write-Host "        net localgroup `"$adminGroupName`" `"AzureAD\user@yourdomain.com`" /add" -ForegroundColor White
        }
        else {
            Write-Host "        net localgroup `"$adminGroupName`" `"$interactiveUser`" /add" -ForegroundColor White
        }
        exit
    }
}

# ===== Clean up items created by older versions of this script =====
$publicDesktop = [Environment]::GetFolderPath("CommonDesktopDirectory")
$oldEditorLnk  = Join-Path $publicDesktop "WireGuard Tunnel Editor.lnk"
$oldEditorDir  = Join-Path $env:ProgramFiles "WireGuardEditor"
if (Test-Path $oldEditorLnk) { Remove-Item $oldEditorLnk -Force -ErrorAction SilentlyContinue }
if (Test-Path $oldEditorDir) { Remove-Item $oldEditorDir -Recurse -Force -ErrorAction SilentlyContinue }

# ===== Windows 11: always show the WireGuard tray icon for the user (best effort) =====
# The entry only exists after WireGuard's tray icon has appeared once in that user's session.
$notifyKey = "Registry::HKEY_USERS\$interactiveSid\Control Panel\NotifyIconSettings"
if (Test-Path $notifyKey) {
    Get-ChildItem $notifyKey -ErrorAction SilentlyContinue | ForEach-Object {
        $exePath = (Get-ItemProperty $_.PSPath -ErrorAction SilentlyContinue).ExecutablePath
        if ($exePath -like "*\WireGuard\wireguard.exe") {
            Set-ItemProperty -Path $_.PSPath -Name "IsPromoted" -Value 1 -Type DWord
            Write-Host "[OK] WireGuard tray icon set to always visible." -ForegroundColor Green
        }
    }
}

Write-Host ""
Write-Host "======================================" -ForegroundColor Cyan
Write-Host " Configuration completed." -ForegroundColor Green
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Apps:" -ForegroundColor Cyan
$appResults | ForEach-Object { Write-Host "  - $_" }
Write-Host ""
Write-Host "After the restart, $interactiveUser can use ALL WireGuard features" -ForegroundColor White
Write-Host "(add / edit / delete / import tunnels). Open WireGuard from the tray icon or Start menu" -ForegroundColor White
Write-Host "and click 'Yes' if Windows asks for permission." -ForegroundColor White

# ===== Automatic restart (needed so the new group membership takes effect) =====
$restartSeconds = 60
& shutdown.exe /r /t $restartSeconds /c "WireGuard configuration completed. Windows will restart in $restartSeconds seconds. Please save your work."
Write-Host ""
Write-Host "[INFO] Windows will restart automatically in $restartSeconds seconds." -ForegroundColor Yellow
Write-Host "       Save your work now. To cancel the restart, run:  shutdown /a" -ForegroundColor Yellow
