#!/bin/bash

# 假设你的镜像仓库地址为 registry.example.com，你需要修改为你自己的地址

# 设置镜像标签和仓库地址
IMAGE_TAG="latest"
REPO="registry.example.com/your-application"

# 登录到 Docker 镜像仓库
docker login -u your-username -p your-password registry.example.com

# 构建 Docker 镜像
docker build -t $REPO:$IMAGE_TAG .

# 推送镜像到仓库
docker push $REPO:$IMAGE_TAG

# 登出 Docker 镜像仓库
docker logout registry.example.com
