+++
author = "zsjshao"
title = "06-OpenStack存储管理"
date = "2020-12-05"
tags = ["openstack"]
categories = ["HCIP_Cloud OpenStack"]

+++

## 本章导读

大家好，我们开始第六章OpenStack存储管理的学习。我们知道在云计算的使用中，我们无法脱离计算、存储和网络这几个概念，那么OpenStack作为实现云计算的一种底层技术，其必定也需要提供计算、存储和网络服务，在前面的课程中我们已经介绍过计算服务Nova，本章我们将介绍OpenStack中的存储组件。但是OpenStack提供了多种存储类型，用户可以根据不同的业务需求，自由地选择存储服务。本章我们重点学习OpenStack中的块存储服务Cinder，并简单介绍对象存储Swift。

本章内容主要包括：

1. OpenStack存储概述

2. 块存储Cinder

3. 对象存储Swift

## 1、OpenStack存储概述

### 1.1、OpenStack有哪些存储类型？

OpenStack中存储可以分为两类：

- Ephemeral Storage，临时存储
  - 如果只部署了Nova服务，则默认分配给虚拟机的磁盘是临时的，当虚拟机终止后，存储空间也会被释放
  - 默认情况下，临时存储以文件形式放置在计算节点的本地磁盘上。

- Persistent Storage，持久化存储
  - 持久化存储设备的生命周期独立于任何其他文件系统设备或资源，存储的数据一直可用，无论虚拟机是否运行。
  - 当虚拟机终止后，持久性存储上的数据仍然可用

目前OpenStack支持三种类型的持久性存储：块存储、对象存储和文件系统存储。

### 1.2、OpenStack持久化存储简介

块存储（Cinder）

- 操作对象是磁盘，直接挂载到主机，一般用于主机的直接存储空间和数据库应用，DAS和SAN都可以提供块存储。

对象存储（Swift）

- 操作对象是对象（object），一个对象名称就是一个域名地址，可以直接通过REST API的方式访问对象。

文件存储（Manila）

- 操作对象是文件和文件夹，在存储系统上增加了文件系统，再通过NFS或CIFS协议进行访问。

因Manila目前使用较少，本章节只重点介绍Cinder和Swift

### 1.3、OpenStack存储类型对比

|                  | 用途                         | 访问方式                                                 | 访问客户端 | 管理访问 | 数据生命周期 | 存储设备容量                                                 | 典型使用案例                           |
| ---------------- | ---------------------------- | -------------------------------------------------------- | ---------- | -------- | ------------ | ------------------------------------------------------------ | -------------------------------------- |
| 临时存储         | 运行操作系统和提供启动空间   | 通过文件系统访问                                         | 虚拟机     | Nova     | 虚拟机终止   | 管理员配置的Flavor指定容量                                   | 虚拟机中第一块磁盘10GB，第二块磁盘20GB |
| 块存储           | 为虚拟机添加额外的持久化存储 | 块设备被分区、格式化后挂载访问（例如/dev/vdc）           | 虚拟机     | Cinder   | 被用户删除   | 用户创建时指定                                               | 1 TB磁盘                               |
| 对象存储         | 存储海量数据，包括虚拟机映像 | REST API                                                 | 任何客户端 | Swift    | 被用户删除   | 可用物理存储空间和数据副本数量                               | 10s TB级数据集存储                     |
| 共享文件系统存储 | 为虚拟机添加额外的持久化存储 | 共享文件系统存储被分区、格式化后挂载访问（例如/dev/vdc） | 虚拟机     | Manila   | 被用户删除   | 用户创建时指定<br />扩容时指定<br />用户配额指定<br />管理员指定容量 | NFS                                    |

## 2、块存储Cinder

### 2.1、Cinder简介

#### 2.1.1、OpenStack块存储服务是什么？

CINDER块存储服务首次出现在OpenStack的“Folsom”版本中。

Cinder提供块存储服务，为虚拟机实例提供持久化存储。

Cinder调用不同存储接口驱动，将存储设备转化成块存储池，用户无需了解存储实际部署的位置和设备类型。

依赖的OpenStack服务

- Keystone

#### 2.1.2、Cinder在OpenStack中的位置和作用

![cinder](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/1.png)

