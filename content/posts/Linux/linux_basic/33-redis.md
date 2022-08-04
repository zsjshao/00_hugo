+++
author = "zsjshao"
title = "33_redis"
date = "2020-05-01"
tags = ["linux_basic"]
categories = ["linux_basic"]

+++

## 一：缓存概念：

缓存是为了调节速度不一致的两个或多个不同的物质的速度，在中间对速度较快的一方起到一个加速访问速度较慢的一方的作用，比如CPU的一级、二级缓存是保存了CPU最近经常访问的数据，内存是保存CPU经常访问硬盘的数据，而且硬盘也有大小不一的缓存，甚至是物理服务器的raid卡也有缓存，都是为了起到加速CPU访问硬盘数据的目的，因为CPU的速度太快了，CPU需要的数据硬盘往往不能在短时间内满足CPU的需求，因此CPU缓存、内存、raid卡以及硬盘缓存就在一定程度上满足了CPU的数据需求，即CPU从缓存读取数据可以大幅提高CPU的工作效率。

![redis_01](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_01.png)

### 1.1：系统缓存

#### 1.1.1：buffer与cache

buffer：缓冲也叫写缓冲，一般用于写操作，可以将数据先写入内存在写入磁盘，buffer 一般用于写缓冲，用于解决不同介质的速度不一致的缓冲，先将数据临时写入到离自己最近地方，以提写入速度， CPU 会把数据先写到内存的磁盘缓冲区，然后就认为数据已经写入完成，然后由内核在后续的时间在写入磁盘，所以服务器突然断电会丢失内存中的部分数据。
cache ：缓存也叫读缓存， 一般用于读操作，CPU 读文件从内存读，如果内存没有就先硬盘读到内存再读到CPU，将需要频繁读取的数据放在离自己最近的缓存区域，下次读取的时候即可快速读取。

#### 1.1.2：cache的保存位置：

客户端：浏览器

内存：本地服务器、远程服务器

硬盘：本机硬盘、远程服务器硬盘

#### 1.1.3：cache的特性

自动过期：给缓存的数据加上有效时间，超出时间后自动过期删除

过期时间：强制过期，源网站更新图片后CDN是不会更新的，需要强制使图片缓存过期

命中率：即缓存的读取命中率

### 1.2：用户层缓存

#### 1.2.1：DNS缓存

默认为60秒，即60秒之内在访问同一个域名就不在进行DNS解析

查看chrome浏览器的DNS缓存(旧版本)

chrome://net-internals/#dns

![redis_02](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_02.png)

#### 1.2.2：浏览器缓存过期机制：

##### 1.2.3.1：最后修改时间

系统调用会获取文件的最后修改时间，如果没有发生变化就返回给服务器304的状态码，表示没有发生变化，然后浏览器就使用本地的缓存展示资源。

![redis_03](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_03.png)

###### 1.2.3.2：Etag标记

基于Etag标记是否一致做判断页面是否发生过变化，比如基于Nginx的etag on来实现

![redis_04](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_04.png)

###### 1.2.3.3：过期时间

以上两种都需要发生请求，即不管资源是否过期都有发送请求进行协商，这样会消耗不必要的时间，因此有了缓存的过期时间，即第一次请求资源的时候带一个资源的过期时间，默认为30天，当前这种方式使用的比较多，但是无法保证客户的时间都是准确并且一致的，因此加入一个最大生存周期，使用用户本地的时间计算缓存数据是否超过多少天，下面的过期时间为2027年，但是缓存的最大生存周期计算为天等于3650天即10年，过期时间如下：

![redis_05](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_05.png)

### 1.3：CDN缓存

#### 1.3.1：什么是CND

内容分发网络（Content Delivery Network），通过将服务内容分发至全网加速节点，利用全球调度系统使用户能够就近获取，有效降低访问延迟，提升服务可用性，CDN第一降低机房的使用带宽，因为很多资源通过CDN就直接返回用户了，第二解决不同运营商之间的互联，因为可以让联通的网络访问联通让电信的网络访问电信，起到加速用户访问的目的，第三：解决用户访问的地域问题，就近返回用户资源。

百度CDN：https://cloud.baidu.com/product/cdn.html

阿里CDN：https://www.aliyun.com/product/cdn

腾讯CDN：https://cloud.tencent.com/product/cdn

#### 1.3.2：用户请求CDN流程：

提前对静态内容进行预缓存，避免大量的请求回源，导致主站网络带宽被打满而导致数据无法更新，另外CDN可以将数据根据访问的热度不同而进行不同级别的缓存，例如访问量最高的资源访问CDN边缘节点的内存，其次的放在SSD或者SATA，再其次的放在云存储，这样兼顾了速度与成本。

![redis_06](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_06.png)

#### 1.3.3：CDN的主要优势

提前对静态内容进行预缓存，避免大量的请求回源，导致主站网络带宽被打满而导致数据无法更新，另外CDN可以将数据根据访问的热度不同而进行不同级别的缓存，例如访问量最高的资源访问CDN边缘节点的内存，其次的放在SSD或者SATA，再其次的放在云存储，这样兼顾了速度与成本。缓存到最快的地方如内存，缓存的数据准确命中率高，访问速度就快

调度准确-将用户调度到最近的边缘节点

性能优化-CDN专门用于缓存响应速度快

安全相关-抵御攻击

节省带宽：由于用户请求由边缘节点响应，因此大幅降低到源站带宽。

### 1.4：应用层缓存：

Nginx、php等web服务可以设置应用缓存以加速响应用户请求，另外有些解释性语言比如PHP/Python不能直接运行，需要先编译成字节码，但字节码需要解释器解释为机器码之后才能执行，因此字节码也是一种缓存，有时候会出现程序代码上线后字节码没有更新的现象。

### 1.5：其他层面缓存

CPU缓存（L1的数据缓存和L1的指令缓存）、二级缓存、三级缓存

![redis_07](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_07.png)

磁盘缓存

RAID卡

分布式缓存：redis、memcache

## 二：redis部署与使用

### 2.1：redis基础

官网地址：https://redis.io

Redis和Memcached是非关系型数据库也称为NoSQL数据库，MySQL、Mariadb、SQL Server、PostgreSQL、Oracle数据库属于关系型数据库（RDBMS，Relational Database Management System）

#### 2.1.1：redis简介：

Redis（Remote Dictionary Server）在2009年发布，开发者Salvatore Sanfilippo是意大利开发者，他本想为自己的公司开发一个用于替换MySQL的产品Redis，但是没有想到他把Redis开源后大受欢迎，短短几年，Redis就有了很大的用户群体，目前国内外使用的公司有知乎网、新浪微博、GitHub等，redis是一个开源的、遵循BSD协议的、基于内存的而且目前比较流行的键值数据库（key-value database），是一个非关系型数据库，redis提供将内存通过网络远程共享的一种服务，提供类似功能的还有memcached，但相比memcached，redis还提供了易扩展、高性能、具备数据持久性等功能。

Redis在高并发、低延迟环境要求比较高的环境使用量非常广泛，目前redis在DB-Engine月排行榜中一直比较靠前，而且一直是键值型存储类的首位。

https://db-engines.com/en/ranking

![redis_08](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_08.png)

#### 2.1.2：redis对比memcached：

支持数据的持久化：可以将内存中的数据保持在磁盘中，重启redis服务或者服务器之后可以从备份文件中恢复数据到内存继续使用。

支持更多的数据类型：支持string(字符串) 、hash(哈希数据) 、list(列表) 、set(集合) 、zet(有序集合)

支持数据的备份：可以实现类似于数据的master-slave模式的数据备份， 另外也支持使用快照+AOF。

支持更大的value数据：memcache单个key value最大只支持1MB， 而redis最大支持512MB。Red is是单线程， 而memcache是多线程， 所以单机情况下没有memcache并发高， 但redis支持分布式集群以实现更高的并发， 单Redis实例可以实现数万并发。

 支持集群横向扩展：基于redis cluster的横向扩展， 可以实现分布式集群， 大幅提升性能和数据安全性。

 都是基于c语言开发。

#### 2.1.3：redis典型应用场景：

Session共享：常见于web集群中的Tomcat或者PHP中多web服务器session共享

消息队列：ELK的日志缓存、部分业务的订阅发布系统

计数器：访问排行榜、商品浏览数等和次数相关的数值统计场景

缓存：数据查询、电商网站商品信息、新闻内容

微博/微信社交场合：共同好友、点赞评论等

### 2.2：Redis安装及使用

官方下载地址：http://download.redis.io/releases

#### 2.2.1：dnf安装redis：

```
[root@c83 ~]# dnf install redis
[root@c83 ~]# systemctl start redis
[root@c83 ~]# systemctl enable redis
127.0.0.1:6379> ping
PONG
```

#### 2.2.2：编译安装redis

下载当前最新release版本redis源码包：

http://download.redis.io

##### 2.2.2.1:编译安装命令：

```
[root@c81 src]# pwd
/usr/local/src
[root@c81 src]# tar xf redis-5.0.7.tar.gz 
[root@c81 src]# cd redis-5.0.7
[root@c81 redis-5.0.7]# make PREFIX=/apps/redis install
[root@c84 redis-5.0.7]# useradd -r -s /sbin/nologin redis
[root@c81 redis-5.0.7]# mkdir /apps/redis/{etc,data,logs,run} -pv
[root@c81 redis-5.0.7]# chown redis.redis /apps/redis/ -R
[root@c81 redis-5.0.7]# cp redis.conf /apps/redis/etc/
```

##### 2.2.2.2：前台启动redis

```
[root@c81 redis-5.0.7]# /apps/redis/bin/redis-server /apps/redis/etc/redis.conf 
12978:C 06 Mar 2020 18:22:49.278 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
12978:C 06 Mar 2020 18:22:49.278 # Redis version=5.0.7, bits=64, commit=00000000, modified=0, pid=12978, just started
12978:C 06 Mar 2020 18:22:49.278 # Configuration loaded
12978:M 06 Mar 2020 18:22:49.278 * Increased maximum number of open files to 10032 (it was originally set to 1024).
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 5.0.7 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 12978
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

12978:M 06 Mar 2020 18:22:49.279 # WARNING: The TCP backlog setting of 511 cannot be enforced because /proc/sys/net/core/somaxconn is set to the lower value of 128.
12978:M 06 Mar 2020 18:22:49.279 # Server initialized
12978:M 06 Mar 2020 18:22:49.279 # WARNING overcommit_memory is set to 0! Background save may fail under low memory condition. To fix this issue add 'vm.overcommit_memory = 1' to /etc/sysctl.conf and then reboot or run the command 'sysctl vm.overcommit_memory=1' for this to take effect.12978:M 06 Mar 2020 18:22:49.279 # WARNING you have Transparent Huge Pages (THP) support enabled in your kernel. This will create latency and memory usage issues with Redis. To fix this issue run the command 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' as root, and add it to your /etc/rc.local in order to retain the setting after a reboot. Redis must be restarted after THP is disabled.
12978:M 06 Mar 2020 18:22:49.279 * DB loaded from disk: 0.000 seconds
12978:M 06 Mar 2020 18:22:49.279 * Ready to accept connections
```

