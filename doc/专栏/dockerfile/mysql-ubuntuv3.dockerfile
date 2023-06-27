FROM mysql
LABEL ts <v_tangsu01@baidu.com>

# 设置默认时区为Asia/Shanghai
ENV TZ=Asia/Shanghai

# 切换到root用户
USER root

WORKDIR /home/work

RUN apt update && \
    ln -sf /usr/share/zoneinfo/$TZ /etc/localtime && \
    echo $TZ > /etc/timezone && \
    apt install -y tzdata && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    # sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mysql.conf.d/mysqld.cnf && \
    # /etc/init.d/mysql start && /etc/init.d/mysql status && \
    mysql -u root -e "CREATE USER 'nacos'@'%' IDENTIFIED BY 'nacos'; GRANT ALL PRIVILEGES ON *.* TO 'nacos'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;select host,user, authentication_string FROM mysql.user;" 

# 暴露 MySQL 默认端口
EXPOSE 3306

# 启动 MySQL 服务
ENTRYPOINT ["/bin/bash", "-c", "mysqld", "--user=root", "--console"]
