#!/bin/bash

# 使用elrepo源
rpm -Uvh https://mirrors.aliyun.com/elrepo/elrepo/el7/x86_64/RPMS/elrepo-release-7.0-5.el7.elrepo.noarch.rpm

# 列出可以使用的kernel包版本
yum --disablerepo="*" --enablerepo="elrepo-kernel" list available

# 安装最新稳定版本
yum --enablerepo=elrepo-kernel install kernel-lt -y
# 安装指定版本
#yum --enablerepo=elrepo-kernel install kernel-lt-5.4.180-1.el7.elrepo -y

# 生成 grub 配置文件
grub2-mkconfig -o /boot/grub2/grub.cfg

# 查看系统上的所有可用内核
awk -F\' '$1=="menuentry " {print i++ " : " $2}' /etc/grub2.cfg

# 更改内核默认启动顺序
grub2-set-default 0

# 重启
reboot