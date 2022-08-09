#!/bin/bash
set -e
#设置hostname
hostnamectl set-hostname k8s-$1
# 卸载 networkmanager
systemctl stop NetworkManager
yum remove NetworkManager -y
# 同步服务器时间
yum install chrony -y
systemctl enable --now chronyd
chronyc sources
# 安装其他必要组件和常用工具包
yum install -y yum-utils zlib zlib-devel openssl openssl-devel net-tools vim wget lsof unzip zip bind-utils lrzsz telnet
#关闭swap
swapoff -a
sed -ir 's/.*swap*/#&/' /etc/fstab
free -h|grep Swap
cat /etc/fstab|grep swap
#bridged网桥设置
cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
vm.swappiness = 0
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system
modprobe br_netfilter
modprobe overlay
sysctl -p /etc/sysctl.d/k8s.conf
lsmod | grep -e br_netfilter -e overlay
#配置ipvs
yum -y install ipset ipvsadm
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack
EOF
chmod +x /etc/sysconfig/modules/ipvs.modules
/bin/bash /etc/sysconfig/modules/ipvs.modules
lsmod | grep -e ip_vs -e nf_conntrack
yum install ipset ipvsadm -y
#配置containerd，使用 systemd cgroup驱动程序
mkdir -p /etc/containerd
containerd config default | tee /etc/containerd/config.toml
cat <<EOF | tee /etc/crictl.yaml
runtime-endpoint: "unix:///run/containerd/containerd.sock"
image-endpoint: "unix:///run/containerd/containerd.sock"
timeout: 10
debug: false
pull-image-on-create: false
disable-pull-on-run: false
EOF
sed -i "s#k8s.gcr.io#registry.aliyuncs.com/google_containers#g"  /etc/containerd/config.toml
sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml
sed -i "s#https://registry-1.docker.io#https://registry.aliyuncs.com#g"  /etc/containerd/config.toml
systemctl daemon-reload
systemctl enable containerd
systemctl restart containerd
#安装kubelet、kubeadm、kubectl
cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubelet-1.24.3 kubeadm-1.24.3 kubectl-1.24.3
systemctl enable kubelet
systemctl start kubelet 
#初始化失败，reset后重新init
# kubeadm reset -f
# rm -rf /etc/kubernetes
# rm -rf /var/lib/etcd/
# rm -rf $HOME/.kube
#下载各个机器需要的镜像
if [ $1 == master ];then
	images=`kubeadm config images list|awk -F / '{print $NF}'`
fi
if [[ $1 =~ node* ]];then
	images=`kubeadm config images list|awk -F / '{print $NF}'|grep -E 'kube-proxy|pause'`
fi
for imageName in ${images[@]} ; do
	crictl pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done
if [ $1 == master ];then
	#初始化主节点
	cd ~
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
kubernetesVersion: v1.24.3
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
	kubeadm init --config kubeadm-config.yaml
	#按照初始化输出提示，设置.kube/config
	mkdir -p $HOME/.kube
	sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
	sudo chown $(id -u):$(id -g) $HOME/.kube/config
	
	# 命令自动补全
	yum install -y bash-completion
	source <(crictl completion bash)
	crictl completion bash >/etc/bash_completion.d/crictl
	source <(kubectl completion bash)
	kubectl completion bash >/etc/bash_completion.d/kubectl
	source /usr/share/bash-completion/bash_completion
	#安装网络插件calico
	curl https://docs.projectcalico.org/archive/v3.19/manifests/calico.yaml -O
	sed -ir "s/.*- name: CALICO_IPV4POOL_CIDR/            - name: CALICO_IPV4POOL_CIDR/" calico.yaml
	sed -ir "3684c\              value: \"10.244.0.0/16\"" calico.yaml
	images=`cat calico.yaml |grep image|sed -n "s/.*image: //p"`
	for imageName in ${images[@]} ; do
		crictl pull $imageName
	done
	kubectl apply -f calico.yaml
	#token有效期24小时，过期要生成新的
	#kubeadm token create --print-join-command
fi
if [[ $1 =~ node* ]];then
	echo "查看master的token，手动加入集群"
fi