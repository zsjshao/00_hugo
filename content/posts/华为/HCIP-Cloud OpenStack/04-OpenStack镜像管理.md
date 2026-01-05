+++
author = "zsjshao"
title = "04-OpenStack镜像管理"
date = "2020-12-05"
tags = ["openstack"]
categories = ["HCIP_Cloud OpenStack"]

+++

## 本章导读

本章我们主要讲解OpenStack镜像管理Glance部分，Glance也是OpenStack的基础服务，创建虚拟机实例时离不开镜像服务。

本章我们在介绍时仍然会分为两个部分，理论部分主要讲解Glance的作用、架构、原理和流程。实验部分会重点锻炼学员Glance镜像制作和日常维护，帮助大家理论联系实际，真正了解和掌握Glance。

本章内容主要包括：

1. OpenStack镜像服务Glance简介

2. Glance架构

3. Glance工作原理和流程

4. Glance镜像制作

5. OpenStack动手实验： Glance操作

## 1、OpenStack镜像服务Glance简介与架构

### 1.1、镜像服务Glance

GLANCE镜像服务首次出现在OpenStack的“Bexar”版本中。

Glance提供发现、注册和检索虚拟机镜像功能。

Glance提供的虚拟机实例镜像可以存放在不同地方，例如本地文件系统、Swift对象存储、Cinder块存储等。

依赖的OpenStack服务

- keytone

### 1.2、镜像服务在OpenStack中的位置和作用

![Glance](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/04/1.png)

Glance提供发现、注册和检索虚拟机镜像功能，编写时遵循高可用、可恢复和高容错的原则。

## 2、Glance架构

![Glance](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/04/2.png)

Glance 使用C/S架构，提供REST API，用户可以通过API执行对服务器的请求。

### 2.1、Glance组件详解

Client

- Glance-client，使用Glance服务器的任何应用程序，接收请求并调用glance-api。

REST API

- glance-api，通过REST接口对外开放Glance功能，接收请求。

Glance Domain Controller

- 管理Glance内部服务器，Glance Domain Controller分层实现特定任务，如认证、事件通知、策略控制和数据库连接等。

Registry Layer

- 实现Glance Domain Controller与DAL之间的安全访问。

Database Abstraction Layer（DAL）- 数据库抽象层

- 提供Glance与数据库之间的统一API接口

Glance DB

- Glance DB在所有组件之间共享，存放管理、配置信息等数据。

Glance Store

- 负责与外部存储后端或本地文件系统的交互，持久化存储镜像文件。

- Glance Store提供一个统一的接口来访问后端存储，屏蔽不同后端存储的差异。

## 3、Glance工作原理和流程

### 3.1、OpenStack中的镜像、实例和规格

| 镜像Image                                                    | 实例Instance                    | 规格Flavor                                                   |
| ------------------------------------------------------------ | ------------------------------- | ------------------------------------------------------------ |
| 虚拟机镜像包含一个虚拟磁盘，其上包含可引导的操作系统，为虚拟机提供模板。 | 实例是在OpenStack上运行的虚拟机 | 规格定义了实例可以有多少个虚拟CPU，多大的RAM以及多大的临时磁盘。 |

镜像、实例和规格的关系：

- 用户可以从同一个镜像启动任意数量的实例。

- 每个启动的实例都是基于镜像的一个副本，实例上的任何修改都不会影响到镜像。

- 启动实例时，必须指定一个规格，实例按照规格使用资源。

创建实例时必须指定镜像和规格。

### 3.2、Glance镜像磁盘格式

将镜像添加到Glance时，必须指定虚拟机镜像的磁盘格式。

| 磁盘格式 | 描述                                                   |
| -------- | ------------------------------------------------------ |
| raw      | 一种非结构化的磁盘镜像格式                             |
| vhd      | VMware，Xen，Microsoft，VirtualBox等使用的常见磁盘格式 |
| vhdx     | vhd格式的增强版本，支持更大的磁盘容量和其他功能        |
| vmdk     | 常见的磁盘格式                                         |
| vdi      | VirtualBox和QEMU支持的磁盘格式                         |
| iso      | 光盘（例如CDROM）的存档格式                            |
| ploog    | Virtuozzo支持和使用的磁盘格式，用于运行OS Containers   |
| qcow2    | QEMU支持的磁盘格式，支持动态扩展和写时复制             |
| aki      | Amazon Kernel Image                                    |
| ari      | Amazon Ramdisk Image                                   |
| ami      | Amazon Machine Image                                   |