##### 2.2.2.3：解决当前的警告提示：

###### 2.2.2.3.1：tcp-backlog

backlog参数控制的是三次握手的时候server端收到client ack确认号之后的队列值。

```
[root@c81 ~]# echo 'net.core.somaxconn = 512' >> /etc/sysctl.conf 
[root@c81 ~]# sysctl -p
net.core.somaxconn = 512
```

###### 2.2.2.3.2：vm.overcommit_memory

0：表示内核将检查是否有足够的可用内存供应用进程使用；如果有足够的可用内存，内存申请允许；否则，内存申请失败，并把错误返回给应用进程。

1：表示内核允许分配所有的物理内存，而不管当前的内存状态如何。

2：表示内核允许分配超过所有物理内内存和交换空间总和的内存

```
[root@c81 ~]# echo 'vm.overcommit_memory = 1' >> /etc/sysctl.conf 
[root@c81 ~]# sysctl -p
vm.overcommit_memory = 1
```

###### 2.2.2.3.3：Transparent Huge Pages

关闭大页内存动态分配，让redis自行负责内存管理。

```
[root@c81 ~]# echo never > /sys/kernel/mm/transparent_hugepage/enabled
[root@c81 ~]# echo 'echo never > /sys/kernel/mm/transparent_hugepage/enabled' >> /etc/rc.d/rc.local 
[root@c81 ~]# chmod +x /etc/rc.d/rc.local
```

###### 2.2.2.3.4：再次启动redis：

将以上配置同步到其他redis服务器。

```
[root@c81 redis-5.0.7]# /apps/redis/bin/redis-server /apps/redis/etc/redis.conf 
13409:C 06 Mar 2020 19:06:57.463 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
13409:C 06 Mar 2020 19:06:57.463 # Redis version=5.0.7, bits=64, commit=00000000, modified=0, pid=13409, just started
13409:C 06 Mar 2020 19:06:57.463 # Configuration loaded
13409:M 06 Mar 2020 19:06:57.463 * Increased maximum number of open files to 10032 (it was originally set to 1024).
                _._                                                  
           _.-``__ ''-._                                             
      _.-``    `.  `_.  ''-._           Redis 5.0.7 (00000000/0) 64 bit
  .-`` .-```.  ```\/    _.,_ ''-._                                   
 (    '      ,       .-`  | `,    )     Running in standalone mode
 |`-._`-...-` __...-.``-._|'` _.-'|     Port: 6379
 |    `-._   `._    /     _.-'    |     PID: 13409
  `-._    `-._  `-./  _.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |           http://redis.io        
  `-._    `-._`-.__.-'_.-'    _.-'                                   
 |`-._`-._    `-.__.-'    _.-'_.-'|                                  
 |    `-._`-._        _.-'_.-'    |                                  
  `-._    `-._`-.__.-'_.-'    _.-'                                   
      `-._    `-.__.-'    _.-'                                       
          `-._        _.-'                                           
              `-.__.-'                                               

13409:M 06 Mar 2020 19:06:57.465 # Server initialized
13409:M 06 Mar 2020 19:06:57.465 * DB loaded from disk: 0.000 seconds
13409:M 06 Mar 2020 19:06:57.465 * Ready to accept connections
```

###### 2.2.2.4：编辑redis服务启动脚本

```
[root@c81 ~]# cat /usr/lib/systemd/system/redis.service
[Unit]
Description=Redis persistent key-value database
After=network.target

[Service]
ExecStart=/apps/redis/bin/redis-server /apps/redis/etc/redis.conf --supervised systemd
ExecReload=/bin/kill -s HUP $MAINPID
ExecStop=/bin/kill -s QUIT $MAINPID
Type=notify
User=redis
Group=redis
RuntimeDirectory=redis
RuntimeDirectoryMode=0755

[Install]
WantedBy=multi-user.target
```

###### 2.2.2.5：创建redis用户

```
[root@c81 ~]# useradd -r -s /sbin/nologin redis
```

###### 2.2.2.6：验证redis启动：

```
[root@c81 redis-5.0.7]# systemctl daemon-reload
[root@c81 redis-5.0.7]# systemctl start redis
[root@c81 redis-5.0.7]# ss -tnl
State            Recv-Q             Send-Q                          Local Address:Port                         Peer Address:Port            
LISTEN           0                  128                                   0.0.0.0:22                                0.0.0.0:*               
LISTEN           0                  511                                 127.0.0.1:6379                              0.0.0.0:*                          
LISTEN           0                  128                                      [::]:22                                   [::]:*                            
[root@c81 redis-5.0.7]# ln -sv /apps/redis/bin/redis-* /usr/sbin/
[root@c81 redis-5.0.7]# redis-cli 
127.0.0.1:6379> info
## Server
redis_version:5.0.7
redis_git_sha1:00000000
redis_git_dirty:0
```

###### 2.2.2.7：编译安装后的命令：

```
[root@c81 redis-5.0.7]# ll /apps/redis/bin/
total 42532
-rwxr-xr-x. 1 root root  5945136 Mar  6 18:18 redis-benchmark #redis性能测试工具
-rwxr-xr-x. 1 root root 10377848 Mar  6 18:18 redis-check-aof #AOF文件检查工具
-rwxr-xr-x. 1 root root 10377848 Mar  6 18:18 redis-check-rdb #RDB文件检查工具
-rwxr-xr-x. 1 root root  6466368 Mar  6 18:18 redis-cli #客户端工具
lrwxrwxrwx. 1 root root      12 Mar  6 18:18 redis-sentinel -> redis-server #哨兵
-rwxr-xr-x. 1 root root 10377848 Mar  6 18:18 redis-server #redis服务端
```

### 2.3：redis配置文件：

#### 2.3.1：redis主要配置项

```
bind 0.0.0.0                    #监听地址，可以用空格隔开多个监听IP
protected-mode yes              #redis 3.2之后加入的新特性，在没有设置bind ip或密码的时候只允许访问127.0.0.1:6379
port 6379                       #监听端口
tcp-backlog 511                 #TCP连接中已完成队列(完成三次握手之后)的长度
timeout 0                       #客户端和Redis服务器的连接超时时间，默认是0表示永不超时
tcp-keepalive 300               #tcp 会话保持时间
daemonize yes                   #是否以守护进程的方式运行redis，默认为no
supervised systemd              #以何种方式管理redis守护进程，centos7以后使用systemd
pidfile /apps/redis/run/redis_6379.pid     #pid文件路径
loglevel notice                 #日志级别
logfile "/apps/redis/logs/redis_6378.log"  #日志路径
databases 16                    #设置db库数量，默认16个库
always-show-logo yes            #在启动redis时是否显示log

save 900 1                      #在900秒内有1个键内容发生更改就触发快照机制
save 300 10                     #在300秒内有10个键内容发生更改就触发快照机制
save 60 10000
stop-writes-on-bgsave-error no  #快照出错时是否禁止redis写入操作，默认为yes，应设为no
rdbcompression yes              #持久化到RDB文件时是否压缩，yes为压缩
rdbchecksum yes                 #是否开启RC64校验，默认是开启
dbfilename dump_6379.rdb        #快照文件名
dir /apps/redis/data            #快照文件保存路径

replica-serve-stale-data no     #当从库与主库失去连接或者复制正在进行，从库有两种运行方式：1）当为yes（默认）时，从库会继续响应客户端的读请求。2）当为no时，除去一些特殊命令之外，其他请求都会返回一个“SYNC with master in progress”。
replica-read-only yes           #是否设置从库只读
repl-diskless-sync no           #是否生成rdb文件到硬盘给slave共享复制。no为生成，yes为不生成直接通过socket方式依次复制到slave节点。只有网络快而磁盘慢的场景才使用socket方式，否则使用默认的disk方式。
repl-diskless-sync-delay 30     #复制的延迟时间，设置0为关闭。在这段时间连接的slave将共用rdb文件，且复制开始到结束之间，master将不会接受新的slave复制请求。
## repl-ping-replica-period 10   #slave根据master指定的时间进行周期性的PING探测
## repl-timeout 60               #复制链接超时时间，需大于探测时间，否则会经常报超时
repl-disable-tcp-nodelay no     #socket模式下，是否禁用TCP_NODELAY，yes为延迟等待数据合并成一个大包进行发送。no为不延迟直接发送，会使用更多的带宽。
## repl-backlog-size 1mb         #复制缓冲区大小，只有在slave连接之后才分配内存
## repl-backlog-ttl 3600         #达到超时时间，master将清空backlog缓冲区
replica-priority 100            #优先级，当master不可用时，sentinel选择优先级最小的为master，优先级为0表示不会被选举。

## requirepass foobared          #设置redis连接密码
## rename-command CONFIG ""      #重命名一些高危命令

## maxclients 65535              #客户端最大连接数

## maxmemory <bytes>             #最大内存，单位为bytes字节，slave的输出缓冲区不计算在内

appendonly no                   #是否开启AOF日志记录
appendfilename "appendonly.aof" #AOF文件名
appendfsync everysec            #aof持久化策略的配置，no表示不执行fsync，有操作系统保证数据同步到磁盘，always表示每次写入都执行fsync，everysec表示每秒执行一次fsync，可能会导致丢失这1s数据。
no-appendfsync-on-rewrite no    #在aof rewrite期间，是否仍立即同步更新的数据，no表示不暂缓，yes为暂缓，Linux的默认fsync策略是30秒，可能会丢失30秒数据。由于yes性能较好而且会避免出现阻塞因此比较推荐。
auto-aof-rewrite-percentage 100 #触发重写aof log的百分比，，设置为0表示不重写
auto-aof-rewrite-min-size 64mb  #触发aof rewrite的最小文件大小
aof-load-truncated yes          #是否加载由于其他原因导致的末尾异常的AOF文件（kill、断电等）
aof-use-rdb-preamble yes        #redis4.0新增RDB-AOF混合持久化格式，已有数据用RDB记录，新增数据用AOF记录。

