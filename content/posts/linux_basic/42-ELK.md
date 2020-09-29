+++
author = "zsjshao"
title = "42_ELK"
date = "2020-05-01"
tags = ["linux_basic"]
categories = ["linux_basic"]

+++


## 什么是ELK？

通俗来讲，ELK 是由Elasticsearch、Logstash、Kibana 、filebeat 三个开源软件的组成的一个组合体，这三个软件当中，每个软件用于完成不同的功能，ELK 又称为ELK stack，官方域名为elastic.co，ELK stack 的主要优点有如下几个：

处理方式灵活：elasticsearch 是实时全文索引，具有强大的搜索功能

配置相对简单：elasticsearch 全部使用JSON 接口，logstash 使用模块配置，kibana 的配置文件部分更简单。

检索性能高效：基于优秀的设计，虽然每次查询都是实时，但是也可以达到百亿级数据的查询秒级响应。

集群线性扩展：elasticsearch 和logstash 都可以灵活线性扩展

前端操作绚丽：kibana 的前端设计比较绚丽，而且操作简单

## 什么是Elasticsearch：

是一个高度可扩展的开源全文搜索和分析引擎，它可实现数据的实时全文搜索搜索、支持分布式可实现高可用、提供API 接口，可以处理大规模日志数据，比如Nginx、Tomcat、系统日志等功能。

