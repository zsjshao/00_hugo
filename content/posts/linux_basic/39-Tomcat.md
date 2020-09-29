+++
author = "zsjshao"
title = "39_tomcat"
date = "2020-05-01"
tags = ["linux_basic"]
categories = ["linux_basic"]

+++

## 1、历史

起始于SUN的一个Servlet的参考实现项目Java Web Server，作者是James Duncan Davidson，后将项目贡献给了ASF。和ASF现有的项目合并，并开源成为顶级项目，官网http://tomcat.apache.org/。

Tomcat仅仅实现了Java EE规范的与Servlet、JSP相关的类库，是JavaEE不完整实现。

著名图书出版商O'Reilly约稿该项目成员，Davidson希望使用一个公猫作为封面，但是公猫已经被另一本书使用，书出版后封面是一只雪豹。

![tomcat_01](http://images.zsjshao.net/java/tomcat/tomcat_01.png)

1999年发布初始版本是Tomcat 3.0，实现了Servlet 2.2和JSP1.1规范。

Tomcat 4.x发布时，内建了Catalina（Servlet容器）和Jasper（JSP engine）等。

商用的有IBM WebSphere、Oracle WebLogic（原属于BEA公司）、Oracle Oc4j、Glassfish、JBoss等。

开源实现有Tomcat、Jetty、Resin。

## 2、安装

可以使用Centos7 yum源自带的安装。yum源中是Tomcat 7.0版本。安装完通过浏览器可以观察一下首页。

```
# yum install tomcat tomcat-admin-webapps tomcat-webapps
# systemctl start tomcat.service
# ss -tanl
LISTEN 0 100 :::8009
LISTEN 0 100 :::8080
```

采用Apache官网下载，下载8.x.x

```
# tar xf apache-tomcat-8.5.53.tar.gz -C /usr/local/
# cd /usr/local
# ln -sv apache-tomcat-8.5.53/ tomcat
"tomcat" -> "apache-tomcat-8.5.42/"

# cd tomcat
# cd bin
# ./catalina.sh --help
# ./catalina.sh version
# ./catalina.sh start
# ss -tanlp
# ./catalina.sh stop

# ./startup.sh
# ./shutdown.sh
```

useradd -r java 建立系统账号

上例中，启动身份是root，如果使用普通用户启动可以使用

```
# useradd -r java
# chown java.java /usr/local/tomcat/ -R
# su - java -c '/usr/local/tomcat/bin/catalina.sh start'
# ps -aux | grep tomcat
```

![tomcat_02](http://images.zsjshao.net/java/tomcat/tomcat_02.png)

## 3、目录结构

|目录|说明|
|---|---|
|bin |服务启动、停止等相关|
|conf |配置文件|
|lib |库目录|
|logs |日志目录|
|webapps| 应用程序，应用部署目录|
|work |jsp编译后的结果文件|

## 4、配置文件

|文件名|说明|
|---|---|
|**server.xml**| 主配置文件|
|**web.xml**|每个webapp只有“部署”后才能被访问，它的部署方式通常由web.xml进行定义，其存放位置为WEB-INF/目录中；此文件为所有的webapps提供默认部署相关的配置|
|**context.xml**|每个webapp都可以专用的配置文件，它通常由专用的配置文件context.xml来定义，其存放位置为WEB-INF/目录中；此文件为所有的webapps提供默认配置|
|tomcat-users.xml |用户认证的账号和密码文件|
|catalina.policy |当使用-security选项启动tomcat时，用于为tomcat设置安全策略|
|catalina.properties |Java属性的定义文件，用于设定类加载器路径，以及一些与JVM调优相关参数|
|logging.properties| 日志系统相关的配置。log4j|

## 5、组件分类

顶级组件
Server，代表整个Tomcat容器

服务类组件
Service，组织Engine和Connector，里面只能包含一个Engine

连接器组件
Connector，有HTTP、HTTPS、A JP协议的连接器

容器类
Engine、Host、Context都是容器类组件，可以嵌入其它组件，内部配置如何运行应用程序。

内嵌类
可以内嵌到其他组件内，valve、logger、realm、loader、manager等。以logger举例，在不同容器组件内定义。

集群类组件
listener、cluster

## 6、Tomcat内部组成

由上述组件就构成了Tomcat，如下图

![tomcat_03](http://images.zsjshao.net/java/tomcat/tomcat_03.png)

|名称|说明|
|---|---|
|Server| Tomcat运行的进程实例|
|Connector |负责客户端的HTTP、HTTPS、A JP等协议的连接。一个Connector只属于某一个Engine|
|Service| 用来组织Engine和Connector的关系|
|Engine| 响应并处理用户请求。一个引擎上可以绑定多个Connector|
|Host |虚拟主机|
|Context| 应用的上下文，配置路径映射path => directory|

AJP（Apache Jserv protocol）是一种基于TCP的二进制通讯协议。

```
核心组件
  Tomcat启动一个Server进程。可以启动多个Server，但一般只启动一个
  创建一个Service提供服务。可以创建多个Service，但一般也只创建一个
    每个Service中，是Engine和其连接器Connector的关联配置
  可以为这个Server提供多个连接器Connector，这些Connector使用了不同的协议，绑定了不同的端口。其作用就是处理来自客户端的不同的连接请求或响应
  Service内部还定义了Engine，引擎才是真正的处理请求的入口，其内部定义多个虚拟主机Host
    Engine对请求头做了分析，将请求发送给相应的虚拟主机
    如果没有匹配，数据就发往Engine上的defaultHost缺省虚拟主机
    Engine上的缺省虚拟主机可以修改
  Host定义虚拟主机，虚拟主机有name名称，通过名称匹配
  Context定义应用程序单独的路径映射和配置
```

```
<?xml version="1.0" encoding="UTF-8"?>
<Server port="8005" shutdown="SHUTDOWN">
  <Service name="Catalina">
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
    <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
    
    <Engine name="Catalina" defaultHost="localhost">
      <Host name="localhost" appBase="webapps"
            unpackWARs="true" autoDeploy="true">
      </Host>
    </Engine>
  </Service>
</Server>
```

举例：
假设来自客户的请求为：http://localhost:8080/test/index.jsp

```
浏览器端的请求被发送到服务端端口8080，Tomcat进程监听在此端口上。通过侦听的HTTP/1.1 Connector获得此请求。
Connector把该请求交给它所在的Service的Engine来处理，并等待Engine的响应
Engine获得请求localhost:8080/test/index.jsp，匹配它所有虚拟主机Host。
Engine匹配到名为localhost的Host。即使匹配不到也把请求交给该Host处理，因为该Host被定义为该Engine的默认主机
localhost Host获得请求/test/index.jsp，匹配它所拥有的所有Context
Host匹配到路径为/test的Context
path=/test的Context获得请求/index.jsp，在它的mapping table中寻找对应的servlet
Context匹配到URL PATTERN为*.jsp 的servlet，对应于JspServlet类构造HttpServletRequest对象和HttpServletResponse对象，作为参数调用JspServlet的doGet或doPost方法。
Context把执行完了之后的HttpServletResponse对象返回给Host
Host把HttpServletResponse对象返回给Engine
Engine把HttpServletResponse对象返回给Connector
Connector把HttpServletResponse对象返回给浏览器端
```

## 7、应用部署

### 7.1、根目录

Tomcat中默认网站根目录是CATALINA_BASE/webapps/

在Tomcat中部署主站应用程序和其他应用程序，和之前WEB服务程序不同。

#### 7.1.1、nginx

假设在nginx中部署2个网站应用eshop、bbs，假设网站根目录是/var/www/html，那么部署可以是这样的。

eshop解压缩所有文件放到/var/www/html/目录下。

bbs的文件放在/var/www/html/bbs下。

#### 7.1.2、Tomcat

Tomcat中默认网站根目录是CATALINA_BASE/webapps/

在Tomcat的webapps目录中，有个非常特殊的目录ROOT，它就是网站默认根目录。

将eshop解压后的文件放到这个ROOT中。

bbs解压后文件都放在CATALINA_BASE/webapps/bbs目录下。

每一个虚拟主机的目录都可以使用appBase配置自己的站点目录，里面都可以使用ROOT目录作为主站目录。

### 7.2、JSP WebApp目录结构

```
WEB-INF/：当前WebApp的私有资源路径，通常存储当前应用使用的web.xml和context.xml配置文件
META-INF/：类似于WEB-INF
classes/：类文件，当前webapp需要的类
lib/：当前应用依赖的jar包
```

主页配置：一般指定为index.jsp或index.html

```
<web-app xmlns="http://xmlns.jcp.org/xml/ns/javaee"
...
  <welcome-file-list>
    <welcome-file>index.jsp</welcome-file>
    <welcome-file>index.htm</welcome-file>
    <welcome-file>index.html</welcome-file>
  </welcome-file-list>
</web-app>
```

### 7.3、webapp归档格式

```
.war：WebApp打包
.jar：EJB类打包文件
.rar：资源适配器类打包文件
.ear：企业级WebApp打包

传统，应用开发测试后，通常打包为war格式，这种文件部署到了Tomcat的webapps下，还可以自动展开。
<Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
```

### 7.4、部署Deploy

```
部署：将webapp的源文件放置到目标目录，通过web.xml和context.xml文件中配置的路径就可以访问该webapp，通过类加载器加载其特有的类和依赖的类到JVM上。
  自动部署Auto Deploy：Tomcat发现多了这个应用就把它加载并启动起来
  手动部署
    冷部署：将webapp放到指定目录，才去启动Tomcat
    热部署：Tomcat服务不停止，需要依赖工具manager、ant脚本、tcd（tomcat client deployer）等
反部署undeploy：停止webapp的运行，并从JVM上清除已经加载的类，从Tomcat实例上卸载掉webapp
启动start：是webapp能够访问
停止stop：webapp不能访问，不能提供服务，但是JVM并不清除它
```

### 7.5、配置详解

```
<?xml version="1.0" encoding="UTF-8"?>
<Server port="8005" shutdown="SHUTDOWN">
  <Service name="Catalina">
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
    <Connector port="8009" protocol="AJP/1.3" redirectPort="8443" />
    
    <Engine name="Catalina" defaultHost="localhost">
      <Host name="localhost" appBase="webapps"
            unpackWARs="true" autoDeploy="true">
      </Host>
    </Engine>
  </Service>
</Server>
```

#### 7.5.1、管理端口

8005是Tomcat的管理端口，默认监听在127.0.0.1上。SHUTDOWN这个字符串接收到后就会关闭此Server。

```
<Server port="8005" shutdown="SHUTDOWN">

# telnet 127.0.0.1 8005
Trying 127.0.0.1...
Connected to 127.0.0.1.
Escape character is '^]'.
SHUTDOWN
```

这个管理功能建议禁用，改shutdown为一串猜不出的字符串。

#### 7.5.2、用户认证

用户认证，配置文件是conf/tomcat-users.xml。

```
<GlobalNamingResources>
  <!-- Editable user database that can also be used by
       UserDatabaseRealm to authenticate users
  -->
  <Resource name="UserDatabase" auth="Container"
            type="org.apache.catalina.UserDatabase"
            description="User database that can be updated and saved"
            factory="org.apache.catalina.users.MemoryUserDatabaseFactory"
            pathname="conf/tomcat-users.xml" />
</GlobalNamingResources>
```

打开tomcat-users.xml，我们需要一个角色manager-gui。

```
<tomcat-users xmlns="http://tomcat.apache.org/xml"
              xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
              xsi:schemaLocation="http://tomcat.apache.org/xml tomcat-users.xsd"
              version="1.0">
  <role rolename="manager-gui"/>
  <user username="wayne" password="wayne" roles="manager-gui"/>
</tomcat-users>
```

Tomcat启动加载后，这些内容是常驻内存的。如果配置了新的用户，需要重启Tomcat。

文件路径/usr/local/tomcat/webapps/manager/META-INF/context.xml

```
<?xml version="1.0" encoding="UTF-8"?>
<Context antiResourceLocking="false" privileged="true" >
  <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
  <Manager sessionAttributeValueClassNameFilter="java\.lang\.(?:Boolean|Integer|Long|Number|String)|org\.apache\.catalina\.filters\.CsrfPreventionFilter\$LruCache(?:\$1)?|java\.util\.(?:Linked)?HashMap"/>
</Context>
```

添加允许访问的主机地址

```
allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1|192\.168\.\d+\.\d+"
```

#### 7.5.3、service

一般情况下，一个Server实例配置一个Service，name属性相当于该Service的ID。

```
<Service name="Catalina">
```

#### 7.5.4、连接器配置

redirectPort，如果访问HTTPS协议，自动转向这个连接器。但大多数时候，Tomcat并不会开启HTTPS，因为Tomcat往往部署在内部，HTTPS性能较差。

```
    <Connector port="8080" protocol="HTTP/1.1"
               connectionTimeout="20000"
               redirectPort="8443" />
```

#### 7.5.5、引擎配置

defaultHost指向内部定义某虚拟主机。缺省虚拟主机可以改动，默认localhost。

```
<Engine name="Catalina" defaultHost="localhost">
```

#### 7.5.6、虚拟主机配置

name必须是主机名，用主机名来匹配。

appBase，当期主机的网页根目录，相对于CATALINA_HOME，也可以使用绝对路径

unpackWARs是否自动解压war格式

autoDeploy 热部署，自动加载并运行应用

```
<Host name="localhost" appBase="webapps" unpackWARs="true" autoDeploy="true">
```

#### 7.5.7、Context配置

```
Context作用
  路径映射
  应用独立配置，例如单独配置应用日志、单独配置应用访问控制

<Context path="/test" docBase="/data/test" reloadable="" />

path指的是访问的路径
docBase，可以是绝对路径，也可以是相对路径（相对于Host的appBase）
reloadable，true表示如果WEB-INF/classes或META-INF/lib目录下.class文件有改动，就会将WEB应用重新加载。
生成环境中，会使用false来禁用。
```

## 8、常见部署方式

![tomcat_04](http://images.zsjshao.net/java/tomcat/tomcat_04.png)

```
standalone模式，Tomcat单独运行，直接接受用户的请求，不推荐。
反向代理，单机运行，提供了一个Nginx作为反向代理，可以做到静态有nginx提供响应，动态jsp代理给
Tomcat
  LNMT：Linux + Nginx + MySQL + Tomcat
  LAMT：Linux + Apache（Httpd）+ MySQL + Tomcat
前置一台Nginx，给多台Tomcat实例做反向代理和负载均衡调度，Tomcat上部署的纯动态页面更适合
  LNMT：Linux + Nginx + MySQL + Tomcat
多级代理
  LNNMT：Linux + Nginx + Nginx + MySQL + Tomcat
```

### 8.1、httpd代理Tomcat

#### 8.1.1、httpd代理配置

**proxy_http_module模块代理配置**

```
<VirtualHost *:80>
    ServerName node1.magedu.com
    ProxyRequests Off
    ProxyVia On
    ProxyPreserveHost On
    ProxyPass / http://127.0.0.1:8080/
    ProxyPassReverse / http://127.0.0.1:8080/
</VirtualHost>

ProxyRequests：Off关闭正向代理。
ProxyPass：反向代理指令
ProxyPassReverse：保留代理的response头不重写（个别除外）
ProxyPreserveHost：On开启。让代理保留原请求的Host首部
ProxyVia：On开启。代理的请求响应时提供一个response的via首部
```

**proxy_ajp_module模块代理配置**

```
<VirtualHost *:80>
    ServerName node1.magedu.com
    ProxyRequests Off
    ProxyVia On
    ProxyPreserveHost On
    ProxyPass / ajp://127.0.0.1:8009/
</VirtualHost>
```

#### 8.1.2、提供测试页

```
vim test.jsp
<%@ page import="java.util.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>lbjsptest</title>
</head>
<body>
<div>ON <%=request.getServerName() %></div>
<div><%=request.getLocalAddr() + ":" + request.getLocalPort() %></div>
<div>SessionID = <span style="color:blue"><%=session.getId() %></span></div>
<%=new Date()%>
</body>
</html>
```

#### 8.1.3、httpd负载均衡（不常用）

```
Header add Set-Cookie "ROUTEID=.%{BALANCER_WORKER_ROUTE}e; path=/" env=BALANCER_ROUTE_CHANGED
<VirtualHost *:80>
    ServerName node1.magedu.com
    ProxyRequests Off
    ProxyVia On
    ProxyPreserveHost On
    ProxyPass / balancer://lbtomcats/
    ProxyPassReverse  /  balancer://lbtomcats/
</VirtualHost>

<Proxy balancer:lbtomcats>
    BalancerMember http://t1.zsjshao.net:8080 loadfactor=1 route=Tomcat=1
    BalancerMember http://t2.zsjshao.net:8080 loadfactor=2 route=Tomcat=2
    ProxySet stickysession=ROUTEID
</Proxy>
```

jvmRoute属性

```
<Engine name="Catalina" defaultHost="t1.zsjshao.net" jvmRoute="Tomcat1">
<Engine name="Catalina" defaultHost="t2.zsjshao.net" jvmRoute="Tomcat2">
```

## 9、会话保持

```
session sticky会话粘性
session复制集群
session server
```

### 9.1、session sticky会话粘性

```
source_ip
  nginx: ip_hash
  haproxy: source
  lvs: sh
cookie：
  nginx：hash 
  haproxy: cookie
```

### 9.2、session复制集群

http://tomcat.apache.org/tomcat-8.5-doc/cluster-howto.html

编辑主配置文件server.xml

```
vim conf/server.xml
  <Engine ...
     #<Host ...
        <Cluster className="org.apache.catalina.ha.tcp.SimpleTcpCluster"
                 channelSendOptions="8">

          <Manager className="org.apache.catalina.ha.session.DeltaManager"
                   expireSessionsOnShutdown="false"
                   notifyListenersOnReplication="true"/>

          <Channel className="org.apache.catalina.tribes.group.GroupChannel">
            <Membership className="org.apache.catalina.tribes.membership.McastService"
                        address="228.0.0.4"
                        port="45564"
                        frequency="500"
                        dropTime="3000"/>
            <Receiver className="org.apache.catalina.tribes.transport.nio.NioReceiver"
                      address="192.168.3.71"
                      port="4000"
                      autoBind="100"
                      selectorTimeout="5000"
                      maxThreads="6"/>

            <Sender className="org.apache.catalina.tribes.transport.ReplicationTransmitter">
              <Transport className="org.apache.catalina.tribes.transport.nio.PooledParallelSender"/>
            </Sender>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.TcpFailureDetector"/>
            <Interceptor className="org.apache.catalina.tribes.group.interceptors.MessageDispatchInterceptor"/>
          </Channel>

          <Valve className="org.apache.catalina.ha.tcp.ReplicationValve"
                 filter=""/>
          <Valve className="org.apache.catalina.ha.session.JvmRouteBinderValve"/>

          <Deployer className="org.apache.catalina.ha.deploy.FarmWarDeployer"
                    tempDir="/tmp/war-temp/"
                    deployDir="/tmp/war-deploy/"
                    watchDir="/tmp/war-listen/"
                    watchEnabled="false"/>

          <ClusterListener className="org.apache.catalina.ha.session.ClusterSessionListener"/>
        </Cluster>
     #</Host>
  </Engine>
```

编辑站点配置文件web.xml

```
vim webapps/ROOT/WEB-INF/web.xml
...
  <distributable/>
</web-app>
```

### 9.3、session server

https://github.com/magro/memcached-session-manager/wiki/SetupAndConfiguration

提供jar包

```
asm-5.2.jar
jedis-3.0.0.jar
kryo-3.0.3.jar
kryo-serializers-0.45.jar
memcached-session-manager-2.3.2.jar
memcached-session-manager-tc8-2.3.2.jar
minlog-1.3.1.jar
msm-kryo-serializer-2.3.2.jar
objenesis-2.6.jar
reflectasm-1.11.9.jar
spymemcached-2.12.3.jar
```

#### 9.3.1、sticky模式

tomcat为主，memcached为备，优先使用tomcat自己的内存，Tomcat通过jvmRoute发现不是自己的Session，便从memcached中找到该Session，更新本机Session，请求完成后更新memcached。

配置

编辑context.conf配置文件

```
vim conf/context.xml
<Context>
  ...
  <Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
    memcachedNodes="n1:192.168.3.71:11211,n2:192.168.3.72:11211"
    failoverNodes="n1"
    requestUriIgnorePattern=".*\.(ico|png|gif|jpg|css|js)$"
    transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"
    />
</Context>
```

#### 9.3.2、non-sticky模式

从msm 1.4.0之后开始支持non-sticky模式

tomcat session仅作为中转session，n1为主，n2为备，节点重新上线不抢占

**memcached配置**

编辑context.conf配置文件

```
<Context>
  ...
  <Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
    memcachedNodes="n1:192.168.3.71:11211,n2:192.168.3.72:11211"
    sticky="false"
    sessionBackupAsync="false"
    lockingMode="uriPattern:/path1|/path2"
    requestUriIgnorePattern=".*\.(ico|png|gif|jpg|css|js)$"
    transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"
    />
</Context>
```

**redis配置**

编辑context.conf配置文件

```
<Context>
  ...
  <Manager className="de.javakaffee.web.msm.MemcachedBackupSessionManager"
    memcachedNodes="redis://192.168.3.71"
    sticky="false"
    sessionBackupAsync="false"
    lockingMode="uriPattern:/path1|/path2"
    requestUriIgnorePattern=".*\.(ico|png|gif|jpg|css|js)$"
    transcoderFactoryClass="de.javakaffee.web.msm.serializer.kryo.KryoTranscoderFactory"
    />
</Context>
```

