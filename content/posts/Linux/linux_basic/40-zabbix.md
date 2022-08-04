+++
author = "zsjshao"
title = "40_zabbix"
date = "2020-05-01"
tags = ["linux_basic"]
categories = ["linux_basic"]

+++

zabbix官网：https://www.zabbix.com/

安装手册：https://www.zabbix.com/documentation/4.0/zh/manual/installation/install

下载链接：https://www.zabbix.com/cn/download

### 1、源码安装：

安装编译环境

```
# ubuntu 18.04
apt install -y gcc rsync libmysqlclient-dev libsnmp-dev libxml2-dev libevent-dev libcurl4-openssl-dev iproute2  telnet nfs-kernel-server nfs-common libssl-dev libpcre3-dev zlib1g-dev telnet  lrzsz tree iotop unzip zip php-gettext php-mbstring php-gd php-bcmath php-xml php-ldap make openjdk-8-jdk apache2 php7.2 php-mysql

# centos 7
yum install lrzsz tree bash-completion rsync gcc make mariadb-devel libxml2-devel net-snmp-devel curl-devel java-1.8.0-openjdk-devel libevent-devel httpd php php-gd php-mysql php-ldap php-bcmath php-mbstring php-xml -y
```

安装数据库

```
# ubuntu 18.04
apt install mariadb-client mariadb-server -y
systemctl start mariadb
mysql -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -e "create user 'zabbix'@'192.168.3.%' identified by 'zabbix';"
mysql -e "grant all privileges on zabbix.* to 'zabbix'@'192.168.3.%';"

# centos 7
yum install mariadb mariadb-server -y
systemctl start mariadb
mysql -e "create database zabbix character set utf8 collate utf8_bin;"
mysql -e "create user 'zabbix'@'192.168.3.%' identified by 'zabbix';"
mysql -e "grant all privileges on zabbix.* to 'zabbix'@'192.168.3.%';"
```

下载安装包

```
wget https://cdn.zabbix.com/stable/4.0.19/zabbix-4.0.19.tar.gz
```

创建用户

```
# ubuntu 18.04
addgroup --system --quiet zabbix
adduser --quiet --system --disabled-login --ingroup zabbix --home /var/lib/zabbix --no-create-home zabbix

# centos 7
groupadd --system zabbix
useradd --system -g zabbix -d /usr/lib/zabbix -s /sbin/nologin -c "Zabbix Monitoring System" zabbix
```

编译安装

```
tar xf zabbix-4.0.19.tar.gz -C /tmp/
cd /tmp/zabbix-4.0.19
./configure --prefix=/apps/zabbix --enable-server --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2 --enable-java 
make -j 2 && make install
mkdir /apps/zabbix/run /apps/zabbix/logs -p
chown zabbix.zabbix /apps/zabbix/ -R
```

导入数据库

```
mysql -uzabbix -pzabbix -h192.168.3.71 zabbix < /tmp/zabbix-4.0.19/database/mysql/schema.sql
mysql -uzabbix -pzabbix -h192.168.3.71 zabbix < /tmp/zabbix-4.0.19/database/mysql/images.sql
mysql -uzabbix -pzabbix -h192.168.3.71 zabbix < /tmp/zabbix-4.0.19/database/mysql/data.sql
```

修改配置文件

```
function edit_config() {
  grep ^${2} ${1} || sed -i "/${2}/a ${3}" ${1}
  sed -i s@^${2}.*@${3}@ ${1}
}

edit_config /apps/zabbix/etc/zabbix_server.conf DBHost= DBHost=192.168.3.71
edit_config /apps/zabbix/etc/zabbix_server.conf DBName= DBName=zabbix
edit_config /apps/zabbix/etc/zabbix_server.conf DBUser= DBUser=zabbix
edit_config /apps/zabbix/etc/zabbix_server.conf DBPassword= DBPassword=zabbix
edit_config /apps/zabbix/etc/zabbix_server.conf LogFile= LogFile=/apps/zabbix/logs/zabbix_server.log
edit_config /apps/zabbix/etc/zabbix_server.conf PidFile= PidFile=/apps/zabbix/run/zabbix_server.pid

edit_config /apps/zabbix/etc/zabbix_agentd.conf Server= Server=192.168.3.71
edit_config /apps/zabbix/etc/zabbix_agentd.conf Hostname= Hostname=192.168.3.71
edit_config /apps/zabbix/etc/zabbix_agentd.conf User= User=root
edit_config /apps/zabbix/etc/zabbix_agentd.conf AllowRoot= AllowRoot=1
edit_config /apps/zabbix/etc/zabbix_agentd.conf LogFile= LogFile=/apps/zabbix/logs/zabbix_agent.log
edit_config /apps/zabbix/etc/zabbix_agentd.conf PidFile= PidFile=/apps/zabbix/run/zabbix_agent.pid

```

