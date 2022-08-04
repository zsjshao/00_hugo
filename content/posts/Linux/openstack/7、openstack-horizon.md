+++
author = "zsjshao"
title = "openstack-horizon"
date = "2020-04-20"
tags = ["openstack"]
categories = ["openstack"]
+++

## horizon

### 1、什么是dashboard

Dashboard(horizon)是一个web接口，使得云平台管理员以及用户可以管理不同的Openstack资源以及服务。
Dashboard 特点：
1)	提供一个web界面操作Openstack的系统。
2)	使用Django框架基于Openstack API开发（开发就是更换下模板）
3)	支持将Session 存储在DB、Memcached
4)	支持集群

<!-- more -->

### 2、安装dashboard

#### controller1的配置

安装dashboard软件包

```
[root@controller1 ~]# yum install openstack-dashboard -y
```

编辑/etc/openstack-dashboard/local_settings配置文件，修改如下内容

```
[root@controller1 ~]# vim /etc/openstack-dashboard/local_settings
OPENSTACK_HOST = "192.168.3.71"
ALLOWED_HOSTS = ['*']
SESSION_ENGINE = 'django.contrib.sessions.backends.cache'

CACHES = {
    'default': {
        'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
        'LOCATION': 'openstack-vip.zsjshao.net:11211',
    },
}

#CACHES = {
#    'default': {
#        'BACKEND': 'django.core.cache.backends.locmem.LocMemCache',
#    },
#}

OPENSTACK_KEYSTONE_URL = "http://%s:5000/v3" % OPENSTACK_HOST
OPENSTACK_KEYSTONE_MULTIDOMAIN_SUPPORT = True

OPENSTACK_API_VERSIONS = {
    "identity": 3,
    "image": 2,
    "volume": 2,
}

OPENSTACK_KEYSTONE_DEFAULT_DOMAIN = "Default"
OPENSTACK_KEYSTONE_DEFAULT_ROLE = "user"

OPENSTACK_NEUTRON_NETWORK = {
    ...
    'enable_router': False,
    'enable_quotas': False,
    'enable_distributed_router': False,
    'enable_ha_router': False,
    'enable_lb': False,
    'enable_firewall': False,
    'enable_vpn': False,
    'enable_fip_topology_check': False,
}

TIME_ZONE = "Asia/Shanghai"
```

编辑/etc/httpd/conf.d/openstack-dashboard.conf配置文件，添加如下内容

```
[root@controller1 ~]# vim /etc/httpd/conf.d/openstack-dashboard.conf
WSGIApplicationGroup %{GLOBAL}
...
```

重启服务

```
[root@controller1 ~]# systemctl restart httpd.service memcached.service
```

#### controller2的配置

```
安装软件包
[root@controller2 ~]# yum install openstack-dashboard -y

拷贝配置文件
[root@controller2 ~]# rsync -avlogp 192.168.3.71:/etc/openstack-dashboard/local_settings /etc/openstack-dashboard/
[root@controller2 ~]# rsync -avlogp 192.168.3.71:/etc/httpd/conf.d/openstack-dashboard.conf /etc/httpd/conf.d/

修改配置文件
[root@controller2 ~]# /etc/openstack-dashboard/local_settings
OPENSTACK_HOST = "192.168.3.72"

重启服务
[root@controller2 ~]# systemctl restart httpd.service memcached.service
```

3、登录dashboard

访问URL：http://控制节点IP/dashboard，Domain:default

![horizon_01](http://images.zsjshao.cn/images/openstack/horizon_01.png)

![horizon_02](http://images.zsjshao.cn/images/openstack/horizon_02.png)