## Cam Table

Cam table ဆိုတာ switch ရယ် ဘယ် port မှာ ဘယ် mac-address ဆိုတာ သိမ်းတယ် 

## ARP Table

ARP table ဆိုတာ switch မှာ ဘယ် mac-address ဟာ ဘယ် ip လည်း ဆိုတာ သိမ်းတယ်

Layer 2 brodcast - FF:FF:FF:FF:FF:FF
Layer 3 brodcast - 255.255.255.255

Switch to PC      - Access Port
Switch to Switch  - Trunk Port

## Trunking Protocol နှစ်မျိုး ရှိ၊ 

# ISL(No use today) and dot1q(IEEE standard any switch any model devices for dot1q model)


show running-config             -  Default configuration  
show arp                        -  ဘယ် ip မှာ ဘယ် mac-address ရှိ
show mac-address table          -  ဘယ် port မှာ ဘယ် mac-address ရှိလဲ
show version
show ip int brief               -  ဘယ် port တွေ down နေလဲ၊ up နေလဲ၊ ကြည်တာ 

## Vlan create နည်း

show vlan 
---------

en
conf t 
vlan 10 
name HR
exit
vlan 20
name Sale
exit
vlan 30
name IT
exit

do show vlan

## Delete vlan

en
conf t
no vlan 10
no vlan 20