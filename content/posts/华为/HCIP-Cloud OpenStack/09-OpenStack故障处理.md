+++
author = "zsjshao"
title = "09-OpenStack故障处理"
date = "2020-12-05"
tags = ["openstack"]
categories = ["HCIP_Cloud OpenStack"]

+++

## 本章导读

OpenSatck服务众多，因此运维人员有必要了解和掌握OpenStack故障处理知识，从而更好地运维OpenStack。本章先从理论方面入手，主要讲解OpenStack故障处理基础知识、工具、典型排错方法及与故障处理相关的其他OpenStack服务。之后通过实验，重点练习OpenStack故障处理基本流程、常用命令及典型故障处理案例，帮助学员理论联系实际，真正掌握OpenStack故障处理能力 。

## 1、OpenStack故障处理基础

### 1.1、OpenStack故障处理一般方法

OpenStack发生故障时，可以通过以下方法进行故障诊断和处理：

![check](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/09/01.png)

这些方法之间没有严格的先后顺序，请根据实际情况选择不同故障处理方法。

### 1.2、验证OpenStack服务状态

要确保OpenStack服务已启动并运行，请验证每个控制器节点上的服务状态。某些OpenStack服务需要在非控制器节点上进行额外验证

方法一：

- 使用SERVICE_NAMEservice-list可以快速验证OpenStack服务状态：
  - 例如nova service-list

方法二：

- 如果服务不支持service-list命令，可以使用如下方法验证：
  - 先ps aux | grep SERVICE_NAME查找出服务
    - 例如ps aux | grep nova
  - 在service SERVICE_NAME status验证服务状态
    - 例如service nova-api status

Ubuntu目前一般使用systemctl管理服务，例如systemctlstatus nova-api.service。

### 1.3、验证OpenStack服务状态一览表

![check](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/09/02.png)

如果服务状态异常，可以尝试重启服务，例如service nova-compute restart

systemctl restart nova-compute.service

### 1.4、检查OpenStack服务日志记录

OpenStack的日志系统非常完善，大多数的故障都能从日志中找到原因。

OpenStack日志路径通常在/var/log/SERVICE_NAME下。

![check](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/09/03.png)

#### 1.4.1、检查OpenStack服务日志记录 - 日志解读

OpenStack的日志格式都是统一的：

![check](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/09/04.png)

- 代码模块是nova.virt.libvirt.config
- 日志内容是生成XML文件
- 源代码文件是/opt/stack/nova/nova/virt/libvirt/config.py的82行，方法是to_xml

日志格式说明：

- 时间戳日志记录的时间，包括年月日时分秒毫秒
- 日志等级有INFO WARNING ERROR DEBUG等
- 代码模块当前运行的模块Request ID 日志会记录连续不同的操作，为了便于区分和增加可读性，每个操作都被分配唯一的Request ID,便于查找
- 日志内容这是日志的主体，记录当前正在执行的操作和结果等重要信息
- 源代码位置日志代码的位置，包括方法名称，源代码文件的目录位置和行号。这一项不是所有日志都有

### 1.5、为OpenStack服务启动调式模式

如果需要获取更多日志信息，可以为OpenStack服务启动调式模式。

开启调试模式，登录每个控制节点，将OpenStack服务配置文件的DEFAULT部分配置为“debug=true”。

- 例如Nova，配置/etc/nova/nova.conf/的DEFAULT部分

```
debug=true
```

注意：

- 处理故障后，请及时关闭OpenStack服务的调试模式，否则会影响性能。

以下服务需要其他配置才能启用调试模式：

- Cinder，使用Cinder角色编辑每个节点上的配置文件。
- Glance，两个配置文件：/etc/glance/glance-api.conf 和/etc/glance/glance-registry.conf

### 1.6、检查OpenStack服务的配置文件

警告：

- 一般情况下，避免修改OpenStack服务的配置文件，可能严重影响OpenStack。
- 修改配置文件前，务必确保提供备份配置文件，以便随时还原。

![check](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/09/05.png)

### 1.7、OpenStack外部故障

![check](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/09/06.png)

## 2、OpenStack故障处理工具

### 2.1、OpenStack故障处理常用工具 - Inav日志查看

基于消息的时间戳，Inav能把多个日志文件合并到一个视图，并将警告和错误信息以不同颜色高亮显示，故障处理更加直观。

