
### 安装docker

### 安装docker-compose
1. 添加Docker仓库：执行以下命令将Docker仓库添加到系统中：
```shell
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
```
这将通过yum-utils工具安装所需的软件包并将Docker仓库添加到系统的仓库列表中。

2. 安装Docker Compose：运行以下命令来安装Docker Compose：
```shell
sudo yum install -y docker-compose
```
yum命令将自动下载并安装Docker Compose及其依赖项。

3. 验证安装：安装完成后，您可以运行以下命令验证Docker Compose是否已成功安装：
```shell
docker-compose --version
```
您应该看到输出显示安装的Docker Compose的版本号。

现在，您已经成功使用yum在基于RPM包管理的Linux发行版上安装了Docker Compose。您可以开始使用Docker Compose来管理Docker化的应用程序和服务。



### 搭建zookeeper

#### windows使用docker搭建单机zookeeper
```shell
docker pull zookeeper:3.6
mkdir D:\docker\zookeeper\data
docker run -d --name zookeeper -p 2181:2181 -e TZ="Asia/Shanghai" -v /opt/zookeeper/data:/data -v /etc/localtime:/etc/localtime,readonly   --restart always zookeeper:3.7

```

#### linux使用docker搭建单机zookeeper
```shell
docker rm zookeeper

mkdir -p /root/docker/zookeeper/data

docker run -d --name zookeeper -p 2181:2181 -e TZ="Asia/Shanghai" -v /root/docker/zookeeper/data:/data -v /etc/localtime:/etc/localtime,readonly   --restart always zookeeper:3.7
```
我尝试使用:ro但是还是报错,最后还是使用了,readonly

```bash
docker: Error response from daemon: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: error mounting "/root/codes/mk/docker/zookeeper/localtime" to rootfs at "/etc/localtime": mount /root/codes/mk/docker/zookeeper/localtime:/etc/localtime (via /proc/self/fd/6), flags: 0x5001: not a directory: unknown: Are you trying to mount a directory onto a file (or vice-versa)? Check if the specified host path exists and is the expected type.
```

**注意:还需待完善** 
所有目录挂载必须遵循最小粒度，如容器仅需要读取宿主机某一个单独文件，禁止将整个目录挂载至容器，对于必须挂载的宿主机/home等的子目录必须为只读权限，以下举例如何设置只读权限:
1. 将zookeeper某个子目录以只读权限挂载只容器, -v 命令使用方法

```shell
docker rm zookeeper
docker run -d --name zookeeper -p 2181:2181 -v /root/codes/mk/docker/zookeeper/localtime:/etc/localtime:ro zookeeper:3.6
# :ro为只读
```

2.  将home某个子目录以只读权限挂载只容器, --mount 命令使用方法，docker 版本 >= 17.09 支持 mount
```shell
docker run -it --name mountTest --mount source=/home/data,destination=/home/data,readonly ubuntu /bin/bash
# ,readonly 表示改目录只能读取
```

### 安装kafka

#### linxu安装单机kafka
```shell
docker pull wurstmeister/kafka:2.12-2.5.0
docker pull wurstmeister/kafka

mkdir mkdir -p /root/docker/kafka/{k-datas,logs}
docker run -d --name kafka -p 9092:9092 --link zookeeper --env KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 -e KAFKA_BROKER_ID=0 -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://宿主机IP:9092 -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 -e TZ="Asia/Shanghai" -v /etc/localtime:/etc/localtime -v /root/docker/kafka/logs:/home/kafka/logs -v /root/docker/kafka/k-datas:/home/kafka/k-datas --restart=always --log-driver json-file --log-opt max-size=100m --log-opt max-file=2 wurstmeister/kafka:2.12-2.5.0


```


参数解析:
```shell
mkdir mkdir -p /root/docker/kafka/{k-datas,logs}
docker run -d --name kafka -p 9092:9092 \
-e KAFKA_BROKER_ID=0 \
-e KAFKA_ZOOKEEPER_CONNECT=Zookeeper-IP:2181 \
-e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://IP:9092 \
-e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 \
-e TZ="Asia/Shanghai" \
-v /etc/localtime:/etc/localtime \
-v /root/docker/kafka/logs:/home/kafka/logs \ 
-v /root/docker/kafka/k-datas:/home/kafka/k-datas \
--restart=always \
--log-driver json-file --log-opt max-size=100m --log-opt max-file=2 \
wurstmeister/kafka:2.12-2.5.0

```
| 参数                           | 说明                                                                                     |
|--------------------------------|------------------------------------------------------------------------------------------|
| -d                             | 在后台模式下运行容器                                                                     |
| --name kafka                   | 指定容器的名称                                                                           |
| -p 9092:9092                   | 将容器的9092端口映射到主机的9092端口                                                      |
| -e KAFKA_BROKER_ID=0           | 设置Kafka Broker的ID为0                                                                  |
| -e KAFKA_ZOOKEEPER_CONNECT=Zookeeper-IP:2181 | 指定Kafka连接的ZooKeeper的IP和端口                                      |
| -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://IP:9092 | kafka的地址和端口，用于向zookeeper注册 ip需要设置宿主机ip                |
| -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 | 设置Kafka监听器的地址和端口                   |
| -e TZ="Asia/Shanghai"          | 设置容器的时区为亚洲/上海时区                                                           |
| -v /etc/localtime:/etc/localtime | 将主机的时区配置同步到容器内                                                            |
| -v /root/docker/kafka/logs:/home/kafka/logs | 将主机上的日志目录挂载到容器的日志目录                           |
| -v /root/docker/kafka/k-datas:/home/kafka/k-datas | 将主机上的数据目录挂载到容器的数据目录                           |
| --restart=always               | 设置容器在异常退出时自动重启                                                              |
| --log-driver json-file         | 指定容器的日志驱动为json-file                                                           |
| --log-opt max-size=100m        | 设置日志文件的最大大小为100MB                                                            |
| --log-opt max-file=2           | 设置日志文件的最大数量为2                                                                |
| wurstmeister/kafka:2.12-2.5.0  | 使用wurstmeister/kafka镜像的2.12-2.5.0版本启动容器                                      |
| wurstmeister/kafka:2.12-2.5.0  | 使用wurstmeister/kafka镜像的2.12-2.5.0版本启动容器                                      |


