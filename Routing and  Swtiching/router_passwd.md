## Router ကို password ပေးနည်း

en
conf t
line console 0
password cisco
login

-----------------------------

## Router ကို username ကော Password ကော ပေးနည်း

en
conf t
line console 0
login local
username cisco password hacker
exit
exit
exit

-------------------------------

## RIP routing Protocol

In router 1 ==>

en
conf t
hostname R1
int g0/0
ip addr 192.168.10.100 255.255.255.0
no shut
exit
int g0/1
ip addr 10.0.0.1 255.255.255.252        /30
no shut
------------------


In router 2 ==>

en
conf t
hostname R2
int g0/0
ip addr 192.168.20.100 255.255.255.0
no shut
exit
int g0/1
ip addr 10.0.0.2 255.255.255.252
no shut
-----------------

In router 1 ==>

en
conf t
router rip
no auto-summary
ver 2
network 10.0.0.0
network 192.168.10.0
exit

--------------------

In router 2 ==>

en
conf t
router rip
no auto-summary
ver 2
network 10.0.0.0
network 192.168.20.0
exit

