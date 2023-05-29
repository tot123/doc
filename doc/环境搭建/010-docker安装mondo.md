
```shell
docker pull mongo

docker network create mongo-cluster
docker network ls 
```
```shell
#创建配置文件地址
mkdir /home/mongodb/master/configdb
#创建db存放地址
mkdir /home/mongodb/master/db

#创建配置文件路径
mkdir /home/mongodb/slave/configdb
#创建db存放路径
mkdir /home/mongodb/slave/db
```
