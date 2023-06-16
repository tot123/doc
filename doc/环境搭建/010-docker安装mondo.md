
## docker快速安装mongo
```shell
docker run --name mongo -p 27017:27017 -d mongo --replSet rs1  --restart always 
docker run --name mongo -p 8017:27017 -d mongo --replSet rs1 

```

## docker安装mongo主从仲
```shell
mkdir -p /home/mongodb/{master,slave,arditer}/{configdb,db}

vi /home/mongodb/master/configdb/mongod.conf
```

```shell
net:
    #启动端口
    port: 27017
    #允许连接的IP(0.0.0.0作用与--bind_ip_all类似)
    bindIp: 0.0.0.0
systemLog:
    #重新启动mongodb的时候日志拼接在以前的日志文件上
    logAppend: true
security:
    #路径是容器映射到宿主机的路径
    keyFile: "/home/mongodb/config/mongodbKeyfile.key"
    #开启客户端连接认证 disabled 关闭授权
    authorization: "enabled"
replication:
    replSetName: "mongo_rs"
```

```shell
#生成key文件
openssl rand -base64 756 > /home/mongodb/master/configdb/mongodbKeyfile.key
#key文件必须设置成400,否则将会失败（设置成其他都会失败了，不知道是不是这个权限问题）
chmod 400 /home/mongodb/master/configdb/mongodbKeyfile.key


# docker run --name mongo -p 21117:27017 -d mongo --replSet rs1
# docker cp mongo:/data/configdb /home/mongodb/master/configdb
# docker cp mongo:/data/ /home/mongodb/master 
 cp -r /home/mongodb/master/configdb/  /home/mongodb/slave/configdb/
 cp -r /home/mongodb/master/configdb/  /home/mongodb/arditer/configdb/

#启动容器 master
docker run -di --name=mongo_master -p 27110:27017 -v /home/mongodb/master/configdb:/data/configdb,readonly -v /home/mongodb/master/db:/data/db,readonly mongo --replSet "mongo_rs" 

#启动容器 slave
docker run -di --name=mongo_slave -p 27111:27017 -v /home/mongodb/slave/configdb/:/data/configdb/ -v /home/mongodb/slave/db:/data/db,readonly mongo --replSet "mongo_rs"

#启动容器 arditer
docker run -di --name=mongo_arditer -p 27112:27017 -v /home/mongodb/arditer/configdb:/data/configdb,readonly -v /home/mongodb/arditer/db:/data/db,readonly mongo --replSet "mongo_rs" 


#master进入容器
docker exec -it mongo_master mongosh admin
#配置主从(同一个服务器可以配置成相同ip,arbiterOnly:true该配置是配置成仲裁)
rs.initiate({_id:"mongo_rs",members:[{_id:0,host:"10.27.34.136:27110"},{_id:1,host:"10.27.34.136:27111"},{_id:2,host:"10.27.34.136:27112",arbiterOnly:true}]})

#切换至admin
use admin
#添加用户
db.createUser({user:'root',pwd:'123456',roles:[{role:'userAdminAnyDatabase',db:'admin'},{role:'dbAdminAnyDatabase',db:'admin'}]})
#登录
db.auth('root','123456')
#切换至测试库
use test
#给测试库添加账户
db.createUser({user:'test',pwd:'123456',roles:[{role:'readWrite',db:'test'}]})
#给测试库添加数据
db.userinfo.insert({"name":"张三","sex":"男"})
docker restart mongo_master mongo_slave mongo_arditer


```

```shell

# 11、进入slave中查看是否已经同步数据
#进入备机
docker exec -it mongo_slave mongosh test
#登录
db.auth('test','123456')
#设置备机可读 不行就使用 rs.secondaryOk()
rs.slaveOk()  
#查询数据
db.userinfo.find()
```





### 1、拉取mongo镜像
```shell
docker pull mongo
```

### 2、创建Master路径