lua-time-limit 5000             #lua脚本的最大执行时间，单位为毫秒

## cluster-enabled yes           #是否开启集群模式，默认是单机模式
## cluster-config-file nodes-6379.conf   #由node节点自动生成的集群配置文件
## cluster-node-timeout 15000    #集群中node节点连接超时时间
## cluster-replica-validity-factor 10    #超出此时间将不会被选举为master，不会进行故障转移
## cluster-migration-barrier 1   #至少正常工作的从节点数。
## cluster-require-full-coverage yes     #集群槽位覆盖，槽位不全将不在对外提供服务，no则可以继续使用但会出现数据查询不到的情况（数据丢失）

slowlog-log-slower-than 10000   #以微妙为单位记录慢日志，为负数会禁用慢日志，为0会记录每个命令操作
slowlog-max-len 128             #记录多少条慢日志保存在队列，循环使用队列
```

#### 2.3.2：redis持久化

redis虽然是一个内存级别的缓存程序，即redis是使用内存进行数据缓存的，但是其可以将内存的数据按照一定的策略将数据保存到硬盘上，从而实现数据持久保存的目的，redis支持两种不同方式的数据持久化保存机制，分别是RDB和AOF

##### 2.3.2.1：RDB模式

RDB：基于时间的快照，只保留当前最新的一次快照，特点是执行速度比较快，缺点是可能会丢失从上次快照到当前快照未完成之间的数据。

RDB实现的具体过程Redis从主进程先form出一个子进程，使用写时复制机制，子进程将内存的数据保存为一个临时文件，比如dump_6379.rdb.temp，当数据保存完成之后再将上一次保存的RDB文件替换掉，然后关闭子进程，这样可以保证每一次做RDB快照的时候保存的数据都是完整的，因为直接替换RDB文件的时候可能会出现突然断电等问题而导致RDB文件还没有保存完整就突然关机停止保存而导致数据丢失的情况，可以手动将每次生成的RDB文件进行备份，这样可以最大化保存历史数据。

![redis_09](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_09.png)

RDB模式的优缺点：

优点：

RDB快照保存了某个时间点的数据，可以通过脚本执行bgsave（非阻塞）或者save（阻塞）命令自定义时间点备份，可以保留多个备份，当出现问题可以恢复到不同时间点的版本。

可以最大化IO的性能，因为父进程在保存RDB文件的时候唯一要做的是fork出一个子进程，然后的操作都会由这个子进程操作，父进程无需任何的IO操作

RDB在大量数据比如几个G的数据，恢复的速度比AOF的快

缺点：

不能时时的保存数据，会丢失自上一次执行RDB备份到当前的内存数据

数据量非常大的时候，从父进程fork的时候需要一点时间，可能是毫秒或者秒

##### 2.3.2.2：AOF模式

AOF：按照操作顺序依次将操作添加到指定的日志文件当中，特点是数据安全性相对较高，缺点是即使有些操作是重复的也会全部记录。

AOF和RDB一样使用了写时复制机制，AOF默认为每秒钟fsync一次，即将执行的命令保存到AOF文件当中，这样即使redis服务器发生故障的话顶多也就丢失1秒钟之内的数据，也可以设置不同的fsync策略，或者设置每次执行命令的时候fsync，fsync会在后台执行线程，所以主进程可以继续处理用户的正常请求而不受到写入AOF文件的IO影响

AOF模式优缺点：

AOF的文件大小要大于RDB格式的文件

根据所使用的fsync策略（fsync是同步内存中redis所有已经修改的文件到存储设备），默认是appendfsync everysec即每秒执行一次fsync。

### 2.4：redis数据类型

http://www.redis.cn/topics/data-types.html

```
获取帮助
To get help about Redis commands type:
      "help @<group>" to get a list of commands in <group>
      "help <command>" for help on <command>
      "help <tab>" to get a list of possible help topics
      "quit" to exit

To set redis-cli preferences:
      ":set hints" enable online hints
      ":set nohints" disable online hints
Set your preferences in ~/.redisclirc
```

#### 2.4.1：字符串（string）

字符串是所有编程语言中最常见的和最常用的数据类型，而且也是redis最基本的数据类型之一，而且redis中所有的key的类型都是字符串。

```
help @string
```

```
添加key
127.0.0.1:6379> set key value [expiration EX seconds|PX milliseconds] [NX|XX]
127.0.0.1:6379> mset key value [key value ...]
  EX：设置自动过期时间

127.0.0.1:6379> set name1 tom
OK
127.0.0.1:6379> mset name3 jack name4 rose
OK

获取key
127.0.0.1:6379> get key
127.0.0.1:6379> mget key [key ...]

127.0.0.1:6379> get name1
"tom"
127.0.0.1:6379> mget name3 name4
1) "jack"
2) "rose"

追加数据
127.0.0.1:6379> APPEND key value

127.0.0.1:6379> APPEND name1 jerry
(integer) 8
127.0.0.1:6379> get name1
"tomjerry"

数值递增/递减
127.0.0.1:6379> INCR key
127.0.0.1:6379> DECR key

127.0.0.1:6379> set num1 5
OK
127.0.0.1:6379> INCR num1
(integer) 6
127.0.0.1:6379> INCR num1
(integer) 7
127.0.0.1:6379> DECR num1
(integer) 6
127.0.0.1:6379> DECR num1
(integer) 5

获取字符串key的长度
127.0.0.1:6379> STRLEN key

127.0.0.1:6379> STRLEN name1
(integer) 8

删除key（任何类型的数据）
127.0.0.1:6379> DEL key [key ...]

127.0.0.1:6379> DEL name1 name3 name4 num1
(integer) 4
```

#### 2.4.2：列表（list）

列表是一个双向可读写的管道，其头部是左侧，尾部是右侧，一个列表最多可以包含2^32-1个元素即4294967295个元素。

```
help @list
```

```
向列表左/右侧追加数据
127.0.0.1:6379> LPUSH key value [value ...]
127.0.0.1:6379> RPUSH key value [value ...]

127.0.0.1:6379> LPUSH names tom jerry jack rose
(integer) 4

获取列表长度
127.0.0.1:6379> LLEN key

127.0.0.1:6379> LLEN names
(integer) 4

获取指定范围中的key的值
127.0.0.1:6379> LRANGE key start stop

127.0.0.1:6379> LRANGE names 0 -1
1) "rose"
2) "jack"
3) "jerry"
4) "tom"

获取指定key中指定下标的值
127.0.0.1:6379> LINDEX key index

127.0.0.1:6379> LINDEX names 0
"rose"

左/右侧弹出列表中的一个数值
127.0.0.1:6379> LPOP key
127.0.0.1:6379> RPOP key

127.0.0.1:6379> LPOP names
"rose"
127.0.0.1:6379> RPOP names
"tom"
```

#### 2.4.3：集合（set）

set是String类型的无序集合。集合成员是唯一的，这就意味着集合中不能出现重复的数据。

```
help @set
```

```
添加一个或多个成员到集合中
127.0.0.1:6379> SADD key member [member ...]

127.0.0.1:6379> SADD names tom jerry jack rose
127.0.0.1:6379> SADD members jack rose dongyong xiaoqi

查看集合中的所有成员
127.0.0.1:6379> SMEMBERS names
1) "jack"
2) "rose"
3) "tom"
4) "jerry"
127.0.0.1:6379> SMEMBERS members
1) "jack"
2) "dongyong"
3) "rose"
4) "xiaoqi"

差集
127.0.0.1:6379> SDIFF names members
1) "tom"
2) "jerry"

并集
127.0.0.1:6379> SINTER names members
1) "jack"
2) "rose"

并集
127.0.0.1:6379> SUNION names members
1) "jack"
2) "rose"
3) "tom"
4) "dongyong"
5) "xiaoqi"
6) "jerry"
```

#### 2.4.4：sorted set（有序集合）

Redis有序集合和集合一样也是string类型元素的集合，且不允许重复的成员。相对于集合，有序集合每个成员都会关联一个double类型的分数，redis通过分数来进行排序，且分数值是可以重复的。有序集合通过哈希表实现，故查找复杂度为O(1)。

```
help @sorted_set
```

```
添加一个或多个成员到有序集合中，若成员存在则更新score值
ZADD key [NX|XX] [CH] [INCR] score member [score member ...]

127.0.0.1:6379> ZADD score 60 tom 80 jerry 59 jack 99 rose

按照score值进行排序输出
127.0.0.1:6379> ZREVRANGE key start stop [WITHSCORES]

127.0.0.1:6379> ZREVRANGE score 0 -1 WITHSCORES
1) "rose"
2) "99"
3) "jerry"
4) "80"
5) "tom"
6) "60"
7) "jack"
8) "59"

获取集合个数
127.0.0.1:6379> ZCARD key

127.0.0.1:6379> ZCARD score
(integer) 4

根据索引获取值
127.0.0.1:6379> ZRANGE key start stop [WITHSCORES]

127.0.0.1:6379> ZRANGE score 0 3
1) "jack"
2) "tom"
3) "jerry"
4) "rose"

根据值获取其索引
127.0.0.1:6379> ZRANK key member

127.0.0.1:6379> ZRANK score rose
(integer) 3
```

#### 2.4.5：哈希（hash）

hash是一个string类型的field和value的映射表，hash特别适合用于存储对象，Redis中每个hash可以存储2^32-1键值对（40多亿）。

```
help @hash
```

```
设置hash key
127.0.0.1:6379> HSET key field value

127.0.0.1:6379> HSET couple1 name jack wife rose
(integer) 2

获取hash key字段值
127.0.0.1:6379> HGET key field
127.0.0.1:6379> HMGET key field [field ...]

127.0.0.1:6379> HMGET couple1 name wife
1) "jack"
2) "rose"

获取hash key中的所有字段值
127.0.0.1:6379> HKEYS key

127.0.0.1:6379> HKEYS couple1
1) "name"
2) "wife"

删除hash key的字段值
127.0.0.1:6379> HDEL key field [field ...]

