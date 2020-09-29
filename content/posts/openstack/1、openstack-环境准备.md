+++
author = "zsjshao"
title = "openstack-环境准备"
date = "2020-04-26"
tags = ["openstack"]
categories = ["openstack"]
+++

## 初始环境

<!-- more -->

### 设备命名、角色及地址

| 名称        | 操作系统   | IP地址                                                       | 角色                                                |
| ----------- | ---------- | ------------------------------------------------------------ | --------------------------------------------------- |
| controller1 | CentOS 7.2 | 192.168.3.71<br />192.168.101.71                             | 控制节点                                            |
| controller2 | CentOS 7.2 | 192.168.3.72<br />192.168.101.72                             | 控制节点                                            |
| compute1    | CentOS 7.2 | 192.168.3.73<br />192.168.101.73                             | 计算节点                                            |
| compute2    | CentOS 7.2 | 192.168.3.74<br />192.168.101.74                             | 计算节点                                            |
| mariadb1    | CentOS 7.2 | 192.168.3.75<br />192.168.101.75                             | mariadb master、rabbitmq cluster、memcached cluster |
| mariadb2    | CentOS 7.2 | 192.168.3.76<br />192.168.101.76                             | mariadb slave、rabbitmq cluster、memcached cluster  |
| haproxy1    | CentOS 8.1 | 192.168.3.81<br />192.168.101.81<br />vip:192.168.3.200<br />vip:192.168.101.200 | keepalived、haproxy                                 |
| haproxy2    | CentOS 8.1 | 192.168.3.81<br />192.168.101.81<br />vip:192.168.3.200<br />vip:192.168.101.200 | keepalived、haproxy                                 |

### mariadb主/从

```
mariadb主
[root@mariadb1 ~]# yum install centos-release-openstack-queens -y

[root@mariadb1 ~]# yum install mariadb-server -y
[root@mariadb1 ~]# vim /etc/my.cnf.d/openstack.cnf
...
[mysqld]
bind-address = 192.168.101.75

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8

log_bin=mysql-bin
server_id=1
skip_name_resolve=ON

[root@mariadb1 ~]# systemctl start mariadb
[root@mariadb1 ~]# systemctl enable mariadb
[root@mariadb1 ~]# mysql -e 'GRANT REPLICATION SLAVE ON *.* TO "repluser"@"192.168.101.76" IDENTIFIED BY "replpass";'

mariadb从
[root@mariadb2 ~]# yum install centos-release-openstack-queens -y

[root@mariadb2 ~]# yum install mariadb-server -y
[root@mariadb2 ~]# vim /etc/my.cnf.d/openstack.cnf
...
[mysqld]
bind-address = 192.168.101.76

default-storage-engine = innodb
innodb_file_per_table = on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8

server_id=2
read_only=ON
skip_name_resolve=ON

[root@mariadb2 ~]# systemctl start mariadb
[root@mariadb2 ~]# systemctl enable mariadb
[root@mariadb2 ~]# mysql -e 'change master to master_host="192.168.101.75",master_user="repluser",master_password="replpass",master_log_file="mysql-bin.000001",master_log_pos=512'
[root@mariadb2 ~]# mysql -e 'start slave'
```

### rabbitmq集群

```
[root@mariadb2 ~]# yum install rabbitmq-server -y
[root@mariadb2 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.101.75	mariadb1
192.168.101.76	mariadb2
[root@mariadb2 ~]# systemctl start rabbitmq-server
[root@mariadb2 ~]# systemctl enable rabbitmq-server
[root@mariadb2 ~]# rabbitmq-plugins enable rabbitmq_management
[root@mariadb2 ~]# rabbitmqctl cluster_status

[root@mariadb1 ~]# yum install rabbitmq-server -y
[root@mariadb1 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.101.75	mariadb1
192.168.101.76	mariadb2
[root@mariadb1 ~]# systemctl start rabbitmq-server
[root@mariadb1 ~]# systemctl enable rabbitmq-server
[root@mariadb1 ~]# rabbitmq-plugins enable rabbitmq_management
[root@mariadb1 ~]# scp /var/lib/rabbitmq/.erlang.cookie 192.168.3.76:/var/lib/rabbitmq/
[root@mariadb1 ~]# rabbitmqctl stop_app
[root@mariadb1 ~]# rabbitmqctl reset
[root@mariadb1 ~]# rabbitmqctl join_cluster rabbit@mariadb2 --ram
[root@mariadb1 ~]# rabbitmqctl start_app
[root@mariadb1 ~]# rabbitmqctl cluster_status
[root@mariadb1 ~]# rabbitmqctl set_policy  ha-all "#"  '{"ha-mode":"all"}'

[root@mariadb1 ~]# rabbitmqctl add_user openstack openstack
[root@mariadb1 ~]# rabbitmqctl set_permissions openstack ".*" ".*" ".*"
```

