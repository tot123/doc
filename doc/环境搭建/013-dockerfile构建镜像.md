### docker 构建镜像常用命令
构建镜像
```shell
docker build --progress=plain --no-cache --squash -f codev.dockerfile -t code:v1 .

# --progress=plain 输出详细过程
# --no-cache 构建不使用缓存
# --squash 将镜像压缩成一层
# -f codev.dockerfile 指定文件位置 不指定默认为Dockerfile
# -t code:v1  指定 构建镜像名称:版本
# . 表示从当前目录
```

调试镜像
```shell
docker run -it --rm --name er-debug -p 8080:8080 --entrypoint sh code:v1
# --rm 容器停止后删除
# --name er-debug 指定运行容器名称
# -p 8080:8080 指定映射端口 宿主机:容器
# --entrypoint sh 替换 ENTRYPOINT[]中的命令,就是不执行的意思
# code:v1  镜像名称:版本
```

登录 登出 docker
```shell
docker login -u 用户名 -p 密码
docker logout
```
提交镜像
```shell
# 提交到本地 
docker commit -a "ts" -m "本次提交信息" c1abdc177915 ts/code:v1
    # -a "tangsu"  指定作者为 ts
    # -m "本次提交信息"  commit信息
    # c1abdc177915   运行容器id
    # ts/code:v1  镜像名称 注意ts是自己的dockerhub用户名


# push到远程 需要登录

```

### dockerfile 常用语法
[Docker Dockerfile 常用语法](https://juejin.cn/post/6844904186161659917)
```shell
# 基于 nginx:1.17.9 镜像构建
FROM nginx:1.17.9

# 指定信息
LABEL ts="ts@xxx.com"

# 设置环境变量
ENV NGINX_VERSION 1.17.9

# 切换 root 用户
USER root

# 执行命令，安装 curl 软件，设置软链接把 nginx 服务的日志显示到终端输出上。
RUN apt-get -yq update && apt-get install -y curl && \
ln -sf /dev/stdout /var/log/nginx/access.log && \
ln -sf /dev/stderr /var/log/nginx/error.log

# 设置容器内 /data 目录为匿名卷
VOLUME ["/data"]

# 设置工作目录
WORKDIR /data/html/

# 复制 index.html 文件到 WORKDIR 目录下。
COPY index.html .

# 映射 80 端口
EXPOSE 80

# 此处 CMD 作为 ENTRYPOINT 的参数。
# CMD ["nginx", "-g", "daemon off;"]
CMD ["-g", "daemon off;"]

# 设置容器启动的命令
ENTRYPOINT ["nginx"]

# 检查容器健康，通过访问 Nginx 服务 80 端口，来判断容器服务是否运行正常。
HEALTHCHECK --interval=5s --timeout=3s \
  CMD curl -fs http://localhost/ || exit 1
```
启动后，HEALTHCHECK 就会5秒钟访问一次 Nginx 服务，来确保容器运行的状态。   

构建命令 docker build 中可以用 --build-arg <参数名>=<值> 来覆盖ENV。   


多个cmd,ENTRYPOINT会被覆盖只执行最后一个   
如果docker run --entrypoint 传参数 cmd会被覆盖 ENTRYPOINT会将传入值当作参数使用   
ENTRYPOINT可以和cmd一起使用 cmd此时就相当于给ENTRYPOINT传入参数    
### 自定义镜像开心一下
注意如果再k8s中运行的话最好使用alpine镜像,因为alpine足够小
alpine 安装包仓库
#### alpine使用node

#### 常用镜像
```shell
openjdk:17-alpine
node:20-alpine3.18
3.12.0b3-alpine3.18
```
调试镜像
```shell
docker run -it --rm --name er-debug -p 8080:8080 --entrypoint sh node:20-alpine3.18
```

##### 手动安装node
```shell 
FROM alpine:latest
# 安装nodejs环境，国内使用阿里云镜像加速，不然太慢了，打包服务器在国外的可以不改。
RUN echo "http://mirrors.aliyun.com/alpine/edge/main/" > /etc/apk/repositories \
    && echo "http://mirrors.aliyun.com/alpine/edge/community/" >> /etc/apk/repositories \
    && apk update \
    && apk add --no-cache --update nodejs npm \ # 关于版本问题，生产环境建议锁定版本
    && node -v && npm -v \
    && npm config set registry https://registry.npm.taobao.org

ENV NODE_ENV production

WORKDIR /home/app

COPY package.json /home/app/

RUN npm install --production

COPY . /home/app

EXPOSE 8080

CMD ["npm", "start"]
```
##### 使用node镜像
```shell
from node:20-alpine3.18
RUN apk add --no-cache build-base git && \
    git clone https://github.com/tot123/html2md.git && \
    git clone https://github.com/curlconverter/curlconverter.git && \
    cd ./html2md && npm install && npm run dev
ENTRYPOINT["/bin/sh", "-c", "npm run dev"]
```