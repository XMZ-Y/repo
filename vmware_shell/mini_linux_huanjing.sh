#!/bin/bash
ip=192.168.21.11
hostname=node1
#设置静态ip
nmcli connection modify ens33 ipv4.addresses $ip\/24 ipv4.gateway 192.168.21.1 ipv4.dns 223.5.5.5 ipv4.method manual autoconnect yes
nmcli connection up ens33
#设置主机名
hostnamectl set-hostname $hostname
#设置selinux
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
#关闭firewall
systemctl stop firewalld
systemctl disable firewalld
#安装常用功能 
yum repolist
yum -y install bash-completion	#tab自动补全
yum -y install net-tools		#netstat命令
yum -y install vim
yum -y install lsof
exit 0