提供启动unit文件

```
cat > /usr/lib/systemd/system/zabbix_server.service <<EOF
[Unit]
Description=ZabbixServer
After=syslog.target
After=network.target
[Service]
Environment="CONFFILE=/apps/zabbix/etc/zabbix_server.conf"
EnvironmentFile=-/etc/sysconfig/zabbix-server
Type=forking
Restart=on-failure
PIDFile=/apps/zabbix/run/zabbix_server.pid
KillMode=control-group
ExecStart=/apps/zabbix/sbin/zabbix_server -c \$CONFFILE
ExecStop=/bin/kill -SIGTERM \$MAINPID
RestartSec=10s
TimeoutSec=0
[Install]
WantedBy=multi-user.target
EOF

cat > /usr/lib/systemd/system/zabbix_agent.service <<EOF
[Unit]
Description=Zabbix-Agent
After=syslog.target
After=network.target
[Service]
Environment="CONFFILE=/apps/zabbix/etc/zabbix_agentd.conf"
EnvironmentFile=-/etc/sysconfig/zabbix-agent
Type=forking
Restart=on-failure
PIDFile=/apps/zabbix/run/zabbix_agent.pid
KillMode=control-group
ExecStart=/apps/zabbix/sbin/zabbix_agentd -c \$CONFFILE
ExecStop=/bin/kill -SIGTERM \$MAINPID
RestartSec=10s
TimeoutSec=0
[Install]
WantedBy=multi-user.target
EOF
```

启动服务

```
systemctl daemon-reload
systemctl start zabbix_server zabbix_agent
```

配置zabbix前端web界面

```
mkdir /var/www/html/zabbix
cp -a /tmp/zabbix-4.0.19/frontends/php/* /var/www/html/zabbix
cat > /var/www/html/zabbix/conf/zabbix.conf.php <<EOF
<?php
// Zabbix GUI configuration file.
global $DB;

$DB['TYPE']     = 'MYSQL';
$DB['SERVER']   = '192.168.3.71';
$DB['PORT']     = '0';
$DB['DATABASE'] = 'zabbix';
$DB['USER']     = 'zabbix';
$DB['PASSWORD'] = 'zabbix';

// Schema name. Used for IBM DB2 and PostgreSQL.
$DB['SCHEMA'] = '';

$ZBX_SERVER      = '192.168.3.71';
$ZBX_SERVER_PORT = '10051';
$ZBX_SERVER_NAME = 'zabbix_server';

$IMAGE_FORMAT_DEFAULT = IMAGE_FORMAT_PNG;
EOF
```

修改php.ini配置文件

```
# ubuntu 18.04
function edit_config() {
  grep "^${2}" ${1} || sed -i "/${2}/a ${3}" ${1}
  sed -i "s@^${2}.*@${3}@" ${1}
}

edit_config /etc/php/7.2/apache2/php.ini "post_max_size =" "post_max_size = 16M"
edit_config /etc/php/7.2/apache2/php.ini "max_execution_time =" "max_execution_time = 300"
edit_config /etc/php/7.2/apache2/php.ini "max_input_time =" "max_input_time = 300"
edit_config /etc/php/7.2/apache2/php.ini "date.timezone =" "date.timezone = Asia/Shanghai"

# centos 7
function edit_config() {
  grep "^${2}" ${1} || sed -i "/${2}/a ${3}" ${1}
  sed -i "s@^${2}.*@${3}@" ${1}
}

edit_config /etc/php.ini "post_max_size =" "post_max_size = 16M"
edit_config /etc/php.ini "max_execution_time =" "max_execution_time = 300"
edit_config /etc/php.ini "max_input_time =" "max_input_time = 300"
edit_config /etc/php.ini "date.timezone =" "date.timezone = Asia/Shanghai"
```

重启httpd，验证效果

```
systemctl restart httpd
```

字体修改

```
cd /var/www/html/zabbix/assets/fonts

vim /var/www/html/zabbix/include/defines.inc.php
...
70# define('ZBX_GRAPH_FONT_NAME',           'DejaVuSans');
111# define('ZBX_FONT_NAME', 'DejaVuSans');
```

监控tomcat

```
vim /apps/zabbix/sbin/zabbix_java/settings.sh
LISTEN_IP=192.168.3.71
LISTEN_PORT=10052
PID_FILE="/tmp/zabbix_java.pid"
START_POLLERS=10
TIMEOUT=30

/apps/zabbix/sbin/zabbix_java/startup.sh

# javagateway与server可不在同一台机
vim /apps/zabbix/etc/zabbix_server.conf
JavaGateway=192.168.3.71
JavaGatewayPort=10052
StartJavaPollers=0
Timeout=30
```