127.0.0.1:6379> HDEL couple1 wife
(integer) 1
```

### 2.5：消息队列

消息队列主要分为两种，分别是生产者消费者模式和发布者订阅者模式，这两种模式Redis都支持。

#### 2.5.1：生产者消费者模式

在生产者 消费(Producer/Consumer)模式下， 上层应用接收到的外部请求后开始处理其当前步骤的操作，在执行完成后将已经完成的操作发送至指定的频道 (channe)当中，并由其下层的应用监听该频道并继续下一步的操作，如果其处理完成后没有下一步的操作就直接返回数据给外部请求，如果还有下一步的操作就再将任务发布到另外一个频道， 由另外一个消费者继续监听和处理。

模式介绍

生产者消费者模式下， 多个消费者同时监听一个队列，但是一个消息只能被最先抢到消息的消费者消费 ，即消息任务是一次性读取和处理 ，此模式在分布业务架构中非常常用，比较常用的软件还有 RabbitMQ、Kafka、RocketMQ、ActiveMQ等

![redis_10](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_10.png)

队列介绍

队列当中的消息由不同的生产者写入也会由不同的消费者取出进行消费处理，但是一个消息一定是只能被取出一次也就是被消费一次。

```
生产者发布消息
127.0.0.1:6379> LPUSH channel1 msg1 msg2 msg3
(integer) 3
127.0.0.1:6379> LPUSH channel1 msg4 msg5
(integer) 5

查看队列所有消息
127.0.0.1:6379> LRANGE channel1 0 -1
1) "msg5"
2) "msg4"
3) "msg3"
4) "msg2"
5) "msg1"

消费者消费消息
127.0.0.1:6379> RPOP channel1  #从管道的右侧消费
"msg1"
127.0.0.1:6379> RPOP channel1
"msg2"
127.0.0.1:6379> RPOP channel1
"msg3"
127.0.0.1:6379> RPOP channel1
"msg4"
127.0.0.1:6379> RPOP channel1
"msg5"
127.0.0.1:6379> RPOP channel1
(nil)
127.0.0.1:6379> 
```

#### 2.5.2：发布者订阅模式：

模式简介：

在发布者订阅模式下，发布者将消息发布到指定的channel里面，凡是监听该channel的消费者都会收到同样的一份消息，这种模式类似于是收音机模式，即凡听某个频道的听众都会收到主持人发布的相同的消息内容。
此模式常用于群聊天、群通知、群公告等场景。

Subscriber：订阅者

Publisher：发布者

Channel：频道

![redis_11](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_11.png)

```
订阅者监听频道
127.0.0.1:6379> SUBSCRIBE channel1       #订阅者订阅指定的频道
Reading messages... (press Ctrl-C to quit)
1) "subscribe"
2) "channel1"
3) (integer) 1

发布者发布消息：
127.0.0.1:6379> PUBLISH channel1 msg1
(integer) 1
127.0.0.1:6379> PUBLISH channel1 msg2
(integer) 1

订阅者收到消息
127.0.0.1:6379> SUBSCRIBE channel1
Reading messages... (press Ctrl-C to quit)
1) "subscribe"
2) "channel1"
3) (integer) 1
1) "message"
2) "channel1"
3) "msg1"
1) "message"
2) "channel1"
3) "msg2"

订阅频道
127.0.0.1:6379> SUBSCRIBE channel [channel ...]

127.0.0.1:6379> SUBSCRIBE channel1 channel2   #订阅多个频道
127.0.0.1:6379> SUBSCRIBE *                   #订阅所有频道
127.0.0.1:6379> SUBSCRIBE channel*            #匹配订阅多个频道
```

### 2.6：redis其他命令

#### 2.6.1：CONFIG

config命令用于查看当前redis配置、以及不重启更改redis配置等。

```
设置最大内存
127.0.0.1:6379> CONFIG SET maxmemory 1073741824
127.0.0.1:6379> CONFIG get maxmemory
1) "maxmemory"
2) "1073741824"

获取当前所有配置
127.0.0.1:6379> CONFIG GET *
  1) "dbfilename"
  2) "dump_6379.rdb"
  ...
```

注：config的修改只对当前生效，需同步修改配置文件

#### 2.6.2：info

```
显示当前节点redis运行状态信息
127.0.0.1:6379> info
## Server
redis_version:5.0.7
redis_git_sha1:00000000
redis_git_dirty:0
redis_build_id:ee4de36db075c08e
redis_mode:standalone
...

仅只显示指定片段信息
127.0.0.1:6379> info memory
## Memory
used_memory:595792
used_memory_human:581.83K
used_memory_rss:5636096
used_memory_rss_human:5.38M
used_memory_peak:596768
used_memory_peak_human:582.78K
...
```

#### 2.6.3：select

```
切换数据库
127.0.0.1:6379> SELECT 1
OK
```

#### 2.6.4：keys

```
查看当前库下的所有key
127.0.0.1:6379[1]> keys *
(empty list or set)
```

#### 2.6.5：BGSAVE

```
手动在后台执行RDB持久化操作
127.0.0.1:6379> BGSAVE
```

#### 2.6.6：DBSIZE

```
返回当前库下的所有key数量
127.0.0.1:6379> DBSIZE
```

#### 2.6.7：FLUSHDB

强制清空当前库中的所有key

#### 2.6.8：FLUSHALL

强制清空当前redis服务器所有数据库中的所有key，即删除所有数据

## 三：redis高可用与集群

虽然Redis可以实现单机的数据持久化，但无论是RDB也好或者AOF也好，都解决不了单点宕机问题，即一旦redis服务器本身出现系统故障、硬件故障等问题后，就会直接造成数据的丢失，因此需要使用另外的技术来解决单点问题。

### 3.1：配置redis主从

主备模式，可以实现Redis数据的跨主机备份

程序端连接到高可用负载的VIP，然后连接到负载服务器设置的Redis后端real server，此模式不需要在程序里面设置Redis服务器的真实IP地址，当后期Redis服务器IP地址发生变更只需要更改redis相应的后端real server即可，可避免更改程序中的IP地址设置。

![redis_12](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_12.png)

#### 3.1.1：slave主要配置

Redis Slave也要开启持久化并设置和master同样的连接密码，因为后期slave会有提升为master的可能，Slave端切换master同步后会丢失之前的所有数据。

一旦某个slave成为一个master的slave，Redis slave服务会清空当前redis服务器上的所有数据并将master的数据导入到自己的内存，但是断开同步关系后不会删除当前已经同步过的数据。

##### 3.1.1.1：命令行配置

当前状态为master，需要转换为slave角色并指向master服务器的IP+PORT+Password

```
准备第二台服务器编译安装redis并启动

127.0.0.1:6379> REPLICAOF 172.16.0.129 6379
OK
127.0.0.1:6379> CONFIG SET masterauth 123456
OK
```

##### 3.1.1.2：同步日志

```
6113:S 08 Mar 2020 23:36:29.559 * Connecting to MASTER 172.16.0.129:6379
6113:S 08 Mar 2020 23:36:29.559 * MASTER <-> REPLICA sync started
6113:S 08 Mar 2020 23:36:29.559 * Non blocking connect for SYNC fired the event.
6113:S 08 Mar 2020 23:36:29.560 * Master replied to PING, replication can continue...
6113:S 08 Mar 2020 23:36:29.561 * Partial resynchronization not possible (no cached master)
6113:S 08 Mar 2020 23:36:29.562 * Full resync from master: 6ed032bb3ad8f9e1754808a233fda60c1c5bf0cb:0
6113:S 08 Mar 2020 23:36:29.580 * MASTER <-> REPLICA sync: receiving 175 bytes from master
6113:S 08 Mar 2020 23:36:29.580 * MASTER <-> REPLICA sync: Flushing old data
6113:S 08 Mar 2020 23:36:29.580 * MASTER <-> REPLICA sync: Loading DB in memory
6113:S 08 Mar 2020 23:36:29.580 * MASTER <-> REPLICA sync: Finished with success
```

##### 3.1.1.3：查看slave状态

```
127.0.0.1:6379> info replication
## Replication
role:slave
master_host:172.16.0.129
master_port:6379
master_link_status:up
master_last_io_seconds_ago:9
master_sync_in_progress:0
slave_repl_offset:42
slave_priority:100
slave_read_only:1
```

##### 3.1.1.4：配置文件方式配置

```
[root@c82 redis-5.0.7]# vim /apps/redis/etc/redis.conf
replicaof 172.16.0.129 6379
masterauth 123456
```

##### 3.1.1.5：重启slave验证：

```
127.0.0.1:6379> info replication
## Replication
role:slave
master_host:172.16.0.129
master_port:6379
master_link_status:up             #重启之后状态必须为up
master_last_io_seconds_ago:9      #最近一次与master通信已经过去多少秒。ping值
master_sync_in_progress:0         #是否正在与master通信，0表示没有
slave_repl_offset:42              #当前同步的偏移量
slave_priority:100                #slave优先级
slave_read_only:1
```

##### 3.1.1.6：验证slave数据：

```
127.0.0.1:6379> keys *
1) "testslave"
```

##### 3.1.1.7：slave状态只读无法写入数据

```
127.0.0.1:6379> set testwrite slave
(error) READONLY You can't write against a read only replica.
```

##### 3.1.1.8：master日志

```
12790:M 08 Mar 2020 23:36:23.855 * Ready to accept connections
12790:M 08 Mar 2020 23:36:24.441 * Replica 172.16.0.130:6379 asks for synchronization
12790:M 08 Mar 2020 23:36:24.441 * Full resync requested by replica 172.16.0.130:6379
12790:M 08 Mar 2020 23:36:24.442 * Starting BGSAVE for SYNC with target: disk
12790:M 08 Mar 2020 23:36:24.442 * Background saving started by pid 12801
12801:C 08 Mar 2020 23:36:24.443 * DB saved on disk
12801:C 08 Mar 2020 23:36:24.443 * RDB: 0 MB of memory used by copy-on-write
12790:M 08 Mar 2020 23:36:24.460 * Background saving terminated with success
12790:M 08 Mar 2020 23:36:24.460 * Synchronization with replica 172.16.0.130:6379 succeeded
```

##### 3.1.1.9：主从复制过程

redis支持主从复制分为全量同步和增量同步，而且从服务器可以在有从服务器。

redis全量复制一般发生在slave初始化阶段。具体步骤如下：

1）从服务器连接主服务器，发送SYNC命令；

2）主服务器接收到SYNC命令后，开始执行BGSAVE命令生成RDB快照文件并使用缓冲区记录此后执行的所有写命令；

3）主服务器BGSAVE执行完成后，想所有从服务器发送RDB文件，并在发送期间继续记录执行的写命令；

4）从服务器收到快照文件后丢弃所有旧数据，载入收到的RDB文件；

5）主服务器RDB文件发送完毕后开始向从服务器发送缓冲区中的写命令；

6）从服务器完成对RDB文件的载入，开始接收命令请求，并执行来自主服务器缓冲区的写命令；

7）后期同步slave先发送自己slave_repl_offset位置，只同步新增加的数据，进行增量同步。

##### 3.1.1.10：slave切换为master

```
127.0.0.1:6379> REPLICAOF no one
OK