![01_elk](http://images.zsjshao.net/elk/01_elk.png)

## 什么是Logstash

可以通过插件实现日志收集和转发，支持日志过滤，支持普通log、自定义json格式的日志解析。

![02_elk](http://images.zsjshao.net/elk/02_elk.png)


## 什么是kibana：

主要是通过接口调用elasticsearch 的数据，并进行前端数据可视化的展现。

![03_elk](http://images.zsjshao.net/elk/03_elk.png)

## 为什么使用 ELK？

ELK 组件在海量日志系统的运维中，可用于解决以下主要问题：

- 分布式日志数据统一收集，实现集中式查询和管理

- 故障排查

- 安全信息和事件管理

- 报表功能

ELK 组件在大数据运维系统中，主要可解决的问题如下：

- 日志查询，问题排查，故障恢复，故障自愈

- 应用日志分析，错误报警

- 性能分析，用户行为分析

## 使用场景：

![04_elk](http://images.zsjshao.net/elk/04_elk.png)

## 一：elasticsearch 部署：

最小化安装 Centos 7.2 x86_64 操作系统的虚拟机，vcpu 2，内存4G 或更多，操作系统盘50G，主机名设置规则为linux-hostX.exmaple.com，其中host1 和host2为elasticsearch服务器，为保证效果特额外添加一块单独的数据磁盘大小为50G 并格式化挂载到/data。

### 1、安装java环境

因为elasticsearch 服务运行需要java 环境，因此两台elasticsearch 服务器需要安装java 环境，可以使用以下方式安装：

方式一：直接使用yum 安装openjdk

```
[root@linux-host1 ~]# yum install java-1.8.0*
```

方式二：本地安装在oracle 官网下载rpm 安装包：

```
[root@linux-host1 ~]# yum localinstall jdk-8u251-linux-x64.rpm
```

方式三：下载二进制包自定义profile 环境变量：

下载地址： http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html

```
[root@c71 ~]# tar xf jdk-8u251-linux-x64.tar.gz -C /usr/local/
[root@c71 ~]# ln -sv /usr/local/jdk1.8.0_251/ /usr/local/jdk
‘/usr/local/jdk’ -> ‘/usr/local/jdk1.8.0_251/’
[root@c71 ~]# ln -sv /usr/local/jdk/bin/java /usr/bin/
‘/usr/bin/java’ -> ‘/usr/local/jdk/bin/java’

[root@c71 ~]# vim /etc/profile.d/java.sh
export JAVA_HOME=/usr/local/jdk
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin

[root@c71 ~]# source /etc/profile.d/java.sh
[root@c71 ~]# java -version
java version "1.8.0_251"
Java(TM) SE Runtime Environment (build 1.8.0_251-b08)
Java HotSpot(TM) 64-Bit Server VM (build 25.251-b08, mixed mode)
```

### 2、官网下载elasticsearch 并安装：

下载地址：https://www.elastic.co/downloads/elasticsearch，当前最新版本7.8.0

```
[root@c71 ~]# wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.8.0-x86_64.rpm
--2020-07-09 01:11:29--  https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-7.8.0-x86_64.rpm
Resolving artifacts.elastic.co (artifacts.elastic.co)... 151.101.230.222, 2a04:4e42:1a::734
Connecting to artifacts.elastic.co (artifacts.elastic.co)|151.101.230.222|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 319213800 (304M) [application/octet-stream]
Saving to: ‘elasticsearch-7.8.0-x86_64.rpm’

100%[=================================================================>] 319,213,800 11.3MB/s   in 40s    

2020-07-09 01:12:10 (7.61 MB/s) - ‘elasticsearch-7.8.0-x86_64.rpm’ saved [319213800/319213800]
```

#### 2.1：两台服务器分别安装elasticsearch:

```
[root@c71 ~]# yum install elasticsearch-7.8.0-x86_64.rpm 
Loaded plugins: fastestmirror
Examining elasticsearch-7.8.0-x86_64.rpm: elasticsearch-7.8.0-1.x86_64
Marking elasticsearch-7.8.0-x86_64.rpm to be installed
Resolving Dependencies
--> Running transaction check
---> Package elasticsearch.x86_64 0:7.8.0-1 will be installed
--> Finished Dependency Resolution

Dependencies Resolved

===========================================================================================================
 Package                 Arch             Version              Repository                             Size
===========================================================================================================
Installing:
 elasticsearch           x86_64           7.8.0-1              /elasticsearch-7.8.0-x86_64           508 M

Transaction Summary
===========================================================================================================
Install  1 Package

Total size: 508 M
Installed size: 508 M
Is this ok [y/d/N]: y
```

#### 2.2：编辑各elasticsearch 服务器的服务配置文件：

```
[root@c71 ~]# grep "^[a-Z]" /etc/elasticsearch/elasticsearch.yml
cluster.name: es-cluster1           #集群名称，同名称为同一集群
node.name: node1                    #集群内的节点名称
path.data: /data/esdata             #数据存储目录
path.logs: /data/eslog              #日志存储目录
bootstrap.memory_lock: true         #锁定内存
network.host: 0.0.0.0               #监听地址
http.port: 9200                     #监听端口
discovery.seed_hosts: ["192.168.9.71", "192.168.9.72"]    #集群成员
cluster.initial_master_nodes: ["192.168.9.71"]            #master节点
```

#### 2.3：修改内存限制，并同步配置文件：

内存锁定的配置参数：
https://discuss.elastic.co/t/memory-lock-not-working/70576

```
[root@c71 ~]# vim /usr/lib/systemd/system/elasticsearch.service
LimitMEMLOCK=infinity    #无限制使用内存

[root@c71 ~]# vim /etc/elasticsearch/jvm.options
-Xms2g
-Xmx2g
```

最小和最大内存限制，为什么最小和最大设置一样大？

https://www.elastic.co/guide/en/elasticsearch/reference/current/heap-size.html

官方配置文档最大建议30G 以内。



拷贝配置文件至另一个节点

```
[root@c71 ~]# scp /etc/elasticsearch/elasticsearch.yml 192.168.9.72:/etc/elasticsearch/elasticsearch.yml
[root@c71 ~]# scp /etc/elasticsearch/jvm.options 192.168.9.72:/etc/elasticsearch/jvm.options
[root@c71 ~]# scp /usr/lib/systemd/system/elasticsearch.service 192.168.9.72:/usr/lib/systemd/system/elasticsearch.service
```

修改节点名称

```
[root@c72 ~]# grep "^[a-Z]" /etc/elasticsearch/elasticsearch.yml
cluster.name: es-cluster1
node.name: node2            #节点名称
path.data: /data/esdata
path.logs: /data/eslog
bootstrap.memory_lock: true
network.host: 0.0.0.0
http.port: 9200
discovery.seed_hosts: ["192.168.9.71", "192.168.9.72"]
cluster.initial_master_nodes: ["192.168.9.71"]
```

#### 2.4：目录权限更改：

各服务器创建数据和日志目录并修改目录权限为elasticsearch：

```
[root@c71 ~]# mkdir /data
[root@c71 ~]# chown elasticsearch.elasticsearch /data/ -R
```

#### 2.5：启动elasticsearch 服务并验证：

```
[root@c71 ~]# systemctl daemon-reload
[root@c71 ~]# systemctl start elasticsearch
[root@c71 ~]# systemctl enable elasticsearch
[root@c71 ~]# tail -f /data/eslog/es-cluster1.log
```

#### 2.6：验证端口监听成功：

9200为用户访问端口，9300为集群通信端口

```
[root@c71 ~]# ss -tnl
State       Recv-Q Send-Q        Local Address:Port                       Peer Address:Port              
LISTEN      0      128                       *:22                                    *:*                  
LISTEN      0      100               127.0.0.1:25                                    *:*                  
LISTEN      0      128                    [::]:9200                               [::]:*                  
LISTEN      0      128                    [::]:9300                               [::]:*                  
LISTEN      0      128                    [::]:22                                 [::]:*                  
LISTEN      0      100                   [::1]:25                                 [::]:*                  
[root@c71 ~]#
```

#### 2.7：使用curl命令访问elasticsearch 服务端口：

```
[root@c71 ~]# curl 192.168.9.71:9200
{
  "name" : "node1",
  "cluster_name" : "es-cluster1",
  "cluster_uuid" : "7GzNfrp6Q8SaU8B1m1zTFg",
  "version" : {
    "number" : "7.8.0",
    "build_flavor" : "default",
    "build_type" : "rpm",
    "build_hash" : "757314695644ea9a1dc2fecd26d1a43856725e65",
    "build_date" : "2020-06-14T19:35:50.234439Z",
    "build_snapshot" : false,
    "lucene_version" : "8.5.1",
    "minimum_wire_compatibility_version" : "6.8.0",
    "minimum_index_compatibility_version" : "6.0.0-beta1"
  },
  "tagline" : "You Know, for Search"
}
```

#### 2.8：Master 与Slave 的区别：

Master 的职责：统计各node 节点状态信息、集群状态信息统计、索引的创建和删除、索引分配的管理、关闭node 节点等
Slave 的职责：从master 同步数据、等待机会成为Master

## 二：部署logstash：

### 1、logstash 环境准备及安装：

Logstash 是一个开源的数据收集引擎，可以水平伸缩，而且logstash 整个ELK当中拥有最多插件的一个组件，其可以接收来自不同来源的数据并统一输出到指定的且可以是多个不同目的地。

#### 1.1、环境准备：

关闭防火墙和selinux，并且安装java 环境

```
[root@c73 ~]# tar xf jdk-8u251-linux-x64.tar.gz -C /usr/local/
[root@c73 ~]# ln -sv /usr/local/jdk1.8.0_251/ /usr/local/jdk
‘/usr/local/jdk’ -> ‘/usr/local/jdk1.8.0_251/’
[root@c73 ~]# ln -sv /usr/local/jdk/bin/java /usr/bin/
‘/usr/bin/java’ -> ‘/usr/local/jdk/bin/java’
[root@c73 ~]# vim /etc/profile.d/java.sh
[root@c73 ~]# source /etc/profile.d/java.sh
[root@c73 ~]# java -version
java version "1.8.0_251"
Java(TM) SE Runtime Environment (build 1.8.0_251-b08)
Java HotSpot(TM) 64-Bit Server VM (build 25.251-b08, mixed mode)
```

#### 1.2、安装logstash：

```
[root@c73 ~]# wget https://artifacts.elastic.co/downloads/logstash/logstash-7.8.0.rpm
[root@c73 ~]# yum install logstash-7.8.0.rpm -y
```

### 2、测试logstash：

#### 2.1、测试标准输入和输出：

```
[root@c73 ~]# /usr/share/logstash/bin/logstash -e 'input { stdin{} } output { stdout{ codec => rubydebug }}'
hello
{
      "@version" => "1",                          #事件版本号，一个事件就是一个ruby 对象
          "host" => "c73.zsjshao.net",            #标记事件发生在哪里
    "@timestamp" => 2020-07-08T18:28:35.282Z,     #当前事件的发生时间
       "message" => "hello"                       #消息的具体内容
}
```

#### 2.2、测试输出到文件：

```
[root@c73 ~]# /usr/share/logstash/bin/logstash -e 'input { stdin{} } output { file { path => "/tmp/log-%{+YYYY.MM.dd}messages.gz"}}'
hello
[INFO ] 2020-07-09 02:34:01.827 [[main]>worker0] file - Opening file {:path=>"/tmp/log-2020.07.08messages.gz"}
[root@c73 ~]# tail /tmp/log-2020.07.08messages.gz 
{"@timestamp":"2020-07-08T18:34:01.566Z","message":"hello","host":"c73.zsjshao.net","@version":"1"}
```

#### 2.3、测试输出到elasticsearch：

```
[root@c73 ~]# /usr/share/logstash/bin/logstash -e 'input { stdin{} } output { elasticsearch {hosts => ["192.168.9.71:9200"] index => "mytest-%{+YYYY.MM.dd}" }}'
hello
```

#### 2.4、elasticsearch 服务器验证收到数据：

```
[root@c71 ~]# ll /data/esdata/nodes/0/indices/
total 0
drwxr-xr-x 4 elasticsearch elasticsearch 29 Jul  9 02:03 csZfce4DTiOsreu4YHPtpQ
drwxr-xr-x 4 elasticsearch elasticsearch 29 Jul  9 02:03 Fqn50KQER_GUzyKNoyNaaQ
drwxr-xr-x 4 elasticsearch elasticsearch 29 Jul  9 02:03 ImGNK3GDTr-Gw3JKPm7-pA
drwxr-xr-x 4 elasticsearch elasticsearch 29 Jul  9 02:03 R0tlVyDfR_OJb2a3LViKyA
drwxr-xr-x 4 elasticsearch elasticsearch 29 Jul  9 02:03 ryrsyNDlQ3qesYHRPtJ_QA
drwxr-xr-x 4 elasticsearch elasticsearch 29 Jul  9 02:38 uzGRzgslR1yRxmgHPMRnFQ
drwxr-xr-x 4 elasticsearch elasticsearch 29 Jul  9 02:03 xjp-3UfjQWirul4rIDOxYA
drwxr-xr-x 4 elasticsearch elasticsearch 29 Jul  9 02:07 Yo42vOXZQNGr-d9xszAtVw
```

## 三：kibana 部署及日志收集：

Kibana 是一个通过调用elasticsearch 服务器进行图形化展示搜索结果的开源项目。

### 1、安装并配置kibana：

可以通过rpm 包或者二进制的方式进行安装

```
[root@c71 ~]# wget https://artifacts.elastic.co/downloads/kibana/kibana-7.8.0-x86_64.rpm
[root@c71 ~]# yum install kibana-7.8.0-x86_64.rpm -y
[root@c71 ~]# grep -n "^[a-Z]" /etc/kibana/kibana.yml
2:server.port: 5601
7:server.host: "0.0.0.0"
28:elasticsearch.hosts: ["http://192.168.9.71:9200"]
115:i18n.locale: "zh-CN"
```

### 2、启动kibana 服务并验证：

```
[root@c71 ~]# systemctl start kibana
[root@c71 ~]# systemctl enable kibana
```

### 3、查看状态：

http://192.168.9.71:5601/status

![05_elk](http://images.zsjshao.net/elk/05_elk.png)

### 4：添加上一步写入的索引：

![06_elk](http://images.zsjshao.net/elk/06_elk.png)

![image-20200709025934105](C:\Users\zengs\AppData\Roaming\Typora\typora-user-images\image-20200709025934105.png)

![image-20200709030004633](C:\Users\zengs\AppData\Roaming\Typora\typora-user-images\image-20200709030004633.png)

![image-20200709030020882](C:\Users\zengs\AppData\Roaming\Typora\typora-user-images\image-20200709030020882.png)

## 四：通过logstash的插件收集日志：

https://www.elastic.co/guide/en/logstash/current/input-plugins.html

https://www.elastic.co/guide/en/logstash/current/output-plugins.html

### 1.file插件

前提需要 logstash用户对被收集的日志文件有读的权限并对写入的文件有写权限。

```
input {
  file {
    path => "/var/log/messages"     #文件路径
    start_position => "beginning"   #文件读取位置，默认为end
    stat_interval => 3              #扫描间隔，默认1s
    type => "messages-log"          #定义类型
    codec => "json"                 #文件输入格式，默认为plain
  }
}
```

#### 1.1、收集nginx访问日志

##### 1.1.1、配置nginx服务

```
[root@c73 ~]# yum install nginx -y
[root@c73 ~]# echo 'Nginx WebPage!' > /usr/share/nginx/html/index.html
[root@c73 ~]# vim /etc/nginx/nginx.conf
    log_format access_json '{"@timestamp":"$time_iso8601",'
                           '"host":"$server_addr",'
                           '"clientip":"$remote_addr",'
                           '"size":$body_bytes_sent,'
                           '"responsetime":$request_time,'
                           '"upstreamtime":"$upstream_response_time",'
                           '"upstreamhost":"$upstream_addr",'
                           '"http_host":"$host",'
                           '"uri":"$uri",'
                           '"domain":"$host",'
                           '"xff":"$http_x_forwarded_for",'
                           '"referer":"$http_referer",'
                           '"tcp_xff":"$proxy_protocol_addr",'
                           '"http_user_agent":"$http_user_agent",'
                           '"status":"$status"}';
    access_log  /var/log/nginx/access.log  access_json;

[root@c73 ~]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
[root@c73 ~]# chmod 775 /var/log/nginx/
[root@c73 ~]# systemctl start nginx
[root@c73 ~]# systemctl enable nginx
[root@c73 ~]# curl 192.168.9.73
Nginx WebPage!
```

##### 1.1.2、配置logstash收集nginx访问日志

```
[root@c73 ~]# cat /etc/logstash/conf.d/nginx.conf
input {
  file {
    path => "/var/log/nginx/access.log"
    start_position => "beginning"
    stat_interval => 3
    type => "nginx-accesslog"
    codec => "json"
  }
}
output {
  if [type] == "nginx-accesslog" {
    elasticsearch {
      hosts => ["192.168.9.71:9200"]
      index => "nginx-accesslog-%{+YYYY.MM.dd}"
    }
  }
}
```

#### 1.2、收集tomcat访问日志

##### 1.2.1、部署tomcat服务

```
[root@c76 ~]# tar xf jdk-8u251-linux-x64.tar.gz -C /usr/local/
[root@c76 ~]# ln -sv /usr/local/jdk1.8.0_251/ /usr/local/jdk
‘/usr/local/jdk’ -> ‘/usr/local/jdk1.8.0_251/’
[root@c76 ~]# ln -sv /usr/local/jdk/bin/java /usr/bin/
‘/usr/bin/java’ -> ‘/usr/local/jdk/bin/java’

[root@c76 ~]# vim /etc/profile.d/java.sh
export JAVA_HOME=/usr/local/jdk
export CLASSPATH=.:$JAVA_HOME/jre/lib/rt.jar:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar
export PATH=$PATH:$JAVA_HOME/bin

[root@c76 ~]# source /etc/profile.d/java.sh
[root@c76 ~]# java -version
java version "1.8.0_251"
Java(TM) SE Runtime Environment (build 1.8.0_251-b08)
Java HotSpot(TM) 64-Bit Server VM (build 25.251-b08, mixed mode)

[root@c76 ~]# mkdir /apps
[root@c76 ~]# tar xf apache-tomcat-8.5.57.tar.gz -C /apps/
[root@c76 ~]# cd /apps/
[root@c76 apps]# ln -sv apache-tomcat-8.5.57/ tomcat
‘tomcat’ -> ‘apache-tomcat-8.5.57/’
[root@c76 apps]# cd tomcat/
[root@c76 tomcat]# ./bin/catalina.sh start
Using CATALINA_BASE:   /apps/tomcat
Using CATALINA_HOME:   /apps/tomcat
Using CATALINA_TMPDIR: /apps/tomcat/temp
Using JRE_HOME:        /usr/local/jdk
Using CLASSPATH:       /apps/tomcat/bin/bootstrap.jar:/apps/tomcat/bin/tomcat-juli.jar
Tomcat started.
[root@c76 tomcat]# vim conf/server.xml
        <Valve className="org.apache.catalina.valves.AccessLogValve" directory="logs"
               prefix="tomcat_access_log" suffix=".log"
               pattern="{&quot;clientip&quot;:&quot;%h&quot;,&quot;ClientUser&quot;:&quot;%l&quot;,&quot;authenticated&quot;:&quot;%u&quot;,&quot;AccessTime&quot;:&quot;%t&quot;,&quot;method&quot;:&quot;%r&quot;,&quot;status&quot;:&quot;%s&quot;,&quot;SendBytes&quot;:&quot;%b&quot;,&quot;Query?string&quot;:&quot;%q&quot;,&quot;partner&quot;:&quot;%{Referer}i&quot;,&quot;AgentVersion&quot;:&quot;%{User-Agent}i&quot;}" />

[root@c76 tomcat]# ./bin/catalina.sh stop
[root@c76 tomcat]# rm -rf logs/*
[root@c76 tomcat]# ./bin/catalina.sh start
[root@c76 tomcat]# tail -1 logs/tomcat_access_log.2020-07-10.log 
{"clientip":"192.168.9.1","ClientUser":"-","authenticated":"-","AccessTime":"[10/Jul/2020:02:20:49 +0800]","method":"GET / HTTP/1.1","status":"200","SendBytes":"11215","Query?string":"","partner":"-","AgentVersion":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.4103.116 Safari/537.36"}
```

##### 1.2.2、验证日志是否为json格式

http://www.bejson.com/

![18_elk](http://images.zsjshao.net/elk/18_elk.png)

##### 1.2.3、安装配置logstash

```
[root@c76 ~]# wget https://artifacts.elastic.co/downloads/logstash/logstash-7.8.0.rpm
[root@c76 ~]# yum install logstash-7.8.0.rpm -y
[root@c76 ~]# cat /etc/logstash/conf.d/nginx.conf
input {
  file {
    path => "/apps/tomcat/logs/tomcat_access_log.*.log"
    start_position => "beginning"
    stat_interval => 3
    type => "tomcat-accesslog"
    codec => "json"
  }
}
output {
  if [type] == "tomcat-accesslog" {
    elasticsearch {
      hosts => ["192.168.9.71:9200"]
      index => "tomcat-accesslog-%{+YYYY.MM.dd}"
    }
  }
}
```

### 2、TCP插件

通过logstash的tcp/udp插件收集日志，通常用于在向elasticsearch日志补录丢失的部分日志，可以将丢失的日志写到一个文件，然后通过TCP日志收集方式直接发送给logstash然后再写入到elasticsearch服务器。

#### 2.1、logstash配置文件

```
[root@c73 ~]# vim /etc/logstash/conf.d/tcp.conf
input {
  tcp {
    port => 8899
    type => "tcplog"
    mode => "server"
  }
}

output {
  if [type] == "tcplog" {
    elasticsearch {
      hosts => ["192.168.9.71:9200"]
      index => "tcp-log-%{+YYYY.MM.dd}"
    }
  }
}

[root@c73 ~]# systemctl restart logstash
[root@c73 ~]# ss -tnl
State       Recv-Q Send-Q        Local Address:Port                       Peer Address:Port              
LISTEN      0      128                       *:80                                    *:*                  
LISTEN      0      128                       *:22                                    *:*                  
LISTEN      0      100               127.0.0.1:25                                    *:*                  
LISTEN      0      128                    [::]:80                                 [::]:*                  
LISTEN      0      128                    [::]:22                                 [::]:*                  
LISTEN      0      100                   [::1]:25                                 [::]:*                  
LISTEN      0      50       [::ffff:127.0.0.1]:9600                               [::]:*                  
LISTEN      0      128                    [::]:8899                               [::]:* 
```

#### 2.2、在其他服务器安装nc命令

NetCat简称nc，在网络工具中有“瑞士军刀”美誉，其功能实用，是一个简单、可靠的网络工具，可通过TCP或UDP协议传输读写数据，另外还具有很多其他功能。

```
[root@c76 ~]# yum install nc -y
[root@c76 ~]# cat /etc/fstab | nc 192.168.9.73 8899
```

#### 2.3：通过伪设备的方式发送消息：

在类Unix操作系统中，块设备有硬盘、内存的硬件，但是还有设备节点并不一定要对应物理设备，我们把没有这种对应关系的设备称为伪设备，比如/dev/null，/dev/zero，/dev/random以及/dev/tcp和/dev/udp等，Linux操作系统使用这些伪设备提供了多种不同的功能，tcp通信只是dev下面众多伪设备当中的一种设备。

```
[root@c76 ~]# echo "伪设备1" > /dev/tcp/192.168.9.73/8899
```

### 3、elasticsearch插件

```
output {
  if [type] == "messages-log" {
    elasticsearch {
      hosts => ["192.168.9.71:9200"]
      index => "message-log-%{+YYYY.MM.dd}"
    }
  }
}
```

































