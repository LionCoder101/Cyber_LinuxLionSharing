# WireGuard Standard User Configuration (`WGconfig.cmd`)

Admin မဟုတ်တဲ့ Standard User တွေ WireGuard VPN tunnel ကို **ဖွင့်/ပိတ်** လုပ်လို့ရအောင် Windows ကို configure လုပ်ပေးတဲ့ script ဖြစ်ပါတယ်။

## Script က ဘာတွေလုပ်ပေးလဲ

1. Administrator အနေနဲ့ run ထားလား စစ်ပါတယ်။
2. WireGuard install ထားလား စစ်ပါတယ်။
3. Registry မှာ `HKLM\SOFTWARE\WireGuard\LimitedOperatorUI = 1` ကို သတ်မှတ်ပါတယ်။
4. လက်ရှိ login ဝင်ထားတဲ့ user ကို ရှာပြီး ပြပါတယ်။
5. **Network Configuration Operators** group ထဲမှာ ဘယ်သူတွေ ပါလဲ ပြပါတယ်။ (group ထဲ user ကို ထည့်မပေးပါ)
6. Public Desktop မှာ `WireGuard.lnk` shortcut ဖန်တီးပါတယ်။
7. Registry value ကို ပြန်စစ်ပါတယ်။

---

## ⚠️ Known Issue — အသုံးမပြုခင် ပြင်ရန်

Line 5 မှာ `IndexOf` ကို သုံးထားလို့ script က **parse error တက်ပြီး ဘာမှ မလုပ်ဘဲ ပြီးသွားပါတယ်**။

**အကြောင်းရင်း:** `#PSCODE#` ဆိုတဲ့ marker စာသားက file ထဲမှာ နှစ်နေရာ ပါနေပါတယ်။ တစ်ခုက line 5 ထဲက `$marker = '#PSCODE#'` ဖြစ်ပြီး နောက်တစ်ခုက line 11 ပါ။ `IndexOf` က ပထမဆုံးတွေ့တဲ့ line 5 ကို ယူသွားလို့ code ကို မှားတဲ့နေရာကနေ ဖြတ်ယူမိပါတယ်။

**ပြင်နည်း:** Line 5 မှာ `IndexOf` ကို `LastIndexOf` လို့ ပြောင်းပါ။

```powershell
$idx = $raw.LastIndexOf($marker);
```

---

## ကြိုတင်လိုအပ်ချက်