127.0.0.1:6379> info replication
## Replication
role:master
connected_slaves:0
```

#### 3.1.2：常见问题汇总

master密码没设置或不对

```
密码没设置
6113:S 08 Mar 2020 23:36:28.548 * Connecting to MASTER 172.16.0.129:6379
6113:S 08 Mar 2020 23:36:28.549 * MASTER <-> REPLICA sync started
6113:S 08 Mar 2020 23:36:28.555 * Non blocking connect for SYNC fired the event.
6113:S 08 Mar 2020 23:36:28.558 * Master replied to PING, replication can continue...
6113:S 08 Mar 2020 23:36:28.560 # Unable to AUTH to MASTER: -ERR Client sent AUTH, but no password is set

密码错误
6234:S 09 Mar 2020 00:39:37.190 * Connecting to MASTER 172.16.0.129:6379
6234:S 09 Mar 2020 00:39:37.191 * MASTER <-> REPLICA sync started
6234:S 09 Mar 2020 00:39:37.191 * Non blocking connect for SYNC fired the event.
6234:S 09 Mar 2020 00:39:37.192 * Master replied to PING, replication can continue...
6234:S 09 Mar 2020 00:39:37.193 # Unable to AUTH to MASTER: -ERR invalid password
```

Redis版本不一致

```
6234:S 09 Mar 2020 00:39:37.193 # Can't handle RDB format version 8
```

### 3.2：redis集群

主从架构无法实现master和slave角色的自动切换，当master出现redis服务异常、主机断电、磁盘损坏等问题导致master无法使用，主从架构无法自动实现故障转移，需手动更改环境配置才能实现slave切换到master，另外也无法横向扩展Redis服务的并行写入性能。主从架构需解决两个核心问题，1、master和slave角色的无缝切换，让业务无感知从而不影响业务使用。2、横向动态扩展Redis服务器，从而实现多台服务器并行写入以实现更高并发的目的。

redis集群实现方式：客户端分片、代理分片、Redis Cluster

#### 3.2.1：Sentinel（哨兵）

Sentinel用于监控redis集群中master主服务器工作的状态，在master主服务器发送故障的时候，可以实现master和slave服务器的切换，保证系统的高可用。

Sentinel（哨兵）是一个分布式系统，多个进程间采用流言协议（gossip protocols）来接收关于master主服务器是否下线的消息，并使用投票协议（Agreement Protocols）来决定是否执行自动故障迁移，以及选择哪个Slave作为新的Master。每个sentinel进行会向其他sentinel、master、slave定时发送消息，以确认对方是否“活”着，如果对指定时间（可配置）内未得到回应，则暂时认为对方已掉线，也就是所谓的“主观认为宕机”，主观是每个成员都具有的独自的而且可能相同也可能不同的意识，英文名称：subjective down，简称SDOWN。当“哨兵群”中的多数sentinel进程在对master主服务器做出SDOWN的判断，并且通过SENTINEL is-master-down-by-addr命令互相交流之后，得出的master server下线判断，这种方式就是“客观宕机”，客观是不依赖于某种意识而已经实际存在的一切事物，英文名称：objectively Down，简称ODOWN。通过一定的vote算法，从剩下的slave从服务器节点中，选一台提示未master服务器节点，然后自动修改相关配置，并开始故障转移（failover）。

sentinel机制可以解决master和slave角色的切换问题。

##### 3.2.1.1：手动配置master

需要手动先指定某一天redis服务器为master，然后将其他slave服务器使用命令配置为master服务器的slave，哨兵的前提是已经手动实现了一个redis master-slave的运行环境。

![redis_13](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_13.png)

主从配置

```
编辑配置文件实现主从配置

主服务器状态
127.0.0.1:6379> info replication
## Replication
role:master
connected_slaves:2
slave0:ip=172.16.0.130,port=6379,state=online,offset=14792,lag=0
slave1:ip=172.16.0.131,port=6379,state=online,offset=14792,lag=0
master_replid:94e68233c676df8ccabdd14940a41759efb15336
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:14792
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:14792

从服务器1状态
127.0.0.1:6379> info replication
## Replication
role:slave
master_host:172.16.0.129
master_port:6379
master_link_status:up
master_last_io_seconds_ago:0
master_sync_in_progress:0
slave_repl_offset:14960
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:94e68233c676df8ccabdd14940a41759efb15336
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:14960
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:14960

从服务器2状态
127.0.0.1:6379> info replication
## Replication
role:slave
master_host:172.16.0.129
master_port:6379
master_link_status:up
master_last_io_seconds_ago:7
master_sync_in_progress:0
slave_repl_offset:15016
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:94e68233c676df8ccabdd14940a41759efb15336
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:15016
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:14653
repl_backlog_histlen:364
```

##### 3.2.1.2：编辑配置文件sentinel.conf

哨兵可以不和redis服务器部署在一起

```
三台哨兵配置文件一样
[root@c81 ~]# vim /apps/redis/etc/sentinel.conf
bind 0.0.0.0
port 26379
daemonize yes
pidfile /apps/redis/run/redis-sentinel.pid
logfile "/apps/redis/logs/sentinel_26379.log"
dir /apps/redis
sentinel monitor mymaster 172.16.0.129 6379 2
sentinel auth-pass mymaster 123456
sentinel down-after-milliseconds mymaster 30000
sentinel parallel-syncs mymaster 1
sentinel failover-timeout mymaster 180000
sentinel deny-scripts-reconfig yes
```

启动哨兵

```
[root@c81 ~]# redis-sentinel /apps/redis/etc/sentinel.conf
[root@c82 ~]# redis-sentinel /apps/redis/etc/sentinel.conf
[root@c83 ~]# redis-sentinel /apps/redis/etc/sentinel.conf
```

哨兵日志

```
9749:X 10 Mar 2020 00:22:23.653 # oO0OoO0OoO0Oo Redis is starting oO0OoO0OoO0Oo
9749:X 10 Mar 2020 00:22:23.653 # Redis version=5.0.7, bits=64, commit=00000000, modified=0, pid=9749, just started
9749:X 10 Mar 2020 00:22:23.653 # Configuration loaded
9750:X 10 Mar 2020 00:22:23.654 * Increased maximum number of open files to 10032 (it was originally set to 1024).
9750:X 10 Mar 2020 00:22:23.655 * Running mode=sentinel, port=26379.
9750:X 10 Mar 2020 00:22:23.656 # Sentinel ID is 2896fd03685ca3c9400b2aaa48dfe996cfa7b7f5
9750:X 10 Mar 2020 00:22:23.656 # +monitor master mymaster 172.16.0.129 6379 quorum 2
9750:X 10 Mar 2020 00:22:23.657 * +slave slave 172.16.0.130:6379 172.16.0.130 6379 @ mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:22:23.658 * +slave slave 172.16.0.131:6379 172.16.0.131 6379 @ mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:22:30.967 * +sentinel sentinel 335a636c38e2a0973f55c9b4b3ab64f0cc9df4e8 172.16.0.130 26379 @ mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:22:33.492 * +sentinel sentinel ac7504cfc4466453fa6a7b9cbdcdcafeaed973d2 172.16.0.131 26379 @ mymaster 172.16.0.129 6379
```

当前sentinel状态

最后一行中涉及的master ip、slave、sentinels必须符合全部服务器的数量。

```
[root@c81 ~]# redis-cli -h 172.16.0.129 -p 26379
172.16.0.129:26379> info sentinel
## Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
sentinel_simulate_failure_flags:0
master0:name=mymaster,status=ok,address=172.16.0.129:6379,slaves=2,sentinels=3
```

停止redis master测试故障转移

```
[root@c81 ~]# systemctl stop redis
查看集群信息
[root@c82 ~]# redis-cli -h 172.16.0.130 -a 123456
172.16.0.130:6379> info replication
## Replication
role:slave
master_host:172.16.0.131
master_port:6379
master_link_status:up
master_last_io_seconds_ago:1
master_sync_in_progress:0
slave_repl_offset:148131
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:c978331a89c52231b84607c0e399c6c463cbda5b
master_replid2:86aa28e7d3c96b8be929481ee82302e609f54aba
master_repl_offset:148131
second_repl_offset:120544
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:148131
```

查看哨兵信息

```
[root@c81 ~]# redis-cli -h 172.16.0.129 -p 26379
172.16.0.129:26379> info sentinel
## Sentinel
sentinel_masters:1
sentinel_tilt:0
sentinel_running_scripts:0
sentinel_scripts_queue_length:0
sentinel_simulate_failure_flags:0
master0:name=mymaster,status=ok,address=172.16.0.131:6379,slaves=2,sentinels=3

