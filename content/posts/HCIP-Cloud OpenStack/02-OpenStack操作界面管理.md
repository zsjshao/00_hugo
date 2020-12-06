+++
author = "zsjshao"
title = "02-OpenStack操作界面管理"
date = "2020-12-05"
tags = ["openstack"]
categories = ["HCIP_Cloud OpenStack"]

+++

## 本章导读

本章我们主要介绍OpenStack操作界面服务Horizon。Horizon是OpenStack中最简单的服务，从Horizon开始着手学习OpenStack，更便于了解OpenStack全貌，为学习OpenStack技术细节打下扎实基础。本章主要分为两小节，理论部分我们主要讲解Horizon的定义和功能，实验部分指导大家进行Horizon基础操作，对OpenStack的使用有个基础的概念。

本章我们主要介绍Horizon定义，功能及进行日常操作练习，希望大家都可以掌握。

本章内容主要包括：

1. OpenStack操作界面服务Horizon简介

2. OpenStack操作界面服务Horizon功能

3. OpenStack动手实验：Horizon操作

## 1、OpenStack操作界面服务Horizon简介

### 1.1、OpenStack操作界面Horizon

Horizon操作界面首次出现在OpenStack的”Essex“版本中

Horizon提供基于Web的控制界面，使云管理员和用户能够管理各种OpenStack资源和服务。

依赖的OpenStack服务

- Horizon唯一依赖的服务是Keystone认证服务
- Horizon可以与其他服务结合使用，例如镜像服务、计算服务和网络服务等。
- Horizon还可以在有独立服务（如对象存储）的环境中使用。

Horizon的后端事实上是一个Web服务器，默认采用Apache Server。

### 1.2、Horizon在OpenStack中的位置和作用

![horizon](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/02/1.png)

Horizon主要提供基于Web的OpenStack控制界面，使云管理员和用户能够管理各种OpenStack资源和服务。

### 1.3、Horizon项目开发思想

核心支持

- 对所有核心OpenStack项目提供开箱即用的支持

可扩展

- 任何人都可以添加新组件

可管理

- 核心代码库简单易用

一致

- 始终保持视觉和交互范式一致性

稳定

- API强调向后兼容性

可用

- 提供人们想要使用的强大界面

## 2、OpenStack操作界面服务Horizon功能

### 2.1、OpenStack Horizon界面 - Project

![horizon](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/02/2.png)

Project界面提供租户可以管理的资源，例如计算、存储、网络等。

### 2.2、OpenStack Horizon界面 - Admin

![horizon](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/02/3.png)

Admin界面提供管理员可以管理的资源，例如计算、存储、网络和系统设置等。

### 2.3、OpenStack Horizon界面 - Identity

![horizon](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/02/4.png)

Identity界面提供认证管理功能。

### 2.4、OpenStack Horizon界面 - Settings

![horizon](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/02/5.png)

Settings界面提供操作界面配置功能。

## 3、OpenStack动手实验：Horizon操作

### 3.1、Web界面方式

#### 3.1.1、登录

admin:admin_user_secret

![horizon](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/02/6.png)

#### 3.1.2、创建flavor

![horizon](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/02/7.png)

#### 3.1.3、创建Instances

![horizon](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/02/8.png)

![horizon](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/02/9.png)

![horizon](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/02/10.png)

![horizon](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/02/11.png)

![horizon](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/02/12.png)

### 3.2、命令行方式

#### 3.2.1、查看admin-openrc.sh

