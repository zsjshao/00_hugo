+++
author = "zsjshao"
title = "openstack-keystone"
date = "2020-04-24"
tags = ["openstack"]
categories = ["openstack"]
+++

## keystone

### 1、什么是keystone

Keystone：身份服务（Identity Service）。为OpenStack其他服务提供身份认证、服务规则、服务令牌的功能和管理用户、帐号和角色信息服务，并为对象存储提供授权服务。可以作为OpenStack的统一认证的组件。
作为 OpenStack 的基础支持服务，Keystone 做下面这几件事情：

<!-- more -->

```
1)管理用户及其权限
2)维护 OpenStack Services 的 Endpoint
3)Authentication（认证）和 Authorization（鉴权）
```

### 2、认识keystone

学习keystone，得理解keystone常用概念

![keystone_01](http://images.zsjshao.net/openstack/keystone/keystone_01.png)

#### user

user何使用 OpenStack 的实体，可以是真正的用户，其他系统或者服务。

![keystone_02](http://images.zsjshao.net/openstack/keystone/keystone_02.png)

当 User 请求访问 OpenStack 时，Keystone 会对其进行验证。Horizon 在 Identity->Users 管理 User。
除了 admin 和 demo，OpenStack 也为 nova、cinder、glance、neutron 服务创建了相应的 User。 admin 也可以管理这些 User。

![keystone_03](http://images.zsjshao.net/openstack/keystone/keystone_03.png)

#### Credentials

Credentials 是 User 用来证明自己身份的信息，可以是： 

````
1)用户名/密码
2)Token
3)API Key
4)其他高级方式
````