### 3、创建Slave路径

### 4、创建Arditer路径
```shell
mkdir -p /home/mongodb/{master,slave,arditer}/{configdb,db}
```


### 5、创建配置文件(三个配置文件保持一致，如果在同一个服务器中一份文件即可)
```shell
vi /home/mongodb/master/configdb/mongod.conf
```
### 6、配置文件内容如下：
```shell
net:
    #启动端口
    port: 27017
    #允许连接的IP(0.0.0.0作用与--bind_ip_all类似)
    bindIp: 0.0.0.0
systemLog:
    #重新启动mongodb的时候日志拼接在以前的日志文件上
    logAppend: true
security:
    #路径是容器映射到宿主机的路径
    keyFile: "/home/mongodb/config/mongodbKeyfile.key"
    #开启客户端连接认证 disabled 关闭授权
    authorization: "enabled"
replication:
    replSetName: "mongo_rs"
```
### 7、生成key文件(需要注意三个都需要用同一个文件，否则会出现验证失败的情况)
```shell
#生成key文件
openssl rand -base64 756 > /home/mongodb/master/configdb/mongodbKeyfile.key
#key文件必须设置成400,否则将会失败（设置成其他都会失败了，不知道是不是这个权限问题）
chmod 400 /home/mongodb/master/configdb/mongodbKeyfile.key
```
### 8、同步配置和key
```shell
cp -r /home/mongodb/master/configdb/  /home/mongodb/slave/configdb/
cp -r /home/mongodb/master/configdb/  /home/mongodb/arditer/configdb/
```

### 9、启动容器
```shell
#启动容器 master
docker run -di --name=mongo_master -p 27110:27017 -v /home/mongodb/master/configdb:/data/configdb,readonly -v /home/mongodb/master/db:/data/db,readonly mongo --replSet "mongo_rs" 

#启动容器 slave
docker run -di --name=mongo_slave -p 27111:27017 -v /home/mongodb/slave/configdb/:/data/configdb/ -v /home/mongodb/slave/db:/data/db,readonly mongo --replSet "mongo_rs"

#启动容器 arditer
docker run -di --name=mongo_arditer -p 27112:27017 -v /home/mongodb/arditer/configdb:/data/configdb,readonly -v /home/mongodb/arditer/db:/data/db,readonly mongo --replSet "mongo_rs" 
```

### 10、配置master
初始化节点
```shell
#进入容器
docker exec -it mongo_master mongosh admin
#配置主从(同一个服务器可以配置成相同ip,arbiterOnly:true该配置是配置成仲裁)
rs.initiate({_id:"mongo_rs",members:[{_id:0,host:"192.168.1.100:27110"},{_id:1,host:"192.168.1.101:27111"},{_id:2,host:"192.168.1.102:27112",arbiterOnly:true}]})
```
配置权限并插入测试数据
```shell
#切换至admin
use admin
#添加用户
db.createUser({user:'root',pwd:'123456',roles:[{role:'userAdminAnyDatabase',db:'admin'},{role:'dbAdminAnyDatabase',db:'admin'}]})
#登录
db.auth('root','123456')
#切换至测试库
use test
#给测试库添加账户
db.createUser({user:'test',pwd:'123456',roles:[{role:'readWrite',db:'test'}]})
#给测试库添加数据
db.userinfo.insert({"name":"张三","sex":"男"})
```
### 11、进入slave中查看是否已经同步数据
```shell
#进入备机
docker exec -it mongo_slave mongo admin
#切换至test库
use test
#登录
db.auth('test','123456')
#设置备机可读 不行就使用 rs.secondaryOk()
rs.slaveOk()
# 查询数据
db.userinfo.find()
```

参考文章地址：
1. [docker 部署mongodb集群(主、从、仲裁)](https://www.cnblogs.com/xiangnanxiao/p/15273224.html) 
2. [dockerhub-mongodb](https://hub.docker.com/_/mongo)  