其他镜像，可以先转换成OpenStack支持的格式，再导入使用。

### 3.3、Glance状态机

Glance中有两种状态机：镜像状态和任务状态

| 镜像状态       | 描述                                                         |
| -------------- | ------------------------------------------------------------ |
| queued         | 已在glance-registry中保留镜像标识符，但镜像数据未上传，镜像大小未初始化 |
| saving         | 镜像的原始数据正在上传到Glance中                             |
| uploading      | 对镜像调用了import data-put请求                              |
| importing      | 导入镜像中，但镜像尚未就绪                                   |
| active         | 镜像创建完成，可以使用                                       |
| deactivated    | 禁止任何非管理员用户访问镜像                                 |
| killed         | 镜像上传时出错，镜像不可用                                   |
| deleted        | Glance保留了镜像信息，但不能继续使用，镜像在一定时间后会被自动清理掉 |
| pending_delete | 类似deleted，Glance尚未删除镜像数据，处于该状态的镜像可恢复  |

任务状态

| 任务状态   | 描述           |
| ---------- | -------------- |
| pending    | 任务挂起       |
| processing | 任务正在处理中 |
| success    | 任务执行成功   |
| failure    | 任务执行失败   |

### 3.4、Glance状态机转化图

![Glance](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/04/3.png)

### 3.5、Glance镜像缓存

镜像缓存：在API节点本地存放原始镜像的一个副本，实质上使多个API服务器能够提供相同的镜像。由于提供镜像的服务器数量增加，提升了镜像服务的可伸缩性。

控制cache总量的大小：

周期性清理

- 周期运行glance-cache-pruner

清理image cache

- 通过glance-cache-cleaner清理状态异常的cache文件

预取某些热门镜像到新增的api节点中

- glance-cache-manage --host=<HOST> queue-image <IMAGE_ID>

手动删除image cache来释放空间

- glance-cache-manage --host=<HOST> delete-cached-image <IMAGE_ID>

镜像缓存机制对终端用户来说是透明的，也就是说终端用户不会清楚从Glance服务获取的镜像文件的真实来源。

### 3.6、镜像与实例交互流程 - 实例启动前

![Glance](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/04/4.png)

Glancestore包含一定数量的镜像，计算节点包含可用的vCPU，内存和本地磁盘资源，Cinder-volume包含一定数量的卷。

### 3.7、镜像与实例交互流程 - 实例从镜像启动

![Glance](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/04/5.png)

启动实例时，需要选择一个镜像，规格和任何可选属性。选定的规格提供一个系统盘，标记为vda，另外一个临时盘被标记为vdb，cinder-volume提供的卷被映射到第三个虚拟磁盘并将其称为vdc。

镜像服务将基本镜像从镜像存储复制到本地磁盘。vda是实例访问的第一个磁盘。如果镜像文件越小，则通过网络复制的数据越少，实例启动就会越快。

实例启动时还会创建一块空的临时磁盘vdb，删除实例时将删除此磁盘。

计算节点使用iSCSI 连接到cinder-volume提供的某个卷。该卷被映射到第三个磁盘vdc。计算节点为实例提供vCPU和内存资源后，实例将从根卷vda启动。该实例运行并更改磁盘上的数据（图中红色标示磁盘）。

如果cinder-volume位于单独的网络上，则存储节点配置文件中my_block_storage_ip选项会将镜像流量定向到计算节点。

注意：

- 此示例场景中的某些详细信息可能与实际环境不同。例如，可以使用不同类型的后端存储或不同的网络协议。常见的一种场景是vda，vdb存放在SAN存储，而不是本地磁盘上。

### 3.8、镜像与实例交互流程 - 实例删除后

![Glance](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/04/6.png)

实例被删除后, 除cinder-volume卷之外的其它资源都会被回收。临时磁盘无论是否加密过，都将会被清空，内存和vCPU资源将会被释放。在这个过程中镜像不会发生任何改变。

注意：

- 如果创建实例时选择了“删除实例时删除卷“，则实例删除时，cinder-volume卷也会被删除。

## 4、Glance镜像制作

### 4.1、Glance镜像制作 - 直接下载镜像文件

最简单的Glance镜像制作方法时下载系统供应商官方发布的OpenStack镜像文件。大多数镜像预安装了cloud-init包，支持SSH密钥对登录和用户数据注入功能。

