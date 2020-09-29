+++
author = "zsjshao"
title = "openstack-glance"
date = "2020-04-23"
tags = ["openstack"]
categories = ["openstack"]
+++

## glance

### 1、什么是image service

glance管理的核心实体是image，它是OpenStack的核心组件之一，为OpenStack提供镜像服务(Image as Service)，主要负责OpenStack镜像以及镜像元数据的生命周期管理、检索、下载等功能。Glance支持将镜像保存到多种存储系统中，后端存储系统称为store，访问镜像的地址称为location，location可以是一个http地址，也可以是一个rbd协议地址。只要实现store的driver就可以作为Glance的存储后端，其中driver的主要接口如下:

<!-- more -->

```
get: 获取镜像的location。
get_size: 获取镜像的大小。
get_schemes: 获取访问镜像的URL前缀(协议部分)，比如rbd、swift+https、http等。
add: 上传镜像到后端存储中。
delete: 删除镜像。
set_acls: 设置后端存储的读写访问权限。
```

### 2、glance架构

![glance_01](http://images.zsjshao.net/openstack/glance/glance_01.png)

#### glance-api

glance-api 是系统后台运行的服务进程。 对外提供 REST API，响应 image 查询、获取和存储的调用。

glance-api 不会真正处理请求。 如果操作是与 image metadata（元数据）相关，glance-api 会把请求转发给 glance-registry； 如果操作是与 image 自身存取相关，glance-api 会把请求转发给该 image 的 store backend。

#### glance-registry

glance-registry 是系统后台运行的服务进程。 负责处理和存取image的metadata，例如image的大小和类型。在控制节点上可以查看glance-registry进程。

Glance 支持多种格式的 image，包括

![glance_02](http://images.zsjshao.net/openstack/glance/glance_02.png)

#### Database

 Image 的 metadata 会保持到 database 中，默认是 MySQL。 在控制节点上可以查看 glance 的 database 信息

#### Store backend

Glance 自己并不存储 image。 真正的 image 是存放在 backend 中的。 Glance 支持多种 backend，包括：

```
A directory on a local file system（这是默认配置）
GridFS
Ceph RBD
Amazon S3
Sheepdog
OpenStack Block Storage (Cinder)
OpenStack Object Storage (Swift)
VMware ESX

具体使用哪种 backend，是在 /etc/glance/glance-api.conf 中配置
  [glance_store]
  stores = file,http
  default_store = file
  filesystem_store_datadir = /var/lib/glance/images/
```

### 3、安装glance

#### 3.1：controller1的配置

创建glance数据库并授权

```
[root@mariadb1 ~]# mysql -e "CREATE DATABASE glance;"
[root@mariadb1 ~]# mysql -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'glance';"
[root@mariadb1 ~]# mysql -e "GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'glance';"
```

创建glance用户

```
[root@controller1 ~]# openstack user create --domain default --password glance glance
```

将glance用户添加到service项目组并授予admin角色

```
[root@controller1 ~]# openstack role add --project service --user glance admin
```

创建image服务

```
[root@controller1 ~]# openstack service create --name glance --description "OpenStack Image" image
```

创建endpoint

```
[root@controller1 ~]# openstack endpoint create --region RegionOne image public http://openstack-vip.zsjshao.net:9292
[root@controller1 ~]# openstack endpoint create --region RegionOne image internal http://openstack-vip.zsjshao.net:9292
[root@controller1 ~]# openstack endpoint create --region RegionOne image admin http://openstack-vip.zsjshao.net:9292
```

安装openstack-glance软件包

```
[root@controller1 ~]# yum install openstack-glance -y
```

编辑 /etc/glance/glance-api.conf配置文件，修改如下内容

```
[root@controller1 ~]# vim /etc/glance/glance-api.conf
[database]
connection = mysql+pymysql://glance:glance@openstack-vip.zsjshao.net/glance

[keystone_authtoken]
auth_uri = http://openstack-vip.zsjshao.net:5000
auth_url = http://openstack-vip.zsjshao.net:5000
memcached_servers = openstack-vip.zsjshao.net:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = glance

[paste_deploy]
flavor = keystone

[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
```

编辑/etc/glance/glance-registry.conf配置文件，修改如下内容

```
[root@controller1 ~]# vim /etc/glance/glance-registry.conf
[database]
connection = mysql+pymysql://glance:glance@openstack-vip.zsjshao.net/glance

[keystone_authtoken]
auth_uri = http://openstack-vip.zsjshao.net:5000
auth_url = http://openstack-vip.zsjshao.net:5000
memcached_servers = openstack-vip.zsjshao.net:11211
auth_type = password
project_domain_name = Default
user_domain_name = Default
project_name = service
username = glance
password = glance

[paste_deploy]
flavor = keystone
```

填充数据库

```
[root@controller1 ~]# su -s /bin/sh -c "glance-manage db_sync" glance
```

启动服务并设为开机自动启动

```
[root@controller1 ~]# systemctl start openstack-glance-api.service openstack-glance-registry.service
[root@controller1 ~]# systemctl enable openstack-glance-api.service openstack-glance-registry.service
```

下载测试镜像

```
[root@controller1 ~]# wget http://download.cirros-cloud.net/0.4.0/cirros-0.4.0-x86_64-disk.img
```

上传镜像

```
[root@controller1 ~]# openstack image create "cirros" --file cirros-0.4.0-x86_64-disk.img --disk-format qcow2 --container-format bare --public
```

查看镜像

```
[root@controller1 ~]# openstack image list
+--------------------------------------+--------+--------+
| ID                                   | Name   | Status |
+--------------------------------------+--------+--------+
| 6a69bd78-e637-4e86-ad0e-ae22b42cfdca | cirros | active |
+--------------------------------------+--------+--------+
```

#### 3.2：controller2的配置

```
安装openstack-glance软件包
[root@controller1 ~]# yum install openstack-glance -y

拷贝配置文件
[root@controller2 ~]# rsync -avlogp 192.168.3.71:/etc/glance/glance-api.conf /etc/glance/glance-api.conf 
[root@controller2 ~]# rsync -avlogp 192.168.3.71:/etc/glance/glance-registry.conf /etc/glance/glance-registry.conf

启动服务并设为开机自动启动
[root@controller2 ~]# systemctl start openstack-glance-api.service openstack-glance-registry.service
[root@controller2 ~]# systemctl enable openstack-glance-api.service openstack-glance-registry.service
```
