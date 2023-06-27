FROM ubuntu:20.04
LABEL ts <v_tangsu01@baidu.com>

# 设置默认时区为Asia/Shanghai
ENV TZ=Asia/Shanghai
ENV JAVA_HOME=/usr/local/jdk-17
ENV PATH=$PATH:$JAVA_HOME/bin
# 切换到root用户
USER root

WORKDIR /home/work

# 复制所需的安装包到镜像中
COPY openjdk-17_linux-x64_bin.tar.gz .
COPY nacos-server-2.0.3.tar.gz .
COPY sentinel-dashboard-1.8.2.jar /usr/local/sentinel-dashboard.jar
COPY seata-server-1.4.2.tar.gz .

# 解压安装包
RUN tar zxvf nacos-server-2.0.3.tar.gz -C /usr/local && \
    tar zxvf openjdk-17_linux-x64_bin.tar.gz -C /usr/local && \
    tar zxvf seata-server-1.4.2.tar.gz -C /usr/local

# 配置Nacos将数据持久化到MySQL 8
RUN sed -i 's/# db.num=1/db.num=1/g' /usr/local/nacos/conf/application.properties && \
    sed -i 's/# db.url.0=jdbc:mysql:\/\/127.0.0.1:3306\/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true/db.url.0=jdbc:mysql:\/\/127.0.0.1:3306\/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true/g' /usr/local/nacos/conf/application.properties && \
    sed -i 's/# db.user=nacos/db.user=nacos/g' /usr/local/nacos/conf/application.properties && \
    sed -i 's/# db.password=nacos/db.password=nacos/g' /usr/local/nacos/conf/application.properties


RUN apt update && \
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt install -y mysql-server tzdata git  && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf && \
    /etc/init.d/mysql start && /etc/init.d/mysql status && \
    mysql -u root -e "CREATE database nacos;"  && \
    mysql -u root -e "CREATE USER 'nacos'@'%' IDENTIFIED BY 'nacos'; GRANT ALL PRIVILEGES ON *.* TO 'nacos'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;select host,user, authentication_string FROM mysql.user;" 

RUN cat /usr/local/nacos/conf/nacos-mysql.sql 

RUN /etc/init.d/mysql start && /etc/init.d/mysql status && \
    mysql -unacos -pnacos -D nacos < /usr/local/nacos/conf/nacos-mysql.sql 

# 暴露 MySQL 默认端口
EXPOSE 3306  8848 8080 8091 8099

# 启动 MySQL 服务
# ENTRYPOINT ["/bin/bash", "-c", "mysqld", "--user=root", "--console"]
ENTRYPOINT ["/bin/bash", "-c", "nohup sh /usr/local/nacos/bin/startup.sh -m standalone & nohup java -jar /usr/local/sentinel-dashboard.jar & nohup sh /usr/local/seata-server-1.4.2/bin/seata-server.sh &"]