配置tomcat监控参数

```
vim /apps/tomcat/bin/catalina.sh
...
CATALINA_OPTS="$CATALINA_OPTS -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=12345 -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=192.168.3.71"
```

java测试

```
测试能否获取到java 当前已经分配的线程数
# java -jar cmdline-jmxclient-0.10.3.jar - 172.18.200.104:12345 'Catalina:name="http-bio-8080",type=ThreadPool' currentThreadCount
# java -jar cmdline-jmxclient-0.10.3.jar - 172.18.200.104:12345 'Catalina:name="http-bio-8080",type=ThreadPool' maxThreads
```

### 2、proxy设置



```
yum install lrzsz tree bash-completion rsync gcc make mariadb-devel libxml2-devel net-snmp-devel curl-devel java-1.8.0-openjdk-devel libevent-devel -y
```



```
groupadd --system zabbix && useradd --system -g zabbix -d /usr/lib/zabbix -s /sbin/nologin -c "Zabbix Monitoring System" zabbix
```





```
./configure --prefix=/apps/zabbix_proxy --enable-proxy --enable-agent --with-mysql --enable-ipv6 --with-net-snmp --with-libcurl --with-libxml2 --enable-java && make -j 2 && make install
```





```
grep "^[a-Z]" /apps/zabbix_proxy/etc/zabbix_proxy.conf
ProxyMode=1 #0为主动，1为被动
Server=192.168.15.201 #zabbixserver服务器的地址或主机名
Hostname=proxy1-mage-passive #代理服务器名称，需要与zabbixserver添加代理时候的proxy name是一致的！
LogFile=/tmp/zabbix_proxy.log
DBHost=192.168.15.203 #数据库服务器地址
DBName=zabbix_proxy#使用的数据库名称
DBUser=proxy #连接数据库的用户名称
DBPassword=123456 #数据库用户密码
DBPort=3306 #数据库端口
ProxyLocalBuffer=3 #已经提交到zabbixserver的数据保留时间
ProxyOfflineBuffer=24 #未提交到zabbixserver的时间保留时间
HeartbeatFrequency=60 #心跳间隔检测时间，默认60秒，范围0-3600秒，被动模式不使用
ConfigFrequency=5 #间隔多久从zabbixserver 获取监控信息
DataSenderFrequency=5 #数据发送时间间隔，默认为1秒，范围为1-3600秒，被动模式不使用
StartPollers=20 #启动的数据采集器数量
JavaGateway=192.168.15.202 #java gateway服务器地址,当需要监控java的时候必须配置否则监控不到数据
JavaGatewayPort=10052 #Javagatewa服务端口
StartJavaPollers=20 #启动多少个线程采集数据
CacheSize=2G #保存监控项而占用的最大内存
HistoryCacheSize=2G #保存监控历史数据占用的最大内存
Timeout=30 #监控项超时时间，单位为秒
LogSlowQueries=3000 #毫秒，多久的数据库查询会被记录到日志
```



```
cat > /tmp/zabbix_proxy.service <<EOF
[Unit]
Description=ZabbixServer
After=syslog.target
After=network.target
[Service]
Environment="CONFFILE=${DDIR}etc/zabbix_proxy.conf"
EnvironmentFile=-/etc/sysconfig/zabbix-proxy
Type=forking
Restart=on-failure
PIDFile=${DDIR}run/zabbix_proxy.pid
KillMode=control-group
ExecStart=${DDIR}sbin/zabbix_proxy -c \$CONFFILE
ExecStop=/bin/kill -SIGTERM \$MAINPID
RestartSec=10s
TimeoutSec=0
[Install]
WantedBy=multi-user.target
EOF

cat > /tmp/zabbix_agent.service <<EOF
[Unit]
Description=Zabbix-Agent
After=syslog.target
After=network.target
[Service]
Environment="CONFFILE=${DDIR}etc/zabbix_agentd.conf"
EnvironmentFile=-/etc/sysconfig/zabbix-agent
Type=forking
Restart=on-failure
PIDFile=${DDIR}run/zabbix_agent.pid
KillMode=control-group
ExecStart=${DDIR}sbin/zabbix_agentd -c \$CONFFILE
ExecStop=/bin/kill -SIGTERM \$MAINPID
RestartSec=10s
TimeoutSec=0
[Install]
WantedBy=multi-user.target
EOF
```



```
systemctl daemon-reload
systemctl restart zabbix_agent zabbix_proxy
```



监控nginx