Cinder的核心功能是对卷的管理，允许对卷、卷的类型、卷的快照、卷备份进行处理。它为后端不同的存储设备提供了统一的接口，不同的块设备服务厂商在Cinder中实现其驱动，可以被OpenStack整合管理。

### 2.2、Cinder架构

![cinder](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/2.png)

Cinder Client封装Cinder提供的rest接口，以CLI形式供用户使用。

Cinder API对外提供rest API，对操作需求进行解析，对API进行路由寻找相应的处理方法。包含卷的增删改查（包括从源卷、镜像、快照创建）、快照增删改查、备份、volume type管理、挂载/卸载（Nova调用）等。

CinderScheduler负责收集backend上报的容量、能力信息，根设定的算法完成卷到指定cinder-volume的调度。

Cinder Volume多节点部署，使用不同的配置文件、接入不同的backend设备，由各存储厂商插入driver代码与设备交互完成设备容量和能力信息收集、卷操作。

Cinder Backup实现将卷的数据备份到其他存储介质（目前SWIFT/Ceph/TSM提供了驱动）。

SQL DB提供存储卷、快照、备份、service等数据，支持Mysql、PG、MSSQL等SQL数据库。

#### 2.2.1、Cinder架构说明

![cinder](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/3.png)

#### 2.2.2、Cinder架构部署：以SAN存储为例

![cinder](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/4.png)

Cinder-api，Cinder-Scheduler，Cinder-Volume可以选择部署到一个节点上，也可以分别部署。

API采用AA模式，Haproxy作为LB，分发请求到多个Cinder API。

Scheduler也采用AA模式，由rabbitmq以负载均衡模式向3个节点分发任务，并同时从rabbitmq收取Cinder volumen上报的能力信息，调度时，scheduler通过在DB中预留资源从而保证数据一致性。

Cinder volume也采用AA模式，同时上报同一个backend容量和能力信息，并同时接受请求进行处理。

RabbitMQ，支持主备或集群。

MySQL，支持主备或集群。

Cinder架构可以避免单节点故障。

### 2.3、Cinder组件详细讲解

#### 2.3.1、Cinder组件 - API

Cinder API对外提供REST API，对操作需求进行解析，并调用处理方法：

- 卷：create/delete/list/show
- 快照：create/delete/list/show
- 卷：attach/detach（Nova调用）
- 其他：
  - Volume types
  - Quotas
  - Backups

#### 2.3.2、Cinder组件 - Scheduler

Cinder Scheduler负责收集后端上报的容量、能力信息，根据设定的算法完成卷到指定cinder-volume的调度。

Cinder Scheduler通过过滤和称权，筛选出合适的后端：

![cinder](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/5.png)

根据后端的能力进行筛选：

- Drivers定期报告后端的能力和状态
- 管理员创建的卷类型（volume type ）
- 创建卷时，用户指定卷类型

#### 2.3.3、Cinder组件 - Volume

Cinder volume多节点部署，使用不同的配置文件、接入不同的后端设备，由各存储厂商插入Driver代码与设备交互，完成设备容量和能力信息收集、卷操作等。

![cinder](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/6.png)

Cinder默认的后端驱动是LVM。

### 2.4、Cinder典型工作流程

#### 2.4.1、Cinder创建卷流程

![cinder](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/7.png)

Cinder-volume：会定期收集底层后端的容量等信息，并通知Scheduler更新内存中的Backend信息。

创建卷类型的目的是为了筛选不同的后端存储，例如SSD、SATA、高性能、低性能等，通过创建不同的自定义卷类型，创建卷时自动筛选出合适的后端存储。

#### 2.4.2、Cinder创建卷流程 - Cinder API

![cinder](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/8.png)

Cinder API服务

- 检查参数合法性（用户输入、权限、资源是否存中等）。
- 准备创建的参数字典，预留和提交配额。
- 在数据库中创建对应的数据记录。
- 通过消息队列将请求和参数发送到Scheduler。

#### 2.4.3、Cinder创建卷流程 - Cinder Scheduler

![cinder](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/9.png)

Cinder Scheduler服务

- 提取接收到的请求参数
- 通过配置的filter和输入参数对后端进行过滤
  - Availability_zone_filter
  - Capacity_filter
  - Capabilities_filter
  - Affinity_filter（SameBackendFilter/DifferentBackendFilter）
  - ......

