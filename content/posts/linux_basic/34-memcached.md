+++
author = "zsjshao"
title = "34_memcached"
date = "2020-05-01"
tags = ["linux_basic"]
categories = ["linux_basic"]

+++

## 1、memcached

官网：http://memcached.org/

memcache本身没有像redis所具备的数据持久化功能，比如RDB和AOF都没有，但是可以通过做集群同步的方式，让各memcache服务器的数据进行同步，从而实现数据的持久性，即使有任何一台或多台memcache发送故障，只要集群中有一台memcache可用就不会出现数据丢失，当其他memcache重新加入到集群的时候可以自动从有数据的memcache当中自动获取数据并提供服务。

memcache借助了操作系统的libevent工具做高效的读写。libevent是个程序库，它将Linux的epoll、BSD类操作系统的kqueue等事件处理功能封装成统一的接口。即使对服务器的连接数增加，也能发挥高性能。memcached使用这个libevent库，因此能在Linux、BSD、Solaris等操作系统上发挥其高性能。

Memcache支持最大的内存存储对象为1M，超过1M的数据可以使用客户端压缩或拆分到各个key中，比较大的数据在进行读取的时候需要消耗的时间比较长，memcache最适合保存用户的session实现session共享，Memcached存储数据时，memcached会去申请1MB的内存，把该块内存称为一个slab，也称为一个page。

memcached具有多种语言的客户端开发包，包括：Perl/PHP/JAVA/C/Python/Ruby/C#。

## 2、单机部署

### 2.1、yum安装与启动

通过yum安装是相对简单的安装方式

```
#!/bin/bash
yum install memcached -y
cat > /etc/sysconfig/memcached <<EOF
PORT="11211"
USER="memcached"
MAXCONN="1024"
CACHESIZE="1024"
OPTIONS="-l 127.0.0.1,::1"
EOF
systemctl start memcached
ss -tnl
#State             Recv-Q              Send-Q                            Local Address:Port                            Peer Address:Port             
#LISTEN            0                   128                                     0.0.0.0:22                                   0.0.0.0:*                
#LISTEN            0                   512                                   127.0.0.1:11211                                0.0.0.0:*                
#LISTEN            0                   128                                        [::]:22                                      [::]:*                
#LISTEN            0                   512                                       [::1]:11211                                   [::]:*                
```

使用telnet连接memcache

```
telnet 127.0.0.1 11211
stats

add KEYNAME FLAG TIME SIZE
add mykey 1 60 4
test

get mykey
```

python操作memcache

```
#!/usr/bin/env python
#coding:utf-8 
import memcache 
mc = memcache.Client(['192.168.101.76:11211'], debug=True) 
for i in range(100): 
  mc.set("key%d" % i,"v%d" % i) 
  ret = mc.get('key%d' % i) 
  print ret

#!/usr/bin/env python
#coding:utf-8 
import memcache 
mc = memcache.Client(['192.168.101.76:11211'], debug=True) 

stats = mc.get_stats()[0]
print(stats)
for k,v in stats[1].items():
  print(k,v)

print('-' * 30)

print(mc.get_stats('items'))
print('-' * 30)
print(mc.get_stats('cachedump 5 0'))

```

### 2.2：编译安装

```
yum install libevent libevent-devel -y
tar xf memcached-1.6.2.tar.gz -C /usr/local/
cd /usr/local/memcached-1.6.2/
./configure --prefix=/usr/local/memcache
make && make install
/usr/local/memcache/bin/memcached -u memcached -p 11211 -m 2048 -c 65536 &
```

## 3、集群部署

### 3.1、Repcached实现原理

在master上可以通过-X指定replication port，在slave上通过-x/-X找到master并connect上去，如果同时指定了-x/-X，repcached会尝试连接master，但如果连接失败，自身将成为master使用-X参数来监听端口。

### 3.2、部署repcached

```
#!/bin/bash
SLAVE_NODE_IP=192.168.101.76

rpm -q libevent &>/dev/null || yum install libevent libevent-devel -y
[ -f memcached-1.2.8-repcached-2.2.1.tar.gz ] || wget http://files.zsjshao.net/pkg/memcached-1.2.8-repcached-2.2.1.tar.gz
if [ ! -f memcached-1.2.8-repcached-2.2.1.tar.gz ] ; then
  echo "file does not exist"
  exit 1
fi
if [ ! -f /usr/local/repached/bin/memcached ] ; then
\rm -rf /usr/local/memcached-1.2.8-repcached-2.2.1
tar xf memcached-1.2.8-repcached-2.2.1.tar.gz -C /usr/local/
cd /usr/local/memcached-1.2.8-repcached-2.2.1/
./configure --prefix=/usr/local/repached --enable-replication
sed -i "59d" memcached.c
sed -i "57d" memcached.c
#vim memcached.c
#修改前
#/* FreeBSD 4.x doesn't have IOV_MAX exposed. */
#ifndef IOV_MAX
#if defined(__FreeBSD__) || defined(__APPLE__)
# define IOV_MAX 1024
#endif
#endif

#修改后
#/* FreeBSD 4.x doesn't have IOV_MAX exposed. */
#ifndef IOV_MAX
# define IOV_MAX 1024
#endif
make && make install
fi

if [ -f /usr/local/repached/bin/memcached ] ; then
/usr/local/repached/bin/memcached -d -m 2048 -p 11211 -u root -c 2048 -x $SLAVE_NODE_IP -X 11212
grep '/usr/local/repached/bin/memcached' /etc/rc.d/rc.local || echo "/usr/local/repached/bin/memcached -d -m 2048 -p 11211 -u root -c 2048 -x $SLAVE_NODE_IP -X 11212" >> /etc/rc.d/rc.local
chmod +x /etc/rc.d/rc.local
fi
```

