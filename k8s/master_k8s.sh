#!/bin/bash
set -e
#生成kubeadm-config文件
cat > ./kubeadm-config.yaml <<!
apiVersion: kubeadm.k8s.io/v1beta3
bootstrapTokens:
- groups:
  - system:bootstrappers:kubeadm:default-node-token
  token: qjbkjd.zp1ta327pwur2k8g
  ttl: 24h0m0s
  usages:
  - signing
  - authentication
kind: InitConfiguration
localAPIEndpoint:
  advertiseAddress: 192.168.21.30
  bindPort: 6443
nodeRegistration:
  criSocket: /run/containerd/containerd.sock 
  name: k8s-master
  taints:
  - effect: NoSchedule
    key: node-role.kubernetes.io/master
---
apiServer:
  timeoutForControlPlane: 4m0s
apiVersion: kubeadm.k8s.io/v1beta3
certificatesDir: /etc/kubernetes/pki
clusterName: kubernetes
controllerManager: {}
dns: {}
etcd:
  local:
    dataDir: /var/lib/etcd
imageRepository: registry.aliyuncs.com/google_containers
kind: ClusterConfiguration
kubernetesVersion: v1.23.6
networking:
  dnsDomain: cluster.local
  podSubnet: 10.244.0.0/16
  serviceSubnet: 10.96.0.0/12
scheduler: {}
---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
---
apiVersion: kubelet.config.k8s.io/v1beta1
kind: KubeletConfiguration
cgroupDriver: systemd
!
# 部署Kubernetes Master
kubeadm init --config kubeadm-config.yaml
echo "请按照屏幕输出提示将node节点join到master节点。"
# 查看默认配置文件
#kubeadm config print init-defaults
# 查看所需镜像
#kubeadm config images list --image-repository registry.aliyuncs.com
# 导出默认配置文件到当前目录
#kubeadm config print init-defaults > kubeadm-init.yaml
#按照屏幕输出，cp配置文件
mkdir -p $HOME/.kube && \
cp /etc/kubernetes/admin.conf $HOME/.kube/config && \
chown $(id -u):$(id -g) $HOME/.kube/config
#重置集群
# kubeadm reset -f
# rm -rf /etc/kubernetes
# rm -rf /var/lib/etcd/
# rm -rf $HOME/.kube