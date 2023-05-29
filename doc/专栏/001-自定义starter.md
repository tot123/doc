
目录结构
## 父pom
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.ts</groupId>
    <artifactId>all</artifactId>
    <version>0.0.1-SNAPSHOT</version>
    <packaging>pom</packaging>
    <name>all</name>
    <description>工具包包含部分starter</description>
    <properties>
        <java.version>17</java.version>
        <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
        <project.reporting.outputEncoding>UTF-8</project.reporting.outputEncoding>
        <spring-boot.version>3.0.2</spring-boot.version>
    </properties>

    <modules>
        <module>all-start</module>
        <module>all-web</module>
        <module>all-service</module>
        <module>ts-spring-boot-starter</module>
    </modules>

    <dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-devtools</artifactId>
            <scope>runtime</scope>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>com.taobao.arthas</groupId>
            <artifactId>arthas-spring-boot-starter</artifactId>
            <version>3.6.7</version>
            <scope>runtime</scope>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-configuration-processor</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.projectlombok</groupId>
            <artifactId>lombok</artifactId>
            <optional>true</optional>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
    </dependencies>
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-dependencies</artifactId>
                <version>${spring-boot.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
            <dependency>
                <groupId>com.ts</groupId>
                <artifactId>all-start</artifactId>
                <version>0.0.1-SNAPSHOT</version>
            </dependency>
            <dependency>
                <groupId>com.ts</groupId>
                <artifactId>all-web</artifactId>
                <version>0.0.1-SNAPSHOT</version>
            </dependency>
            <dependency>
                <groupId>com.ts</groupId>
                <artifactId>all-service</artifactId>
                <version>0.0.1-SNAPSHOT</version>
            </dependency>
        </dependencies>
    </dependencyManagement>

    <build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>17</source>
                    <target>17</target>
                    <encoding>UTF-8</encoding>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>${spring-boot.version}</version>
                <configuration>
                    <mainClass>com.ts.all.AllApplication</mainClass>
                    <skip>true</skip>
                </configuration>
                <executions>
                    <execution>
                        <id>repackage</id>
                        <goals>
                            <goal>repackage</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>

</project>

```
## starter代码
1. ### pom.xml 
```xml
<dependencies>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <optional>true</optional>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-configuration-processor</artifactId>
        <optional>true</optional>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-autoconfigure</artifactId>
    </dependency>
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot</artifactId>
    </dependency>
</dependencies>
```

2. ### com.ts.config.HelloProperties.java
```java
import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;

@Data
@ConfigurationProperties(prefix = "boot.ts.hello")
public class HelloProperties {
    private boolean enabled = false;
    private String name = "test";
    private Integer age = 25;
}
```

3. ### com.ts.config.HelloService.java
```java
import com.ts.config.HelloProperties;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * 默认不要放在IoC容器中
 */
public class HelloService {

    private final HelloProperties helloProperties;

    public HelloService(HelloProperties helloProperties) {
        this.helloProperties = helloProperties;
    }

    public String sayHello() {
        return "姓名: " + helloProperties.getName() + ", 年龄: " + helloProperties.getAge();
    }
}
```
4. ### com.ts.auto.HelloAutoConfiguration.java

```java
import com.ts.config.HelloProperties;
import com.ts.service.HelloService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.autoconfigure.condition.ConditionalOnMissingBean;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.boot.context.properties.EnableConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.Configuration;

/**
 * @Configuration: 声明该类为配置类
 * @ConditionalOnMissingBean: 当容器中没有HelloService这个Bean时, 这个自动配置类才生效
 * @EnableConfigurationProperties: 与相应的XxxProperties属性类进行绑定, 并放入容器中
 */
@Configuration
@EnableConfigurationProperties(HelloProperties.class)
public class HelloAutoConfiguration {
    @Autowired
    private HelloProperties helloProperties;
    @Bean
    @ConditionalOnMissingBean(HelloService.class)
    @ConditionalOnProperty(prefix = "boot.ts.hello", value = "enabled", havingValue = "true")
    public HelloService helloService() {
        return new HelloService(helloProperties);
    }
}
```
5. resource.META-INF.spring.properties

```java
org.springframework.boot.autoconfigure.EnableAutoConfiguration = \
com.ts.auto.HelloAutoConfiguration
```
## 测试starter
1. ### pom

```xml
<dependencies>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
        </dependency>
        <dependency>
            <groupId>com.ts</groupId>
            <artifactId>all-service</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter</artifactId>
        </dependency>
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
            <scope>test</scope>
        </dependency>
</dependencies>
<build>
        <plugins>
            <plugin>
                <groupId>org.apache.maven.plugins</groupId>
                <artifactId>maven-compiler-plugin</artifactId>
                <version>3.8.1</version>
                <configuration>
                    <source>17</source>
                    <target>17</target>
                    <encoding>UTF-8</encoding>
                </configuration>
            </plugin>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
                <version>3.0.2</version>
                <configuration>
                    <mainClass>com.ts.all.AllApplication</mainClass>
                    <excludes>
                        <exclude>
                            <groupId>org.projectlombok</groupId>
                            <artifactId>lombok</artifactId>
                        </exclude>
                    </excludes>
                </configuration>
                <executions>
                    <execution>
                        <id>repackage</id>
                        <goals>
                            <goal>repackage</goal>
                        </goals>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>
```
2. ### application.properties
```properties
boot.ts.hello.enabled=true
boot.ts.hello.name=??
boot.ts.hello.age=77
```

3. ### AllApplication.java
```java
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

/**
 * 第一个是starter中要扫描的路径, 第二个是当前项目的路径
 **/
@SpringBootApplication(scanBasePackages ={"com.ts", "com.ts.ctl"})
public class AllApplication {

    public static void main(String[] args) {
        SpringApplication.run(AllApplication.class, args);
    }

}
```

4. ### com.ts.all.ctl.HelloCtl.java

```java
package com.ts.all.ctl;

import com.ts.service.HelloService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@Slf4j
public class HelloCtl {
    @Autowired
    private HelloService helloService;

    @GetMapping(value = "/hello")
    public String getInfo() {
        String result = helloService.sayHello();
        log.info(result);
        return result;
    }
}

```
5. 浏览器访问

地址 : localhost:8080/hello, 查看打印值
6. 测试默认配置
修改 application.properties
```properties
boot.ts.hello.enabled=true
```
重新运行项目
访问 localhost:8080/hello, 查看打印值



参考文章
1. [Spring Boot 3.x特性-自动配置和自定义Starter](https://blog.csdn.net/renpeng301/article/details/124357138)     
2. [SpringBoot——四大核心之起步依赖（自定义starter）](https://blog.csdn.net/weixin_43823808/article/details/118094267)     
3. [自定义spring boot-starter,实现自动配置,自定义注解扫描注入](https://blog.csdn.net/wolfishness/article/details/101170774)     
4. [只看四、后续补充](https://blog.csdn.net/wolfishness/article/details/101170774)     
5. [只看五、使 Starter 支持配置参数默认值](https://blog.csdn.net/sinat_27245917/article/details/124429078)     