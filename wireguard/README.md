# PC Setup Script (`wire_script.cmd`)

Windows PC အသစ်ကို setup လုပ်ပေးတဲ့ script ဖြစ်ပါတယ်။ Computer name ပြောင်းတာ၊ app တွေ install လုပ်တာ၊ Japanese / Myanmar language ထည့်တာတွေ လုပ်ပေးပါတယ်။ User တစ်ယောက် (local / AD / **Entra ID** user) က WireGuard ကို **feature အစုံ** (tunnel ထည့်၊ ပြင်၊ ဖျက်၊ import/export) နဲ့ သုံးလို့ရအောင်လည်း setup လုပ်ပေးပါတယ်။

## Script က ဘာတွေလုပ်ပေးလဲ

1. **Admin rights တောင်းခြင်း:** Admin အနေနဲ့ run မထားရင် UAC prompt ပေါ်စေပြီး admin အနေနဲ့ ပြန် run ပါတယ်။
2. **Computer name ပြောင်းခြင်း:** Terminal မှာ name အသစ်ကို မေးပါတယ်။ Enter ပဲ နှိပ်ရင် မပြောင်းပါဘူး။ (စည်းကမ်း: စာလုံး ၁၅ လုံးအထိ၊ အင်္ဂလိပ်စာ / ဂဏန်း / `-` သာ၊ ဂဏန်းချည်းပဲ မရ)။ AD domain စက်ဆိုရင် domain account password ကိုပါ မေးပါတယ်။ Restart ပြီးမှ name အသစ် အသက်ဝင်ပါတယ်။
3. **App တွေ install လုပ်ခြင်း (စက်ထဲမှာ မရှိမှပဲ သွင်းပါတယ်။ ရှိရင် ကျော်ပါတယ်):**

   | App | Install နည်း |
   |---|---|
   | Google Chrome | Google ရဲ့ official Enterprise MSI (signature စစ်ပြီးမှ သွင်းပါတယ်) |
   | 7-Zip | winget (`7zip.7zip`) |
   | Microsoft Teams | Microsoft ရဲ့ official Teams bootstrapper (`-p` နဲ့ user အားလုံးအတွက်) |
   | Foxit PDF Reader | winget (`Foxit.FoxitReader`) |
   | **Office (ရွေးရပါတယ်)** | Script အစမှာ `1 = WPS Office`၊ `2 = Microsoft 365`၊ `3 = None` ထဲက ရွေးခိုင်းပါတယ် |
   | └ WPS Office | winget (`Kingsoft.WPSOffice`) |
   | └ Microsoft 365 | Microsoft ရဲ့ official Office Deployment Tool (64-bit, Current channel, Windows language အတိုင်း)။ Word, Excel, PowerPoint, Outlook, OneNote ပါပါတယ်။ Download က 3 GB လောက် ရှိပါတယ် |

4. **Japanese / Myanmar language:**
   - Japanese language (typing, fonts) ကို Windows Update ကနေ install လုပ်ပါတယ်။ (မိနစ်အနည်းငယ် ကြာနိုင်ပါတယ်)
   - Japanese supplemental fonts ကို ထည့်ပါတယ်။ Myanmar font (**Myanmar Text**) က Windows မှာ ပါပြီးသားမို့ ရှိမရှိပဲ စစ်ပါတယ်။
   - User တိုင်း sign in ဝင်တဲ့အခါ **Japanese + Myanmar keyboard** ကို အလိုအလျောက် ထည့်ပေးတဲ့ task တစ်ခု ဖန်တီးပါတယ်။ (Keyboard က user တစ်ယောက်ချင်းစီရဲ့ setting ဖြစ်လို့ပါ)
5. **WireGuard ကို အသစ်ပြန် install လုပ်ခြင်း:**
   - Official site ကနေ နောက်ဆုံး version ကို **အရင် download** လုပ်ပြီး digital signature (WireGuard LLC) ကို စစ်ပါတယ်။ Download မရရင် ရှိပြီးသား WireGuard ကို မဖျက်ဘဲ ဆက်သုံးပါတယ်။
   - ရှိပြီးသား tunnel config တွေကို `C:\ProgramData\WireGuard-Backup\<date-time>` ထဲ backup လုပ်ပါတယ်။
   - ရှိပြီးသား WireGuard ကို uninstall လုပ်ပြီး အသစ်ကို silent install လုပ်ပါတယ်။ ပြီးရင် tunnel config တွေကို ပြန်ထည့်ပေးပါတယ်။
6. **စက်အမျိုးအစား စစ်ခြင်း:** Entra ID joined / Hybrid / AD Domain / Workgroup ထဲက ဘယ်ဟာလဲ ပြပါတယ်။
7. **Login user ကို ရှာခြင်း:** Script ကို run နေတဲ့ desktop session မှာ login ဝင်ထားတဲ့ user ကို ရှာပါတယ်။ (Admin password နဲ့ run ရင်တောင် admin account ကို မဟုတ်ဘဲ screen ပေါ်က user ကို ရှာပါတယ်)
8. **User ကို local Administrators group ထဲ ထည့်ခြင်း:** User ကို name အစား SID နဲ့ ထည့်တာမို့ local၊ AD နဲ့ Entra ID user တွေ အားလုံးမှာ အလုပ်လုပ်ပါတယ်။
9. **Tray icon ပြခြင်း:** Windows 11 မှာ WireGuard tray icon ကို အမြဲ ပေါ်နေအောင် လုပ်ပါတယ်။
10. **Restart:** 60 စက္ကန့်အကြာမှာ Windows ကို အလိုအလျောက် restart လုပ်ပါတယ်။ (ရပ်ချင်ရင် CMD မှာ `shutdown /a`)