- Windows 10 / 11
- [WireGuard for Windows](https://www.wireguard.com/install/) ကို `C:\Program Files\WireGuard\` ထဲမှာ install လုပ်ထားရပါမယ်။
- Administrator အခွင့်အရေး ရှိရပါမယ်။

## Run နည်း

### နည်း ၁ — Double-click နဲ့ run နည်း

`WGconfig.cmd` ကို right-click နှိပ်ပြီး **Run as administrator** ကို ရွေးပါ။

### နည်း ၂ — CMD ကနေ run နည်း

1. Start menu မှာ `cmd` လို့ ရိုက်ပြီး **Run as administrator** ဖြင့် ဖွင့်ပါ။
2. Script ရှိတဲ့ folder ကို သွားပြီး run ပါ။

```cmd
cd /d "<path-to>\wireguard"
WGconfig.cmd
```

### Run ပြီးရင် လုပ်ရမယ့်အချက်များ

1. Standard user ကို **Network Configuration Operators** group ထဲ ထည့်ပါ။ (script က ဒါကို လုပ်မပေးပါ)

   ```cmd
   net localgroup "Network Configuration Operators" "DOMAIN\username" /add
   ```

2. Windows ကို restart လုပ်ပါ။ ဒါမှမဟုတ် sign out ပြီး ပြန် sign in ဝင်ပါ။

> 📌 `LimitedOperatorUI` က **Network Configuration Operators group ထဲမှာ ပါတဲ့ user တွေအတွက်ပဲ** သက်ရောက်ပါတယ်။ Group ထဲ မပါတဲ့ user ကတော့ WireGuard UI ကို သုံးလို့ မရပါဘူး။

---

## Code ရှင်းလင်းချက်

ဒီ file က **CMD + PowerShell hybrid** (file တစ်ခုတည်းထဲမှာ ဘာသာစကား နှစ်မျိုး ပေါင်းရေးထားတာ) ဖြစ်ပါတယ်။ `#PSCODE#` marker အပေါ်ပိုင်းကို CMD က run ပြီး အောက်ပိုင်းကို PowerShell က run ပါတယ်။

### အပိုင်း ၁ — CMD ပိုင်း (line 1–9)

| Line | Code | အဓိပ္ပာယ် |
|---|---|---|
| 1 | `@echo off` | Command တွေကို screen ပေါ်မှာ ထပ်မပြစေဖို့ |
| 2 | `setlocal` | Variable တွေကို ဒီ script ထဲမှာပဲ သက်ရောက်စေဖို့ |
| 3 | `title ...` | CMD window ရဲ့ ခေါင်းစဉ်ကို ပြောင်းတာ |
| 5 | `powershell ...` | File ထဲက PowerShell ပိုင်းကို ဖြတ်ယူပြီး run တာ (အောက်မှာ အသေးစိတ်ရှင်းထားပါတယ်) |
| 7–8 | `echo.` / `pause` | လိုင်းအလွတ်တစ်ကြောင်းထုတ်ပြီး key တစ်ခုနှိပ်တဲ့အထိ စောင့်တာ (window ချက်ချင်း မပိတ်သွားအောင်) |
| 9 | `exit /b` | CMD ပိုင်းကို ဒီမှာ ရပ်တာ။ ဒါကြောင့် CMD က အောက်က PowerShell code ကို လုံးဝ မဖတ်ပါဘူး |

**Line 5 အသေးစိတ်:**

| အပိုင်း | အဓိပ္ပာယ် |
|---|---|
| `-NoProfile` | PowerShell profile ကို မ load ဘဲ မြန်မြန် စတာ |
| `-ExecutionPolicy Bypass` | Script ကန့်သတ်ချက်ကို ကျော်တာ |
| `%~f0` | CMD က ဒီ `.cmd` file ကိုယ်တိုင်ရဲ့ full path နဲ့ အစားထိုးပေးတာ |
| `Get-Content ... -Raw` | File တစ်ခုလုံးကို စာသားတစ်ခုအနေနဲ့ ဖတ်တာ |
| `IndexOf('#PSCODE#')` | Marker ရှိတဲ့နေရာကို ရှာတာ (**Known Issue** ကို ကြည့်ပါ) |
| `Substring(...)` | Marker နောက်က စာသားတွေကို ဖြတ်ယူတာ |
| `Invoke-Expression $code` | ဖြတ်ယူထားတဲ့ စာသားကို PowerShell code အဖြစ် run တာ |

### အပိုင်း ၂ — PowerShell ပိုင်း (`#PSCODE#` နောက်ပိုင်း)

#### Error handling

```powershell
$ErrorActionPreference = "Stop"
```

Error တက်ရင် ဆက်မလုပ်ဘဲ ချက်ချင်း ရပ်ပါတယ်။

#### Administrator ဟုတ်မဟုတ် စစ်ခြင်း

```powershell
$principal = New-Object Security.Principal.WindowsPrincipal(
    [Security.Principal.WindowsIdentity]::GetCurrent()
)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
```

- လက်ရှိ user ရဲ့ identity ကို ယူပြီး Administrator role ထဲမှာ ပါမပါ စစ်ပါတယ်။
- Admin မဟုတ်ရင် `[ERROR] Please run as Administrator.` လို့ပြပြီး ရပ်ပါတယ်။

#### WireGuard install ထားမထား စစ်ခြင်း

```powershell
$wgExe = Join-Path $env:ProgramFiles "WireGuard\wireguard.exe"
if (-not (Test-Path $wgExe)) { ... exit }
```

- `$env:ProgramFiles` ဆိုတာ `C:\Program Files` ပါ။
- `wireguard.exe` မရှိရင် error ပြပြီး ရပ်ပါတယ်။

#### Registry ပြင်ခြင်း (script ရဲ့ အဓိကရည်ရွယ်ချက်)

```powershell
New-ItemProperty -Path "HKLM:\SOFTWARE\WireGuard" `
    -Name "LimitedOperatorUI" -PropertyType DWord -Value 1 -Force
```

- `HKLM:\SOFTWARE\WireGuard` key မရှိရင် အရင် ဖန်တီးပါတယ်။
- `LimitedOperatorUI = 1` ရှိမှ Admin မဟုတ်တဲ့ user တွေက tunnel ကို **ဖွင့်/ပိတ်** လုပ်လို့ရပါတယ်။ Tunnel config ကိုတော့ ပြင်ခွင့်၊ ဖျက်ခွင့် မရပါဘူး။
- Line ဆုံးက backtick (`` ` ``) က PowerShell မှာ command ကို နောက်တစ်ကြောင်းကို ဆက်ရေးတဲ့ သင်္ကေတပါ။
- `| Out-Null` က output ကို မပြအောင် ဖျောက်ထားတာပါ။