```
osbash@controller:~$ cat admin-openrc.sh 
export OS_USERNAME=admin
export OS_PASSWORD=admin_user_secret
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://10.0.0.11:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

#### 3.2.2、查看demo-openrc.sh

```
osbash@controller:~$ cat demo-openrc.sh 
export OS_USERNAME=myuser
export OS_PASSWORD=myuser_user_pass
export OS_PROJECT_NAME=myproject
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://10.0.0.11:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
```

#### 3.2.3、创建instances

```
osbash@controller:~$ openstack flavor list
+--------------------------------------+---------+-----+------+-----------+-------+-----------+
| ID                                   | Name    | RAM | Disk | Ephemeral | VCPUs | Is Public |
+--------------------------------------+---------+-----+------+-----------+-------+-----------+
| cf6b4405-2f60-424a-a929-a156e508a48d | cirrors | 128 |    1 |         0 |     1 | True      |
+--------------------------------------+---------+-----+------+-----------+-------+-----------+
osbash@controller:~$ openstack image list
+--------------------------------------+--------+--------+
| ID                                   | Name   | Status |
+--------------------------------------+--------+--------+
| 9c9b8b2c-8c0b-449f-8736-d773b57f08f8 | cirros | active |
+--------------------------------------+--------+--------+
osbash@controller:~$ openstack network list
+--------------------------------------+-------------+--------------------------------------+
| ID                                   | Name        | Subnets                              |
+--------------------------------------+-------------+--------------------------------------+
| 7026b16b-dc98-4283-aeda-027cb66e3c39 | selfservice | 469317e6-f2dd-496f-b2ba-d33169cf4d4f |
| b8452e19-b6b5-4c96-831a-5ddc05e73c94 | provider    | 5b085117-9dc3-4326-9561-984501e1278e |
+--------------------------------------+-------------+--------------------------------------+
osbash@controller:~$ openstack server create --flavor cirrors --image cirros cirros-cli
+-------------------------------------+------------------------------------------------+
| Field                               | Value                                          |
+-------------------------------------+------------------------------------------------+
| OS-DCF:diskConfig                   | MANUAL                                         |
| OS-EXT-AZ:availability_zone         |                                                |
| OS-EXT-SRV-ATTR:host                | None                                           |
| OS-EXT-SRV-ATTR:hypervisor_hostname | None                                           |
| OS-EXT-SRV-ATTR:instance_name       |                                                |
| OS-EXT-STS:power_state              | NOSTATE                                        |
| OS-EXT-STS:task_state               | scheduling                                     |
| OS-EXT-STS:vm_state                 | building                                       |
| OS-SRV-USG:launched_at              | None                                           |
| OS-SRV-USG:terminated_at            | None                                           |
| accessIPv4                          |                                                |
| accessIPv6                          |                                                |
| addresses                           |                                                |
| adminPass                           | HExz5j3UoTSQ                                   |
| config_drive                        |                                                |
| created                             | 2020-12-04T11:33:05Z                           |
| flavor                              | cirrors (cf6b4405-2f60-424a-a929-a156e508a48d) |
| hostId                              |                                                |
| id                                  | 1cc70865-52ab-40c5-a962-598c27ccfd6c           |
| image                               | cirros (9c9b8b2c-8c0b-449f-8736-d773b57f08f8)  |
| key_name                            | None                                           |
| name                                | cirros-cli                                     |
| progress                            | 0                                              |
| project_id                          | bc78fc6cc32f4e779eb750d212253523               |
| properties                          |                                                |
| security_groups                     | name='default'                                 |
| status                              | BUILD                                          |
| updated                             | 2020-12-04T11:33:05Z                           |
| user_id                             | e9926f5e50ed4d069730d92913298ed3               |
| volumes_attached                    |                                                |
+-------------------------------------+------------------------------------------------+
```

#### 3.2.4、查看instances

```
osbash@controller:~$ openstack server show cirros-cli
+-------------------------------------+----------------------------------------------------------+
| Field                               | Value                                                    |
+-------------------------------------+----------------------------------------------------------+
| OS-DCF:diskConfig                   | MANUAL                                                   |
| OS-EXT-AZ:availability_zone         | nova                                                     |
| OS-EXT-SRV-ATTR:host                | compute1                                                 |
| OS-EXT-SRV-ATTR:hypervisor_hostname | compute1                                                 |
| OS-EXT-SRV-ATTR:instance_name       | instance-00000002                                        |
| OS-EXT-STS:power_state              | Running                                                  |
| OS-EXT-STS:task_state               | None                                                     |
| OS-EXT-STS:vm_state                 | active                                                   |
| OS-SRV-USG:launched_at              | 2020-12-04T11:33:21.000000                               |
| OS-SRV-USG:terminated_at            | None                                                     |
| accessIPv4                          |                                                          |
| accessIPv6                          |                                                          |
| addresses                           | provider=203.0.113.167                                   |
| config_drive                        |                                                          |
| created                             | 2020-12-04T11:33:05Z                                     |
| flavor                              | cirrors (cf6b4405-2f60-424a-a929-a156e508a48d)           |
| hostId                              | ffed804fb577d99887bcccbaecc763b87bc6b4b0600684fa9f613e4a |
| id                                  | 1cc70865-52ab-40c5-a962-598c27ccfd6c                     |
| image                               | cirros (9c9b8b2c-8c0b-449f-8736-d773b57f08f8)            |
| key_name                            | None                                                     |
| name                                | cirros-cli                                               |
| progress                            | 0                                                        |
| project_id                          | bc78fc6cc32f4e779eb750d212253523                         |
| properties                          |                                                          |
| security_groups                     | name='default'                                           |
| status                              | ACTIVE                                                   |
| updated                             | 2020-12-04T11:33:17Z                                     |
| user_id                             | e9926f5e50ed4d069730d92913298ed3                         |
| volumes_attached                    |                                                          |
+-------------------------------------+----------------------------------------------------------+
```

## 4、思考题

1、OpenStack操作界面的管理视图和用户视图有什么区别？

- OpenStack管理员视图支持更多底层配置功能，例如配置规格、安全组、外部网络等，用户视图只能使用管理员预定义的规格、外部网络等。

2、OpenStack使用CLI时，为什么要先source？

- 将OpenStack相关变量预先定义好，source变量后，后续执行OpenStack命令不需要每次添加变量参数（例如os-url，os-user，admin_url等变量）。

## 5、测一测

### 5.1、判断

Horizon唯一依赖的服务是Keystone认证服务。

- `true` 正确`

- false

OpenStack管理员视图支持更多底层配置功能，例如配置规格、安全组、外部网络等，用户视图只能使用管理员预定义的规格、外部网络等。

- `true 正确`

- false

当OpenStack预先定义好source变量后，后续执行OpenStack命令时不再需要每次添加变量参数。

- `true 正确`

- false

### 5.2、单选

以下关于Horizon项目开发思想中的稳定性，描述正确的是？

- Horizon对所有OpenStack核心项目提供开箱即用的支持

- OpenStack本身开源，开放代码允许开发者在原有框架基础上进行扩展开发

- Horizon核心代码库简单易用，用户和开发者可以根据个人需求修改Horizon代码

- `Horizon提供向后兼容的API，使用旧接口的服务和应用，可以运行和对接新接口使用 正确`

以下关于Horizon的描述不正确的？

- Project界面提供租户可以管理的资源，例如计算、存储、网络等

- Admin界面提供管理员可以管理的资源，例如计算、存储、网络和系统设置等

- Horizon可以与其他服务结合使用，例如镜像服务，计算服务和网络服务

- `管理员和普通用户账号登录，两者界面所显示的功能没有区别 正确`

