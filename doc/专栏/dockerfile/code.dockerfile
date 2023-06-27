# 使用centos7为基础镜像
FROM centos:7

# 安装git
RUN yum install -y git

# 备份并替换yum源为阿里源
RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup
RUN curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
RUN yum makecache

# 安装JDK 17
RUN curl -O https://download.java.net/java/GA/jdk17/0d483333a00540d886896bac774ff48b/35/GPL/openjdk-17_linux-x64_bin.tar.gz
RUN tar zxvf openjdk-17_linux-x64_bin.tar.gz -C /usr/local
ENV JAVA_HOME=/usr/local/jdk-17
ENV PATH=$PATH:$JAVA_HOME/bin

# 安装MySQL 8
RUN rpm -Uvh https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm
RUN yum install -y mysql-community-server
RUN systemctl enable mysqld

# 配置MySQL 8
RUN echo "[mysqld]" >> /etc/my.cnf
RUN echo "default_authentication_plugin=mysql_native_password" >> /etc/my.cnf
RUN echo "lower_case_table_names=1" >> /etc/my.cnf

# 启动MySQL 8并设置密码为root
RUN systemctl start mysqld
RUN mysqladmin -u root password 'root'

# 创建nacos用户并授权
RUN mysql -u root -proot -e "CREATE USER 'nacos'@'%' IDENTIFIED BY 'nacos';"
RUN mysql -u root -proot -e "GRANT ALL PRIVILEGES ON *.* TO 'nacos'@'%';"
RUN mysql -u root -proot -e "FLUSH PRIVILEGES;"

# 下载并解压Nacos、Sentinel、Seata
RUN curl -O https://github.com/alibaba/nacos/releases/download/2.0.3/nacos-server-2.0.3.tar.gz
RUN tar zxvf nacos-server-2.0.3.tar.gz -C /usr/local

RUN curl -O https://github.com/alibaba/Sentinel/releases/download/1.8.2/sentinel-dashboard-1.8.2.jar
RUN mv sentinel-dashboard-1.8.2.jar /usr/local/sentinel-dashboard.jar

RUN curl -O https://github.com/seata/seata/releases/download/v1.4.2/seata-server-1.4.2.tar.gz
RUN tar zxvf seata-server-1.4.2.tar.gz -C /usr/local

# 配置Nacos将数据持久化到MySQL 8
RUN sed -i 's/# db.num=1/db.num=1/g' /usr/local/nacos/conf/application.properties
RUN sed -i 's/# db.url.0=jdbc:mysql:\/\/127.0.0.1:3306\/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true/db.url.0=jdbc:mysql:\/\/127.0.0.1:3306\/nacos?characterEncoding=utf8&connectTimeout=1000&socketTimeout=3000&autoReconnect=true/g' /usr/local/nacos/conf/application.properties
RUN sed -i 's/# db.user=nacos/db.user=nacos/g' /usr/local/nacos/conf/application.properties
RUN sed -i 's/# db.password=nacos/db.password=nacos/g' /usr/local/nacos/conf/application.properties

# 导入Nacos的数据库脚本
RUN mysql -u nacos -pnacos < /usr/local/nacos/conf/nacos-mysql.sql

# 启动Nacos、Sentinel、Seata，并暴露相应的端口
EXPOSE 8848 8080 8091 8099 8000 8001 8002 8003 8004 8005 8006 8007 8008 8009 8010 8011 8012

CMD ["/bin/bash", "-c", "nohup sh /usr/local/nacos/bin/startup.sh -m standalone & nohup java -jar /usr/local/sentinel-dashboard.jar & nohup sh /usr/local/seata-server-1.4.2/bin/seata-server.sh &"]
