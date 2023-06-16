

1. ### mysql

```shell
echo "1.创建挂载目录"
mkdir -p /root/docker/mysql/{data,config,logs}

echo "2.指定mysql配置"
cat << EOF >/root/docker/mysql/config/my.cnf
[mysqld]
server-id = 1 #服务Id唯一
port = 3306
log-erro = /var/log/mysql/error.log
#只能用IP地址
skip_name_resolve 
#数据库默认字符集
character-set-server = utf8mb4
#数据库字符集对应一些排序等规则 
collation-server = utf8mb4_general_ci
#设置client连接mysql时的字符集,防止乱码
init_connect='SET NAMES utf8mb4'
#最大连接数
max_connections = 300
#binlog setting
log-bin=mysql-bin  // 开启logbin
binlog-format=ROW  // binlog日志格式
# server-id=1  // mysql主从备份serverId,canal中不能与此相同
EOF

echo "4.docker启动mysql"
docker run --name mysql -d  \
-v /root/docker/mysql/conf:/etc/mysql/conf.d,readonly \
-v /root/docker/mysql/data:/var/lib/mysql,readonly \
-p 3306:3306 -e MYSQL_ROOT_PASSWORD=root mysql:5.7.22

echo "5.设置mysql开启自启"
docker update --restart=always mysql


```

查看binlog日志是否开启成功
```shell
mysql> show variables like 'log_%';
+----------------------------------------+--------------------------------+
| Variable_name                          | Value                          |
+----------------------------------------+--------------------------------+
| log_bin                                | ON                             |
| log_bin_basename                       | /var/lib/mysql/mysql-bin       |
| log_bin_index                          | /var/lib/mysql/mysql-bin.index |
+----------------------------------------+--------------------------------+

mysql> show variables like 'binlog_format';
+---------------+-------+
| Variable_name | Value |
+---------------+-------+
| binlog_format | ROW   |
+---------------+-------+
1 row in set (0.00 sec)

mysql> show master status; // 查看master状态
+------------------+----------+--------------+------------------+-------------------+
| File             | Position | Binlog_Do_DB | Binlog_Ignore_DB | Executed_Gtid_Set |
+------------------+----------+--------------+------------------+-------------------+
| mysql-bin.000001 |      154 |              |                  |                   |
+------------------+----------+--------------+------------------+-------------------+
1 row in set (0.00 sec)

mysql> reset master;  // 重置日志

```



root远程登录
```shell

# docker exec mysql mysql -u root -p root

docker exec -it mysql bash
mysql -uroot -proot -h  -d mysql
mysql -h 127.0.0.1 -P 3306 -u root -proot -D mysql

GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY 'root' WITH GRANT OPTION;
FLUSH PRIVILEGES;
SELECT User, Host FROM user;


其他服务器执行
mysql -u账号 -p密码 -h IP地址
```

canal执行
```shell
CREATE USER canal IDENTIFIED BY 'canal';  
GRANT SELECT, REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'canal'@'%';
# GRANT ALL PRIVILEGES ON *.* TO 'canal'@'%' ;
FLUSH PRIVILEGES;
```
## ELKF 安装
```shell
docker pull elasticsearch:7.17.1
docker pull kibana:7.17.1
docker pull logstash:7.17.1
docker pull store/elastic/filebeat:7.17.1
```

2. ### elasticsearch

```shell
mkdir -p /root/docker/elk/es/{config,data,plugins}
cat << EOF > /root/docker/elk/es/config/es.yml
# 集群名称
cluster.name: elasticsearch-cluster
# 节点名称
node.name: es-node1
# 绑定host，0.0.0.0代表当前节点的ip
network.host: 0.0.0.0
# 设置其它节点和该节点交互的ip地址，如果不设置它会自动判断，值必须是个真实的ip地址(本机ip)
# network.publish_host: 192.168.0.166
# 设置对外服务的http端口，默认为9200
http.port: 9200
# 设置节点间交互的tcp端口，默认是9300
transport.tcp.port: 9300
# 是否支持跨域，默认为false
http.cors.enabled: true
# 当设置允许跨域，默认为*,表示支持所有域名，如果我们只是允许某些网站能访问，那么可以使用正则表达式。比如只允许本地地址。 /https?:\/\/localhost(:[0-9]+)?/
http.cors.allow-origin: "*"
# 表示这个节点是否可以充当主节点
# node.master: true
# 是否充当数据节点
node.data: true
# 所有主从节点ip:port
# discovery.seed_hosts: ["192.168.0.166"]
# cluster.initial_master_nodes: ["es-node1"]
# 这个参数决定了在选主过程中需要 有多少个节点通信  预防脑裂
# discovery.zen.minimum_master_nodes: 1
EOF

docker run --name elasticsearch -p 9200:9200 -p 9300:9300 \
-e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms256m -Xmx256m" \
-v /root/docker/elk/es/config/es.yml:/usr/share/elasticsearch/config/elasticsearch.yml \
-v /root/docker/elk/es/data/:/usr/share/elasticsearch/data \
-v /root/docker/elk/es/plugins:/usr/share/elasticsearch/plugins \
-d elasticsearch:7.17.1




docker network create elknetwork

# 运行 elasticsearch
docker run -d --name elasticsearch \
--net elknetwork  -p 9200:9200 -p 9300:9300 \
-e "ES_JAVA_OPTS=-Xms2048m -Xmx2048m" \
-e "discovery.type=single-node" \
elasticsearch:7.17.1


echo "5.设置mysql开启自启ocker update --restart=always elasticsearch


curl http://127.0.0.1:9200 
```



