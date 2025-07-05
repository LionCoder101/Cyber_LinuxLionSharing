## Check Firewall Port
show


## To assign a static IP address to your firewall, follow these steps:

## config system interface
## edit port1
## set mode static 
## set ip 192.168.1.254 255.255.255.0
## set allowaccess http https ping ssh
## end
## show