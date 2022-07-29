#!/bin/bash
hostname=$1
#设置静态ip
nmcli connection modify ens33 ipv4.addresses 192.168.86.11\/24 ipv4.gateway 192.168.86.1 ipv4.dns 223.5.5.5 ipv4.method manual autoconnect yes
nmcli connection up ens33
#设置主机名
hostnamectl set-hostname $hostname
#设置selinux
setenforce 0
cp -f /etc/sysconfig/selinux /etc/sysconfig/selinux.back
linenum=`grep -n "^SELINUX=" /etc/sysconfig/selinux|awk -F: '{print $1}'`
linetxt="SELINUX=disabled"
sed -i "${linenum}c${linetxt}" /etc/sysconfig/selinux
#关闭firewall
systemctl stop firewalld
systemctl disable firewalld
#安装常用功能 
yum repolist
yum -y install bash-completion	#tab自动补全
yum -y install net-tools		#netstat命令
yum -y install vim
exit 0
