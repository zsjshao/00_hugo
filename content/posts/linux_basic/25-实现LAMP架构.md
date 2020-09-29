+++
author = "zsjshao"
title = "25_实现LAMP架构"
date = "2020-05-01"
tags = ["linux_basic"]
categories = ["linux_basic"]

+++

## 1、LAMP

LAM(M)P：

- L：linux
- A：apache (httpd)
- M：mysql, mariadb
- M：memcached
- P：php, perl, python

![01_lamp](http://images.zsjshao.net/linux_basic/25-lamp/01_lamp.png)

WEB资源类型：

- 静态资源：原始形式与响应内容一致，在客户端浏览器执行
- 动态资源：原始形式通常为程序文件，需要在服务器端执行之后，将执行结果返回给客户端

Web相关语言

- 客户端技术： html，javascript，css，jpg
- 服务器端技术：php， jsp，python，asp

## 2、CGI

CGI：Common Gateway Interface

- 可以让一个客户端，从网页浏览器通过http服务器向执行在网络服务器上的程序传输数据；CGI描述了客户端和服务器程序之间传输的一种标准

请求流程：

- Client -- (http) --> httpd -- (cgi) --> application server (program file) -- (mysql) --> mysql

php: 脚本编程语言、嵌入到html中的嵌入式web程序语言

- 基于zend编译成opcode（二进制格式的字节码，重复运行，可省略编译环境）

## 3、LAMP工作原理

![02_lamp](http://images.zsjshao.net/linux_basic/25-lamp/02_lamp.png)

## 4、PHP简介

官网：http://www.php.net/

PHP是通用服务器端脚本编程语言，主要用于web开发实现动态web页面，也是最早实现将脚本嵌入HTML源码文档中的服务器端脚本语言之一。同时，php还提供了一个命令行接口，因此，其也可以在大多数系统上作为一个独立的shell来使用

Rasmus Lerdorf于1994年开始开发PHP，最初是一组被Rasmus Lerdorf称作“Personal Home Page Tool” 的Perl脚本， 可以用于显示作者的简历并记录用户对其网站的访问。后来，Rasmus Lerdorf使用C语言将这些Perl脚本重写为CGI程序，还为其增加了运行Web forms的能力以及与数据库交互的特性，并将其重命名为“Personal Home Page/Forms Interpreter”或“PHP/FI”。此时，PHP/FI已经可以用于开发简单的动态web程序了，这即PHP1.0。1995年6月，Rasmus Lerdorf把它的PHP发布于comp.infosystems.www.authoring.cgi Usenet讨论组，从此PHP开始走进人们的视野。1997年，其2.0版本发布

1997年，两名以色列程序员Zeev Suraski和Andi Gutmans重写的PHP的分析器(parser)成为PHP发展到3.0的基础，而且从此将PHP重命名为PHP: Hypertext Preprocessor。此后，这两名程序员开始重写整个PHP核心，并于1999年发布了Zend Engine 1.0，这也意味着PHP 4.0的诞生。2004年7月，Zend Engine 2.0发布，由此也将PHP带入了PHP 5时代。PHP5包含了许多重要的新特性，如增强的面向对象编程的支持、支持PDO(PHP Data Objects)扩展机制以及一系列对PHP性能的改进

### 4.1、PHP Zend Engine

Zend Engine是开源的、PHP脚本语言的解释器，它最早是由以色列理工学院(Technion)的学生Andi Gutmans和Zeev Suraski所开发，Zend也正是此二人名字的合称。后来两人联合创立了Zend Technologies公司

Zend Engine 1.0于1999年随PHP 4发布，由C语言开发且经过高度优化，并能够做为PHP的后端模块使用。Zend Engine为PHP提供了内存和资源管理的功能以及其它的一些标准服务，其高性能、可靠性和可扩展性在促进PHP成为一种流行的语言方面发挥了重要作用

Zend Engine的出现将PHP代码的处理过程分成了两个阶段：首先是分析PHP代码并将其转换为称作Zend opcode的二进制格式opcode(类似Java的字节码)，并将其存储于内存中；第二阶段是使用Zend Engine去执行这些转换后的Opcode

### 4.2、PHP的Opcode

Opcode是一种PHP脚本编译后的中间语言，类似于Java的ByteCode,或者.NET的MSL。PHP执行PHP脚本代码一般会经过如下4个步骤(确切的来说，应该是PHP的语言引擎Zend)

- 1、Scanning 词法分析,将PHP代码转换为语言片段(Tokens)
- 2、Parsing 语义分析,将Tokens转换成简单而有意义的表达式
- 3、Compilation 将表达式编译成Opcode
- 4、Execution 顺次执行Opcode，每次一条，从而实现PHP脚本的功能

扫描-->分析-->编译-->执行

### 4.3、php配置

php：脚本语言解释器

- 配置文件：/etc/php.ini, /etc/php.d/*.ini
- 配置文件在php解释器启动时被读取
- 对配置文件的修改生效方法
  - Modules：重启httpd服务
  - FastCGI：重启php-fpm服务

/etc/php.ini配置文件格式：

- [foo]：Section Header
- directive = value
- 注释符：较新的版本中，已经完全使用;进行注释
- #：纯粹的注释信息
- ;：用于注释可启用的directive

### 4.4、php设置

php.ini的核心配置选项文档： http://php.net/manual/zh/ini.core.php

php.ini配置选项列表：http://php.net/manual/zh/ini.list.php

php常见设置：

- max_execution_time= 30 最长执行时间30s
- memory_limit=128M 生产不够，可调大
- display_errors=off 调试使用，不要打开，否则可能暴露重要信息
- display_startup_errors=off 建议关闭
- post_max_size=8M 最大上传数据大小，生产可能调大，比下面项大
- upload_max_filesize =2M 最大上传文件，生产可能要调大
- max_file_uploads = 20 同时上传最多文件数
- date.timezone =Asia/Shanghai 指定时区
- short_open_tag=on 开启短标签,如<? phpinfo();?>

## 5、LAMP

LAMP

- httpd：接收用户的web请求；静态资源则直接响应；动态资源为php脚本，对此类资源的请求将交由php来运行
- php：运行php程序
- MariaDB：数据管理系统

httpd与php结合的方式

- modules (将php编译成为httpd的模块,默认方式)
  - MPM:
    - prefork: libphp5.so
    - event, worker: libphp5-zts.so
- FastCGI

### 5.1、实现LAMP方式

CentOS 7:

- Modules：httpd, php, php-mysql, mariadb-server
- FastCGI：httpd, php-fpm, php-mysql, mariadb-server

CentOS 6：

- Modules：httpd, php, php-mysql, mysql-server
- FastCGI：默认不支持

### 5.2、基于php模块方式安装LAMP

安装LAMP

- CentOS 6:
  - yum install httpd, php, mysql-server, php-mysql
  - service httpd start
  - service mysqld start

- CentOS 7:
  - yum install httpd, php, php-mysql, mariadb-server
  - systemctl start httpd.service
  - systemctl start mariadb.service

- 注意：要使用prefork模型

### 5.3、php代码

php语言格式

```
<?php
  ...php code...
?>
```

php测试代码

```
<?php
  echo date("Y/m/d H:i:s");
  phpinfo();
?>
```

格式1

```
<?php
  echo "<h1>Hello world!</h1>"
?>
```

格式2

```
<h1>
  <?php echo "Hello world!" ?>
</h1>
```

### 5.4、使用mysql扩展连接数据库

php使用mysql扩展连接数据库的测试代码

```
<?php
  $conn = mysql_connect('mysqlserver','username','password');
  if ($conn)
    echo "OK";
  else
    echo "Failure";
    #echo mysql_error();
  mysql_close();
?>
```

### 5.5、使用mysqli扩展连接数据库

php使用mysqli扩展连接数据库的测试代码

```
<?php
  $mysqli=new mysqli("mysqlserver", "username", "password");
  if(mysqli_connect_errno()){
    echo "Failure";
    $mysqli=null;
    exit;
  }
  echo "OK";
  $mysqli->close();
?>
```

### 5.6、使用PDO(PHP Data Object)扩展连接数据库

php使用pdo扩展连接数据库的测试代码1

```
<?php
  $dsn='mysql:host=mysqlhost;dbname=test';
  $username='root';
  $passwd='magedu';
  $dbh=new PDO($dsn,$username,$passwd);
  var_dump($dbh);
?>
```

php使用pdo扩展连接数据库的测试代码2

```
<?php
  try {
    $user='root';
    $pass='magedu';
    $dbh = new PDO('mysql:host=mysqlhost;dbname=mysql', $user, $pass);
    foreach($dbh->query('SELECT user,host from user') as $row) {
    print_r($row);
  }
  $dbh = null;
  } catch (PDOException $e) {
  print "Error!: " . $e->getMessage() . "<br/>";
  die();
  }
?>
```

### 5.7、常见LAMP应用

PhpMyAdmin是一个以PHP为基础，以Web-Base方式架构在网站主机上的MySQL的数据库管理工具，让管理者可用Web接口管理MySQL数据库

WordPress是一种使用PHP语言开发的博客平台，用户可以在支持PHP和MySQL数据库的服务器上架设属于自己的网站。也可把 WordPress当作一个内容管理系统（CMS）来使用

PHPWind:2003年发布了PHPWind的前身版本ofstar，并发展成为包含BBS、CMS、博客、SNS等一系列程序的通用型建站软件, 于2008年加入阿里巴巴集团

Crossday Discuz! Board（简称 Discuz!）是一套通用的社区论坛软件系统。自2001年6月面世以来，是全球成熟度最高、覆盖率最大的论坛软件系统之一。2010年8月23日，与腾讯达成收购协议

ECShop是一款B2C独立网店系统，适合企业及个人快速构建个性化网上商店。系统是基于PHP语言及MYSQL数据库构架开发的跨平台开源程序。2006年6月，ECShop推出第一个版本1.0

### 5.8、布署phpMyadmin

```
yum -y install httpd mariadb-server php php-mysql
systemctl start httpd
systemctl start mariadb
mysql_secure_installation
下载：https://www.phpmyadmin.net/downloads/
tar xvf phpMyAdmin-4.0.10.20-all-languages.tar.xz cd /var/www/html
cd phpadmin/
cp config.sample.inc.php config.inc.php
yum -y install php-mbstring
systemctl reload httpd
```

### 5.9、布署wordpress

下载地址：

- 教室：ftp://172.16.0.1/pub/Sources/sources/httpd/
- 官网：https://cn.wordpress.org/

解压缩WordPress博客程序到网页站点目录下

- unzip wordpress-5.0.3-zh_CN.zip

新建wpdb库和wpuser用户

- mysql> create database wpdb;
- mysql> grant all privileges on wpdb.* to wpuser@'%' identified by "wppass";

打开http://webserver/wordpress进行页面安装

注意wordpress目录权限

- Setfacl –R –m u:apache:rwx wordpress

## 6、php的加速器

php的加速器：基于PHP的特殊扩展机制如opcode缓存扩展也可以将opcode缓存于php的共享内存中，从而可以让同一段代码的后续重复执行时跳过编译阶段以提高性能。这些加速器并非真正提高了opcode的运行速度，而仅是通过分析opcode后并将它们重新排列以达到快速执行的目的

常见的php加速器有：

1、APC (Alternative PHP Cache)
遵循PHP License的开源框架，PHP opcode缓存加速器，目前的版本不适用于PHP 5.4
项目地址http://pecl.php.net/package/APC

2、eAccelerator
源于Turck MMCache，早期的版本包含了一个PHP encoder和PHP loader，目前encoder已经不在支持。项目地址 http://eaccelerator.net/

3、XCache
快速而且稳定的PHP opcode缓存，经过严格测试且被大量用于生产环境。项目地址：http://xcache.lighttpd.net/,收录EPEL源

4、Zend Optimizer和Zend Guard Loader
Zend Optimizer并非一个opcode加速器，它是由Zend Technologies为PHP5.2及以前的版本提供的一个免费、闭源的PHP扩展，其能够运行由Zend Guard生成的加密的PHP代码或模糊代码。 而Zend Guard Loader则是专为PHP5.3提供的类似于Zend Optimizer功能的扩展。项目地址http://www.zend.com/en/products/guard/runtime-decoders

5、NuSphere PhpExpress
NuSphere的一款开源PHP加速器，它支持装载通过NuSphere PHP Encoder编码的PHP程序文件，并能够实现对常规PHP文件的执行加速。项目地址，http://www.nusphere.com/products/phpexpress.htm

### 6.1、CentOS7编译Php-xcache加速访问

官网：http://xcache.lighttpd.net/wiki/ReleaseArchive

- 安装方法
- rpm包：来自epel源
- 编译安装

编译安装

- yum -y install php-devel
- 下载并解压缩xcache-3.2.0.tar.bz2
- phpize 生成编译环境
- cd xcache-3.2.0
- ./configure --enable-xcache
- make && make install
- cp xcache.ini /etc/php.d/
- systemctl restart httpd.service

## 7、php

httpd+php结合的方式：

- module: php
- fastcgi : php-fpm

php-fpm：

CentOS 6：

- PHP-5.3.2之前：默认不支持fpm机制；需要自行打补丁并编译安装
- httpd-2.2：默认不支持fcgi协议，需要自行编译此模块
- 解决方案：编译安装httpd-2.4, php-5.3.3+

CentOS 7：

- httpd-2.4：rpm包默认编译支持fcgi模块
- php-fpm包：专用于将php运行于fpm模式

### 7.1、配置fastcgi

fcgi服务配置文件：/etc/php-fpm.conf, /etc/php-fpm.d/*.conf

官方文档：http://php.net/manual/zh/install.fpm.configuration.php

连接池：pm = static|dynamic

- static：固定数量的子进程；pm.max_children
- dynamic：子进程数量以动态模式管理，默认值
  - pm.max_children = 50
  - pm.start_servers =5
  - pm.min_spare_servers =5
  - pm.max_spare_servers =35
  - pm.max_requests = 500 每个进程可以处理的请求数

确保运行php-fpm进程的用户对session目录有读写权限

- mkdir /var/lib/php/session
- chown apache.apache /var/lib/php/session

(1) 配置httpd，添加/etc/httpd/conf.d/fcgi.conf配置文件，内容类似

```
DirectoryIndex index.php
ProxyRequests Off
ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/var/www/html/$1

UDS（unix domain socket）方式
ProxyPassMatch ^/(.*\.php)$ unix:/var/run/php.sock|fcgi://localhost/app/httpd24/htdocs/$1
```

参看：http://httpd.apache.org/docs/2.4/mod/mod_proxy_fcgi.html

注意：在HTTPD服务器上必须启用proxy_fcgi_module模块，充当PHP客户端

- httpd –M |grep fcgi
- cat /etc/httpd/conf.modules.d/00-proxy.conf

2) 虚拟主机配置

```
vim /etc/httpd/conf.d/vhosts.conf
DirectoryIndex index.php
<VirtualHost *:80>
  ServerName www.b.net
  DocumentRoot /apps/vhosts/b.net
  ProxyRequests Off
  ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/apps/vhosts/b.net/$1
  <Directory "/apps/vhosts/b.net">
    Options None
    AllowOverride None
    Require all granted
  </Directory>
</VirtualHost>
```

### 7.2、CentOS 7安装LAMP(PHP-FPM模式)

安装PHP-FPM

- 首先要卸载PHP
- yum install php-fpm

查看php-fpm所对应的配置文件

```
rpm -ql php-fpm
/usr/lib/systemd/system/php-fpm.service
/etc/logrotate.d/php-fpm
/etc/php-fpm.conf
/etc/php-fpm.d
/etc/php-fpm.d/www.conf
/etc/sysconfig/php-fpm
/run/php-fpm
```

PHP-FPM常见配置

- daemonize = no //是否将程序运行在后台
- listen = 127.0.0.1:9000 //FPM 监听地址
- listen = /var/run/php.sock //UDF模式使用
- listen.mode= 0666 //UDF模式使用
- listen.backlog = -1 //等待队列的长度 -1表示无限制 listen.allowed_clients = 127.0.0.1 //仅允许哪些主机访问
- pm = dynamic //PM是动态运行还是静态运行
  - //static 固定数量的子进程，pm.max_childen
  - //dynamic子进程数据以动态模式管理
- pm.start_servers
- pm.min_spare_servers
- pm.max_spare_servers
- pm.max_requests = 500
- php_value[session.save_handler] = files
- php_value[session.save_path] = /var/lib/php/session
  - //设置session存放位置

启动PHP-FPM

```
systemctl start php-fpm
```

安装httpd包

```
yum install httpd
```



查看Httpd mod_fcgi模块是否加载

```
httpd -M | grep fcgi
proxy_fcgi_module (shared)
```

添加FCGI的配置文件

```
DirectoryIndex index.php
ProxyRequests off //是否开启正向代理
ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/var/www/html/$1 //开启FCGI反向代理,//前面的/相对于后面的/var/www/html而言，后面的$1是指前面的/(.*\.php)
```

重启Httpd：

```
systemctl start httpd
```

### 7.3、CentOS7编译安装LAMP

在centos7上编译安装LAMP：

mairadb：通用二进制格式，mariadb-5.5.56

httpd：编译安装，httpd-2.4.25

php5：编译安装，php-5.6.30

phpMyAdmin：安装phpMyAdmin-4.4.15.10-all-languages

Xcache：编译安装xcache-3.2.0

php5.4依赖于mariadb-devel包

顺序：mariadb-->httpd-->php



二进制安装mariadb

```
ftp://172.16.0.1/pub/Source/7.x86_64/mariadb/mariadb-5.5-46-linux-x86_64.tar.gz
tar xvf mariadb-5.5-46-linux-x86_64.tar.gz -C /usr/local
cd /usr/local
ls -sv mariadb-5.5.46-linux-x86_64 mysql
cd mysql
chown -R root.mysql ./*
mkdir /mydata/data -p
chown -R mysql.mysql /mydata/data
mkdir /etc/mysql
cp support-files/my-large.cnf /etc/mysql/my.cnf

vim /etc/mysql/my.cnf
[mysqld]加三行
datadir =/mydata/data
innodb_file_per_table = ON
skip_name_resolve = ON

vim /etc/profile.d/mysql.sh
export PATH=/usr/local/mysql/bin/:$PATH

cd /usr/local/mysql;scripts/mysql_install_db --user=mysql --datadir=/mydata/data
cp support-files/mysql.server /etc/rc.d/init.d/mysqld
chkconfig --add mysqld
service mysqld start
```

编译安装httpd-2.4

```
yum install gcc pcre-devel openssl-devel expat-devel

./configure --prefix=/app/httpd24 \
--enable-so \
--enable-ssl \
--enable-cgi \
--enable-rewrite \
--with-zlib \
--with-pcre \
--enable-modules=most \
--enable-mpms-shared=all \
--with-mpm=prefork \
--with-included-apr

make -j 4 && make install
```

编译安装php-7.3.0

相关包：

- libxml2-devel bzip2-devel libmcrypt-devel (epel)

```
./configure --prefix=/app/php --enable-mysqlnd --with-mysqli=mysqlnd --with-openssl --with-pdo-mysql=mysqlnd --enable-mbstring --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --enable-sockets --with-apxs2=/app/httpd24/bin/apxs --with-config-file-path=/etc --with-config-file-scan-dir=/etc/php.d --enable-maintainer-zts --disable-fileinfo
```

注意：php-7.0以上版本使用--enable-mysqlnd --with-mysqli=mysqlnd ，原--with-mysql不再支持

为php提供配置文件

```
cp php.ini-production /etc/php.ini
```

编辑apache配置文件httpd.conf，以使apache支持php

```
vim /etc/httpd24/conf/httpd.conf
1加二行
AddType application/x-httpd-php .php
AddType application/x-httpd-php-source .phps

2 定位至DirectoryIndex index.html
修改为DirectoryIndex index.php index.html

apachectl restart
```



```
yum install libxml2-devel bzip2-devel libmcrypt-devel (epel)
tar xvf php-7.3.5.tar.bz2
cd php-7.3.5/
./configure --prefix=/app/php \
--enable-mysqlnd \
--with-mysqli=mysqlnd \
--with-pdo-mysql=mysqlnd \
--with-openssl \
--with-freetype-dir \
--with-jpeg-dir \
--with-png-dir \
--with-zlib \
--with-libxml-dir=/usr \
--with-config-file-path=/etc \
--with-config-file-scan-dir=/etc/php.d \
--enable-mbstring \
--enable-xml \
--enable-sockets \
--enable-fpm \
--enable-maintainer-zts \
--disable-fileinfo
make && make install

cp php.ini-production /etc/php.ini
cp sapi/fpm/init.d.php-fpm /etc/init.d/php-fpm
chmod +x /etc/init.d/php-fpm
chkconfig --add php-fpm
chkconfig php-fpm on

cd /app/php/etc
cp php-fpm.conf.default php-fpm.conf
cp php-fpm.d/www.conf.default php-fpm.d/www.conf

service php-fpm start

```

配置httpd支持php

```
vim /app/httpd24/conf/httpd.conf

取消下面两行的注释
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_fcgi_module modules/mod_proxy_fcgi.so

修改下面行
<IfModule dir_module>
DirectoryIndex index.php index.html
</IfModule>

加下面四行
AddType application/x-httpd-php .php
AddType application/x-httpd-php-source .phps
ProxyRequests Off
ProxyPassMatch ^/(.*\.php)$ fcgi://127.0.0.1:9000/app/httpd24/htdocs/$1
```