```shell
docker run --name elasticsearch -p 9200:9200 -p 9300:9300 -e "discovery.type=single-node" -e ES_JAVA_OPTS="-Xms256m -Xmx256m"  -d elasticsearch:7.17.1
docker cp  /root/docker/elk/es/config/es.yml elasticsearch:/usr/share/elasticsearch/config/es.yml
docker restart elasticsearch
```

安装中文分词插件-在线
```shell
docker exec -it elasticsearch bash
./bin/elasticsearch-plugin install https://github.com/medcl/elasticsearch-analysis-ik/releases/download/v7.4.2/elasticsearch-analysis-ik-7.4.2.zip
./bin/elasticsearch-plugin install http://xbib.org/repository/org/xbib/elasticsearch/importer/elasticsearch-jdbc/2.3.4.0/elasticsearch-jdbc-2.3.4.0-dist.zip
cd /plugins/  // 进入插件目录,可以看到已安装 analysis-ik 

```

安装中文分词插件-离线
```shell

docker exec -it elasticsearch bashcd 
cd /bin/
docker cp elasticsearch-analysis-ik-6.4.0.zip elasticsearch-6.4:/usr/share/elasticsearch/plugins
mkir ik/  // 创建目录
unzip elasticsearch-analysis-ik-6.4.0.zip -d ik/  // 解压zip到目录中
rm -rf elasticsearch-analysis-ik-6.4.0.zip  // plugins目录里不能有其他格式文件


```
3. ### kibana

```shell
mkdir -p /root/docker/kibana/config
cat << EOF >kibana.yml
#
# ** THIS IS AN AUTO-GENERATED FILE **
#
# Default Kibana configuration for docker target
server.host: "0.0.0.0"
server.shutdownTimeout: "5s"
# 注意你的本地IP
elasticsearch.hosts: [ "http://yourip:9200" ] 
monitoring.ui.container.elasticsearch.enabled: true
i18n.locale: "zh-CN"
EOF
docker run --name kibana -e ELASTICSEARCH_URL=http://172.17.0.4:9200 -p 5601:5601 -d kibana:7.17.1


```



汉化
```shell
docker exec  -it kibana bash 
echo ' ' >> /usr/share/kibana/config/kibana.yml
echo 'i18n.locale: "zh-CN"' >> /usr/share/kibana/config/kibana.yml
cat /usr/share/kibana/config/kibana.yml



docker exec  kibana cat /usr/share/kibana/config/kibana.yml

```
4. ### canal

```shell
vim /docker/canal/start.sh
# 内容
docker run --name canal \
-e canal.instance.master.address=192.168.2.102:3306 \
-e canal.instance.dbUsername=canal \
-e canal.instance.dbPassword=canal \
-p 11111:11111 \
-d canal/canal-server:v1.1.4


```

5. ### RoketMQ 

#####  快速使用
```shell
docker run -d -p 9876:9876  --name rmqnamesrv -e "MAX_POSSIBLE_HEAP=100000000" rocketmqinc/rocketmq:4.4.0 sh mqnamesrv

docker run -d -p 10911:10911 -p 10909:10909 --name rmqbroker --link rmqnamesrv:namesrv -e "NAMESRV_ADDR=namesrv:9876" -e "MAX_POSSIBLE_HEAP=200000000" rocketmqinc/rocketmq:4.4.0 sh mqbroker -c /opt/rocketmq-4.4.0/conf/broker.conf

docker run -e "JAVA_OPTS=-Drocketmq.namesrv.addr={本地外网 IP}:9876 -Dcom.rocketmq.sendMessageWithVIPChannel=false" -p 8080:8080 -t pangliang/rocketmq-console-ng

```



```shell
docker run -d -p 9876:9876 -v /usr/local/mq/data/namesrv/logs:/root/logs -v /usr/local/mq/data/namesrv/store:/root/store --name rmqnamesrv -e "MAX_POSSIBLE_HEAP=100000000" 09bbc30a03b6 sh mqnamesrv

docker run -d -p 10911:10911 -p 10909:10909 -v /usr/local/mq/data/broker/logs:/root/logs -v /usr/local/mq/data/broker/store:/root/store -v /usr/local/mq/conf/broker.conf:/opt/rocketmq-4.4.0/conf/broker.conf --name rmqbroker --link rmqnamesrv:namesrv -e "NAMESRV_ADDR=namesrv:9876" -e "MAX_POSSIBLE_HEAP=200000000" 09bbc30a03b6 sh mqbroker -c /opt/rocketmq-4.4.0/conf/broker.conf





docker run -d -p 10911:10911 -p 10909:10909\
 --name rmqbroker --link rmqserver:namesrv\
 -e "NAMESRV_ADDR=namesrv:9876" -e "JAVA_OPTS=-Duser.home=/opt"\
 -e "JAVA_OPT_EXT=-server -Xms128m -Xmx128m"\
 foxiswho/rocketmq:broker-4.5.1
```

6. ### mysql

```shell

```
7. ### redis

```shell
docker run -p 6379:6379 --name redis \
-v /mydata/redis/data:/data \
-v /mydata/redis/conf/redis.conf:/etc/redis/redis.conf \
-d redis redis-server /etc/redis/redis.conf
```


简单点
```shell
docker run -p 6379:6379 --name redis \
-d redis redis-server /etc/redis/redis.conf
```
8. ### mysql


