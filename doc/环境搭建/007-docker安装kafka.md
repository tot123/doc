docker pull zookeeper:3.6


mkdir D:\docker\zookeeper\localtime
docker run -d --name zookeeper -p 2181:2181 -v /D/docker/zookeeper/localtime:/etc/localtime zookeeper:3.6