例如，合并查看Nova和Glance的日志，追踪虚拟机请求启动镜像的详细情况：

```
$ lnav /var/log/nova/nova-api.log /var/log/glance/glance-api.log
```

Lnav需要自行安装

- Ubuntu ：sudoapt install lnav
- CentOS ：sudo yum -y install epel-release& sudo yum -y install lnav

### 2.2、OpenStack故障处理常用工具 - 命令行debug

执行OpenStack命令时，使用“debug”选项可以追踪命令详细执行过程。

```
openstack server create --flavor cirros --image cirros --network provider cirros --debug
```

## 3、OpenStack典型故障处理

![check](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/09/07.png)

### 3.1、Nova故障案例 - No valid host was found

根据不同调度器故障，采用不同故障处理方法

![check](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/09/08.png)

![check](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/09/09.png)

## 4、OpenStack动手实验：故障处理

略

## 5、OpenStack故障处理相关项目

### 5.1、根因分析Vitrage

VITRAGE根因分析服务首次出现在OpenStack的“Newton”版本中。

Vitrage为OpenStack提供故障根本原因分析。

Vitrage能够组织，分析和可视化OpenStack警报和事件，给出问题出现的根本原因，并能提前预测可能出现的问题点。

依赖的OpenStack服务

- Keystone

帮助OpenStack故障处理

- 预防故障，出现故障时帮助找出故障根本原因

### 5.2、告警Aodh

AODH告警服务首次出现在OpenStack的“Liberty”版本中

Aodh为OpenStack给提供资源告警服务。

Aodh主要基于ceilometer所获取的测量值或者事件，当达到告警阈值时，自动触发告警。

依赖的OpenStack服务

- Keystone

帮助OpenStack故障处理

- 监控资源状态，产生故障告警事件和消息。

### 5.3、监控Monasca

MONASCA监控服务首次出现在OpenStack的“mitaka”版本中。

Monasca是与OpenStack集成的多租户，可扩展，高性能，容错的监控即服务解决方案。

Monasca实验REST API进行高速处理和查询，并具有流式警报引擎和通知引擎。

依赖的OpenStack服务

- Keystone

帮助OpenStack故障处理

- 监控告警，及时通知故障处理。

### 5.4、工作流Mistral

MISTRAL工作流服务首次出现在OpenStack的“Liberty”版本中。

Mistral为OpenStack提供工作流服务。

Mistral能够将多个业务流程在分布式环境中以特定顺序自动执行，保证业务执行的正确性。

依赖的OpenStack服务

- Keystone

帮助OpenStack故障处理

- 提前定义故障处理工作流，出现特定故障时自动执行工作流，自动处理故障。

### 5.5、灾备Freezer

FREEZER灾备服务首次出现在OpenStack的“Mitaka”版本中。

Freezer提供分布式备份，还原和灾难恢复服务。

Freezer支持不同类型操作系统（Linux，Windows，OSX ...），提供基于块的备份，基于文件的增量备份，时间点操作，作业同步等功能。

依赖的OpenStack服务

- Keystone

帮助OpenStack故障处理

- 发生故障时，避免丢失数据，恢复数据和业务运行。

### 5.6、示例：智能化OpenStack故障处理

![check](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/09/10.png)

## 6、思考题

有哪些常用OpenStack故障处理工具？

如果虚拟机不能从DHCP获取IP，如何排除故障？

如果不能创建虚拟机，提示“No valid host was found”，如何排除故障？

## 7、测一测

### 7.1、多选

以下哪些是OpenStack中常用的故障处理方法？

- `验证 OpenSatck 服务状态`
- `检查 OpenSatck 服务日志记录`
- `为 OpenSatck 服务启用调试模式`
- `检查 OpenSatck 服务的配置文件`

OpenStack日志系统非常完善，其日志等级有哪些？

- `NFO`
- `ERROR`
- FATAL
- `DEBUG`

### 7.2、单选

OpenSatck出现故障时一般会有故障代码，以下关于故障代码描述不正确的是？

- 401表示身份认证失败

- 403表示权限被拒绝

- 503表示服务不可用

- `505表示内部错误 正确`

### 7.3、判断

当我们需要获取更多日志信息，来定位故障或问题时，可以为OpenStack服务启用调试模式。

- `true 正确`

- false

OpenStack服务故障处理完毕后，需要及时关闭OpenSatck服务的调试模式，否则会影响性能。

- `true 正确`

- false