## ကြိုတင်လိုအပ်ချက်

- Windows 10 / 11 (Entra join ရှိရှိ မရှိရှိ ရပါတယ်)
- Internet
- Administrator account ရဲ့ username / password

## Run နည်း

1. WireGuard သုံးမယ့် **user account နဲ့ login ဝင်ပါ**။
2. Script ကို local disk (ဥပမာ Desktop) ပေါ် copy ကူးပါ။ (Network drive `Z:\` ပေါ်ကနေ run ရင် admin session က အဲဒီ drive ကို မမြင်ရတတ်ပါဘူး)
3. `wire_script.cmd` ကို **double-click** နှိပ်ပါ။ (ဒါမှမဟုတ် right-click → **Run as administrator**)
4. UAC window မှာ **admin username / password** ရိုက်ထည့်ပါ။
5. Terminal က **computer name အသစ်** မေးရင် ရိုက်ထည့်ပြီး Enter နှိပ်ပါ။ (မပြောင်းချင်ရင် Enter ပဲ နှိပ်ပါ) ပြီးရင် **Office** ကို ရွေးခိုင်းပါမယ်: `1` (WPS)၊ `2` (Microsoft 365)၊ `3` (မသွင်း)။ ဒီနောက်ပိုင်း အဆင့်တွေက ဘာမှ ထပ်မမေးဘဲ သူ့ဘာသာ ဆက်လုပ်သွားပါတယ်။ App တွေ၊ language တွေ download လုပ်ရလို့ အချိန်တော်တော် ကြာနိုင်ပါတယ်။
6. Script ပြီးရင် Windows က 60 စက္ကန့်အကြာမှာ အလိုအလျောက် restart လုပ်ပါမယ်။
7. Restart ပြီးရင် user က WireGuard ကို **feature အစုံ** နဲ့ သုံးလို့ရပါပြီ။ Tray icon ဒါမှမဟုတ် Start menu ကနေ ဖွင့်ပါ။ Windows က permission မေးရင် **Yes** နှိပ်ပါ။

> ⚠️ **လုံခြုံရေး သတိပေးချက်:** User ကို Administrators group ထဲ ထည့်လိုက်တာမို့ user က WireGuard အပြင် **စက်တစ်လုံးလုံးကို admin အနေနဲ့ ထိန်းချုပ်နိုင်သွားပါမယ်** (software install/uninstall၊ setting ပြောင်းတာ စသည်)။

## Output နမူနာ

```
[OK] Administrator privilege detected.
[INFO] Existing WireGuard found. It will be uninstalled and reinstalled.
[INFO] Downloading wireguard-amd64-x.x.x.msi ...
[OK] Installer signature verified (WireGuard LLC).
[OK] Tunnel configs backed up to: C:\ProgramData\WireGuard-Backup\20261127-101500
[OK] Old WireGuard uninstalled.
[OK] WireGuard installed successfully.
[OK] Tunnel configs restored.
[INFO] Device join type: Entra ID joined
[INFO] Logged-on user: AzureAD\UserName (S-1-12-1-...)
[OK] AzureAD\UserName added to the Administrators group.

======================================
 Configuration completed.
======================================

[INFO] Windows will restart automatically in 60 seconds.
```

## Code ဖွဲ့စည်းပုံ

ဒီ file က **CMD + PowerShell hybrid** (file တစ်ခုတည်းထဲမှာ ဘာသာစကား နှစ်မျိုး) ဖြစ်ပါတယ်။

- **CMD ပိုင်း (`#PSCODE#` marker အပေါ်):** Admin ဟုတ်မဟုတ် `fltmc` နဲ့ စစ်ပြီး မဟုတ်ရင် UAC နဲ့ ပြန် run ပါတယ်။ ပြီးရင် file ထဲက PowerShell ပိုင်းကို ဖြတ်ယူပြီး run ပါတယ်။
- **PowerShell ပိုင်း (`#PSCODE#` marker အောက်):** အပေါ်က "Script က ဘာတွေလုပ်ပေးလဲ" အဆင့်တွေ အားလုံးကို လုပ်ပါတယ်။

## ပြန်ဖျက်နည်း (Rollback)

User ကို Administrators group ထဲက ပြန်ထုတ်ချင်ရင် admin CMD မှာ run ပါ။

```cmd
net localgroup Administrators "PCNAME\username" /delete
```

Entra ID user ဆိုရင် `"AzureAD\user@yourdomain.com"` ပုံစံ သုံးပါ။ ပြီးရင် user က sign out / sign in ပြန်ဝင်ရပါမယ်။
