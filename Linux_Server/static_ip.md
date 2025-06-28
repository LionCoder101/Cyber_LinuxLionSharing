## Check Network Device

nmcli d

## Edit this card

vim /etc/sysconfig/network-scripts/ifcfg-[network_device_name]

BOOTPROTO="static"
ONBOOT="yes"
IPADDR=192.168.1.254
NETMASK=255.255.255.0
GATEWAY=192.168.1.1
DNS1=8.8.8.8
DNS2=8.8.4.4

## Restart the network service

sudo systemctl restart NetworkManager
(or)
sudo ifdown ens160
sudo ifup ens160



## Description
This guide provides step-by-step instructions for configuring a static IP address on a Linux server. It covers checking your network device, editing the appropriate network configuration file, and setting the necessary parameters such as IP address, netmask, gateway, and DNS servers.
