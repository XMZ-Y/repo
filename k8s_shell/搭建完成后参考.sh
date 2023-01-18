#master执行，生成新的token
#kubeadm token create --print-join-command

#使用token，加入集群
#kubeadm join k8s-master:6443 --token agz7qs.3d2ihpu9w12aty5t

#node节点使用kubectl命令
scp -r $HOME/.kube k8s-node1:$HOME

#安装nginx，测试集群
kubectl create deployment nginx --image=nginx
kubectl expose deployment nginx --port=80 --type=NodePort
kubectl get pods,svc


#containerd配置文件修改参考
:<<!
[root@k8s-master ~]# cat /etc/containerd/config.toml
......省略部分......
    enable_selinux = false
    selinux_category_range = 1024
    #sandbox_image = "k8s.gcr.io/pause:3.2"
    # 注释上面那行，添加下面这行
    sandbox_image = "registry.cn-hangzhou.aliyuncs.com/google_containers/pause:3.2"
    stats_collect_period = 10
    systemd_cgroup = false
......省略部分......
          privileged_without_host_devices = false
          base_runtime_spec = ""
          [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
            # 添加下面这行
            SystemdCgroup = true
    [plugins."io.containerd.grpc.v1.cri".cni]
      bin_dir = "/opt/cni/bin"
......省略部分......
      [plugins."io.containerd.grpc.v1.cri".registry.mirrors]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."docker.io"]
          #endpoint = ["https://registry-1.docker.io"]
          # 注释上面那行，添加下面三行
          endpoint = ["https://docker.mirrors.ustc.edu.cn"]
        [plugins."io.containerd.grpc.v1.cri".registry.mirrors."k8s.gcr.io"]
          endpoint = ["https://registry.cn-hangzhou.aliyuncs.com/google_containers"]
    [plugins."io.containerd.grpc.v1.cri".image_decryption]
      key_model = ""
......省略部分......
[root@k8s-master ~]#
!