# 使用CentOS 7为基础镜像
FROM centos:7

# 安装Git
# RUN yum install -y git wget && yum clean all

# 备份并替换Yum源为阿里云源
# RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup && \
#     curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo && \
#     yum makecache && \
#     yum clean all
    
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
ENV JAVA_HOME=/usr/local/jdk-17
ENV PATH=$PATH:$JAVA_HOME/bin

# 安装MySQL 8
# RUN yum install -y mysql80-community-release-el7-2.noarch.rpm mysql-community-server && \
#     systemctl enable mysqld && \
#     yum clean all

# # 配置MySQL 8
# RUN echo "[mysqld]" >> /etc/my.cnf && \
#     echo "default_authentication_plugin=mysql_native_password" >> /etc/my.cnf && \
#     echo "lower_case_table_names=1" >> /etc/my.cnf

# # 启动MySQL 8并设置密码为root
# RUN systemctl start mysqld && \
#     mysqladmin -u root password 'root'

# # 创建nacos用户并授权
# RUN mysql -u root -proot -e "CREATE USER 'nacos'@'%' IDENTIFIED BY 'nacos';" && \
#     mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'nacos'@'%';" && \
#     mysql -u root -proot -e "FLUSH PRIVILEGES;"

# 配置Nacos将数据持久化到MySQL 8
RUN sed -i 's/# db.num=1/db.num=1/g' /usr/local/nacos/conf/application.properties && \
    sed -i 's/# db.url.0=jdbc:mysql:\/\/172.21.192.95:3306\/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true/db.url.0=jdbc:mysql:\/\/127.0.0.1:3306\/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true/g' /usr/local/nacos/conf/application.properties && \
    sed -i 's/# db.user=nacos/db.user=nacos/g' /usr/local/nacos/conf/application.properties && \
    sed -i 's/# db.password=nacos/db.password=nacos/g' /usr/local/nacos/conf/application.properties

# 导入Nacos的数据库脚本
# RUN mysql -u nacos -pnacos < /usr/local/nacos/conf/nacos-mysql.sql

# 定义容器启动时执行的命令
# ENTRYPOINT ["/bin/bash", "-c", "nohup sh /usr/local/nacos/bin/startup.sh -m standalone & nohup java -jar /usr/local/sentinel-dashboard.jar & nohup sh /usr/local/seata-server-1.4.2/bin/seata-server.sh &"]
