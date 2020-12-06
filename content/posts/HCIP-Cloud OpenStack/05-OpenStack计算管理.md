+++
author = "zsjshao"
title = "05-OpenStack计算管理"
date = "2020-12-05"
tags = ["openstack"]
categories = ["HCIP_Cloud OpenStack"]

+++

## 本章导读

本章我们将开始新的章节OpenStack 计算管理。Nova是OpenStack中的核心组件之一，主要负责与计算相关的服务，可以提供大规模可扩展、按需弹性和自助服务的计算资源，可以对虚拟机的生命周期进行管理，因此他是针对虚拟机相关操作的一个组件也是整个OpenStack中最核心的项目。本章我们将同样按照之前的课程设计，分为理论和实验两个部分，理论部分我们将简单介绍Nova的作用，并从其基本架构出发，对其架构进行讲解，然后会对其工作原理和流程进行深入学习。实验部分主要锻炼学员对于Nova的日常运维操作，帮助大家理论联系实际，真正掌握Nova的知识。

本章主要内容包括：

1. OpenStack计算服务Nova简介

2. Nova架构

3. Nova组件详细讲解

4. Nova典型操作

5. Nova典型工作流程

6. OpenStack动手实验：Nova操作

## 1、OpenStack计算服务Nova简介

### 1.1、OpenStack计算服务是什么？

NOVA计算服务首次出现在OpenStack的“Austin”版本中。

Nova提供大规模、可扩展、按需自助服务的计算资源。

Nova支持管理裸机、虚拟机和容器。

依赖的OpenStack服务

- OpenStack最初几个版本中，计算、存储和网络都由Nova实现，后面逐步拆分出存储和网络。

- 目前Nova专注提供计算服务，依赖Keystone的认证服务，Neutron的网络服务，Glance的镜像服务。

### 1.2、Nova在OpenStack中的位置和作用

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/1.png)

Nova是什么？

- OpenStack中提供计算资源服务的项目

Nova负责什么？

- 虚拟机生命周期管理
- 其他计算资源生命周期管理

Nova不负责什么？

- 承载虚拟机的物理主机自身的管理
- 全面的系统状态监控

Nova是OpenStack事实上最核心的项目

- 历史最长：OpenStack首批两个项目之一
- 功能最复杂，代码量最大
- 大部分集成项目和Nova之间都存在配合关系
- 贡献者在社区中的影响力最大

## 2、Nova架构

### 2.1、Nova架构图

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/2.png)

Nova内部服务使用REST调用，Nova和其他OpenStack服务交互时，使用消息队列。

### 2.2、Nova运行架构

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/3.png)

Nova服务各组件可分布式部署，且可通过virtDriver对接不同的虚拟化平台。

### 2.3、Nova资源池管理架构

Region、Availability Zone、Host Aggregate

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/4.png)

Region > Availability Zone > Host Aggregate

## 3、Nova组件详细讲解

### 3.1、Nova组件 - API

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/5.png)

Nova API功能：

- 对外提供REST接口，接收和处理请求。
- 对传入参数进行合法性校验和约束限制。
- 对请求的资源进行配额的校验和预留。
- 资源的创建，更新，删除，查询等。
- 虚拟机生命周期管理的入口。

WSGI：Web Server Gateway Interface

### 3.2、Nova组件 - Conductor

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/6.png)

Nova-Conductor功能

- 数据库操作，解耦其他组件（Nova-Compute）数据库访问。

- Nova复杂流程控制，如创建，冷迁移，热迁移，虚拟机规格调整，虚拟机重建等。

- 其他组件的依赖，如nova-compute需要nova-conductor启动成功后才能启动。

- 其他组件的心跳定时写入。

引入nova-conductor的好处：

- 安全性上考虑。之前每个nova-compute都是直接访问数据库的。如果由于某种原因，某个计算节点被攻陷了，那攻击者就可以获取访问数据库的全部权限，肆意操作数据库。
- 方便升级。将数据库和nova-compute解耦，如果数据库的模式改变，nova-compute就不用升级了。
- 性能上考虑。之前数据库的访问在nova-compute中直接访问且数据库访问是阻塞性的，由于nova-compute只有一个os线程，所以当一个绿色线程去访问数据库的时候会阻塞其他绿色线程，导致绿色线程无法并发。但是nova-conductor是通过rpc 调用，rpc调用是绿色线程友好的，一个rpc call的执行返回前不会阻塞其他绿色线程的执行。这样就会提高了操作的并发。

