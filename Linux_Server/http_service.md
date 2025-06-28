## Install http
yum install httpd* -y

## Configuration

vim /etc/httpd/conf/httpd.conf

configre "Server Admin" line no. 86
ServerAdmin root@lionhacker404.com

ServerName Setting --- line no. 95
ServerName www.lionhacker404.com:80

Check Document root

## firewall setting
firewall-cmd --add-service=http --permanent
firewall-cmd --reload