- Weigher计算后端进行权重
  - CapacityWeigher/AllocatedCapacityWeigher
  - ChanceWeigher
  - GoodnessWeigher
  - ......

- 选取最优的Backend并通过消息队列将请求发送到指定的后端

和Nova Scheduler类似，Cinder Scheduler也是经过Filter筛选符合条件的后端，然后使用Weigher计算后端进行权重排序，最终选择出最合适的后端存储。

#### 2.4.4、Cinder创建卷流程 - Cinder Volume

![cinder](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/10.png)

Cinder Volume服务

- 提取接收到的请求参数
- 调用对应的Driver在后端创建实际的卷
- 使用Driver返回的模型更新数据库中的记录

#### 2.4.5、Cinder挂载卷流程

![cinder](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/11.png)

挂卷流程：挂卷是通过Nova和Cinder的配合最终将远端的卷连接到虚拟机所在的Host节点上，并最终通过虚拟机管理程序映射到内部的虚拟机中。

Nova调用Cinder API创建卷，传递主机的信息，如hostname, iSCSI initiator name, FC WWPNs

Cinder API将该信息传递给Cinder Volume。

Cinder Volume通过创建卷时保存的host信息找到对应的Cinder Driver。

Cinder Driver通知存储允许该主机访问该卷，并返回该存储的连接信息（如iSCSI iqn，portal，FC Target WWPN，NFS path等）

Nova调用针对于不同存储类型进行主机识别磁盘的代码（Cinder 提供了brick模块用于参考）实现识别磁盘或者文件设备。

Nova通知Cinder已经进行了挂载。

Nova将主机的设备信息传递给hypervisor来实现虚拟机挂载磁盘。

### 2.5、OpenStack动手实验：Cinder操作

#### 2.5.1、Cinder主要操作

![cinder](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/12.png)

Cinder操作主要三个资源：

- Volume：块设备卷，提供创建、删除、扩容、挂载/卸载等功能
- Snapshot：针对于块设备卷的快照创建、删除、回滚等功能。
- Backup：提供对块设备卷的备份，恢复能力

#### 2.5.2、Cinder操作

##### 2.5.2.1、卷类型

```
osbash@controller:~$ openstack volume type create --public vtype_cli
+-------------+--------------------------------------+
| Field       | Value                                |
+-------------+--------------------------------------+
| description | None                                 |
| id          | 3f6f7b4a-1cdf-45d2-a515-56d3c6cf9378 |
| is_public   | True                                 |
| name        | vtype_cli                            |
+-------------+--------------------------------------+
osbash@controller:~$ openstack volume type list
+--------------------------------------+-------------+-----------+
| ID                                   | Name        | Is Public |
+--------------------------------------+-------------+-----------+
| 3f6f7b4a-1cdf-45d2-a515-56d3c6cf9378 | vtype_cli   | True      |
| 7f3920b4-8699-473a-8e39-65ba56c3204b | __DEFAULT__ | True      |
+--------------------------------------+-------------+-----------+
```

##### 2.5.2.2、QOS

```
osbash@controller:~$ openstack volume qos create --consumer back-end --property minIOPS=20 qos_cli
+------------+--------------------------------------+
| Field      | Value                                |
+------------+--------------------------------------+
| consumer   | back-end                             |
| id         | b616c136-9842-4b1c-a465-4ca3bdd451c0 |
| name       | qos_cli                              |
| properties | minIOPS='20'                         |
+------------+--------------------------------------+
osbash@controller:~$ openstack volume qos associate qos_cli vtype_cli
osbash@controller:~$ openstack volume qos list 
+--------------------------------------+---------+----------+--------------+--------------+
| ID                                   | Name    | Consumer | Associations | Properties   |
+--------------------------------------+---------+----------+--------------+--------------+
| b616c136-9842-4b1c-a465-4ca3bdd451c0 | qos_cli | back-end | vtype_cli    | minIOPS='20' |
+--------------------------------------+---------+----------+--------------+--------------+
```

##### 2.5.2.3、卷