-e KAFKA_ZOOKEEPER_CONNECT=Zookeeper-IP:2181 可替换成
--link zookeeper --env KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181
| 参数                                 | 说明                                                   |
|--------------------------------------|--------------------------------------------------------|
| --link zookeeper                     | 将容器链接到名为zookeeper的容器                           |
| --env KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 | 设置Kafka连接的ZooKeeper的主机名和端口号   |


#### linxu安装集群kafka
只需要修改端口和KAFKA_BROKER_ID=1的值,KAFKA_BROKER_ID不要重复
kafka节点1
```shell
mkdir mkdir -p /root/docker/kafka1/{k-datas,logs}
docker run -d --name kafka1 -p 9093:9092 --link zookeeper --env KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 -e KAFKA_BROKER_ID=1 -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://宿主机IP:9092 -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 -e TZ="Asia/Shanghai" -v /etc/localtime:/etc/localtime -v /root/docker/kafka1/logs:/home/kafka/logs -v /root/docker/kafka31/k-datas:/home/kafka/k-datas --restart=always --log-driver json-file --log-opt max-size=100m --log-opt max-file=2 wurstmeister/kafka:2.12-2.5.0
```
kafka节点2
```shell
mkdir mkdir -p /root/docker/kafka2/{k-datas,logs}
docker run -d --name kafka2 -p 9094:9092 --link zookeeper --env KAFKA_ZOOKEEPER_CONNECT=zookeeper:2181 -e KAFKA_BROKER_ID=2 -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://宿主机IP:9092 -e KAFKA_LISTENERS=PLAINTEXT://0.0.0.0:9092 -e TZ="Asia/Shanghai" -v /etc/localtime:/etc/localtime -v /root/docker/kafka2/logs:/home/kafka/logs -v /root/docker/kafka2/k-datas:/home/kafka/k-datas --restart=always --log-driver json-file --log-opt max-size=100m --log-opt max-file=2 wurstmeister/kafka:2.12-2.5.0
```


#### 验证zookeeper是否可用
```shell
docker exec -it zookeeper /bin/bash

sh zkCli.sh -server 127.0.0.1:2181

[zk: 127.0.0.1:2181(CONNECTED) 7] ls /
[zookeeper, kafka]
[zk: 127.0.0.1:2181(CONNECTED) 8] ls /kafka
[cluster, controller, controller_epoch, brokers, admin, isr_change_notification, consumers, config]
[zk: 127.0.0.1:2181(CONNECTED) 9]

```
#### 验证kafka是否可用
```shell
[root@blog]$docker exec -it kafka /bin/sh
/ # ps -ef
PID   USER     TIME  COMMAND
    1 root      0:08 /usr/lib/jvm/java-1.8-openjdk/jre/bin/java -Xmx1G -Xms1G -server -XX:+UseG1GC -XX:MaxGCPauseMillis=20 -XX:InitiatingHeapOccupancyPercent=35 -XX:+ExplicitGCInvokesConcurrent -XX:MaxIn
  502 root      0:00 /bin/sh
  506 root      0:00 ps -ef
/ #
生产者
bash-4.4# ./kafka-console-producer.sh --broker-listrver localhost:9092 --topic sun
123456789
abcdefgs

消费者
bash-4.4# ./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic sun --from-beginning

123456789
abcdefgs

```





### docker固定容器ip
docker安装后，默认会创建三种网络类型，bridge、host和none，可通过如下命令查看
```shell
sudo docker network ls
```
bridge:网络桥接 
默认情况下启动、创建容器都是用该模式，所以每次docker容器重启时会按照顺序获取对应ip地址，这就导致容器每次重启，ip都发生变化
none：无指定网络 
启动容器时，可以通过–network=none,docker容器不会分配局域网ip
host：主机网络 
docker容器的网络会附属在主机上，两者是互通的。

创建固定ip容器
1、创建自定义网络类型，并且指定网段
```shell
docker network create --subnet=192.168.0.0/16 mynetwork
```

通过docker network ls可以查看到网络类型中多了一个mynetwork

2、使用新的网络类型创建并启动容器
```shell
docker run -itd --name userserver --hostname kafka_node --net mynetwork --ip 192.168.0.2 docker.io/centos  /bin/bash
```
通过docker inspect可以查看容器ip为192.168.0.2，关闭容器并重启，发现容器ip并未发生改变

 

进入centos容器
```shell
docker attach bce6d9a692b2
```


