#!/bin/bash
#calico网络插件
rm -f calico.yaml
curl -O https://docs.projectcalico.org/manifests/calico.yaml
kubectl apply -f calico.yaml
#部署Dashboard常用扩展工具
rm -f dashboard-recommended.yaml
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.0/aio/deploy/recommended.yaml
mv recommended.yaml dashboard-recommended.yaml
sed -i '42a\      nodePort: 30005' dashboard-recommended.yaml
sed -i '39a\  type: NodePort' dashboard-recommended.yaml
kubectl apply -f dashboard-recommended.yaml
#auth.yaml
cat > ./auth.yaml <<!
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
!
kubectl apply -f auth.yaml