```
osbash@controller:~$ openstack volume create --type vtype_cli --size 1 --availability-zone nova --bootable volume_cli
+---------------------+--------------------------------------+
| Field               | Value                                |
+---------------------+--------------------------------------+
| attachments         | []                                   |
| availability_zone   | nova                                 |
| bootable            | false                                |
| consistencygroup_id | None                                 |
| created_at          | 2020-12-05T21:28:32.000000           |
| description         | None                                 |
| encrypted           | False                                |
| id                  | a20e0de2-b1d5-4552-85cf-171ef13d411e |
| migration_status    | None                                 |
| multiattach         | False                                |
| name                | volume_cli                           |
| properties          |                                      |
| replication_status  | None                                 |
| size                | 1                                    |
| snapshot_id         | None                                 |
| source_volid        | None                                 |
| status              | creating                             |
| type                | vtype_cli                            |
| updated_at          | None                                 |
| user_id             | e9926f5e50ed4d069730d92913298ed3     |
+---------------------+--------------------------------------+

osbash@controller:~$ openstack server add volume cirrors volume_cli
osbash@controller:~$ openstack volume list
+--------------------------------------+------------+-----------+------+----------------------------------+
| ID                                   | Name       | Status    | Size | Attached to                      |
+--------------------------------------+------------+-----------+------+----------------------------------+
| a20e0de2-b1d5-4552-85cf-171ef13d411e | volume_cli | in-use    |    1 | Attached to cirrors on /dev/vdb  |
| cafac4da-5186-45dd-a39a-72af6dbc910a |            | in-use    |    1 | Attached to cirrors on /dev/vda  |
+--------------------------------------+------------+-----------+------+----------------------------------+

osbash@controller:~$ openstack server remove volume cirrors volume_cli

osbash@controller:~$ openstack volume set --non-bootable --size 2 volume_cli
osbash@controller:~$ openstack volume show volume_cli
+--------------------------------+--------------------------------------+
| Field                          | Value                                |
+--------------------------------+--------------------------------------+
| attachments                    | []                                   |
| availability_zone              | nova                                 |
| bootable                       | false                                |
| consistencygroup_id            | None                                 |
| created_at                     | 2020-12-05T21:28:32.000000           |
| description                    | None                                 |
| encrypted                      | False                                |
| id                             | a20e0de2-b1d5-4552-85cf-171ef13d411e |
| migration_status               | None                                 |
| multiattach                    | False                                |
| name                           | volume_cli                           |
| os-vol-host-attr:host          | compute1@lvm#LVM                     |
| os-vol-mig-status-attr:migstat | None                                 |
| os-vol-mig-status-attr:name_id | None                                 |
| os-vol-tenant-attr:tenant_id   | bc78fc6cc32f4e779eb750d212253523     |
| properties                     |                                      |
| replication_status             | None                                 |
| size                           | 2                                    |
| snapshot_id                    | None                                 |
| source_volid                   | None                                 |
| status                         | available                            |
| type                           | vtype_cli                            |
| updated_at                     | 2020-12-05T21:31:48.000000           |
| user_id                        | e9926f5e50ed4d069730d92913298ed3     |
+--------------------------------+--------------------------------------+
```

##### 2.5.2.4、卷快照

```
osbash@controller:~$ openstack volume snapshot create --volume volume_cli vsnap_cli
+-------------+--------------------------------------+
| Field       | Value                                |
+-------------+--------------------------------------+
| created_at  | 2020-12-05T21:34:47.423577           |
| description | None                                 |
| id          | d65e277b-fa65-4d0e-bbe4-e75790d02b24 |
| name        | vsnap_cli                            |
| properties  |                                      |
| size        | 2                                    |
| status      | creating                             |
| updated_at  | None                                 |
| volume_id   | a20e0de2-b1d5-4552-85cf-171ef13d411e |
+-------------+--------------------------------------+
osbash@controller:~$ openstack volume snapshot list
+--------------------------------------+-----------+-------------+-----------+------+
| ID                                   | Name      | Description | Status    | Size |
+--------------------------------------+-----------+-------------+-----------+------+
| d65e277b-fa65-4d0e-bbe4-e75790d02b24 | vsnap_cli | None        | available |    2 |
+--------------------------------------+-----------+-------------+-----------+------+

osbash@controller:~$ openstack image create --volume volume_cli --disk-format qcow2 vimg_cli
+---------------------+--------------------------------------+
| Field               | Value                                |
+---------------------+--------------------------------------+
| container_format    | bare                                 |
| disk_format         | qcow2                                |
| display_description | None                                 |
| id                  | a20e0de2-b1d5-4552-85cf-171ef13d411e |
| image_id            | 90ca6001-e589-4cad-801f-3ce3482b5fd0 |
| image_name          | vimg_cli                             |
| protected           | False                                |
| size                | 2                                    |
| status              | uploading                            |
| updated_at          | 2020-12-05T21:31:48.000000           |
| visibility          | shared                               |
| volume_type         | vtype_cli                            |
+---------------------+--------------------------------------+
osbash@controller:~$ openstack image list
+--------------------------------------+------------+--------+
| ID                                   | Name       | Status |
+--------------------------------------+------------+--------+
| 9c9b8b2c-8c0b-449f-8736-d773b57f08f8 | cirros     | active |
| b2a69822-dada-46ec-8607-85618f820707 | img_cli    | active |
| 87b087c0-3dbe-4848-b749-ea579ca71765 | snap_cli   | active |
| 87ead516-b52d-4cc5-9697-871328705f54 | ubuntu_cli | active |
| 90ca6001-e589-4cad-801f-3ce3482b5fd0 | vimg_cli   | queued |
+--------------------------------------+------------+--------+
```

