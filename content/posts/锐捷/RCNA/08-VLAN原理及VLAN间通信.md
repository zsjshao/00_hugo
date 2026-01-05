+++
author = "zsjshao"
title = "08_VLAN原理及VLAN间通信"
date = "2020-05-23"
tags = ["NA"]
categories = ["RS"]

+++

## 1、VLAN工作原理

### 1.1、VLAN应用场景

如下场景中，公司内部网络随着主机数目增多，出现带宽浪费、安全等问题

- 交换机从所有接口洪泛广播包
- 级联的二层交换机组成一个巨大的广播域
- 广播数据在广播域中洪泛，占用网络带宽，降低设备性能，导致安全隐患

![01_vlan](http://images.zsjshao.cn/images/rs/08-vlan/01_vlan.png)

- 公司大楼的五层和六层均有技术部和财务部的办公室
- 客户要求部门内部是可以互相通讯的，但部门之间要求相互二层隔离
- 为了实现需求，需要采用划分VLAN的方式实现

![02_vlan](http://images.zsjshao.cn/images/rs/08-vlan/02_vlan.png)

### 1.2、VLAN概述

VLAN定义

- Virtual Local Area Network 虚拟局域网，可以将一台物理交换机通过配置为多台逻辑交换机
- 每台逻辑交换机连接一个局域网，称为VLAN
- 每个VLAN是一个广播域，VLAN可以隔离广播，减小广播域

VLAN的特点

- 基于逻辑的分组，可以根据业务或功能进行分组
- 不受物理位置限制，更加灵活组网
- 减少节点在网络中移动带来的管理代价
- 不同VLAN内用户要通信需要借助三层设备

VLAN的用途

- 控制不必要的广播的扩散，从而提高网络带宽利用率，减少资源浪费
- 划分不同的用户组，对组之间的访问进行限制，从而增加安全性

![03_vlan](http://images.zsjshao.cn/images/rs/08-vlan/03_vlan.png)

### 1.3、VLAN标准

为了实现在互联线缆上承载多个VLAN的数据帧，需要一种能够区分不同VLAN数据帧的方式

- 交换机用VLAN标签区分不同VLAN的以太网帧
- 802.1Q规定了VLAN的标签信息及标签格式

![04_vlan](http://images.zsjshao.cn/images/rs/08-vlan/04_vlan.png)

### 1.4、交换机端口类型

Access端口

- Access端口只能属于一个VLAN，它发送的帧不带有VLAN标签，一般用于连接计算机的端口

Trunk端口

- 可以允许多个VLAN通过，它发出的帧一般是带有VLAN标签的，一般用于交换机之间连接的端口

![05_vlan](http://images.zsjshao.cn/images/rs/08-vlan/05_vlan.png)

### 1.5、802.1Q标准封装

在标准以太网帧头部增加TAG字段

标记协议标识（TPID）

- 固定值0x8100,表示该帧载有802.1Q标记信息

标记控制信息（TCI）

- VLAN ID：12bit，表示VID，可用范围1－4094，用来唯一标识一个VLAN
- Priority：3bit，表示优先级，用于QoS
- Canonical format indicator：1bit，表示总线型以太网、FDDI、令牌环网

![06_vlan](http://images.zsjshao.cn/images/rs/08-vlan/06_vlan.png)

### 1.6、VLAN工作原理

![07_vlan](http://images.zsjshao.cn/images/rs/08-vlan/07_vlan.png)

### 1.7、Native VLAN

- 属于Native VLAN的数据帧在trunk链路上不携带VLAN 标签传输
- 不带标签的数据经过trunk链路时会打上Native VLAN所属的VLAN ID TAG形成802.1Q数据帧。
- 若同一条trunk链路两端配置不同的native VLAN，将造成不同VLAN的数据合并
- 锐捷交换机默认情况下native VLAN为1，建议实际项目中将trunk端口的native VLAN设置为非业务VLAN

## 2、VLAN配置

### 2.1、VLAN的配置步骤

创建VLAN

- 每台交换机上创建对应VLAN

配置Access接口

- 将对应的主机根据接口划分到VLAN

配置Trunk接口

- 交换机互联的接口配置Trunk接口

查看**VLAN**状态与端口状态

![08_vlan](http://images.zsjshao.cn/images/rs/08-vlan/08_vlan.png)

### 2.2、VLAN基本配置

#### 2.2.1、创建VLAN

- 步骤1：创建VLAN
  - Switch(config)#vlan vlan-id

- 步骤2：命名VLAN
  - Switch(config-vlan)#name vlan-name

```
RG-S2652G(config)#vlan 10  // 创建VLAN
RG-S2652G(config-vlan)# name JiShuBu  //VLAN的命名，方便运维
RG-S2652G(config)#vlan 20
RG-S2652G(config-vlan)# name CaiWuBu
```

#### 2.2.2、配置Access口

- 步骤1：进入端口配置模式
  - Swtich(config)#interface interface
- 步骤2：将端口模式设置为接入端口
  - Switch(config-if)#switchport mode access
- 步骤3：将端口添加到特定VLAN
  - Switch(config-if)#switchport access vlan vlan-id

```
RG-S2652G(config)#interface range f0/1-2
RG-S2652G(config-if-range)#switchport access vlan 10  //接口划分到VLAN 10
RG-S2652G(config)#interface f0/3
RG-S2652G(config-if)#switchport access vlan 20
```

#### 2.2.3、将一组端口加入VLAN

- 步骤1：进入到一组需要添加到VLAN的端口中
  - Swtich(config)#interface range interface-range
- 步骤2：将端口模式设置为接入端口
  - Switch(config-range-if)#switchport mode access
- 步骤3：将一组端口划分到指定VLAN
  - Switch(config-range-if)#swtichport access vlan vlan-id 

#### 2.2.4、配置Trunk

- 步骤1：进入需要配置的端口
  - swtich(config)#interface interface
- 步骤2：将端口的模式设置为Trunk
  - Switch(config-if)#switchport mode trunk
- 步骤3：定义Trunk链路的VLAN控制行为列表 （VLAN修剪等）（可选，慎用）
  - Switch(config-if)#switchport trunk allowed vlan { all | [ add | remove | except ] } vlan-list

#### 2.2.5、查看、删除VLAN

- 删除VLAN
  - Switch(config)#no vlan VLAN-id

- 查看配置信息
  - Switch# show vlan

```
Ruijie#show vlan
VLAN Name                             Status    Ports     
---- -------------------------------- --------- -----------------------------------
   1 VLAN0001                         STATIC    Fa0/4, Fa0/5, Fa0/6, Fa0/7            
                                                Fa0/8, Fa0/9, Fa0/10, Fa0/11          
                                                Fa0/12, Fa0/13, Fa0/14, Fa0/15        
                                                Fa0/16, Fa0/17, Fa0/18, Fa0/19        
                                                Fa0/20, Fa0/21, Fa0/22, Fa0/23        
                                                Fa0/24, Gi0/25, Gi0/26                
  10 VLAN0010                         STATIC    Fa0/1, Fa0/2
  20 VLAN0020                         STATIC    Fa0/3
```

## 3、VLAN间通讯

### 3.1、VLAN间通信 —— 单臂路由

在如下应用场景中：单位内部不同子网间需要通信

早期网络将二层交换机与路由器结合，使用“单臂路由”方式进行VLAN间路由

数据帧在Trunk链路上往返发送，会有转发延迟

路由器软件转发IP报文，如果VLAN间路由数据量较大，会消耗大量CPU资源，造成转发性能瓶颈

![09_vlan](http://images.zsjshao.cn/images/rs/08-vlan/09_vlan.png)

### 3.2、VLAN间通信 —— 三层交换机

三层交换机集成了VLAN内部的二层交换和VLAN间路由转发功能

简单说，三层交换技术就是“二层交换技术+三层转发”，解决了上述问题

二层交换基于MAC地址，由硬件实现，低延迟

三层交换基于IP地址，使用硬件ASIC技术，转发速度高

![10_vlan](http://images.zsjshao.cn/images/rs/08-vlan/10_vlan.png)

### 3.3、交换机表项的建立与数据转发

PC1和PC2连接在同一台三层交换机上，位于不同的VLAN，从PC1 ping PC2的通信过程如下：

- 1）PC1判断目标PC2不在同一个子网中，PC发送ARP解析**网关的MAC地址**

- 2）交换机发送**ARP应答**（包含VLAN10的MAC），同时**更新ARP表项与MAC地址表**（ PC1的IP和MAC地址）

![11_vlan](http://images.zsjshao.cn/images/rs/08-vlan/11_vlan.png)

- 3）PC1发送目的IP地址为192.168.20.2的ICMP请求
- 4）交换机收到ICMP请求，根据报文的**目的MAC是VLAN10接口MAC**，判断该报文为**三层转发报文**
- 5）**交换机根据报文目的IP地址192.168.20.2查找三层转发表项，起初并未建立任何记录，交换机将查找软件路由表，发现一个直连路由，继续查找软件ARP表，起初ARP表中没有关于PC2的表项，交换机继续向VLAN20所有端口发送ARP请求，以获取PC2的MAC地址**
- 6）PC2收到交换机发送的ARP请求，发送ARP应答，并将自己的MAC地址包含其中

![12_vlan](http://images.zsjshao.cn/images/rs/08-vlan/12_vlan.png)

- 7）交换机收到PC2的ARP应答，记录PC2的IP和MAC地址对应关系到自己的ARP表，并将PC1的ICMP请求发送给PC2。交换机将在三层转发表项中添加表项（包含IP、MAC、VLAN、出端口），后续的PC1发往PC2的报文就可以直接通过硬件三层表项直接转发。
- 8）PC2收到交换机转发过来的ICMP请求，将回应ICMP应答给交换机，交换机将直接把应答报文由硬件三层交换转发给PC1
- 9）**后续报文都经过查MAC表、查三层转发表的过程，直接进入硬件转发。**

![13_vlan](http://images.zsjshao.cn/images/rs/08-vlan/13_vlan.png)

