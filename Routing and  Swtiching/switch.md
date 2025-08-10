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
# show mac-address table          -  ဘယ် port မှာ ဘယ် mac-address ရှိလဲ 
# (ping မှာ port နဲ့ mac address ကို တွေ့ရတာ)

show version
show ip int brief               -  ဘယ် port တွေ down နေလဲ၊ up နေလဲ၊ ကြည်တာ 
show int fa 0/5 switchport      - fa 0/5 ရယ် switchport ကို ကြည်တာ    

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

-----------------------

Switch တည်းကို ဝင် 

            en 
            conf t
            int range fa 0/1-2
            switchport mode access
            switchport access vlan 10
            do show vlan
            exit
----------------------------

conf t
int range fa 0/3-4
switchport mode access
switchport access vlan 20
do show vlan
exit
----------------------------

## Router မှာ Trunk mode ကြော်ငြာ ပေးရမယ်

Router နဲ့ ချိတ်ထားတဲ့ switch port မှာ trunk mode ကြော်ငြာပေးရမယ်
# In the swith >>>
                en
                conf t
                int fa 0/5
                switchport mode trunk
                exit


show int trunk

## Router

en
conf t
int g 0/0.10
encapsulation dot1Q 10
ip addr 192.168.1.100    <<< vlan 10 ရယ် gateway

exit

int g 0/0.20
encapsulation dot1Q 10
ip addr 192.168.2.100
