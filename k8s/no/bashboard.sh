#!/bin/bash
set -e
#部署dashboard
wget https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.0/aio/deploy/recommended.yaml
sed -ir "42a\      nodePort: 30005" recommended.yaml
sed -ir "39a\  type: NodePort" recommended.yaml
kubectl apply -f ./recommended.yaml
# echo -e "\n\n手动修改将type: ClusterIP改为：type: NodePort\n
# 命令：kubectl edit svc kubernetes-dashboard -n kubernetes-dashboard\n
# 查看端口命令：kubectl get svc -A | grep kubernetes-dashboard\n"
#创建访问账号
cat <<EOF |tee ./dash.yaml
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