### 3.3、Nova组件 - Scheduler

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/7.png)

Nova-Scheduler功能

- 筛选和确定将虚拟机实例分配到哪一台物理机。

- 分配过程主要分为两步，过滤和权重：
  - 通过过滤器选择满足条件的计算节点；
  - 通过权重选择最优的节点

Nova-scheduler：确定将虚拟机分配到哪一台物理机，分配过程主要分为两步，过滤和权重；用户创建虚拟机时会提出资源需求，例如CPU、内存、磁盘各需要多少，OpenStack将这些需求定义在flavor中，用户只需要指定flavor就可以了。

### 3.4、Nova组件 - Compute

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/8.png)

Nova-Compute框架

- Manager

- Driver

对接不同的虚拟化平台

- KVM
- VMware
- Xen
- LXC
- QEMU
- ... ...

虚拟机各生命周期操作的真正执行者(会调用对应的hypervisor的driver）。

底层对接不同虚拟化的平台(KVM/VMware/XEN/Ironic等）

内置周期性任务，完成资源刷新，虚拟机状态同步等功能。

资源管理模块(resource_tracker)配合插件机制，完成资源的统计。

### 3.5、Nova服务示例

列出Nova服务

```
osbash@controller:~$ openstack compute service list
+----+----------------+------------+----------+---------+-------+----------------------------+
| ID | Binary         | Host       | Zone     | Status  | State | Updated At                 |
+----+----------------+------------+----------+---------+-------+----------------------------+
|  3 | nova-conductor | controller | internal | enabled | up    | 2020-12-05T14:44:40.000000 |
|  4 | nova-scheduler | controller | internal | enabled | up    | 2020-12-05T14:44:34.000000 |
|  5 | nova-compute   | compute1   | nova     | enabled | up    | 2020-12-05T14:44:39.000000 |
+----+----------------+------------+----------+---------+-------+----------------------------+
```

## 4、Nova典型操作

| 分组               | 说明                                                         |
| ------------------ | ------------------------------------------------------------ |
| 虚拟机生命周期管理 | 虚拟机创建、删除、启动、关机、重启、重建、规格更改、暂停、解除暂停、挂起、继续、迁移、在线迁移、锁定、解锁、疏散、拯救、解拯救、搁置、删除搁置、恢复搁置、备份、虚拟机导出镜像、列表、详细信息、信息查询更改和密码修改 |
| 卷和快照管理操作   | 本质上是对Cinder API的封装。卷创建、删除、列表、详细信息查询。快照创建、删除、列表、详细信息查询 |
| 虚拟机卷操作       | 虚拟机挂卷、虚拟机卸卷、虚拟机挂卷列表、虚拟机挂卷详细信息查询 |
| 虚拟网络操作       | 本质上是对Neutron API的封装。虚拟网络创建、删除、列表、详细信息查询 |
| 虚拟机虚拟网卡操作 | 虚拟机挂载网卡、虚拟机卸载网卡、虚拟机网卡列表               |
| 虚拟机镜像的操作   | 本质上是对Glance API的封装。支持镜像的创建、删除、列表、详细信息查询 |
| 其他资源其他操作   | Flavor，主机组，keypairs，quota等                            |

### 4.1、Nova主要操作对象

| 名称            | 简介                  | 说明                                                         |
| --------------- | --------------------- | ------------------------------------------------------------ |
| Server          | 虚拟机                | Nova管理提供的云服务资源，Nova中最重要的数据对象             |
| Server metadata | 虚拟机元数据          | 通常用于为虚拟机附加必要描述信息，key/value格式              |
| Flavor          | 虚拟机规格模板        | 用于定义虚拟机类型，如2个vCPU、4GB内存，40GB本地存储空间的虚拟机。Flavor由系统管理员创建，供普通用户在创建虚拟机时使用。 |
| Quota           | 资源配额              | 用于指定租户最多能够使用的逻辑资源上限                       |
| Hypervisor/node | 节点                  | 对于KVM、Xen等虚拟化技术，一个node即对应一个物理主机。对于vCenter，一个node对应一个cluster |
| Host            | 主机                  | 对于KVM、Xen等虚拟化技术，一个host即对应一个物理主机，同时对应一个node。对于vCenter，一个host对于一套vCenter部署 |
| Host Aggregate  | 主机组                | 一个HA包含若干host，一个HA内的物理主机通常具有相同的CPU型号等物理资源特性 |
| Server group    | 虚拟机亲和性/反亲和性 | 同一个亲和性组的虚拟机，在创建时会被调度到相同的物理主机上。同一个反亲和性组的虚拟机，在创建时会被调度到不同的物理主机上 |
| Service         | Nova各个服务          | 管理nova相关服务的状态，包括nova-compute，nova-condutor，nova-scheduler，nova-novncproxy，nova-consoleauth，nova-console |
| BDM             | Block device mapping  | 块存储设备，用于描述虚拟机拥有的存储设备信息                 |
| image           | 镜像                  | 包含操作系统的文件，用于创建虚拟机                           |

### 4.2、虚拟机状态介绍

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/9.png)

虚拟机状态类型

- vm_state：数据库中记录的虚拟机状态

- task_state：当前虚拟机的任务状态，一般是中间态或者None。

- power_state：从hypervisor获取的虚拟机的真实状态。

- Status：对外呈现的虚拟机状态

状态之间的关系

- 系统内部只记录vm_state和task_state，power_state

- Statue是由vm_state和task_state联合生成的

举例

- vm_state为active，task_state为rebooting，则status为REBOOT

- vm_state为building，则status为BUILD

### 4.3、虚拟机状态组合

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/10.png)

