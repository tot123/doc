# 使用CentOS 7为基础镜像
# FROM openjdk:17-alpine
FROM openjdk:8
LABEL ts <xx@baidu.com>

# 安装Git
# RUN apk add --no-cache git curl openrc  wget 
# RUN yum instll -y git curl openrc  wget 
RUN  uname -a
# RUN apt-get update && apt-get install -y git curl openrc  wget lsof
    
# 复制所需的安装包到镜像中
COPY openjdk-17_linux-x64_bin.tar.gz .
COPY nacos-server-2.0.3.tar.gz .
COPY sentinel-dashboard-1.8.2.jar /usr/local/sentinel-dashboard.jar
COPY seata-server-1.4.2.tar.gz .

# 解压安装包
RUN tar zxvf nacos-server-2.0.3.tar.gz -C /usr/local && \
    tar zxvf openjdk-17_linux-x64_bin.tar.gz -C /usr/local && \
    tar zxvf seata-server-1.4.2.tar.gz -C /usr/local

# 设置环境变量
# ENV JAVA_HOME=/usr/local/jdk-17
# ENV PATH=$PATH:$JAVA_HOME/bin

# # 配置Nacos将数据持久化到MySQL 8
RUN sed -i 's/# db.num=1/db.num=1/g' /usr/local/nacos/conf/application.properties && \
    sed -i 's/# db.url.0=jdbc:mysql:\/\/172.21.192.95:3306\/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true/db.url.0=jdbc:mysql:\/\/127.0.0.1:3306\/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true/g' /usr/local/nacos/conf/application.properties && \
    sed -i 's/# db.user=nacos/db.user=nacos/g' /usr/local/nacos/conf/application.properties && \
    sed -i 's/# db.password=nacos/db.password=nacos/g' /usr/local/nacos/conf/application.properties 

RUN sed -i 's/type = "file"/type = "nacos"/g' /usr/local/seata/seata-server-1.4.2/conf/registry.conf && \
    sed -i 's/serverAddr = "127.0.0.1:8848"/serverAddr = "127.0.0.1:8848"/g' /usr/local/seata/seata-server-1.4.2/conf/registry.conf 

# 定义容器启动时执行的命令 nohup command 
# ENTRYPOINT ["/bin/bash", "-c", "nohup /usr/local/nacos/bin/startup.sh -m standalone & nohup java -jar /usr/local/sentinel-dashboard.jar & nohup sh /usr/local/seata-server-1.4.2/bin/seata-server.sh &"]
ENTRYPOINT ["/bin/bash", "-c", "nohup /usr/local/nacos/bin/startup.sh -m standalone > ~/nacos.log 2>&1 & nohup java -jar /usr/local/sentinel-dashboard.jar > ~/sentinel.log 2>&1 & nohup sh /usr/local/seata-server-1.4.2/bin/seata-server.sh > ~/seata.log 2>&1 &  tail -f  ~/*.log"]

# docker build --progress=plain --no-cache --squash -f codev1-3.dockerfile -t code:v7 .
# docker run -itd -p 8848:8848 -p 8080:8080 -p 8091:8091  --name code code:v7   

# http://127.0.0.1:8848/nacos nacos nacos
# http://127.0.0.1:8080 sentinel sentinel
# http://127.0.0.1:8091 

# nacos官网 https://nacos.io/zh-cn/index.html
# dubbo官网 http://dubbo.apache.org/en-us/
# seata官网 http://seata.io/zh-cn/
# Seata分布式事务启用Nacos做配置中心 https://seata.io/zh-cn/blog/seata-nacos-analysis.html