#!/bin/bash
set -e
#下载解压 crictl 命令
cd ~
VERSION="v1.24.2"
wget https://hub.fastgit.org/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz --no-check-certificate
tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz*
crictl config runtime-endpoint unix:///run/containerd/containerd.sock
crictl config image-endpoint unix:///run/containerd/containerd.sock
echo "crictl is ok"