### memcached集群

```
[root@mariadb1 ~]# yum install memcached libevent libevent-devel -y
[root@mariadb1 src]# wget https://sourceforge.net/projects/repcached/files/repcached/2.2.1-1.2.8/memcached-1.2.8-repcached-2.2.1.tar.gz
[root@mariadb1 src]# tar xf memcached-1.2.8-repcached-2.2.1.tar.gz 
[root@mariadb1 src]# cd memcached-1.2.8-repcached-2.2.1/
[root@mariadb1 memcached-1.2.8-repcached-2.2.1]# ./configure --prefix=/usr/local/repached --enable-replication
[root@mariadb1 memcached-1.2.8-repcached-2.2.1]# vim memcached.c
修改前
/* FreeBSD 4.x doesn't have IOV_MAX exposed. */
#ifndef IOV_MAX
#if defined(__FreeBSD__) || defined(__APPLE__)
# define IOV_MAX 1024
#endif
#endif

修改后
/* FreeBSD 4.x doesn't have IOV_MAX exposed. */
#ifndef IOV_MAX
# define IOV_MAX 1024
#endif
[root@mariadb1 memcached-1.2.8-repcached-2.2.1]# make && make install
[root@mariadb1 ~]# /usr/local/repached/bin/memcached -d -m 2048 -p 11211 -u root -c 2048 -x 192.168.101.76
[root@mariadb1 ~]# vim /etc/rc.d/rc.local
...
/usr/local/repached/bin/memcached -d -m 2048 -p 11211 -u root -c 2048 -x 192.168.101.76

[root@mariadb1 ~]# chmod +x /etc/rc.d/rc.local

[root@mariadb1 ~]# scp /usr/local/src/memcached-1.2.8-repcached-2.2.1.tar.gz 192.168.101.76:/usr/local/src


[root@mariadb2 src]# tar xf memcached-1.2.8-repcached-2.2.1.tar.gz 
[root@mariadb2 src]# cd memcached-1.2.8-repcached-2.2.1/
[root@mariadb2 memcached-1.2.8-repcached-2.2.1]# ./configure --prefix=/usr/local/repached --enable-replication
[root@mariadb2 memcached-1.2.8-repcached-2.2.1]# vim memcached.c 
修改前
/* FreeBSD 4.x doesn't have IOV_MAX exposed. */
#ifndef IOV_MAX
#if defined(__FreeBSD__) || defined(__APPLE__)
# define IOV_MAX 1024
#endif
#endif

修改后
/* FreeBSD 4.x doesn't have IOV_MAX exposed. */
#ifndef IOV_MAX
# define IOV_MAX 1024
#endif

[root@mariadb2 memcached-1.2.8-repcached-2.2.1]# make && make install
[root@mariadb2 memcached-1.2.8-repcached-2.2.1]# /usr/local/repached/bin/memcached -d -m 2048 -p 11211 -u root -c 2048 -x 192.168.101.75

[root@mariadb1 ~]# vim /etc/rc.d/rc.local
...
/usr/local/repached/bin/memcached -d -m 2048 -p 11211 -u root -c 2048 -x 192.168.101.76

[root@mariadb1 ~]# chmod +x /etc/rc.d/rc.local
```

### 时间同步

```
控制节点
[root@controller1 ~]# yum install chrony -y
[root@controller1 ~]# vim /etc/chrony.conf
...
allow 192.168.3.0/24
allow 192.168.101.0/24


[root@controller1 ~]# systemctl start chronyd
[root@controller1 ~]# systemctl enable chronyd

其他节点
[root@controller2 ~]# yum install chrony -y
[root@controller2 ~]# vim /etc/chrony.conf
...
server 192.168.101.71 iburst

[root@controller2 ~]# systemctl start chronyd
[root@controller2 ~]# systemctl enable chronyd

```

### keepalived

