#!/bin/bash
set -i
cd ~
#calico网络插件
rm -f calico.yaml
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
# # 您也可以使用下面的指令，唯一的区别是，该指令使用华为云的镜像仓库替代 docker hub 分发 Kuboard 所需要的镜像
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