注：若哨兵数量不对需删除哨兵配置文件，重新配置。
```

故障转移时sentinel信息：

```
9750:X 10 Mar 2020 00:30:23.349 # +sdown master mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:23.405 # +odown master mymaster 172.16.0.129 6379 #quorum 2/2
9750:X 10 Mar 2020 00:30:23.405 # +new-epoch 1
9750:X 10 Mar 2020 00:30:23.405 # +try-failover master mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:23.406 # +vote-for-leader 2896fd03685ca3c9400b2aaa48dfe996cfa7b7f5 1
9750:X 10 Mar 2020 00:30:23.408 # ac7504cfc4466453fa6a7b9cbdcdcafeaed973d2 voted for 2896fd03685ca3c9400b2aaa48dfe996cfa7b7f5 1
9750:X 10 Mar 2020 00:30:23.409 # 335a636c38e2a0973f55c9b4b3ab64f0cc9df4e8 voted for 2896fd03685ca3c9400b2aaa48dfe996cfa7b7f5 1
9750:X 10 Mar 2020 00:30:23.507 # +elected-leader master mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:23.507 # +failover-state-select-slave master mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:23.563 # +selected-slave slave 172.16.0.131:6379 172.16.0.131 6379 @ mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:23.563 * +failover-state-send-slaveof-noone slave 172.16.0.131:6379 172.16.0.131 6379 @ mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:23.654 * +failover-state-wait-promotion slave 172.16.0.131:6379 172.16.0.131 6379 @ mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:24.615 # +promoted-slave slave 172.16.0.131:6379 172.16.0.131 6379 @ mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:24.615 # +failover-state-reconf-slaves master mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:24.685 * +slave-reconf-sent slave 172.16.0.130:6379 172.16.0.130 6379 @ mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:25.622 # -odown master mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:25.623 * +slave-reconf-inprog slave 172.16.0.130:6379 172.16.0.130 6379 @ mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:25.623 * +slave-reconf-done slave 172.16.0.130:6379 172.16.0.130 6379 @ mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:25.675 # +failover-end master mymaster 172.16.0.129 6379
9750:X 10 Mar 2020 00:30:25.675 # +switch-master mymaster 172.16.0.129 6379 172.16.0.131 6379
9750:X 10 Mar 2020 00:30:25.675 * +slave slave 172.16.0.130:6379 172.16.0.130 6379 @ mymaster 172.16.0.131 6379
9750:X 10 Mar 2020 00:30:25.675 * +slave slave 172.16.0.129:6379 172.16.0.129 6379 @ mymaster 172.16.0.131 6379
9750:X 10 Mar 2020 00:30:55.691 # +sdown slave 172.16.0.129:6379 172.16.0.129 6379 @ mymaster 172.16.0.131 6379
```

故障转移后的手动检查redis配置文件，配置为新的主master，sentinel.conf配置文件无需修改，由sentinel进程自动完成变更。

#### 3.2.2：redis cluster

redis分布式部署方案

1）客户端分区：由客户端程序决定key写分配和写入的redis node，但是需要客户端自己处理写入分配、高可用管理和故障转移等。

2）代理方案：基于第三方软件实现redis proxy，客户端先连接至代理层，有代理层实训key的写入分配，对客户端来说是比较简单，但是对于集群节点增减相对比较麻烦，而且代理本身也是单点和性能瓶颈。

在哨兵sentinel机制中，可以解决redis高可用的问题，即当master故障后可以自动将slave提升为master从而可以保证redis服务的正常使用，但是无法解决redis单机写入的瓶颈问题，即单机的redis写入性能受限于单机的内存大小、并发数量、网卡速率等因素，因此redis官方在redis3.0版本之后推出了无中心架构的redis cluster机制，在无中心的redis集群中，其每个节点保存当前节点数据和整个集群状态，每个节点都和其他节点连接，特点如下：

1：所有redis节点使用（PING机制）互联

2、集群中某个节点失效，是整个集群中超过半数的节点检测都失效才算真正的失效

3、客户端不需要proxy即可直接连接redis，应用程序需要写全部的redis服务器IP。

4、redis cluster把所有的redis node映射到0-16383个槽位（slot）上，读写需要到指定的redis node上进行操作，因此有多少个redis node相当于redis并发扩展了多少倍。

5、redis cluster预先分配16384个（slot）槽位，当需要在redis集群中写入一个key-value的时候，会使用CRC16（key）mod 16384之后的值，决定将key写入至哪一个槽位从而决定写入到哪一个redis节点上，从而有效解决单机瓶颈。

##### 3.2.2.1：redis cluster架构

redis cluster基本架构

假如三个节点分别是：A，B，C三个节点，采用哈希槽（hash slot）的方式来分配16384个是的话，它们三个节点分别承担的slot区间是：

节点A覆盖0-5460

节点B覆盖5461-10922

节点C覆盖10923-16383

!![redis_14](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_14.png)

redis cluster主从架构

redis cluster的架构虽然解决了并发的问题，但是又引入了一个新的问题，每个redis master的高可用如何解决？

![redis_15](http://images.zsjshao.cn/images/linux_basic/33-redis/redis_15.png)

##### 3.2.2.2：部署redis集群

环境准备：

七台服务器，其中一台做预留使用

| 172.16.0.129         | 172.16.0.130 | 172.16.0.131 |
| :------------------- | ------------ | ------------ |
| 172.16.0.132         | 172.16.0.133 | 172.16.0.134 |
| 172.16.0.135（预留） |              |              |

创建redis cluster集群的前提

1、每个redis node节点采用相同的硬件配置、相同的密码

2、每个节点必须开启的参数

  cluster-enable yes #必须开启集群状态，开启后redis进程会有cluster显示

  cluster-config-file nodes-6379.conf  #此文件有redis cluster集群自动创建和维护，不需要任何手动操作

  masterauth 123456  #设置主从同步master的密码，若requirepass为空则此项不必设置。

3、所有redis服务器必须没有任何数据

4、先启动为单机redis且没有任何key value

```
进程带有[cluster]标志，服务器通信端口16379有开启
[root@c81 ~]# ps -ef | grep redis
redis      2148      1  0 13:08 ?        00:00:00 /apps/redis/bin/redis-server 0.0.0.0:6379 [cluster]
root       2153   1446  0 13:08 pts/0    00:00:00 grep --color=auto redis
[root@c81 ~]# ss -tnl
State             Recv-Q              Send-Q                            Local Address:Port                            Peer Address:Port             
LISTEN            0                   128                                     0.0.0.0:22                                   0.0.0.0:*                
LISTEN            0                   511                                     0.0.0.0:16379                                0.0.0.0:*                
LISTEN            0                   511                                     0.0.0.0:6379                                 0.0.0.0:*                
LISTEN            0                   128                                        [::]:22                                      [::]:*  
```

创建集群：

redis 5之前的版本使用redis-trib.rb工具进行集群创建，redis 5直接使用redis-cli --cluster就可以对集群进行相关操作。

```
[root@c81 ~]# redis-cli --cluster help
Cluster Manager Commands:
  create         host1:port1 ... hostN:portN
                 --cluster-replicas <arg>
  check          host:port
                 --cluster-search-multiple-owners
  info           host:port
  fix            host:port
                 --cluster-search-multiple-owners
  reshard        host:port
                 --cluster-from <arg>
                 --cluster-to <arg>
                 --cluster-slots <arg>
                 --cluster-yes
                 --cluster-timeout <arg>
                 --cluster-pipeline <arg>
                 --cluster-replace
  rebalance      host:port
                 --cluster-weight <node1=w1...nodeN=wN>
                 --cluster-use-empty-masters
                 --cluster-timeout <arg>
                 --cluster-simulate
                 --cluster-pipeline <arg>
                 --cluster-threshold <arg>
                 --cluster-replace
  add-node       new_host:new_port existing_host:existing_port
                 --cluster-slave
                 --cluster-master-id <arg>
  del-node       host:port node_id
  call           host:port command arg arg .. arg
  set-timeout    host:port milliseconds
  import         host:port
                 --cluster-from <arg>
                 --cluster-copy
                 --cluster-replace
  help           

For check, fix, reshard, del-node, set-timeout you can specify the host and port of any working node in the cluster.
```

创建redis cluster集群

```
[root@c81 ~]# redis-cli -a 123456 --cluster create 172.16.0.129:6379 172.16.0.130:6379 172.16.0.131:6379 172.16.0.132:6379 172.16.0.133:6379 172.16.
0.134:6379 --cluster-replicas 1Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Performing hash slots allocation on 6 nodes...
Master[0] -> Slots 0 - 5460
Master[1] -> Slots 5461 - 10922
Master[2] -> Slots 10923 - 16383
Adding replica 172.16.0.133:6379 to 172.16.0.129:6379
Adding replica 172.16.0.134:6379 to 172.16.0.130:6379
Adding replica 172.16.0.132:6379 to 172.16.0.131:6379
M: 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6 172.16.0.129:6379
   slots:[0-5460] (5461 slots) master
M: 7340574e749f0778282122949e2e44ed8ddf229f 172.16.0.130:6379
   slots:[5461-10922] (5462 slots) master
M: e10c35aa184c49d0abdc060e21386ab1cbbc496f 172.16.0.131:6379
   slots:[10923-16383] (5461 slots) master
S: f491d147121ee9224e524d506bd82334847bf5c8 172.16.0.132:6379
   replicates e10c35aa184c49d0abdc060e21386ab1cbbc496f
S: 8e1e0329182a016efd8cd725211766761a5e3cac 172.16.0.133:6379
   replicates 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
S: 3a8ffb76ad6b2e9dfa8143d5f178b9437e2455f1 172.16.0.134:6379
   replicates 7340574e749f0778282122949e2e44ed8ddf229f
Can I set the above configuration? (type 'yes' to accept): yes
>>> Nodes configuration updated
>>> Assign a different config epoch to each node
>>> Sending CLUSTER MEET messages to join the cluster
Waiting for the cluster to join
......
>>> Performing Cluster Check (using node 172.16.0.129:6379)
M: 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6 172.16.0.129:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: 3a8ffb76ad6b2e9dfa8143d5f178b9437e2455f1 172.16.0.134:6379
   slots: (0 slots) slave
   replicates 7340574e749f0778282122949e2e44ed8ddf229f
M: e10c35aa184c49d0abdc060e21386ab1cbbc496f 172.16.0.131:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
M: 7340574e749f0778282122949e2e44ed8ddf229f 172.16.0.130:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: f491d147121ee9224e524d506bd82334847bf5c8 172.16.0.132:6379
   slots: (0 slots) slave
   replicates e10c35aa184c49d0abdc060e21386ab1cbbc496f
S: 8e1e0329182a016efd8cd725211766761a5e3cac 172.16.0.133:6379
   slots: (0 slots) slave
   replicates 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

验证master状态

```
127.0.0.1:6379> info replication
## Replication
role:master
connected_slaves:1
slave0:ip=172.16.0.133,port=6379,state=online,offset=70,lag=0
master_replid:84c335af97c81e7ef80a1b8b4daae2dc47fd983b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:70
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:70
127.0.0.1:6379> 
```

验证slave状态

```
127.0.0.1:6379> info replication
## Replication
role:slave
master_host:172.16.0.129
master_port:6379
master_link_status:up
master_last_io_seconds_ago:2
master_sync_in_progress:0
slave_repl_offset:154
slave_priority:100
slave_read_only:1
connected_slaves:0
master_replid:84c335af97c81e7ef80a1b8b4daae2dc47fd983b
master_replid2:0000000000000000000000000000000000000000
master_repl_offset:154
second_repl_offset:-1
repl_backlog_active:1
repl_backlog_size:1048576
repl_backlog_first_byte_offset:1
repl_backlog_histlen:154
127.0.0.1:6379>
```

验证集群状态

```
127.0.0.1:6379> CLUSTER INFO
cluster_state:ok
cluster_slots_assigned:16384
cluster_slots_ok:16384
cluster_slots_pfail:0
cluster_slots_fail:0
cluster_known_nodes:6
cluster_size:3
cluster_current_epoch:6
cluster_my_epoch:1
cluster_stats_messages_ping_sent:485
cluster_stats_messages_pong_sent:493
cluster_stats_messages_sent:978
cluster_stats_messages_ping_received:493
cluster_stats_messages_pong_received:485
cluster_stats_messages_received:978
127.0.0.1:6379> 
```