##### 2.5.2.5、transfer

```
osbash@controller:~$ openstack volume transfer request create --name transfer_cli volume_cli
+------------+--------------------------------------+
| Field      | Value                                |
+------------+--------------------------------------+
| auth_key   | 2259f0ba77599dfe                     |
| created_at | 2020-12-05T21:38:32.402695           |
| id         | 33c8cc27-d6bf-49d5-868d-d1b66f7d32d4 |
| name       | transfer_cli                         |
| volume_id  | a20e0de2-b1d5-4552-85cf-171ef13d411e |
+------------+--------------------------------------+

osbash@controller:~$ openstack volume show volume_cli
+--------------------------------+--------------------------------------+
| Field                          | Value                                |
+--------------------------------+--------------------------------------+
| attachments                    | []                                   |
| availability_zone              | nova                                 |
| bootable                       | false                                |
| consistencygroup_id            | None                                 |
| created_at                     | 2020-12-05T21:28:32.000000           |
| description                    | None                                 |
| encrypted                      | False                                |
| id                             | a20e0de2-b1d5-4552-85cf-171ef13d411e |
| migration_status               | None                                 |
| multiattach                    | False                                |
| name                           | volume_cli                           |
| os-vol-host-attr:host          | compute1@lvm#LVM                     |
| os-vol-mig-status-attr:migstat | None                                 |
| os-vol-mig-status-attr:name_id | None                                 |
| os-vol-tenant-attr:tenant_id   | bc78fc6cc32f4e779eb750d212253523     |
| properties                     |                                      |
| replication_status             | None                                 |
| size                           | 2                                    |
| snapshot_id                    | None                                 |
| source_volid                   | None                                 |
| status                         | awaiting-transfer                    |
| type                           | vtype_cli                            |
| updated_at                     | 2020-12-05T21:38:32.000000           |
| user_id                        | e9926f5e50ed4d069730d92913298ed3     |
+--------------------------------+--------------------------------------+

osbash@controller:~$ cat user_cli_01-openrc.sh 
export OS_USERNAME=user_cli_01
export OS_PASSWORD=Huawei@123
export OS_PROJECT_NAME=project_cli
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://10.0.0.11:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
osbash@controller:~$ source user_cli_01-openrc.sh 
osbash@controller:~$ openstack volume transfer request accept --auth-key 2259f0ba77599dfe 33c8cc27-d6bf-49d5-868d-d1b66f7d32d4
+-----------+--------------------------------------+
| Field     | Value                                |
+-----------+--------------------------------------+
| id        | 33c8cc27-d6bf-49d5-868d-d1b66f7d32d4 |
| name      | transfer_cli                         |
| volume_id | a20e0de2-b1d5-4552-85cf-171ef13d411e |
+-----------+--------------------------------------+
osbash@controller:~$ openstack volume list
+--------------------------------------+------------+-----------+------+-------------+
| ID                                   | Name       | Status    | Size | Attached to |
+--------------------------------------+------------+-----------+------+-------------+
| a20e0de2-b1d5-4552-85cf-171ef13d411e | volume_cli | available |    2 |             |
+--------------------------------------+------------+-----------+------+-------------+
```

##### 2.5.2.6、status

