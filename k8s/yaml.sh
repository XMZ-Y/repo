#!/bin/bash
#calico网络插件
rm -f calico.yaml
curl https://docs.projectcalico.org/archive/v3.19/manifests/calico.yaml -O
sed -ir "s/.*- name: CALICO_IPV4POOL_CIDR/            - name: CALICO_IPV4POOL_CIDR/" calico.yaml
sed -ir "3684c\              value: \"10.244.0.0/16\"" calico.yaml
images=`cat calico.yaml |grep image|sed -n "s/.*image: //p"`
for imageName in ${images[@]} ; do
	crictl pull $imageName
done
kubectl apply -f calico.yaml
#部署Dashboard常用扩展工具
rm -f dashboard-recommended.yaml
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.0/aio/deploy/recommended.yaml
mv recommended.yaml dashboard-recommended.yaml
sed -i '42a\      nodePort: 30005' dashboard-recommended.yaml
sed -i '39a\  type: NodePort' dashboard-recommended.yaml
kubectl apply -f dashboard-recommended.yaml

tee ./dash.yaml <<'EOF'
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF
kubectl apply -f dash.yaml
kubectl -n kubernetes-dashboard get secret $(kubectl -n kubernetes-dashboard get sa/admin-user -o jsonpath="{.secrets[0].name}") -o go-template="{{.data.token | base64decode}}"