```
[root@haproxy1 ~]# dnf install keepalived -y
[root@haproxy1 ~]# cat /etc/keepalived/keepalived.conf
! Configuration File for keepalived

global_defs {
   notification_email {
     root@zsjshao.net
   }
   notification_email_from keepalived@zsjshao.net
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id c81
   vrrp_skip_check_adv_addr
   vrrp_strict
   vrrp_iptables
   vrrp_garp_interval 0
   vrrp_gna_interval 0
}

vrrp_instance VI_1 {
    state MASTER
    interface br1
    virtual_router_id 51
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.101.200 dev br1 label br1:0
    }
}
vrrp_instance VI_2 {
    state BACKUP
    interface br2
    virtual_router_id 52
    priority 80
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.3.200 dev br2 label br2:0
    }
}
[root@haproxy1 ~]# systemctl start keepalived
[root@haproxy1 ~]# systemctl enable keepalived



[root@haproxy2 ~]# dnf install keepalived -y
[root@haproxy2 ~]# cat /etc/keepalived/keepalived.conf 
! Configuration File for keepalived

global_defs {
   notification_email {
     root@zsjshao.net
   }
   notification_email_from keepalived@zsjshao.net
   smtp_server 127.0.0.1
   smtp_connect_timeout 30
   router_id c82
   vrrp_skip_check_adv_addr
   vrrp_strict
   vrrp_iptables
   vrrp_garp_interval 0
   vrrp_gna_interval 0
}

vrrp_instance VI_1 {
    state BACKUP
    interface br1
    virtual_router_id 51
    priority 80
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.101.200 dev br1 label br1:0
    }
}
vrrp_instance VI_2 {
    state MASTER
    interface br2
    virtual_router_id 52
    priority 100
    advert_int 1
    authentication {
        auth_type PASS
        auth_pass 123456
    }
    virtual_ipaddress {
        192.168.3.200 dev br2 label br2:0
    }
}
[root@haproxy2 ~]# systemctl start keepalived
[root@haproxy2 ~]# systemctl enable keepalived
```

### haproxy

```
[root@c81 ~]# dnf install haproxy 
[root@haproxy1 ~]# cat /etc/haproxy/haproxy.cfg 
global
    maxconn 100000
#   chroot /usr/local/haproxy
    #stats socket /var/lib/haproxy/haproxy.sock mode 600 level admin
    uid 995
    gid 992
    daemon
    nbproc 4
    cpu-map 1 0
    cpu-map 2 1
    cpu-map 3 2
    cpu-map 4 3
    pidfile /var/run/haproxy.pid
    log 127.0.0.1 local3 info

defaults
    option http-keep-alive
    option  forwardfor
    maxconn 100000
    mode http
    timeout connect 300000ms
    timeout client  300000ms
    timeout server  300000ms

listen stats
    bind :9999
    stats enable
    stats hide-version
    stats uri /haproxy-status
    stats realm HAPorxy\Stats\Page
    stats auth haadmin:123456
    stats refresh 30s
    stats admin if TRUE

listen  dashboard_ex_80
    bind 192.168.3.200:80
    mode tcp
    server web1  192.168.3.71:80  check inter 3000 fall 2 rise 5
    server web2  192.168.3.72:80  check inter 3000 fall 2 rise 5

listen  dashboard_in_80
    bind 192.168.101.200:80
    mode tcp
    server web1  192.168.101.71:80  check inter 3000 fall 2 rise 5
    server web2  192.168.101.72:80  check inter 3000 fall 2 rise 5

listen  mariadb_3306
    bind 192.168.101.200:3306
    mode tcp
    server mariadb1  192.168.101.75:3306  check inter 3000 fall 2 rise 5
    server mariadb2  192.168.101.76:3306  check inter 3000 fall 2 rise 5 backup

listen  rabbitmq_5672
    bind 192.168.101.200:5672
    mode tcp
    balance source
    server rabbitmq1  192.168.101.75:5672  check inter 3000 fall 2 rise 5
    server rabbitmq2  192.168.101.76:5672  check inter 3000 fall 2 rise 5

listen  rabbitmq_web_15672
    bind 192.168.3.200:15672
    mode tcp
    balance source
    server rabbitmq1  192.168.3.75:15672  check inter 3000 fall 2 rise 5
    server rabbitmq2  192.168.3.76:15672  check inter 3000 fall 2 rise 5

listen  memcached_11211
    bind 192.168.101.200:11211
    mode tcp
    balance source
    server memcached1  192.168.101.75:11211  check inter 3000 fall 2 rise 5
    server memcached2  192.168.101.76:11211  check inter 3000 fall 2 rise 5

listen keystone_5000
    bind 192.168.101.200:5000
    mode tcp
    server controller1 192.168.101.71:5000 check inter 3000 fall 2 rise 5
    server controller2 192.168.101.72:5000 check inter 3000 fall 2 rise 5

listen keystone_35357
    bind 192.168.101.200:35357
    mode tcp
    server controller1 192.168.101.71:35357 check inter 3000 fall 2 rise 5
    server controller2 192.168.101.72:35357 check inter 3000 fall 2 rise 5

listen glance_9292
    bind 192.168.101.200:9292
    mode tcp
    server controller1 192.168.101.71:9292 check inter 3000 fall 2 rise 5
    server controller2 192.168.101.72:9292 check inter 3000 fall 2 rise 5

listen nova_8774
    bind 192.168.101.200:8774
    mode tcp
    server nova1 192.168.101.71:8774 check inter 3000 fall 2 rise 5
    server nova2 192.168.101.72:8774 check inter 3000 fall 2 rise 5

listen metadata_8775
    bind 192.168.101.200:8775
    mode tcp
    server metadata1 192.168.101.71:8775 check inter 3000 fall 2 rise 5
    server metadata2 192.168.101.72:8775 check inter 3000 fall 2 rise 5

listen placement_8778
    bind 192.168.101.200:8778
    mode tcp
    server placement1 192.168.101.71:8778 check inter 3000 fall 2 rise 5
    server placement2 192.168.101.72:8778 check inter 3000 fall 2 rise 5

listen nova_vnc_6080
    bind 192.168.101.200:6080
    mode tcp
    server nova_vnc1 192.168.101.71:6080 check inter 3000 fall 2 rise 5
    server nova_vnc2 192.168.101.72:6080 check inter 3000 fall 2 rise 5

listen neutron_9696
    bind 192.168.101.200:9696
    mode tcp
    server neutron1 192.168.101.71:9696 check inter 3000 fall 2 rise 5
    server neutron2 192.168.101.72:9696 check inter 3000 fall 2 rise 5

[root@c81 ~]# systemctl start haproxy
[root@c81 ~]# systemctl enable haproxy
```