```
osbash@controller:~$ openstack volume set --state in-use volume_cli
osbash@controller:~$ openstack volume show volume_cli
+--------------------------------+--------------------------------------+
| Field                          | Value                                |
+--------------------------------+--------------------------------------+
| attachments                    | []                                   |
| availability_zone              | nova                                 |
| bootable                       | false                                |
| consistencygroup_id            | None                                 |
| created_at                     | 2020-12-05T21:28:32.000000           |
| description                    | None                                 |
| encrypted                      | False                                |
| id                             | a20e0de2-b1d5-4552-85cf-171ef13d411e |
| migration_status               | None                                 |
| multiattach                    | False                                |
| name                           | volume_cli                           |
| os-vol-host-attr:host          | compute1@lvm#LVM                     |
| os-vol-mig-status-attr:migstat | None                                 |
| os-vol-mig-status-attr:name_id | None                                 |
| os-vol-tenant-attr:tenant_id   | 52fcdd1c109b4ccebbef22c61d8115a3     |
| properties                     |                                      |
| replication_status             | None                                 |
| size                           | 2                                    |
| snapshot_id                    | None                                 |
| source_volid                   | None                                 |
| status                         | in-use                               |
| type                           | vtype_cli                            |
| updated_at                     | 2020-12-05T21:42:33.000000           |
| user_id                        | 17acecb0f56a447e9cfd8e113f27abbd     |
+--------------------------------+--------------------------------------+
```

## 3、对象存储Swift

### 3.1、Swift简介

#### 3.1.1、对象存储服务是什么？

SWIFT对象存储服务首次出现在OpenStack的“Austin”版本中。

Swift提供高度可用、分布式、最终一致的对象存储服务。

Swift可以高效、安全且廉价地存储大量数据。

Swift非常适合存储需要弹性扩展的非结构化数据。

依赖的OpenStack服务

- 为其他OpenStack服务提供对象存储服务。

#### 3.1.2、Swift在OpenStack中的位置

![swift](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/13.png)

Swift提供高度可用、分布式、最终一致的对象存储服务。

#### 3.1.3、Swift在OpenStack中的作用

![swift](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/14.png)

Swift并不是文件系统或者实时的数据存储系统，它称为对象存储，用于永久类型的静态数据的长期存储，这些数据可以检索、调整，必要时进行更新。

最适合存储的数据类型的例子是虚拟机镜像、图片存储、邮件存储和存档备份。

因为没有中心单元或主控节点，Swift提供了更强的扩展性、冗余和持久性。

Swift经常用于存储镜像或用于存储虚拟机实例卷的备份副本。

#### 3.1.4、Swift特点

![swift](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/15.png)

极高的数据持久性

- 从理论上测算过，Swift在5个Zone、5×10个存储节点的环境下，数据复制份是为3，数据持久性的SLA能达到10个9。

完全对称的系统架构

- “对称”意味着Swift中各节点可以完全对等，能极大地降低系统维护成本。

无限的可扩展性

- 这里的扩展性分两方面，一是数据存储容量无限可扩展；二是Swift性能（如QPS、吞吐量等）可线性提升。因为Swift是完全对称的架构，扩容只需简单地新增机器，系统会自动完成数据迁移等工作，使各存储节点重新达到平衡状态。

无单点故障

- 在互联网业务大规模应用的场景中，存储的单点一直是个难题。例如数据库，一般的HA方法只能做主从，并且“主”一般只有一个；还有一些其他开源存储系统的实现中，元数据信息的存储一直以来是个头痛的地方，一般只能单点存储，而这个单点很容易成为瓶颈，并且一旦这个点出现差异，往往能影响到整个集群。
- Swift的元数据存储是完全均匀随机分布的，并且与对象文件存储一样，元数据也会存储多份。整个Swift集群中，也没有一个角色是单点的，并且在架构和设计上保证无单点业务是有效的。

#### 3.1.5、Swift应用场景

镜像存储后端

- 在OpenStack中与镜像服务Glance结合，为其存储镜像文件。

静态数据存储

- 由于Swift的扩展能力，适合存储日志文件和数据备份仓库。

### 3.2、Swift架构

#### 3.2.1、对象存储服务的架构

- 完全对称、面向资源的分布式系统架构设计

![swift](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/16.png)

Swift中对象的存储URL如下所示：https://swift.example.com/v1/account/container/object