![keystone_04](http://images.zsjshao.net/openstack/keystone/keystone_04.png)

#### Authentication

Authentication 是 Keystone 验证 User 身份的过程。User 访问 OpenStack 时向 Keystone 提交用户名和密码形式的 Credentials，Keystone 验证通过后会给 User 签发一个 Token 作为后续访问的 Credential。

![keystone_05](http://images.zsjshao.net/openstack/keystone/keystone_05.png)

#### Token

Token 是由数字和字母组成的字符串，User 成功 Authentication 后 Keystone 生成 Token 并分配给 User。

```
1)Token 用做访问 Service 的 Credential
2)Service 会通过 Keystone 验证 Token 的有效性
3)Token 的有效期默认是 24 小时
```

![keystone_06](http://images.zsjshao.net/openstack/keystone/keystone_06.png)



#### Project

Project 用于将 OpenStack 的资源（计算、存储和网络）进行分组和隔离。
根据 OpenStack 服务的对象不同，Project 可以是一个客户（公有云，也叫租户）、部门或者项目组（私有云）。
这里请注意：

```
1)资源的所有权是属于 Project 的，而不是 User。
2)在 OpenStack 的界面和文档中，Tenant / Project / Account 这几个术语是通用的，但长期看会倾向使用 Project
3)每个 User（包括 admin）必须挂在 Project 里才能访问该 Project 的资源。 一个User可以属于多个 Project。
4)admin 相当于 root 用户，具有最高权限
```

![keystone_07](http://images.zsjshao.net/openstack/keystone/keystone_07.png)

Horizon 在 Identity->Projects 中管理 Project

![keystone_08](http://images.zsjshao.net/openstack/keystone/keystone_08.png)

通过 Manage Members 将 User 添加到 Project

![keystone_09](http://images.zsjshao.net/openstack/keystone/keystone_09.png)

#### Service

OpenStack 的 Service 包括 Compute (Nova)、Block Storage (Cinder)、Object Storage (Swift)、Image Service (Glance) 、Networking Service (Neutron) 等。每个 Service 都会提供若干个 Endpoint，User 通过 Endpoint 访问资源和执行操作。

![keystone_10](http://images.zsjshao.net/openstack/keystone/keystone_10.png)

#### Endpoint

Endpoint 是一个网络上可访问的地址，通常是一个 URL。Service 通过 Endpoint 暴露自己的 API。 Keystone 负责管理和维护每个 Service 的 Endpoint。

![keystone_11](http://images.zsjshao.net/openstack/keystone/keystone_11.png)

可以使用下面的命令来查看 Endpoint
```
[root@controller1 ~]# source /root/admin
[root@controller1 ~]# openstack endpoint list --service identity
+----------------------------------+-----------+--------------+--------------+---------+-----------+-------------------------------------------+
| ID                               | Region    | Service Name | Service Type | Enabled | Interface | URL                                       |
+----------------------------------+-----------+--------------+--------------+---------+-----------+-------------------------------------------+
| 28613dd78c7d4b3680dd7f2c3f1917d6 | RegionOne | keystone     | identity     | True    | internal  | http://openstack-vip.zsjshao.net:5000/v3/ |
| 4a679afce74544fda5c662d1a56f7fd3 | RegionOne | keystone     | identity     | True    | admin     | http://openstack-vip.zsjshao.net:5000/v3/ |
| 632b8a8b734042e49568bd4856a7845d | RegionOne | keystone     | identity     | True    | public    | http://openstack-vip.zsjshao.net:5000/v3/ |
+----------------------------------+-----------+--------------+--------------+---------+-----------+-------------------------------------------+

[root@controller1 ~]# openstack catalog list
+----------+----------+-------------------------------------------------------+
| Name     | Type     | Endpoints                                             |
+----------+----------+-------------------------------------------------------+
| keystone | identity | RegionOne                                             |
|          |          |   internal: http://openstack-vip.zsjshao.net:5000/v3/ |
|          |          | RegionOne                                             |
|          |          |   admin: http://openstack-vip.zsjshao.net:5000/v3/    |
|          |          | RegionOne                                             |
|          |          |   public: http://openstack-vip.zsjshao.net:5000/v3/   |
|          |          |                                                       |
| glance   | image    | RegionOne                                             |
|          |          |   admin: http://openstack-vip.zsjshao.net:9292        |
|          |          | RegionOne                                             |
|          |          |   internal: http://openstack-vip.zsjshao.net:9292     |
|          |          | RegionOne                                             |
|          |          |   public: http://openstack-vip.zsjshao.net:9292       |
|          |          |                                                       |
+----------+----------+-------------------------------------------------------+
```

#### Role

安全包含两部分：Authentication（认证）和 Authorization（授权）
Authentication 解决的是“你是谁？”的问题
Authorization 解决的是“你能干什么？”的问题
Keystone 借助 Role 实现 Authorization：

1)Keystone定义role

```
[root@controller1 ~]# openstack role list
+----------------------------------+-------+
| ID                               | Name  |
+----------------------------------+-------+
| 6850da8b55f7407e8c4708659c733c65 | user  |
| b408ca86212547a99199ca63d7fefddd | admin |
+----------------------------------+-------+
```

2)可以为 User 指定Role，Horizon 的菜单为 Identity->Project->Manage Members

![keystone_12](http://images.zsjshao.net/openstack/keystone/keystone_12.png)

3)Service 决定每个 Role 能做什么事情 Service 通过各自的 policy.json 文件对 Role 进行访问控制。 下面是 Nova 服务 /etc/glance/policy.json 中的示例

```
[root@controller1 ~]# cat /etc/glance/policy.json 
{
    "context_is_admin":  "role:admin",
    "default": "role:admin",

    "add_image": "",
    "delete_image": "",
    "get_image": "",
    "get_images": "",
    "modify_image": "",
    "publicize_image": "role:admin",
    ...
```

上面配置的含义是：对于 add_image、delete_image 等操作，任何Role的 User 都可以执行； 但只有 admin 这个 Role 的 User 才能执行publicize_image 操作。
OpenStack 默认配置只区分 admin 和非 admin Role。 如果需要对特定的 Role 进行授权，可以修改 policy.json。

### 3、安装keystone

#### 3.1：controller1的配置

创建keystone数据库并授权

```
# mysql
CREATE DATABASE keystone;
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'keystone';
GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'keystone';
```

安装keystone相关软件包

```
[root@controller1 ~]# yum install openstack-keystone httpd mod_wsgi -y
```

编辑/etc/keystone/keystone.conf配置文件，修改如下内容

```
[root@controller1 ~]# vim /etc/keystone/keystone.conf
[database]
connection = mysql+pymysql://keystone:keystone@openstack-vip.zsjshao.net/keystone
[token]
provider=fernet
```

初始化数据库

```
[root@controller1 ~]# su -s /bin/sh -c "keystone-manage db_sync" keystone
```

初始化Fernet密钥存储库

```
[root@controller1 ~]# keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
[root@controller1 ~]# keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
[root@controller1 ~]# ll  /etc/keystone/fernet-keys/
total 8
-rw------- 1 keystone keystone 44 Mar 12 23:11 0
-rw------- 1 keystone keystone 44 Mar 12 23:11 1
```

初始化keystone服务，将admin用户的密码设置为admin

```
[root@controller1 ~]# keystone-manage bootstrap --bootstrap-password admin \
   --bootstrap-admin-url http://openstack-vip.zsjshao.net:5000/v3/ \
   --bootstrap-internal-url http://openstack-vip.zsjshao.net:5000/v3/ \
   --bootstrap-public-url http://openstack-vip.zsjshao.net:5000/v3/ \
   --bootstrap-region-id RegionOne
```

配置http服务

```
编辑/etc/httpd/conf/httpd.conf配置文件，修改如下内容
[root@controller1 ~]# vim /etc/httpd/conf/httpd.conf
  ServerName controller1.zsjshao.net

创建软链接
[root@controller1 ~]# ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/

启动服务并设为开机自动启动
[root@controller1 ~]# systemctl start httpd.service
[root@controller1 ~]# systemctl enable httpd.service
```

编辑hosts文件

```
[root@controller1 ~]# cat /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.101.71	controller1.zsjshao.net	controller1
192.168.101.72	controller2.zsjshao.net	controller2
192.168.101.73	compute1.zsjshao.net	compute1
192.168.101.74	compute2.zsjshao.net	compute2
192.168.101.200 openstack-vip.zsjshao.net
```

创建用户凭证并导入用户凭证

```
[root@controller1 ~]# vim admin
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=admin
export OS_AUTH_URL=http://openstack-vip.zsjshao.net:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
[root@controller1 ~]# source admin
```

创建service项目

```
[root@controller1 ~]# openstack project create --domain default --description "Service Project" service
```

创建user角色

```
[root@controller1 ~]# openstack role create user
```

#### 3.2：controller2的配置

```
安装keystone相关软件包
[root@controller2 ~]# yum install openstack-keystone httpd mod_wsgi -y

拷贝文件controller1的keystone文件
[root@controller2 ~]# rsync -avlogp 192.168.3.71:/etc/keystone/* /etc/keystone/
[root@controller2 ~]# rsync -avlogp 192.168.3.71:/etc/hosts /etc/

编辑/etc/httpd/conf/httpd.conf配置文件，修改如下内容
[root@controller1 ~]# vim /etc/httpd/conf/httpd.conf
  ServerName controller2.zsjshao.net

创建软链接
[root@controller2 ~]# ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/

启动服务并设为开机自动启动
[root@controller2 ~]# systemctl start httpd.service
[root@controller2 ~]# systemctl enable httpd.service

若还有其他控制节点参考controller2的配置步骤
```
