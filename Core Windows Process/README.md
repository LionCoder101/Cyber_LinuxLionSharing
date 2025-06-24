
# **Windows Core Process**

*ဘာကြောင့် ကျွနု်တော် တို့ က **Windows Core Process** ကို သိသင့်တာလဲ။*

**System (ntoskrnl.exe)**
ntoskrnl.exe ဆိုတာ  **Windows Kernel** ကို စီမံပါတယ် **Hardware**, **Memory** နဲ့ **Driver** တွေကို ချိတ်ဆက်ပေးခြင်း

(**ntoskrnl.exe**) ဒီ **Process** ပိတ်သွားရင် **Blue Screen of Death (BSOD)** ဖြစ်မယ်။
----------
**Session Manager Subsystem (smss.exe)**
smss.exe ဆိုတာ **Windows Startup** မှာ **User Session** တွေကို စတင်ပေးတယ်။

**သွင်ပြင်**: ယေဘုယျအားဖြင့် တစ်ခါပြီးတစ်ခါ ပေါ်လာပြီး ပျောက်သွားတတ်တယ်။
---------------------------------
**Windows Start-Up Application (wininit.exe)**
wininit.exe ဆိုတာ **System Startup** မှာ **Background Services** တွေကို စတင်ပေးတယ် (ဥပမာ: **lsass.exe**, **services.exe**)

**Directory Location**: %SystemRoot%\System32
---------------------
**Local Security Authority Subsystem Service (lsass.exe)**
lsass.exe ဆိုတာ **User Password** စစ်ဆေးခြင်း၊ **Security Policy** များ အကောင်အထည်ဖော်ခြင်း။

**အန္တရာယ်**: **Hacker** တွေ ပစ်မှတ်ထားလေ့ရှိပြီး၊ **Mimikatz tool** နဲ့ **Password** ခိုးယူတတ်ကြတယ်။
----------------------
**Service Host Process (svchost.exe)**
**အခန်းကဏ္ဍ**: **Background Services** တွေကို **Group** လုပ်ပေးထားတဲ့ **Container** (ဥပမာ: **Windows Update**, **Network Service**)။

**သတိပြုရန်**: များသောအားဖြင့် တစ်ခါတည်း **Process**
------------------------


Windows Logon Application	       winlogon.exe	     User Login/Logout စီမံခြင်း
Client Server Runtime Process	   csrss.exe	     GUI နဲ့ Console ကို 
Task Manager                   	   taskmgr.exe	