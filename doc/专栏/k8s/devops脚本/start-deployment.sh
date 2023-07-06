#!/bin/bash

# 编译和打包脚本路径
BUILD_SCRIPT="build.sh"

# 构建和推送镜像脚本路径
BUILD_PUSH_SCRIPT="build-and-push.sh"

# Kubernetes 资源文件路径
PV_PVC_FILE="pv-pvc.yaml"
DEPLOYMENT_SERVICE_FILE="deployment-service.yaml"
INGRESS_FILE="ingress.yaml"

# 检查 PV 和 PVC 是否已存在
PV_PVC_EXIST=$(kubectl get pv your-pv --ignore-not-found=true)
if [ -z "$PV_PVC_EXIST" ]; then
  # 创建 PV 和 PVC
  echo "创建 PV 和 PVC..."
  kubectl apply -f $PV_PVC_FILE
else
  echo "PV 和 PVC 已存在，跳过创建步骤。"
fi
  
# 执行编译和打包
echo "执行编译和打包脚本..."
sh $BUILD_SCRIPT

# 执行构建和推送镜像
echo "执行构建和推送镜像脚本..."
sh $BUILD_PUSH_SCRIPT

# 检查 Deployment 是否已存在
DEPLOYMENT_EXIST=$(kubectl get deployment your-application-deployment --ignore-not-found=true)
if [ -z "$DEPLOYMENT_EXIST" ]; then

  # 创建 Deployment 和 Service
  echo "创建 Deployment 和 Service..."
  kubectl apply -f $DEPLOYMENT_SERVICE_FILE
else
  echo "Deployment 已存在，执行滚动更新..."

  # 执行滚动更新
  echo "执行滚动更新..."
  kubectl set image deployment/your-application-deployment your-application=registry.example.com/your-application:new-version
  
  # 等待滚动更新完成
  echo "等待滚动更新完成..."
  kubectl rollout status deployment/your-application-deployment
fi

# 检查 Ingress 是否已存在
INGRESS_EXIST=$(kubectl get ingress your-application-ingress --ignore-not-found=true)
if [ -z "$INGRESS_EXIST" ]; then
  # 创建 Ingress
  echo "创建 Ingress..."
  kubectl apply -f $INGRESS_FILE
else
  echo "Ingress 已存在，跳过创建步骤。"
fi

echo "启动脚本执行完毕！"