![Glance](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/04/7.png)

镜像的具体下载链接，请参考OpenStack社区网站：

- https://docs.openstack.org/image-guide/obtain-images.html

### 4.2、Glance镜像制作 - 手动制作镜像

如果直接下载的镜像不符合要求，可以手动制作Glance镜像文件

以制作Ubuntu 18.04为例：

- 使用virt-manager创建一个Ubuntu 18.04虚拟机并安装系统

- 登录虚拟机并安装cloud-init       $ sudo apt install cloud-init

- 虚拟机内部，停止虚拟机            $ sudo shutdown -h now

- 预清理虚拟机                                $ sudo virt-sysprep -d VM_ID

- 释放虚拟机定义                             $ virsh undefine VM_ID

- 制作jingx                                       $ qemu-img create

- 上传镜像                                        $ openstack image create

Virt-manager是一套图形化的虚拟机管理工具，提供虚拟机管理的基本功能，如开机，挂起，重启，关机，强制关机/重启，迁移等。

### 4.3、Glance镜像制作 - 常用工具

镜像制作工具

- Diskimage-builder
  - 自动化磁盘映像创建工具，可以制作Fedora，Red Hat Enterprise Linux，Ubuntu，Debian，CentOS和openSuSE镜像。
  - 示例：$ disk-image-create ubuntu vm

- Packer
  - 使用Packer制作的镜像，可以适配到不同云平台，适合使用多个云平台的用户

- virt-builder
  - 快速创建新虚拟机的工具，可以在几分钟或更短的时间内创建各种用于本地或云用途的虚拟机镜像。

### 4.4、Glance镜像制作 - 镜像转换

命令行qemu-img convert

| 镜像格式          | qemu-img参数 |
| ----------------- | ------------ |
| QCOW2（KVM，Xen） | qcow2        |
| QED（KVM）        | qed          |
| RAW               | raw          |
| VDI（VirtualBox） | vdi          |
| VHD（Hyper-V）    | vpc          |
| VMDK（VMware）    | vmdk         |

示例：raw转换为qcow2

```
qemu-img convert -f raw -O qcow2 image.img image.qcow2
```

VBoxManage：VDI（VirtualBox）转换为RAW

```
VBoxManage clonehd image.vdi image.img --format raw
```

## 5、OpenStack动手实验： Glance操作

### 5.1、WEB界面

略

### 5.2、CLI命令行

#### 5.2.1、获取镜像

```
wget http://download.cirros-cloud.net/0.5.1/cirros-0.5.1-x86_64-disk.img
```

#### 5.2.2、查看镜像信息

```
osbash@controller:~$ qemu-img info cirros-0.5.1-x86_64-disk.img
image: cirros-0.5.1-x86_64-disk.img
file format: qcow2
virtual size: 112M (117440512 bytes)
disk size: 16M
cluster_size: 65536
Format specific information:
    compat: 1.1
    lazy refcounts: false
    refcount bits: 16
    corrupt: false
```

#### 5.2.3、help

```
osbash@controller:~$ openstack image --help
Command "image" matches:
  image add project
  image create
  image delete
  image list
  image member list
  image remove project
  image save
  image set
  image show
  image unset
```

#### 5.2.4、上传镜像

```
osbash@controller:~$ source admin-openrc.sh 
osbash@controller:~$ openstack image create --disk-format qcow2 --min-disk 1 --min-ram 128 --private --protected --file ./cirros-0.5.1-x86_64-disk.img img_cli
+------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field            | Value                                                                                                                                                                                      |
+------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| checksum         | 1d3062cd89af34e419f7100277f38b2b                                                                                                                                                           |
| container_format | bare                                                                                                                                                                                       |
| created_at       | 2020-12-05T13:22:05Z                                                                                                                                                                       |
| disk_format      | qcow2                                                                                                                                                                                      |
| file             | /v2/images/b2a69822-dada-46ec-8607-85618f820707/file                                                                                                                                       |
| id               | b2a69822-dada-46ec-8607-85618f820707                                                                                                                                                       |
| min_disk         | 1                                                                                                                                                                                          |
| min_ram          | 128                                                                                                                                                                                        |
| name             | img_cli                                                                                                                                                                                    |
| owner            | bc78fc6cc32f4e779eb750d212253523                                                                                                                                                           |
| properties       | os_hash_algo='sha512', os_hash_value='553d220ed58cfee7dafe003c446a9f197ab5edf8ffc09396c74187cf83873c877e7ae041cb80f3b91489acf687183adcd689b53b38e3ddd22e627e7f98a09c46', os_hidden='False' |
| protected        | True                                                                                                                                                                                       |
| schema           | /v2/schemas/image                                                                                                                                                                          |
| size             | 16338944                                                                                                                                                                                   |
| status           | active                                                                                                                                                                                     |
| tags             |                                                                                                                                                                                            |
| updated_at       | 2020-12-05T13:22:06Z                                                                                                                                                                       |
| virtual_size     | None                                                                                                                                                                                       |
| visibility       | private                                                                                                                                                                                    |
+------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```