### 4.4、虚拟机状态变迁图

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/11.png)

## 5、Nova典型工作流程

### 5.1、Nova创建虚拟机流程

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/12.png)

Step1：用户通过Dashboard/CLI申请创建虚拟机，并以REST API方式来请求KeyStone授权

- Keystone鉴定后和送回auth-token（用来通过REST-call向其他组件发送请求）

Step2：Dashboard或者CLI将创建虚拟机请求转换成REST API形式并发送给nova-api

Step3：nova-api收到请求后向keystone发送请求验证auth-token并获取权限

- Keystone验证token并发送角色和权限更新的认证报头

Step4：nova-api联系nova-database ，为新的实例创建初始数据库条目（此时虚拟机状态开始变成building）

Step5：nova-api发送请求给nova-scheduler，以获得适合安装虚拟机的主机

Step6：nova-scheduler从queue中拿到请求

Step7：nova-scheduler联系nova-database通过过滤与权衡来查找最合适的主机

- nova-scheduler在过滤与权衡后返回最适合安装虚拟机的主机的ID
- nova-scheduler发送请求给nova-compute，请求创建虚拟机

Step8：nova-compute从queue中拿到请求，发送请求给nova-conductor以获取选定主机的信息，如规格( ram , cpu,disk)

Step9：nova-conductor从queue中拿到请求，联系nova-db，返回选定主机的信息

- nova-conductor将信息发送到queue中
- nova-compute从queue中得到选定主机的信息

Step10：nova-compute通过传递auth-token给glance-api进行REST调用，向glance请求使用镜像服务

Step11：glance-api与keystone验证auth-token，nova-compute得到镜像元数据

Step12：nova-compute通过传递auth-token给Neutron-api进行REST调用，以获取网络服务

Step13：Neutron-api与keystone验证auth-token，nova-compute得到网络信息

Step14：nova-compute通过传递auth-token给Cinder-api进行REST调用，以获取快存储服务

Step15：cinder-api与keystone验证auth-token，nova-compute得到块存储信息

Step16：nova-compute生成驱动数据，驱动hypervisor生成虚拟机，完成虚拟机创建

### 5.2、Nova调度过程

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/13.png)

### 5.3、Nova过滤调度器

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/14.png)

Nova调度过程，Nova-scheduler的Filter Scheduler

### 5.4、Nova热迁移

![Nova](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/05/15.png)

迁移成功后会清除源节点的信息。

迁移失败后会回滚，清除目标节点的信息。

## 6、OpenStack动手实验：Nova操作

支持本机迁移

```
vim /etc/nova/nova.conf
allow_resize_to_same_host = true

systemctl restart nova*
```

### 6.1、主机聚合

1、创建主机聚合