存储URL有两个基本部分：集群位置和存储位置。

- 集群位置：swift.example.com/v1/
- 存储位置（对象）：/account/container/object

存储位置有如下三种：

- /account
  - 帐户存储位置是唯一命名的存储区域，其中包含帐户本身的元数据（描述性信息）以及帐户中的容器列表。
    请注意，在Swift中，帐户不是用户身份。当您听到帐户时，请考虑存储区域。

- /account/container
  - 容器存储位置是帐户内的用户定义的存储区域，其中包含容器本身和容器中的对象列表的元数据。

- /account/container/object
  - 对象存储位置存储了数据对象及其元数据的位置。

#### 3.2.2、Swift组件

Proxy Server

- 对外提供对象服务API，由于采用无状态的REST请求协议，可以进行横向扩展来均衡负载

Account Server

- 提供账号元数据和统计信息，并维护所含容器列表的服务，每个账户的信息被存储在一个SQLite数据库中。

Container Server

- 提供容器元数据和统计信息，并维护所含对象列表的服务，每个容器的信息也存储在一个SQLite数据库中。

Object Server

- 提供对象元数据和内容服务，每个对象的内容会以文件的形式存储在文件系统中，元数据会作为文件属性来存储，建议采用支持扩展属性的XFS文件系统。

Replicator

- 检测本地分区副本和远程副本是否一致，发现不一致时会采用推式（Push）更新远程副本，并且确保被标记删除的对象从文件系统中移除。

Updater

- 当对象由于高负载的原因而无法立即更新时，任务将会被系列化到本地文件系统中进行排队，以便服务恢复后进行异步更新。

Auditor

- 检查对象，容器和账户的完整性，如果发现比特级的错误，文件将被隔离，并复制其他的副本以覆盖本地损坏的副本；其他类型的错误会被记录到日志中。

Account Reaper

- 移除被标记为删除的账户，删除其所包含的所有容器和对象。

#### 3.2.3、Swift API

Swift通过Proxy Server向外提供基于HTTP的REST服务接口，对账户、容器和对象镜像CRUD等操作。

Swift RESTful API总结

| 资源类型 | URL                       | GET                  | PUT                  | POST           | DELETE   | HEAD           |
| -------- | ------------------------- | -------------------- | -------------------- | -------------- | -------- | -------------- |
| 账户     | /account/                 | 获取容器列表         | -                    | -              | -        | 获取账户元数据 |
| 容器     | /account/container        | 获取对象列表         | 创建容器             | 更新容器元数据 | 删除容器 | 获取容器元数据 |
| 对象     | /account/container/object | 获取对象内容和元数据 | 创建、更新或复制对象 | 更新对象元数据 | 删除对象 | 获取对象元数据 |

#### 3.2.4、Swift数据模型

Swift供设三层逻辑结构：Account/Container/Object（即账户/容器/对象）。

每层节点数均没有限制，可以任意扩展。

![swift](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/06/17.png)

使用命令swift stat可以显示Swift中的帐户、容器和对象的信息。

Swift为账户，容器和对象分别定义了Ring（环）将将虚拟节点（分区）映射到一组物理存储设备上，包括Account Ring、Container Ring 、Object Ring。

## 4、思考题

OpenStack中由哪几种类型的存储？

- OpenStack中主要有临时存储和永久性存储。

块存储和对象存储分别适用于哪些场景？

块存储服务主要包含哪些组件？

块存储服务是怎么创建卷的？

对象存储服务主要包含哪些组件？

## 5、测一测

### 5.1、判断

持久化存储设备的生命周期独立于任何其他系统设备或资源，除非用户手动操作，否则存储的数据一直可用，无论虚拟机是否运行。

- `true 正确`
- false

Cinder client与cinder-api、cinder-api与cinder-volume之间都可以通过Message Queue访问彼此。

- true
- `false 正确`

块存储和对象存储都需要被格式化并挂载后才可以访问。

- true

- `false 正确`

### 5.2、单选

以下哪个组件负责执行卷、快照相关的业务，并通过调用不同的driver管理不同的存储后端？

- cinder-scheduler
- cinder-api
- `cinder-volume 正确`
- cinder-client

### 5.3、多选

以下哪些是Swift的特点？

- `无单点故障`
- `完全对称的系统架构`
- `可扩展性强`
- `极高的数据持久性`