#### 5.2.5、查看镜像详细信息

```
osbash@controller:~$ openstack image show img_cli
+------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field            | Value                                                                                                                                                                                      |
+------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| checksum         | 1d3062cd89af34e419f7100277f38b2b                                                                                                                                                           |
| container_format | bare                                                                                                                                                                                       |
| created_at       | 2020-12-05T13:22:05Z                                                                                                                                                                       |
| disk_format      | qcow2                                                                                                                                                                                      |
| file             | /v2/images/b2a69822-dada-46ec-8607-85618f820707/file                                                                                                                                       |
| id               | b2a69822-dada-46ec-8607-85618f820707                                                                                                                                                       |
| min_disk         | 1                                                                                                                                                                                          |
| min_ram          | 128                                                                                                                                                                                        |
| name             | img_cli                                                                                                                                                                                    |
| owner            | bc78fc6cc32f4e779eb750d212253523                                                                                                                                                           |
| properties       | os_hash_algo='sha512', os_hash_value='553d220ed58cfee7dafe003c446a9f197ab5edf8ffc09396c74187cf83873c877e7ae041cb80f3b91489acf687183adcd689b53b38e3ddd22e627e7f98a09c46', os_hidden='False' |
| protected        | True                                                                                                                                                                                       |
| schema           | /v2/schemas/image                                                                                                                                                                          |
| size             | 16338944                                                                                                                                                                                   |
| status           | active                                                                                                                                                                                     |
| tags             |                                                                                                                                                                                            |
| updated_at       | 2020-12-05T13:22:06Z                                                                                                                                                                       |
| virtual_size     | None                                                                                                                                                                                       |
| visibility       | private                                                                                                                                                                                    |
+------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```

#### 5.2.6、设置镜像可见性

```
osbash@controller:~$ openstack image set --shared img_cli
osbash@controller:~$ openstack image add project img_cli project_cli
+------------+--------------------------------------+
| Field      | Value                                |
+------------+--------------------------------------+
| created_at | 2020-12-05T13:26:12Z                 |
| image_id   | b2a69822-dada-46ec-8607-85618f820707 |
| member_id  | 52fcdd1c109b4ccebbef22c61d8115a3     |
| schema     | /v2/schemas/member                   |
| status     | pending                              |
| updated_at | 2020-12-05T13:26:12Z                 |
+------------+--------------------------------------+
```

#### 5.2.7、接收镜像

```
osbash@controller:~$ source user_cli_01-openrc.sh
osbash@controller:~$ openstack image set --accept b2a69822-dada-46ec-8607-85618f820707
osbash@controller:~$ openstack image list
+--------------------------------------+---------+--------+
| ID                                   | Name    | Status |
+--------------------------------------+---------+--------+
| 9c9b8b2c-8c0b-449f-8736-d773b57f08f8 | cirros  | active |
| b2a69822-dada-46ec-8607-85618f820707 | img_cli | active |
+--------------------------------------+---------+--------+
```

#### 5.2.8、格式转换

```
osbash@controller:~$ wget https://mirrors.huaweicloud.com/ubuntu-cloud-images/bionic/current/bionic-server-cloudimg-amd64.vmdk
osbash@controller:~$ qemu-img info bionic-server-cloudimg-amd64.vmdk 
image: bionic-server-cloudimg-amd64.vmdk
file format: vmdk
virtual size: 10G (10737418240 bytes)
disk size: 329M
cluster_size: 65536
Format specific information:
    cid: 2119925927
    parent cid: 4294967295
    create type: streamOptimized
    extents:
        [0]:
            compressed: true
            virtual size: 10737418240
            filename: bionic-server-cloudimg-amd64.vmdk
            cluster size: 65536
            format: 
osbash@controller:~$ qemu-img convert -f vmdk -O qcow2 -c -p bionic-server-cloudimg-amd64.vmdk bionic-server-cloudimg-amd64.qcow2
    (100.00/100%)
```