```
osbash@controller:~$ openstack aggregate create --zone nova aggr_cli
+-------------------+----------------------------+
| Field             | Value                      |
+-------------------+----------------------------+
| availability_zone | nova                       |
| created_at        | 2020-12-05T17:03:30.175232 |
| deleted           | False                      |
| deleted_at        | None                       |
| hosts             | None                       |
| id                | 1                          |
| name              | aggr_cli                   |
| properties        | None                       |
| updated_at        | None                       |
+-------------------+----------------------------+
```

2、添加主机到聚合

```
osbash@controller:~$ openstack aggregate add host aggr_cli compute1
+-------------------+----------------------------+
| Field             | Value                      |
+-------------------+----------------------------+
| availability_zone | nova                       |
| created_at        | 2020-12-05T17:03:30.000000 |
| deleted           | False                      |
| deleted_at        | None                       |
| hosts             | compute1                   |
| id                | 1                          |
| name              | aggr_cli                   |
| properties        | availability_zone='nova'   |
| updated_at        | None                       |
+-------------------+----------------------------+
```

3、查看主机聚合

```
osbash@controller:~$ openstack aggregate show aggr_cli
+-------------------+----------------------------+
| Field             | Value                      |
+-------------------+----------------------------+
| availability_zone | nova                       |
| created_at        | 2020-12-05T17:03:30.000000 |
| deleted           | False                      |
| deleted_at        | None                       |
| hosts             | compute1                   |
| id                | 1                          |
| name              | aggr_cli                   |
| properties        |                            |
| updated_at        | None                       |
+-------------------+----------------------------+
```

4、删除主机聚合

```
osbash@controller:~$ openstack aggregate remove host aggr_cli compute1
+-------------------+----------------------------+
| Field             | Value                      |
+-------------------+----------------------------+
| availability_zone | nova                       |
| created_at        | 2020-12-05T17:03:30.000000 |
| deleted           | False                      |
| deleted_at        | None                       |
| hosts             |                            |
| id                | 1                          |
| name              | aggr_cli                   |
| properties        | availability_zone='nova'   |
| updated_at        | None                       |
+-------------------+----------------------------+
osbash@controller:~$ openstack aggregate delete aggr_cli
```

### 6.2、flavor

1、创建flavor

```
osbash@controller:~$ openstack flavor create --vcpu 1 --ram 128 --disk 1 --private --project project_cli flavor_cli
+----------------------------+--------------------------------------+
| Field                      | Value                                |
+----------------------------+--------------------------------------+
| OS-FLV-DISABLED:disabled   | False                                |
| OS-FLV-EXT-DATA:ephemeral  | 0                                    |
| disk                       | 1                                    |
| id                         | ee0b927a-0ccb-4fe9-8ece-27cfe0e2fb91 |
| name                       | flavor_cli                           |
| os-flavor-access:is_public | False                                |
| properties                 |                                      |
| ram                        | 128                                  |
| rxtx_factor                | 1.0                                  |
| swap                       |                                      |
| vcpus                      | 1                                    |
+----------------------------+--------------------------------------+
```

2、查看flavor

```
osbash@controller:~$ openstack flavor list --all 
+--------------------------------------+------------+-----+------+-----------+-------+-----------+
| ID                                   | Name       | RAM | Disk | Ephemeral | VCPUs | Is Public |
+--------------------------------------+------------+-----+------+-----------+-------+-----------+
| 74f3d398-5c0e-406c-a100-c09479b608d7 | cirrors    | 128 |    1 |         0 |     1 | True      |
| ee0b927a-0ccb-4fe9-8ece-27cfe0e2fb91 | flavor_cli | 128 |    1 |         0 |     1 | False     |
+--------------------------------------+------------+-----+------+-----------+-------+-----------+
```

3、删除flavor

```
osbash@controller:~$ openstack flavor delete flavor_cli
```

### 6.3、server

1、虚拟机操作

```
osbash@controller:~$ openstack server stop cirrors
osbash@controller:~$ openstack server start cirrors
osbash@controller:~$ openstack server reboot --soft  cirrors
osbash@controller:~$ openstack server lock cirrors
osbash@controller:~$ openstack server unlock cirrors
osbash@controller:~$ openstack server pause cirrors
osbash@controller:~$ openstack server unpause cirrors
osbash@controller:~$ openstack server suspend cirrors
osbash@controller:~$ openstack server resume cirrors
osbash@controller:~$ openstack server shelve cirrors
osbash@controller:~$ openstack server unshelve cirrors
```

