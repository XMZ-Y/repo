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

cd ~
#calico网络插件
curl https://docs.projectcalico.org/archive/v3.19/manifests/calico.yaml -O
sed -ir "s/.*- name: CALICO_IPV4POOL_CIDR/            - name: CALICO_IPV4POOL_CIDR/" calico.yaml
sed -ir "3684c\              value: \"10.244.0.0/16\"" calico.yaml
images=`cat calico.yaml |grep image|sed -n "s/.*image: //p"`
for imageName in ${images[@]} ; do
	crictl pull $imageName
done
kubectl apply -f calico.yaml&&sleep 1m
#------------------------------------------------------------------------------------------------------
#安装kuboard
wget https://addons.kuboard.cn/kuboard/kuboard-v3.yaml
kubectl apply -f kuboard-v3.yaml
# # 您也可以使用下面的指令，唯一的区别是，该指令使用华为云的镜像仓库替代 docker&k8s笔记 hub 分发 Kuboard 所需要的镜像
# # kubectl apply -f https://addons.kuboard.cn/kuboard/kuboard-v3-swr.yaml
# #	 访问端口：30080
# #    用户名： admin
# #    密码： Kuboard123
#
#------------------------------------------------------------------------------------------------------
# #安装Dashboard
# rm -f dashboard-recommended.yaml
# wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.5.1/aio/deploy/recommended.yaml
# mv recommended.yaml dashboard-recommended.yaml
# sed -i '42a\      nodePort: 30005' dashboard-recommended.yaml
# sed -i '39a\  type: NodePort' dashboard-recommended.yaml
# kubectl apply -f dashboard-recommended.yaml&&sleep 1m
# tee ./auth.yaml <<'EOF'
# apiVersion: v1
# kind: ServiceAccount
# metadata:
  # name: admin-user
  # namespace: kubernetes-dashboard
# ---
# apiVersion: rbac.authorization.k8s.io/v1
# kind: ClusterRoleBinding
# metadata:
  # name: admin-user
# roleRef:
  # apiGroup: rbac.authorization.k8s.io
  # kind: ClusterRole
  # name: cluster-admin
# subjects:
# - kind: ServiceAccount
  # name: admin-user
  # namespace: kubernetes-dashboard
# EOF
# kubectl apply -f auth.yaml&&sleep 1m
# kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"