#### လက်ရှိ login ဝင်ထားတဲ့ user ကို ရှာခြင်း

```powershell
$interactiveUser = (Get-CimInstance Win32_ComputerSystem).UserName
```

Console မှာ login ဝင်ထားတဲ့ user name ကို ပြပါတယ်။ ရှာမတွေ့ရင် warning ပြပါတယ်။

#### Network Configuration Operators group ကို စစ်ကြည့်ခြင်း

```powershell
$group   = Get-LocalGroup -SID "S-1-5-32-556"
$members = Get-LocalGroupMember -Group $group.Name
```

- SID `S-1-5-32-556` က Network Configuration Operators ဆိုတဲ့ built-in group ပါ။ Group name အစား SID နဲ့ ရှာထားလို့ Windows ဘာသာစကား ဘယ်လိုပဲ ဖြစ်ဖြစ် အလုပ်လုပ်ပါတယ်။
- Group ထဲမှာ ဘယ်သူတွေ ရှိလဲဆိုတာကို **ပြရုံပဲ ပြပါတယ်။ ဘာမှ ပြောင်းလဲမပေးပါဘူး**။
- `try/catch` က error တက်ရင် script တစ်ခုလုံး မရပ်သွားဘဲ warning ပြရုံပဲ ပြစေပါတယ်။

#### Public Desktop မှာ shortcut ဖန်တီးခြင်း

```powershell
$publicDesktop = [Environment]::GetFolderPath("CommonDesktopDirectory")
$ws = New-Object -ComObject WScript.Shell
$shortcut = $ws.CreateShortcut((Join-Path $publicDesktop "WireGuard.lnk"))
```

- `CommonDesktopDirectory` ဆိုတာ `C:\Users\Public\Desktop` ပါ။ ဒီနေရာမှာ ထားတဲ့ shortcut ကို user အားလုံး မြင်ရပါတယ်။
- `WScript.Shell` COM object ကို သုံးပြီး `wireguard.exe` ကို ညွှန်တဲ့ shortcut ကို ဖန်တီးပါတယ်။

#### Registry ကို ပြန်စစ်ခြင်း

`LimitedOperatorUI` value ကို ပြန်ဖတ်ပြီး `1` ဖြစ်နေရင် `[OK]` ပြပါတယ်။ မဟုတ်ရင် `[ERROR]` ပြပါတယ်။

#### ပြီးဆုံးခြင်း

Setting အသက်ဝင်ဖို့ Windows ကို restart လုပ်ဖို့ ဒါမှမဟုတ် sign out ပြီး ပြန် sign in ဝင်ဖို့ ပြောပါတယ်။

---

## Output နမူနာ (အောင်မြင်တဲ့အခါ)

```
======================================
 WireGuard Standard User Configuration
======================================

[OK] Administrator privilege detected.
[OK] WireGuard installation detected.
[OK] LimitedOperatorUI configured.
[INFO] Interactive user: PC01\user1

Network Configuration Operators:
  PC01\user1

[INFO] Group membership was not changed.
[OK] Public Desktop shortcut created.
[OK] Registry verification successful.

======================================
 Configuration completed.
======================================

Please restart Windows or sign out/in.
```

## Setting ကို ပြန်ဖျက်နည်း (Rollback)

Admin CMD ကနေ အောက်ပါ command တွေ run ပါ။

```cmd
reg delete "HKLM\SOFTWARE\WireGuard" /v LimitedOperatorUI /f
del "C:\Users\Public\Desktop\WireGuard.lnk"
net localgroup "Network Configuration Operators" "DOMAIN\username" /delete
```
