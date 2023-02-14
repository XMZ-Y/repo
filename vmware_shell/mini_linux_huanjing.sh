#!/bin/bash
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
yum -y install net-tools	#netstat命令
yum -y install vim
echo "设置基础环境完成"