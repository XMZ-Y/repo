#!/bin/bash
set -e
read -p $'主机名：\n' hostname
read -p $'ip地址：\n' ipadd
read -p $'ip网关：\n' ipgw
#设置主机名
hostnamectl set-hostname $hostname
#设置静态ip
nmcli connection modify ens33 ipv4.addresses $ipadd\/24 ipv4.gateway $ipgw ipv4.dns 223.5.5.5 ipv4.method manual autoconnect yes
echo "修改主机名和ip已完成,重启网卡中···"
nmcli connection up ens33
echo "重启网卡完成"