#!/bin/bash

# 编译和打包脚本路径
BUILD_SCRIPT="build.sh"

# 构建和推送镜像脚本路径
BUILD_PUSH_SCRIPT="build-and-push.sh"

# Kubernetes 资源文件路径
PV_PVC_FILE="pv-pvc.yaml"
DEPLOYMENT_SERVICE_FILE="deployment-service.yaml"
INGRESS_FILE="ingress.yaml"

# 执行编译和打包
echo "执行编译和打包脚本..."
sh $BUILD_SCRIPT

# 执行构建和推送镜像
echo "执行构建和推送镜像脚本..."
sh $BUILD_PUSH_SCRIPT

# 创建 PV 和 PVC
echo "创建 PV 和 PVC..."
kubectl apply -f $PV_PVC_FILE

# 创建 Deployment 和 Service
echo "创建 Deployment 和 Service..."
kubectl apply -f $DEPLOYMENT_SERVICE_FILE

# 创建 Ingress
echo "创建 Ingress..."
kubectl apply -f $INGRESS_FILE

echo "启动脚本执行完毕！"
# chmod +x start-deployment.sh