查看集群node应用关系

```
127.0.0.1:6379> CLUSTER NODES
f491d147121ee9224e524d506bd82334847bf5c8 172.16.0.132:6379@16379 slave e10c35aa184c49d0abdc060e21386ab1cbbc496f 0 1583820534000 4 connected
31d2c6b9f9269e3627c15883dcd26e0c62d47fb6 172.16.0.129:6379@16379 myself,master - 0 1583820532000 1 connected 0-5460
7340574e749f0778282122949e2e44ed8ddf229f 172.16.0.130:6379@16379 master - 0 1583820534280 2 connected 5461-10922
8e1e0329182a016efd8cd725211766761a5e3cac 172.16.0.133:6379@16379 slave 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6 0 1583820535285 5 connected
3a8ffb76ad6b2e9dfa8143d5f178b9437e2455f1 172.16.0.134:6379@16379 slave 7340574e749f0778282122949e2e44ed8ddf229f 0 1583820533000 6 connected
e10c35aa184c49d0abdc060e21386ab1cbbc496f 172.16.0.131:6379@16379 master - 0 1583820534000 3 connected 10923-16383
127.0.0.1:6379> 
```

验证集群写入key

```
172.16.0.129:6379> set name tom        #读写数据取模后落在指定的slot
(error) MOVED 5798 172.16.0.130:6379

172.16.0.130:6379> set name tom        #在指定的slot上方可存入数据
OK
```

集群状态监控

```
[root@c81 ~]# redis-cli -a 123456 --cluster check 172.16.0.129:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
172.16.0.129:6379 (31d2c6b9...) -> 0 keys | 5461 slots | 1 slaves.
172.16.0.130:6379 (7340574e...) -> 1 keys | 5462 slots | 1 slaves.
172.16.0.131:6379 (e10c35aa...) -> 0 keys | 5461 slots | 1 slaves.
[OK] 1 keys in 3 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 172.16.0.129:6379)
M: 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6 172.16.0.129:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
S: f491d147121ee9224e524d506bd82334847bf5c8 172.16.0.132:6379
   slots: (0 slots) slave
   replicates e10c35aa184c49d0abdc060e21386ab1cbbc496f
M: 7340574e749f0778282122949e2e44ed8ddf229f 172.16.0.130:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: 8e1e0329182a016efd8cd725211766761a5e3cac 172.16.0.133:6379
   slots: (0 slots) slave
   replicates 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
S: 3a8ffb76ad6b2e9dfa8143d5f178b9437e2455f1 172.16.0.134:6379
   slots: (0 slots) slave
   replicates 7340574e749f0778282122949e2e44ed8ddf229f
M: e10c35aa184c49d0abdc060e21386ab1cbbc496f 172.16.0.131:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

##### 3.2.2.3：应用程序如何连接redis？

redis官方客户端：https://redis.io/clients

#### 3.2.3：redis cluster集群节点维护

集群运行时间长久之后 ，难免由于硬件故障、 网络规划、业务增长等原因对已有集群进行相应的调整，比如增加Redis node节点 、减少节点 、节点迁移、更换服务器等。
增加节点和删除节点会涉及到已有的槽位重新分配及数据迁移。

##### 3.2.3.1：集群维护之动态添加节点

增加redis node节点，需要与之前的redis node版本相同、配置一致，然后分别启动两台redis node。

添加master节点到集群

```
[root@c81 ~]# redis-cli -a 123456 --cluster add-node 172.16.0.135:6379 172.16.0.129:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Adding node 172.16.0.135:6379 to cluster 172.16.0.129:6379
>>> Performing Cluster Check (using node 172.16.0.129:6379)
M: 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6 172.16.0.129:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: f491d147121ee9224e524d506bd82334847bf5c8 172.16.0.132:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
M: 7340574e749f0778282122949e2e44ed8ddf229f 172.16.0.130:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: 8e1e0329182a016efd8cd725211766761a5e3cac 172.16.0.133:6379
   slots: (0 slots) slave
   replicates 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
S: 3a8ffb76ad6b2e9dfa8143d5f178b9437e2455f1 172.16.0.134:6379
   slots: (0 slots) slave
   replicates 7340574e749f0778282122949e2e44ed8ddf229f
S: e10c35aa184c49d0abdc060e21386ab1cbbc496f 172.16.0.131:6379
   slots: (0 slots) slave
   replicates f491d147121ee9224e524d506bd82334847bf5c8
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
>>> Send CLUSTER MEET to node 172.16.0.135:6379 to make it join the cluster.
[OK] New node added correctly.
```

添加slave节点到集群，需指明master的ID，redis-cli -a 123456 --cluster check 172.16.0.129:6379

```
[root@c81 ~]# redis-cli -a 123456 --cluster add-node 172.16.0.136:6379 172.16.0.129:6379 --cluster-slave --cluster-master-id 2ba7ac48636cd08aa376f28
da15e8d0345b1e32dWarning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Adding node 172.16.0.136:6379 to cluster 172.16.0.129:6379
>>> Performing Cluster Check (using node 172.16.0.129:6379)
M: 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6 172.16.0.129:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: 2ba7ac48636cd08aa376f28da15e8d0345b1e32d 172.16.0.135:6379
   slots: (0 slots) master
M: f491d147121ee9224e524d506bd82334847bf5c8 172.16.0.132:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
M: 7340574e749f0778282122949e2e44ed8ddf229f 172.16.0.130:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: 8e1e0329182a016efd8cd725211766761a5e3cac 172.16.0.133:6379
   slots: (0 slots) slave
   replicates 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
S: 3a8ffb76ad6b2e9dfa8143d5f178b9437e2455f1 172.16.0.134:6379
   slots: (0 slots) slave
   replicates 7340574e749f0778282122949e2e44ed8ddf229f
S: e10c35aa184c49d0abdc060e21386ab1cbbc496f 172.16.0.131:6379
   slots: (0 slots) slave
   replicates f491d147121ee9224e524d506bd82334847bf5c8
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
>>> Send CLUSTER MEET to node 172.16.0.136:6379 to make it join the cluster.
Waiting for the cluster to join

>>> Configure node as replica of 172.16.0.135:6379.
[OK] New node added correctly.
```

重新分配槽位

```
[root@c81 ~]# redis-cli -a 123456 --cluster reshard 172.16.0.135:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Performing Cluster Check (using node 172.16.0.135:6379)
M: 2ba7ac48636cd08aa376f28da15e8d0345b1e32d 172.16.0.135:6379
   slots: (0 slots) master
   1 additional replica(s)
S: 3a8ffb76ad6b2e9dfa8143d5f178b9437e2455f1 172.16.0.134:6379
   slots: (0 slots) slave
   replicates 7340574e749f0778282122949e2e44ed8ddf229f
M: f491d147121ee9224e524d506bd82334847bf5c8 172.16.0.132:6379
   slots:[10923-16383] (5461 slots) master
   1 additional replica(s)
S: 8e1e0329182a016efd8cd725211766761a5e3cac 172.16.0.133:6379
   slots: (0 slots) slave
   replicates 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
M: 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6 172.16.0.129:6379
   slots:[0-5460] (5461 slots) master
   1 additional replica(s)
M: 7340574e749f0778282122949e2e44ed8ddf229f 172.16.0.130:6379
   slots:[5461-10922] (5462 slots) master
   1 additional replica(s)
S: e6b3c51ed0b54383ec5a614bf1157b8a7ba67f9e 172.16.0.136:6379
   slots: (0 slots) slave
   replicates 2ba7ac48636cd08aa376f28da15e8d0345b1e32d
S: e10c35aa184c49d0abdc060e21386ab1cbbc496f 172.16.0.131:6379
   slots: (0 slots) slave
   replicates f491d147121ee9224e524d506bd82334847bf5c8
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
How many slots do you want to move (from 1 to 16384)? 4096
What is the receiving node ID? 2ba7ac48636cd08aa376f28da15e8d0345b1e32d
Please enter all the source node IDs.
  Type 'all' to use all the nodes as source nodes for the hash slots.
  Type 'done' once you entered all the source nodes IDs.
Source node #1: all
    ...
    Moving slot 1360 from 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
    Moving slot 1361 from 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
    Moving slot 1362 from 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
    Moving slot 1363 from 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
    Moving slot 1364 from 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
Do you want to proceed with the proposed reshard plan (yes/no)? yes
```

验证重新分配槽位后的集群状态

```
[root@c81 ~]# redis-cli -a 123456 --cluster info 172.16.0.129:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
172.16.0.129:6379 (31d2c6b9...) -> 0 keys | 4096 slots | 1 slaves.
172.16.0.135:6379 (2ba7ac48...) -> 0 keys | 4096 slots | 1 slaves.
172.16.0.132:6379 (f491d147...) -> 0 keys | 4096 slots | 1 slaves.
172.16.0.130:6379 (7340574e...) -> 0 keys | 4096 slots | 1 slaves.
[OK] 0 keys in 4 masters.
0.00 keys per slot on average.
```

##### 3.2.3.2：集群维护之动态删除节点

删除节点前需要将节点上的所有槽位迁移到其他master节点上，槽位迁移后在从集群移除节点。

**若集群异常则使用fix选项进行修复**

```
[root@c81 ~]# redis-cli -a 123456 --cluster fix 172.16.0.129:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
172.16.0.129:6379 (31d2c6b9...) -> 0 keys | 4096 slots | 1 slaves.
172.16.0.135:6379 (2ba7ac48...) -> 1 keys | 4096 slots | 1 slaves.
172.16.0.132:6379 (f491d147...) -> 0 keys | 4096 slots | 1 slaves.
172.16.0.130:6379 (7340574e...) -> 0 keys | 4096 slots | 1 slaves.
[OK] 1 keys in 4 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 172.16.0.129:6379)
M: 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6 172.16.0.129:6379
   slots:[1365-5460] (4096 slots) master
   1 additional replica(s)
M: 2ba7ac48636cd08aa376f28da15e8d0345b1e32d 172.16.0.135:6379
   slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master
   1 additional replica(s)
M: f491d147121ee9224e524d506bd82334847bf5c8 172.16.0.132:6379
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
M: 7340574e749f0778282122949e2e44ed8ddf229f 172.16.0.130:6379
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
S: 8e1e0329182a016efd8cd725211766761a5e3cac 172.16.0.133:6379
   slots: (0 slots) slave
   replicates 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
