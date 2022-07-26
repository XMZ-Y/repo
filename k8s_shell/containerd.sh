#!/bin/bash
set -e
#下载解压 containerd
cd ~
yum -y install wget
wget https://download.fastgit.org/containerd/containerd/releases/download/v1.6.6/containerd-1.6.6-linux-amd64.tar.gz
tar -xvf containerd-1.6.6-linux-amd64.tar.gz -C /usr/local/
rm -f containerd-1.6.6-linux-amd64.tar.gz*
#生成 containerd 配置文件
cd /usr/local/bin/
mkdir -p /etc/containerd
./containerd config default > /etc/containerd/config.toml
cat /etc/containerd/config.toml
#配置 containerd 作为服务运行
touch /lib/systemd/system/containerd.service
cat <<! > /lib/systemd/system/containerd.service
[Unit]
Description=containerd container runtime
Documentation=https://containerd.io
After=network.target

[Service]
ExecStartPre=/sbin/modprobe overlay
ExecStart=/usr/local/bin/containerd
Delegate=yes
KillMode=process
LimitNOFILE=1048576
# Having non-zero Limit*s causes performance problems due to accounting overhead
# in the kernel. We recommend using cgroups to do container-local accounting.
LimitNPROC=infinity
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
!
systemctl daemon-reload
#启动 containerd
systemctl enable containerd.service
systemctl start containerd.service
systemctl status containerd.service
echo "containerd is ok"
#下载解压 crictl 命令
cd ~
VERSION_crictl="v1.24.2"
wget https://download.fastgit.org/kubernetes-sigs/cri-tools/releases/download/$VERSION_crictl/crictl-$VERSION_crictl-linux-amd64.tar.gz
tar zxvf crictl-$VERSION_crictl-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION_crictl-linux-amd64.tar.gz*
crictl config runtime-endpoint unix:///run/containerd/containerd.sock
crictl config image-endpoint unix:///run/containerd/containerd.sock
echo "crictl is ok"