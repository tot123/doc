# 使用 Alpine Linux 版本的 OpenJDK 8 镜像作为基础镜像
FROM openjdk:8-jre-alpine
LABEL ts <xx@baidu.com>

# 安装 Git 和其他工具
# RUN apk add --no-cache git curl wget lsof
WORKDIR /home/work 
# 复制所需的安装包到镜像中
# COPY openjdk-17_linux-x64_bin.tar.gz .
# COPY nacos-server-2.0.3.tar.gz .
# COPY sentinel-dashboard-1.8.2.jar /home/work/sentinel-dashboard.jar
# COPY seata-server-1.4.2.tar.gz .
COPY *.gz *.jar /home/work 

# 解压安装包并删除不需要的文件
RUN tar zxvf nacos-server-2.0.3.tar.gz -C /home/work && \
    # tar zxvf openjdk-17_linux-x64_bin.tar.gz -C /home/work && \
    tar zxvf seata-server-1.4.2.tar.gz -C /home/work && \
    rm -rf *.tar.gz /var/cache/apk/* 

# 配置 Nacos 和 Seata Server
RUN sed -i 's/# db.num=1/db.num=1/g' /home/work/nacos/conf/application.properties && \
    sed -i 's/# db.url.0=jdbc:mysql:\/\/127.0.0.1:3306\/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true/db.url.0=jdbc:mysql:\/\/172.21.192.95:3306\/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true/g' /home/work/nacos/conf/application.properties && \
    sed -i 's/# db.user=nacos/db.user=nacos/g' /home/work/nacos/conf/application.properties && \
    sed -i 's/# db.password=nacos/db.password=nacos/g' /home/work/nacos/conf/application.properties && \
    sed -i 's/type = "file"/type = "nacos"/g' /home/work/seata/seata-server-1.4.2/conf/registry.conf && \
    sed -i 's/serverAddr = "127.0.0.1:8848"/serverAddr = "127.0.0.1:8848"/g' /home/work/seata/seata-server-1.4.2/conf/registry.conf

# 定义容器启动时执行的命令
ENTRYPOINT ["/bin/sh", "-c", "nohup /home/work/nacos/bin/startup.sh -m standalone > ~/nacos.log 2>&1 & nohup java -jar /home/work/sentinel-dashboard.jar > ~/sentinel.log 2>&1 & nohup sh /home/work/seata-server-1.4.2/bin/seata-server.sh > ~/seata.log 2>&1 & tail -f /home/work/*.log"]