### etcd

```
[root@controller1 ~]# yum install etcd -y
[root@controller1 ~]# grep -v ^# /etc/etcd/etcd.conf 
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://192.168.101.71:2380,http://127.0.0.1:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.101.71:2379,http://127.0.0.1:2379"
ETCD_NAME="controller1"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.101.71:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.101.71:2379"
ETCD_INITIAL_CLUSTER="controller1=http://192.168.101.71:2380,controller2=http://192.168.101.72:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="new"
[root@controller1 ~]# systemctl start etcd
[root@controller1 ~]# systemctl enable etcd

[root@controller2 ~]# yum install etcd -y
[root@controller2 ~]# grep -v ^# /etc/etcd/etcd.conf
ETCD_DATA_DIR="/var/lib/etcd/default.etcd"
ETCD_LISTEN_PEER_URLS="http://192.168.101.72:2380,http://127.0.0.1:2380"
ETCD_LISTEN_CLIENT_URLS="http://192.168.101.72:2379,http://127.0.0.1:2379"
ETCD_NAME="controller2"
ETCD_INITIAL_ADVERTISE_PEER_URLS="http://192.168.101.72:2380"
ETCD_ADVERTISE_CLIENT_URLS="http://192.168.101.72:2379"
ETCD_INITIAL_CLUSTER="controller1=http://192.168.101.71:2380,controller2=http://192.168.101.72:2380"
ETCD_INITIAL_CLUSTER_TOKEN="etcd-cluster"
ETCD_INITIAL_CLUSTER_STATE="existing"
[root@controller2 ~]# systemctl start etcd
[root@controller2 ~]# systemctl enable etcd

[root@controller1 ~]# etcdctl member list
436615ac15609671: name=controller2 peerURLs=http://192.168.101.72:2380 clientURLs=http://192.168.101.72:2379 isLeader=true
74492978ad38fdfd: name=controller1 peerURLs=http://192.168.101.71:2380 clientURLs=http://192.168.101.71:2379 isLeader=false
```

### 各节点添加yum源，安装OpenStack客户端

```
[root@controller1 ~]# yum install centos-release-openstack-queens -y
[root@controller1 ~]# yum install python-openstackclient python-memcached -y

若启用SELinux，需安装openstack-selinux软件包以自动管理openstack服务的安全策略
# yum install openstack-selinux -y
```
