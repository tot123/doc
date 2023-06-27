
FROM hub.docker.com/r/alpinelinux/docker-compose

git clone https://github.com/nacos-group/nacos-docker.git
cd nacos-docker
docker-compose -f example/standalone-derby.yaml up