#### 5.2.9、上传镜像

```
osbash@controller:~$ openstack image create --disk-format qcow2 --min-disk 1 --min-ram 128 --public --unprotected --file ./bionic-server-cloudimg-amd64.qcow2 ubuntu_cli  
+------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Field            | Value                                                                                                                                                                                      |
+------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| checksum         | 282c8ac6c9037ea0aaf98b41de740473                                                                                                                                                           |
| container_format | bare                                                                                                                                                                                       |
| created_at       | 2020-12-05T13:40:54Z                                                                                                                                                                       |
| disk_format      | qcow2                                                                                                                                                                                      |
| file             | /v2/images/87ead516-b52d-4cc5-9697-871328705f54/file                                                                                                                                       |
| id               | 87ead516-b52d-4cc5-9697-871328705f54                                                                                                                                                       |
| min_disk         | 1                                                                                                                                                                                          |
| min_ram          | 128                                                                                                                                                                                        |
| name             | ubuntu_cli                                                                                                                                                                                 |
| owner            | 52fcdd1c109b4ccebbef22c61d8115a3                                                                                                                                                           |
| properties       | os_hash_algo='sha512', os_hash_value='74bd1bc0fcb07cc40417674738a8aa8e99863a3ec9ac1393a85634c2bda7ff7e9b517e773455e62187da79a03144c6247cdfe4cb733fa3a2c7b1966f2266038a', os_hidden='False' |
| protected        | False                                                                                                                                                                                      |
| schema           | /v2/schemas/image                                                                                                                                                                          |
| size             | 361299968                                                                                                                                                                                  |
| status           | active                                                                                                                                                                                     |
| tags             |                                                                                                                                                                                            |
| updated_at       | 2020-12-05T13:40:58Z                                                                                                                                                                       |
| virtual_size     | None                                                                                                                                                                                       |
| visibility       | public                                                                                                                                                                                     |
+------------------+--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
```

#### 5.2.10、导出镜像

```
osbash@controller:~$ openstack image save --file ubuntu.qcow2 ubuntu_cli
```

#### 5.2.11、删除镜像

```
osbash@controller:~$ openstack image delete ubuntu_cli
```

## 6、思考题

Glance的主要作用是什么？

- Glance提供发现、注册和检索虚拟机镜像功能。

Glance中镜像是如何与实例交互的？

如何制作Glance镜像，有哪些方法和常用工具？

- 直接下载
- 手动制作
- 工具制作
  - Diskimage
  - Packer
  - virt-builder

## 7、测一测

### 7.1、判断

Glance提供的虚拟机实例镜像可以存放在不同地方，例如本地文件系统、Swift对象存储、Cinder块存储等。

- `true 正确`
- false

镜像缓存机制对终端用户来说是透明的，也就是说，终端用户并不清楚其从Glance服务中获取的镜像文件的真实来源。

- `true 正确`

- false

### 7.2、单选

以下关于Glance组件的描述，不正确的是？

- Glance-API ，通过REST接口对外开放Glance功能，接收请求

- Glance DB在所有组件之间共享，存放管理、配置信息等数据。

- Glance Store提供一个统一的接口来访问后端存储，屏蔽不同后端存储的差异

- `Registry Layer提供Glance与数据库之间的统一API接口 正确`

### 7.3、多选

### 多选

以下关于OpenStack中的镜像、实例和规格之间的关系描述正确的是？

- `同一时间，用户可以从同一个镜像启动若干个实例`

- 同一时间，用户只可以从同一个镜像启动一个实例

- `每个启动的实例都是基于镜像的一个副本，实例上的任何修改都不会影响到镜像`

- `启动实例时，必须指定一个规格，实例按照规格使用资源`

以下关于Glance镜像磁盘格式的描述正确的是？

- `VHD是VMware、Xen、Microsoft、VirtualBox等使用的常见磁盘格式`

- `ISO是光盘（例如CD/ROM）的存档格式`

- `Qcow2是QEMU支持的磁盘格式，支持动态扩展和写时复制`

- `VDI是VirtualBox和QEMU支持的磁盘格式`