S: 3a8ffb76ad6b2e9dfa8143d5f178b9437e2455f1 172.16.0.134:6379
   slots: (0 slots) slave
   replicates 7340574e749f0778282122949e2e44ed8ddf229f
S: e6b3c51ed0b54383ec5a614bf1157b8a7ba67f9e 172.16.0.136:6379
   slots: (0 slots) slave
   replicates 2ba7ac48636cd08aa376f28da15e8d0345b1e32d
S: e10c35aa184c49d0abdc060e21386ab1cbbc496f 172.16.0.131:6379
   slots: (0 slots) slave
   replicates f491d147121ee9224e524d506bd82334847bf5c8
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
[WARNING] Node 172.16.0.130:6379 has slots in importing state 5798.
[WARNING] The following slots are open: 5798.
>>> Fixing open slot 5798
Set as importing in: 172.16.0.130:6379
>>> Case 2: Moving all the 5798 slot keys to its owner 172.16.0.135:6379
Moving slot 5798 from 172.16.0.130:6379 to 172.16.0.135:6379: 
>>> Setting 5798 as STABLE in 172.16.0.130:6379
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

**迁移master的槽位至其他master**

```
[root@c81 ~]# redis-cli -a 123456 --cluster reshard 172.16.0.129:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Performing Cluster Check (using node 172.16.0.129:6379)
M: 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6 172.16.0.129:6379
   slots:[1365-5460] (4096 slots) master
   1 additional replica(s)
M: 2ba7ac48636cd08aa376f28da15e8d0345b1e32d 172.16.0.135:6379
   slots:[0-1364],[5461-6826],[10923-12287] (4096 slots) master
   1 additional replica(s)
M: f491d147121ee9224e524d506bd82334847bf5c8 172.16.0.132:6379
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
M: 7340574e749f0778282122949e2e44ed8ddf229f 172.16.0.130:6379
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
S: 8e1e0329182a016efd8cd725211766761a5e3cac 172.16.0.133:6379
   slots: (0 slots) slave
   replicates 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
S: 3a8ffb76ad6b2e9dfa8143d5f178b9437e2455f1 172.16.0.134:6379
   slots: (0 slots) slave
   replicates 7340574e749f0778282122949e2e44ed8ddf229f
S: e6b3c51ed0b54383ec5a614bf1157b8a7ba67f9e 172.16.0.136:6379
   slots: (0 slots) slave
   replicates 2ba7ac48636cd08aa376f28da15e8d0345b1e32d
S: e10c35aa184c49d0abdc060e21386ab1cbbc496f 172.16.0.131:6379
   slots: (0 slots) slave
   replicates f491d147121ee9224e524d506bd82334847bf5c8
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
How many slots do you want to move (from 1 to 16384)? 4096
What is the receiving node ID? 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
Please enter all the source node IDs.
  Type 'all' to use all the nodes as source nodes for the hash slots.
  Type 'done' once you entered all the source nodes IDs.
Source node #1: 2ba7ac48636cd08aa376f28da15e8d0345b1e32d
Source node #2: done
```

**验证槽位迁移完成**

```
[root@c81 ~]# redis-cli -a 123456 --cluster info 172.16.0.129:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
172.16.0.129:6379 (31d2c6b9...) -> 1 keys | 8192 slots | 2 slaves.
172.16.0.135:6379 (2ba7ac48...) -> 0 keys | 0 slots | 0 slaves.
172.16.0.132:6379 (f491d147...) -> 0 keys | 4096 slots | 1 slaves.
172.16.0.130:6379 (7340574e...) -> 0 keys | 4096 slots | 1 slaves.
[OK] 1 keys in 4 masters.
0.00 keys per slot on average.
```

**从集群删除服务器**

```
[root@c81 ~]# redis-cli -a 123456 --cluster del-node 172.16.0.135:6379 2ba7ac48636cd08aa376f28da15e8d0345b1e32d
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Removing node 2ba7ac48636cd08aa376f28da15e8d0345b1e32d from cluster 172.16.0.135:6379
>>> Sending CLUSTER FORGET messages to the cluster...
>>> SHUTDOWN the node.
```

**验证node是否删除**

```
[root@c81 ~]# redis-cli -a 123456 --cluster info 172.16.0.129:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
172.16.0.129:6379 (31d2c6b9...) -> 1 keys | 8192 slots | 2 slaves.
172.16.0.132:6379 (f491d147...) -> 0 keys | 4096 slots | 1 slaves.
172.16.0.130:6379 (7340574e...) -> 0 keys | 4096 slots | 1 slaves.
[OK] 1 keys in 3 masters.
0.00 keys per slot on average.
```

**重新调整slave**

将172.16.0.136转移为172.16.0.130的slave

```
[root@c88 redis-5.0.7]# redis-cli -h 172.16.0.136
172.16.0.136:6379> auth 123456
OK
172.16.0.136:6379> CLUSTER REPLICATE 7340574e749f0778282122949e2e44ed8ddf229f
OK
```

查看集群状态

```
[root@c81 ~]# redis-cli -a 123456 --cluster check 172.16.0.129:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
172.16.0.129:6379 (31d2c6b9...) -> 1 keys | 8192 slots | 1 slaves.
172.16.0.132:6379 (f491d147...) -> 0 keys | 4096 slots | 1 slaves.
172.16.0.130:6379 (7340574e...) -> 0 keys | 4096 slots | 2 slaves.
[OK] 1 keys in 3 masters.
0.00 keys per slot on average.
>>> Performing Cluster Check (using node 172.16.0.129:6379)
M: 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6 172.16.0.129:6379
   slots:[0-6826],[10923-12287] (8192 slots) master
   1 additional replica(s)
M: f491d147121ee9224e524d506bd82334847bf5c8 172.16.0.132:6379
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
M: 7340574e749f0778282122949e2e44ed8ddf229f 172.16.0.130:6379
   slots:[6827-10922] (4096 slots) master
   2 additional replica(s)
S: 8e1e0329182a016efd8cd725211766761a5e3cac 172.16.0.133:6379
   slots: (0 slots) slave
   replicates 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
S: 3a8ffb76ad6b2e9dfa8143d5f178b9437e2455f1 172.16.0.134:6379
   slots: (0 slots) slave
   replicates 7340574e749f0778282122949e2e44ed8ddf229f
S: e6b3c51ed0b54383ec5a614bf1157b8a7ba67f9e 172.16.0.136:6379
   slots: (0 slots) slave
   replicates 7340574e749f0778282122949e2e44ed8ddf229f
S: e10c35aa184c49d0abdc060e21386ab1cbbc496f 172.16.0.131:6379
   slots: (0 slots) slave
   replicates f491d147121ee9224e524d506bd82334847bf5c8
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
```

**删除slave节点**

slave节点没有槽位可直接删除

```
[root@c81 ~]# redis-cli -a 123456 --cluster del-node 172.16.0.136:6379 e6b3c51ed0b54383ec5a614bf1157b8a7ba67f9e
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
>>> Removing node e6b3c51ed0b54383ec5a614bf1157b8a7ba67f9e from cluster 172.16.0.136:6379
>>> Sending CLUSTER FORGET messages to the cluster...
>>> SHUTDOWN the node.

[root@c81 ~]# redis-cli -a 123456 --cluster info 172.16.0.129:6379
Warning: Using a password with '-a' or '-u' option on the command line interface may not be safe.
172.16.0.129:6379 (31d2c6b9...) -> 1 keys | 8192 slots | 1 slaves.
172.16.0.132:6379 (f491d147...) -> 0 keys | 4096 slots | 1 slaves.
172.16.0.130:6379 (7340574e...) -> 0 keys | 4096 slots | 1 slaves.
[OK] 1 keys in 3 masters.
0.00 keys per slot on average.
```

##### 3.2.3.3：集群维护之导入其他redis数据

**导入数据需要redis cluster关闭认证**

```
[root@c81 ~]# redis-cli
127.0.0.1:6379> CONFIG set requirepass ''
(error) NOAUTH Authentication required.
127.0.0.1:6379> auth 123456
OK
127.0.0.1:6379> CONFIG set requirepass ''
OK
```

**导入数据**

```
[root@c81 ~]# redis-cli  --cluster import 172.16.0.130:6379 --cluster-from 172.16.0.135:6379 --cluster-copy --cluster-replace
>>> Importing data from 172.16.0.135:6379 to cluster 172.16.0.130:6379
>>> Performing Cluster Check (using node 172.16.0.130:6379)
M: 7340574e749f0778282122949e2e44ed8ddf229f 172.16.0.130:6379
   slots:[6827-10922] (4096 slots) master
   1 additional replica(s)
S: 3a8ffb76ad6b2e9dfa8143d5f178b9437e2455f1 172.16.0.134:6379
   slots: (0 slots) slave
   replicates 7340574e749f0778282122949e2e44ed8ddf229f
S: 8e1e0329182a016efd8cd725211766761a5e3cac 172.16.0.133:6379
   slots: (0 slots) slave
   replicates 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6
M: f491d147121ee9224e524d506bd82334847bf5c8 172.16.0.132:6379
   slots:[12288-16383] (4096 slots) master
   1 additional replica(s)
M: 31d2c6b9f9269e3627c15883dcd26e0c62d47fb6 172.16.0.129:6379
   slots:[0-6826],[10923-12287] (8192 slots) master
   1 additional replica(s)
S: e10c35aa184c49d0abdc060e21386ab1cbbc496f 172.16.0.131:6379
   slots: (0 slots) slave
   replicates f491d147121ee9224e524d506bd82334847bf5c8
[OK] All nodes agree about slots configuration.
>>> Check for open slots...
>>> Check slots coverage...
[OK] All 16384 slots covered.
*** Importing 5 keys from DB 0
Migrating name to 172.16.0.129:6379: OK
Migrating name1 to 172.16.0.132:6379: OK
Migrating name2 to 172.16.0.129:6379: OK
Migrating name4 to 172.16.0.130:6379: OK
Migrating name3 to 172.16.0.129:6379: OK
```

注：若redis cluster存在相同key的数据则会被覆盖。

**查看导入的数据**

```
[root@c81 ~]# redis-cli 
127.0.0.1:6379> KEYS *
1) "name3"
2) "name2"
3) "name"
127.0.0.1:6379> get name
"zsjshao"
```

#### 3.2.4：redis扩展集群方案

除了redis官方自带的Redis cluster集群之外，还有一些开源的集群解决方案可供参考使用

codis

  github：https://github.com/CodisLabs/codis/blob/release3.2/doc/tutorial_zh.md

twemproxy

  github：https://github.com/twitter/twemproxy

