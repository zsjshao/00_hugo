+++
author = "zsjshao"
title = "41_jenkins"
date = "2020-05-01"
tags = ["linux_basic"]
categories = ["linux_basic"]

+++

Jenkins部署与基础配置：

https://jenkins.io/zh/

配置 java环境 并部署 jenkins：

```
[root@c81 ~]# tar xf jdk-8u241-linux-x64.tar.gz -C /usr/local/
[root@c81 ~]# ln -sv /usr/local/jdk1.8.0_241 /usr/local/jdk
```

配置java环境变量

```
[root@c81 ~]# cat /etc/profile.d/java.sh 
export JAVA_HOME=/usr/local/jdk
export PATH=$JAVA_HOME/bin:$JAVA_HOME/jre/bin:$PATH
export CLASSPATH=.$CLASSPATH:$JAVA_HOME/lib:$JAVA_HOME/jre/lib:$JAVA_HOME/lib/tools.jar

[root@c81 ~]# source /etc/profile.d/java.sh
[root@c81 ~]# java -version
java version "1.8.0_241"
Java(TM) SE Runtime Environment (build 1.8.0_241-b07)
Java HotSpot(TM) 64-Bit Server VM (build 25.241-b07, mixed mode)
```

rpm包安装jenkins配置：

```
[root@c81 ~]# dnf install jenkins-2.204.6-1.1.noarch.rpm

JENKINS_JAVA_OPTIONS="-server -Xms1g -Xmx1g -Xss512k -Xmn1g \
-XX:CMSInitiatingOccupancyFraction=65 \
-XX:+UseFastAccessorMethods \
-XX:+AggressiveOpts -XX:+UseBiasedLocking \
-XX:+DisableExplicitGC -XX:MaxTenuringThreshold=10 \
-XX:NewSize=2048M -XX:MaxNewSize=2048M -XX:NewRatio=2 \
-XX:PermSize=128m -XX:MaxPermSize=512m -XX:CMSFullGCsBeforeCompaction=5 \
-XX:+ExplicitGCInvokesConcurrent -XX:+UseConcMarkSweepGC -XX:+UseParNewGC \
-XX:+CMSParallelRemarkEnabled -Djava.awt.headless=true \ 
-Dcom.sun.management.jmxremote  \
-Dcom.sun.management.jmxremote.port=12345 \
-Dcom.sun.management.jmxremote.authenticate=false \
-Dcom.sun.management.jmxremote.ssl=false \
-Djava.rmi.server.hostname="192.168.3.181""
```

启动jenkins

```
[root@c81 jenkins]# ln -sv /usr/local/jdk/bin/java /usr/bin/java
[root@c81 jenkins]# systemctl start jenkins
```

访问jenkins页面



选择安装jenkins插件

插件安装过程中。如果插件安装失败可以在后期再单独安装



创建jenkins管理员



配置jenkins URL：



配置完成并登陆jenkins



登陆jenkins界面



http://mirrors.jenkins-ci.org/status.html















