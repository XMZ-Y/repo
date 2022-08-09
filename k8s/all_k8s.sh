#!/bin/bash

# 更新
yum update -y

# 卸载 firewalld
systemctl stop firewalld
yum remove firewalld -y

# 卸载 networkmanager
systemctl stop NetworkManager
yum remove NetworkManager -y

# 同步服务器时间
yum install chrony -y
systemctl enable --now chronyd
chronyc sources

# 安装iptables(搭建完集群后再安装，比较省事)
#yum install -y iptables iptables-services && systemctl enable --now iptables.service

# 关闭 selinux
setenforce 0
sed -i '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config
getenforce

# 关闭swap分区
swapoff -a # 临时
sed -i '/ swap / s/^/# /g' /etc/fstab #永久

# 安装其他必要组件和常用工具包
yum install -y yum-utils zlib zlib-devel openssl openssl-devel net-tools vim wget lsof unzip zip bind-utils lrzsz telnet

# 如果是从安装过docker的服务器升级k8s，建议将/etc/sysctl.conf配置清掉
# 这条命令会清除所有没被注释的行
# sed -i '/^#/!d' /etc/sysctl.conf

# 安装ipvs
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
modprobe -- ip_vs
modprobe -- ip_vs_rr
modprobe -- ip_vs_wrr
modprobe -- ip_vs_sh
modprobe -- nf_conntrack
EOF
chmod 755 /etc/sysconfig/modules/ipvs.modules 
bash /etc/sysconfig/modules/ipvs.modules 
lsmod | grep -e ip_vs -e nf_conntrack
yum install ipset ipvsadm -y

# 允许 iptables 检查桥接流量
cat <<EOF | tee /etc/modules-load.d/k8s.conf
br_netfilter
EOF
sysctl --system

cat <<EOF | tee /etc/sysctl.d/k8s.conf
vm.swappiness = 0
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOF
modprobe br_netfilter
lsmod | grep netfilter
sysctl -p /etc/sysctl.d/k8s.conf

# 安装 containerd
yum install -y yum-utils device-mapper-persistent-data lvm2
yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum list containerd.io --showduplicates
yum install -y containerd.io
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

# 使用 systemd cgroup驱动程序
sed -i "s#k8s.gcr.io#registry.aliyuncs.com/google_containers#g"  /etc/containerd/config.toml
sed -i "s/SystemdCgroup = false/SystemdCgroup = true/g" /etc/containerd/config.toml
sed -i "s#https://registry-1.docker.io#https://registry.aliyuncs.com#g"  /etc/containerd/config.toml
systemctl daemon-reload
systemctl enable containerd
systemctl restart containerd

# 添加kubernetes yum软件源
cat > /etc/yum.repos.d/kubernetes.repo << EOF
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 安装kubeadm,kubelet和kubectl
yum list kubeadm --showduplicates
yum install -y kubelet-1.24.3 kubeadm-1.24.3 kubectl-1.24.3 --disableexcludes=kubernetes

# 设置开机自启
systemctl daemon-reload
systemctl enable kubelet
systemctl restart kubelet
# kubelet每隔几秒就会重启，陷入等待 kubeadm 指令的死循环

# 命令自动补全
yum install -y bash-completion
source <(crictl completion bash)
crictl completion bash >/etc/bash_completion.d/crictl
source <(kubectl completion bash)
kubectl completion bash >/etc/bash_completion.d/kubectl
source /usr/share/bash-completion/bash_completion
#下载各个机器需要的镜像
images=`kubeadm config images list|awk -F / '{print $NF}'`
for imageName in ${images[@]} ; do
	crictl pull registry.cn-hangzhou.aliyuncs.com/google_containers/$imageName
done