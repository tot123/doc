# 基于一个包含 JDK 17 的基础镜像构建应用程序镜像
FROM openjdk:17-alpine

WORKDIR /home/work
USER root

# 将编译好的 JAR 文件复制到容器中
COPY target/*.jar /home/work

# 指定容器启动时执行的命令
CMD ["java", "-jar", "/app/your-application.jar"]