2、创建快照

```
osbash@controller:~$ openstack server image create --name snap_cli cirrors
```

3、更改虚拟机配置

```
osbash@controller:~$ openstack flavor create --vcpu 1 --ram 156 --disk 1 flavor_cli_new
osbash@controller:~$ openstack server resize --flavor flavor_cli_new cirrors
osbash@controller:~$ openstack server show cirrors
+-------------------------------------+----------------------------------------------------------+
| Field                               | Value                                                    |
+-------------------------------------+----------------------------------------------------------+
| OS-DCF:diskConfig                   | AUTO                                                     |
| OS-EXT-AZ:availability_zone         | nova                                                     |
| OS-EXT-SRV-ATTR:host                | compute1                                                 |
| OS-EXT-SRV-ATTR:hypervisor_hostname | compute1                                                 |
| OS-EXT-SRV-ATTR:instance_name       | instance-00000004                                        |
| OS-EXT-STS:power_state              | Running                                                  |
| OS-EXT-STS:task_state               | None                                                     |
| OS-EXT-STS:vm_state                 | resized                                                  |
| OS-SRV-USG:launched_at              | 2020-12-05T17:34:06.000000                               |
| OS-SRV-USG:terminated_at            | None                                                     |
| accessIPv4                          |                                                          |
| accessIPv6                          |                                                          |
| addresses                           | provider=203.0.113.193                                   |
| config_drive                        |                                                          |
| created                             | 2020-12-05T15:27:05Z                                     |
| flavor                              | flavor_cli_new (0bf54818-d43f-4ad5-ab39-d3d6caa62ce0)    |
| hostId                              | ffed804fb577d99887bcccbaecc763b87bc6b4b0600684fa9f613e4a |
| id                                  | 6900a70b-c777-4c4f-8d75-7b8408199f46                     |
| image                               |                                                          |
| key_name                            | None                                                     |
| name                                | cirrors                                                  |
| progress                            | 0                                                        |
| project_id                          | bc78fc6cc32f4e779eb750d212253523                         |
| properties                          |                                                          |
| security_groups                     | name='default'                                           |
| status                              | VERIFY_RESIZE                                            |
| updated                             | 2020-12-05T17:34:07Z                                     |
| user_id                             | e9926f5e50ed4d069730d92913298ed3                         |
| volumes_attached                    | id='cafac4da-5186-45dd-a39a-72af6dbc910a'                |
+-------------------------------------+----------------------------------------------------------+

osbash@controller:~$ openstack server resize confirm cirrors
osbash@controller:~$ openstack server resize revert cirrors
```

4、rebuild

```
osbash@controller:~$ openstack server rebuild --image snap_cli cirrors
```

5、删除虚拟机

```
osbash@controller:~$ openstack server delete cirrors
```

## 7、思考题

Nova由哪些组件构成，各组件的主要作用是什么？

- nova-api、nova-conductor、nova-scheduler、nova-compute、DB/消息队列

请描述下虚拟机创建流程

请描述下Nova是如何做Filter Scheduler

- 筛选-权重

## 8、测一测

### 8.1、判断

Nova在OpenStack中负责虚拟机生命周期管理和承载虚拟机的物理主机自身的管理。

- true

- `false 正确`

### 8.2、单选

以下关于Nova资源池管理架构中涉及的Region、Availability Zone 和Host Aggregate三个概念关系排列正确的是？

- Region > Host Aggregate > Availability Zone

- Availability Zone > Host Aggregate > Region

- Host Aggregate > Region > Availability Zone

- `Region > Availability Zone > Host Aggregate 正确`

### 8.3、多选

Nova可以对接以下哪些虚拟化平台？

- `KVM`

- `VMware`

- `Xen`
- `Hyper-V`

以下关于虚拟机状态的描述正确的是？

- `vm_state，数据库中记录的虚拟机状态`
- `task_state，当前虚拟机的任务状态`
- `power_state，从hypervisor获取的虚拟机的真实状态`
- `Status是由vm_state和task_state联合生成的，是对外呈现的虚拟机状态`

以下哪些属于Nova的主要操作对象？

- `Flavor`
- `Host`
- `Hypervisor/node`
- `Quota`

