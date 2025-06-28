## Install SSH
yum install ssh

## firewall Setting
systemctl status firewalld
firewall-cmd --add-service=ssh --permanent
firewall-cmd --reload
firewall-cmd --list-all

## SSH Services Setting
systemctl enable sshd.service
systemctl start sshd.service
systemctl status sshd.service