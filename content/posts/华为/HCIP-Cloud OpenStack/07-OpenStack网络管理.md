+++
author = "zsjshao"
title = "07-OpenStack网络管理"
date = "2020-12-05"
tags = ["openstack"]
categories = ["HCIP_Cloud OpenStack"]

+++

## 本章导读

今天我们来讲解OpenSatck网络管理的内容。首先看下前言部分，Neutron作为OpenStack的核心项目，为OpenStack提供“网络即服务”，实现灵活和自动化管理OpenStack网络。

本章节分为两个部分：理论和实验。理论部分主要讲解Linux网络虚拟化基础，Neutron作用、架构、原理和流程。实验部分重点锻炼学员Neutron日常运维操作，帮助学员理论联系实际，真正掌握Neutron 。

本章的主要内容包括：

1. Linux网络虚拟化基础

2. OpenStack网络服务Neutron简介

3. Neutron概念

4. Neutron架构与组件分析

5. OpenStack动手实验： Neutron操作

6. Neutron网络流量分析

## 1、Linux网络虚拟化基础

### 1.1、为什么介绍Linux网络虚拟化基础知识？

Neutron在技术实现上，充分利用了Linux各种网络相关的技术，包括网卡虚拟化、交换机虚拟化以及网络隔离等。

Neutron的设计目标是实现“网络即服务”。

- 设计上：遵循基于“软件定义网络（SDN）”的灵活和自动化原则。
- 实现上：充分利用Linux各种网络相关的技术。

学习Linux系统中的网络虚拟化知识，有助于快速理解Neutron的原理和实现。

### 1.2、物理网络和虚拟化网络

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/01.png)

Neutron最为核心的工作是对二层物理网络的抽象与管理，物理服务器虚拟化后，虚拟机的网络功能由虚拟网卡（vNIC）提供，物理交换机（Switch）也被虚拟化为虚拟交换机（vSwitch），各个vNIC连接在vSwitch的端口上，最后这些vSwitch通过物理服务器的物理网卡访问外部的物理网络。

### 1.3、Linux网络虚拟化实现技术

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/02.png)

OpenStack中使用较多的网络虚拟化技术主要是网卡虚拟化、交换机虚拟化和网络隔离。

#### 1.3.1、Linux网卡虚拟化 - TAP/TUN/VETH

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/03.png)

TAP设备：模拟一个二层的网络设备，可以接收和发送二层数据包

TUN设备：模拟一个三层的网络设备，可以接收和发送三层数据包。

VETH：虚拟Ethernet接口，通常以pair的方式出现，一端发出的数据包，会被另一端接收，可以形成两个网桥之间的通道

TAP/TUN 提供了一台主机内用户空间的数据传输机制。它虚拟了一套网络接口，这套接口和物理的接口无任何区别，可以配置IP，可以路由流量，不同的是，它的流量只在主机内流通。

TAP/TUN 有些许的不同，TUN 只操作三层的IP 包，而TAP 操作二层的以太网帧。

Veth-Pair 是成对出现的一种虚拟网络设备，一端连接着协议栈，一端连接着彼此，数据从一端出，从另一端进。它的这个特性常常用来连接不同的虚拟网络组件，构建大规模的虚拟网络拓扑，比如连接Linux Bridge、OVS、LXC 容器等。一个很常见的案例就是它被用于OpenStack Neutron，构建非常复杂的网络形态。

#### 1.3.2、Linux交换机虚拟化 - Linux bridge

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/04.png)

Linux bridge：工作于二层的网络设备，功能类似于物理交换机。

Bridge可以绑定Linux上的其他网络设备，并将这些设备虚拟化为端口。

当一个设备被绑定到bridge时，就相当于物理交换机端口插入了一条连接着终端的网线。

使用brctl命令配置Linux bridge：

- brctl addbr BRIDGE
- brctl addif BRIDGE DEVICE

#### 1.3.3、Linux交换机虚拟化 - Open vSwitch

Open vSwitch是产品级的虚拟交换机。

- Linux bridge更适用于小规模，主机内部间通信场景。

- Open vSwitch更适合于大规模，多主机间通信场景。

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/05.png)

Open vSwitch常用的命令：

- ovs-vsctl add-br BRIDGE
- ovs-vsctl add-port BRIDGE PORT
- ovs-vsctl show BRIDGE
- ovs-vsctl dump-ports-desc BRIDGE
- ovs-vsctl dump-flows BRIDGE

### 1.4、Linux网络隔离 - Network Namespace

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/06.png)

Network Namespace能创建多个隔离的网络空间，它们有独自的网络配置信息，例如网络设备、路由表、iptables等。

不同网络空间中的虚拟机运行的时候仿佛自己就在独立的网络中。

```
osbash@controller:~$ ip netns help
Usage: ip netns list
       ip netns add NAME
       ip netns set NAME NETNSID
       ip [-all] netns delete [NAME]
       ip netns identify [PID]
       ip netns pids NAME
       ip [-all] netns exec [NAME] cmd ...
       ip netns monitor
       ip netns list-id
```

Network Namespace通常与VRF（Virtual Routing Forwarding虚拟路由和转发）一起工作，VRF是一种IP技术，允许路由表的多个实例同时在同一路由器上共存。

使用VETH可以连接两个不同网络命名空间，使用Bridge可以连接多个不同网络命名空间。



## 2、OpenStack网络服务Neutron简介

本单元我们主要介绍OpenStack中的网络服务Neurton及其作用，还将介绍Neutron中的各种相关概念，包括Network、Subnet、Port、Router、Floating IP、Physical Network、Provider Network、Self-service Netwok、External Netwrok、Security Group等。

### 2.1、网络服务Neutron

NEUTRON网络服务首次出现在OpenStack的“Folsom”版本中。

Neutron负责管理虚拟网络组件，专注于为OpenStack提供网络即服务（NaaS）。

依赖的OpenStack服务

- Keystone

### 2.2、Neutron在OpenStack中的位置和作用

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/07.png)

Neutron负责管理虚拟网络组件，专注于为OpenStack提供网络即服务（NaaS）。

## 3、Neutron概念

Neutron是一种虚拟网络服务，为OpenStack计算提供网络连通和寻址服务。

为了便于操作管理，Neutron对网络进行了抽象，有如下基本管理对象：

- Network
- Subnet
- Port
- Router
- Floating IP

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/08.png)

### 3.1、Neutron概念 - Network

Network：网络

一个隔离的、虚拟二层广播域，也可看出一个Virtual Switch，或者Logical Switch。

Neutron支持多种类型的Network，包括Local，Flat，VLAN，VXLAN和GRE。

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/09.png)

Local：与其他网络和节点隔离。Local 网络中的虚拟机只能与位于同一节点上同一网络的虚拟机通信，Local 网络主要用于单机测试。

Flat：无VLAN tagging的网络。Flat网络中虚拟机能与位于同一网络的虚拟机通信，并可以跨多个节点。

VLAN：802.1q tagging网络。VLAN是一个二层的广播域，同一VLAN中的虚拟机可以通信，不同VLAN只能通过Router通信。VLAN网络可跨节点，是应用最广泛的网络类型。

VXLAN：基于隧道技术的overlay网络。VXLAN网络通过唯一的segmentation ID（也叫VNI）与其他VXLAN网络区分。VXLAN中数据包会通过VNI封装成UDP包进行传输。因为二层的包通过封装在三层传输，能够克服VLAN 和物理网络基础设施的限制。

GRE：与VXLAN类似的一种overlay网络，主要区别在于使用IP包而非UDP进行封装。

生产环境中，一般使用的是VLAN、VXLAN或GRE网络。

### 3.2、Neutron概念 - Subnet

Subnet：子网

- 一个IPv4或者IPv6地址段。虚拟机的IP从Subnet中分配。每个Subnet需要定义IP地址的范围和掩码。
- Subnet必须于Network关联。
- Subnet可选属性：DNS，网关IP，静态路由

### 3.3、Neutron概念 - Port

Port：端口

- 逻辑网络交换机上的虚拟交换端口
- 虚拟机通过Port附着到Network上
- Port可以分配IP地址和Mac地址。

### 3.4、Neutron概念 - Router

Router：路由器

- 连接租户内同一Network或不同Network之间的子网，以及连接内外网。

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/10.png)

### 3.5、Neutron概念 - Fixed IP

Fixed IP：固定IP

- 分配到每个端口上的IP，类似于物理环境中配置到网卡上的IP

### 3.6、Neutron概念 - Floating IP

Floating IP：浮动IP

- Floating IP是从External Network创建的一种特殊Port，可以将Floating IP绑定到任意Network中的Port上，底层会做NAT转发，将发送给Floating IP的流量转发到该Port对应的Fixed IP上。
- 外界可以通过Floating IP访问虚拟机，虚拟机也可以通过Floating IP访问外界。

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/11.png)

### 3.7、Neutron概念 - Physical Network

Physical Network：物理网络

- 在物理网络环境中连接OpenStack不同节点的网络，每个物理网络可以支持Neutron中的一个或多个虚拟网络。

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/12.png)

OpenStack必须通过Physical Network才能和真实物理网络通信。

### 3.8、Neutron概念 - Provider Network

Provider Network：

- 由OpenStack管理员创建的，直接对应于数据中心现有物理网络的一个网段。
- Provider Network通常使用VLAN或者Flat模式，可以在多个租户之间共享。

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/13.png)

### 3.9、Neutron概念 - Self-service Network

Self-service Network：自助服务网络，也叫租户网络或项目网络

- 由OpenStack租户创建的，完全虚拟的，只在本网络内部连通，不能在租户间共享。
- Self-service Network通常使用VXLAN或者GRE模式，可以通过Virtual Router的SNAT与Provider Network通信。

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/14.png)

不同Self-service Network中的网段可以相同，类似于物理环境中不同公司的内部网络。

Self-service Network如果需要和外部物理网络通信，需要通过Router，类似于物理环境中公司上网需要通过路由器或防火墙。

### 3.10、Neutron概念 - External Network

External Network：外部网络，也叫公共网络

- 一种特殊的Provider Network，连接的物理网络与数据中心或Internet相通，网络中的Port可以访问外网。
- 一般将租户的Virtual Router连接到该网络，并创建Floating IP绑定虚拟机，实现虚拟机与外网通信。

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/15.png)

External Network类似于物理环境中直接使用公网IP网段，不同的是，OpenStack中External Network对应的物理网络不一定能直连Internet，有可能只是数据中心的一个内部私有网络。

### 3.11、Neutron概念 - Security Group

Security Group：安全组

- 安全组是作用在neutron port上的一组策略，规定了虚拟机入口和出口流量的规则。
- 安全组基于Linux Iptables实现。
- 安全组默认拒绝所有流量，只有添加了放行规则的流量才允许通过。
- 每个OpenStack项目中都有一个default默认安全组，默认包含如下规则：
  - 拒绝所有入口流量，允许所有出口流量

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/16.png)

## 4、Neutron架构与组件分析

### 4.1、Neutron架构图

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/17.png)

Neutron 架构原则

- 统一API
- 核心部分最小化
- 可插入式的开放架构
- 可扩展

Message Queue

- Neutron-server使用Message Queue与其他Neutron agents进行交换消息，但是这个Message Queue不会用于Neutron-server与其他OpenStack组件（如nova ）进行交换消息。

L2 Agent

- 负责连接端口（ports）和设备，使他们处于共享的广播域(broadcast domain)。通常运行在Hypervisor上。

L3 Agent

- 负责连接tenant网络到数据中心，或连接到Internet。在真实的部署环境中，一般都需要多个L3 Agent同时运行。

DHCP agent

- 用于自动配置虚拟机网络。

Advanced Service

- 提供LB、Firewall和VPN等服务。

### 4.2、Neutron架构说明

Neutron的架构是基于插件的，不同的插件提供不同的网络服务，主要包含如下插件：

- Neutron Server
  - 对外提供网络API，并调用Plugin处理请求。

- Plugin
  - 处理Neutron Server的请求，维护网络状态，并调用Agent处理请求。

- Agent
  - 处理Plugin的请求，调用底层虚拟或物理网络设备实现各种网络功能。

Neutron Server

Core Plugin

Service Plugin

- L3 Service Plugin
- LB Service Plugin
- Firewall Service Plugin
- VPN  Service Plugin

各种Agent

- L2（ovs-agent）
- L3 Agent
- DHCP Agent
- MetaData Agent

#### 4.2.1、Neutron组件 - Neutron Server

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/18.png)

Neutron Server = APIs + Plugins

- API定义各类网络服务

- Plugin实现各类网络服务

Neutron Server = APIs + Plugins，通过这种方式，可以自由对接不同网络后端能力。

#### 4.2.2、Neutron组件 - Core Plugin

Core Plugin，主要是指ML2 Plugin，是一个开放性框架，在一个plugin下，可以集成各个厂家、各种后端技术支持的Layer 2网络服务。

- 通过Type Driver和Mechanism Driver调用不同的底层网络技术，实现二层互通。

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/19.png)

ML2= Modular Layer 2

Core plugin 提供基础的网络功能，使用不同的drivers调用不同的底层网络实现技术。

ML2 Plugin的Drivers主要分为以下两种：

- Type Driver：定义了网络类型，每种网络类型对应一个Type Driver。
- Mechanism Driver：对接各种二层网络技术和物理交换设备，如OVS，Linux Bridge等。Mechanism Driver从Type Driver获取相关的底层网络信息，确保对应的底层技术能够根据这些信息正确配置二层网络。

#### 4.2.3、Neutron组件 - Service Plugin

Service Plugin用于实现高价网络服务，例如路由、负责均衡、防火墙和VPN服务等。

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/20.png)

L3 Service Plugin主要提供路由，浮动IP服务等。

#### 4.2.4、Neutron组件 - Agent

Neutron Agent向虚拟机提供二层和三层的网络连接、完成虚拟网络和物理网络之间的转换、提供扩展服务等。

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/21.png)

## 5、OpenStack动手实验：Neutron操作

### 5.1、Neutron操作 - 常用命令

```
neutron net-create
neutron net-list
neutron subnet-list
neutron port-create
neutron router-interface-add
neutron agent-list
```

### 5.2、network

```
osbash@controller:~$ openstack network create --share network_cli
osbash@controller:~$ openstack network list
+--------------------------------------+-------------+--------------------------------------+
| ID                                   | Name        | Subnets                              |
+--------------------------------------+-------------+--------------------------------------+
| 53a8a22e-089d-451c-8843-8e1e190e103e | network_cli |                                      |
| 7026b16b-dc98-4283-aeda-027cb66e3c39 | selfservice | 469317e6-f2dd-496f-b2ba-d33169cf4d4f |
| b8452e19-b6b5-4c96-831a-5ddc05e73c94 | provider    | 5b085117-9dc3-4326-9561-984501e1278e |
+--------------------------------------+-------------+--------------------------------------+
```

### 5.3、subnet

```
osbash@controller:~$ openstack subnet create --network network_cli --subnet-range 192.168.21.0/24 --allocation-pool start=192.168.21.100,end=192.168.21.200 --gateway 192.168.21.254 subnet_cli
osbash@controller:~$ openstack subnet list
+--------------------------------------+-------------+--------------------------------------+-----------------+
| ID                                   | Name        | Network                              | Subnet          |
+--------------------------------------+-------------+--------------------------------------+-----------------+
| 469317e6-f2dd-496f-b2ba-d33169cf4d4f | selfservice | 7026b16b-dc98-4283-aeda-027cb66e3c39 | 172.16.1.0/24   |
| 5b085117-9dc3-4326-9561-984501e1278e | provider    | b8452e19-b6b5-4c96-831a-5ddc05e73c94 | 203.0.113.0/24  |
| bf87d804-953f-43f6-a057-7c173677e05a | subnet_cli  | 53a8a22e-089d-451c-8843-8e1e190e103e | 192.168.21.0/24 |
+--------------------------------------+-------------+--------------------------------------+-----------------+
osbash@controller:~$ openstack port list --network network_cli --long
+--------------------------------------+------+-------------------+-------------------------------------------------------------------------------+--------+-----------------+--------------+------+
| ID                                   | Name | MAC Address       | Fixed IP Addresses                                                            | Status | Security Groups | Device Owner | Tags |
+--------------------------------------+------+-------------------+-------------------------------------------------------------------------------+--------+-----------------+--------------+------+
| f346ea48-ff33-4446-9411-005c062f2ce9 |      | fa:16:3e:fc:47:f3 | ip_address='192.168.21.100', subnet_id='bf87d804-953f-43f6-a057-7c173677e05a' | ACTIVE |                 | network:dhcp |      |
+--------------------------------------+------+-------------------+-------------------------------------------------------------------------------+--------+-----------------+--------------+------+
```

### 5.4、router

```
osbash@controller:~$ openstack router create router_cli
osbash@controller:~$ openstack router list
+--------------------------------------+------------+--------+-------+----------------------------------+-------------+-------+
| ID                                   | Name       | Status | State | Project                          | Distributed | HA    |
+--------------------------------------+------------+--------+-------+----------------------------------+-------------+-------+
| 044314a1-27e2-4456-ac1e-19c2a0c58a6e | router     | ACTIVE | UP    | 0afea53657dd41fd97371ef246786515 | False       | False |
| 4a0d0815-fe50-4feb-ac4b-2d0d9b877f15 | router_cli | ACTIVE | UP    | bc78fc6cc32f4e779eb750d212253523 | False       | False |
+--------------------------------------+------------+--------+-------+----------------------------------+-------------+-------+
osbash@controller:~$ openstack router set --external-gateway provider router_cli
osbash@controller:~$ openstack router add subnet router_cli subnet_cli
```

### 5.5、floating ip

```
osbash@controller:~$ openstack floating ip create provider
osbash@controller:~$ openstack floating ip list
+--------------------------------------+---------------------+------------------+------+--------------------------------------+----------------------------------+
| ID                                   | Floating IP Address | Fixed IP Address | Port | Floating Network                     | Project                          |
+--------------------------------------+---------------------+------------------+------+--------------------------------------+----------------------------------+
| 2aea1d14-3b9f-4412-9688-150c1bf6321d | 203.0.113.119       | None             | None | b8452e19-b6b5-4c96-831a-5ddc05e73c94 | bc78fc6cc32f4e779eb750d212253523 |
+--------------------------------------+---------------------+------------------+------+--------------------------------------+----------------------------------+

osbash@controller:~$ openstack server add floating ip cirrors 203.0.113.119
osbash@controller:~$ openstack server remove floating ip cirrors 203.0.113.193
osbash@controller:~$ openstack floating ip delete 203.0.113.119
```

### 5.6、Security Group

```
osbash@controller:~$ openstack security group create sg_cli
osbash@controller:~$ openstack security group rule create --protocol ICMP --ingress --remote-ip 0.0.0.0/0 sg_cli
osbash@controller:~$ openstack security group rule create --protocol TCP --ingress --remote-ip 0.0.0.0/0 sg_cli
osbash@controller:~$ openstack security group rule list | grep cf7eee04-fa5a-47a3-b202-e705f04394c0
| 9629a3d0-067e-4c78-9c40-f5c6ed4ba332 | None        | IPv6      | ::/0      |            | None                                 | cf7eee04-fa5a-47a3-b202-e705f04394c0 |
| d0787975-cf68-4c4e-8c1a-14bee1c42760 | tcp         | IPv4      | 0.0.0.0/0 |            | None                                 | cf7eee04-fa5a-47a3-b202-e705f04394c0 |
| db14672e-648e-4bf7-9af6-26b26f8b73b1 | None        | IPv4      | 0.0.0.0/0 |            | None                                 | cf7eee04-fa5a-47a3-b202-e705f04394c0 |
| fde64300-0895-41d1-9005-03365e4e17b8 | icmp        | IPv4      | 0.0.0.0/0 |            | None                                 | cf7eee04-fa5a-47a3-b202-e705f04394c0 |

osbash@controller:~$ openstack server remove security group cirrors default              
osbash@controller:~$ openstack server add security group cirrors sg_cli
```

## 6、Neutron网络流量分析

Neutron支持多种多样的网络技术和类型，可以自由组合各种网络模型。

如下两种网络模型是OpenStack生产环境中常用的：

- Linux Bridge + Flat/VLAN网络
  - 仅提供简单的网络互通，虚拟网络、路由、负责均衡等由物理设备提供。
  - 网络简单、高效，适合中小企业私有云网络场景。

- Open vSwitch + VXLAN网络
  - 提供多租户、大规模网络隔离能力，适合大规模私有云或公有云网络场景。

### 6.1、Linux Bridge + Flat网络

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/22.png)

Flat网络类似于使用网线直接连接物理网络，OpenStack不负责网络隔离。

图中interface 2不带VLAN tag。

### 6.2、Linux Bridge + VLAN网络

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/23.png)

图中interface 2需通过多个VLAN，连接的物理交换机一般需配置trunk模式，并允许这些VLAN通过。

#### 6.2.1、Linux Bridge + VLAN实现

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/24.png)

使用Linux Bridge + VLAN网络时：

- ML2的Type Driver为VLAN
- ML2的Mechanism Driver为LinuxBridge
- L2 Agent为LinuxBridge

#### 6.2.2、Linux Bridge + VLAN场景说明

使用Linux Bridge + VLAN实现Provider Network，网络流量可以分为如下几种：

- 南北向流量：虚拟机和外部网络（例如Internet）通信的流量

- 东西向流量：虚拟机之间的流量

- Provider Network和外部网络之间的流量：由物理网络设备负责交换和路由。

后续的网络流量分析基于如下示例：

- Provider Network 1（VLAN）
  - VLAN 101（tagged），IP地址段203.0.113.0/24，网关203.0.113.1（物理网络设备上）

- Provider Network 2（VLAN）
  - VLAN 102（tagged），IP地址段192.0.2.0/24，网关192.0.2.1（vRouter端口上）

##### 6.2.2.1、使用Fixed IP的虚拟机南北流量分析

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/25.png)

以下步骤涉及计算节点1：

- 虚拟机数据包由虚拟网卡（1）通过veth pair转发到Provider Bridge上的端口（2）
- Provider Bridge上的安全组规则（3）检查防火墙和记录连接跟踪
- provider Bridge上的VLAN子接口（4）将数据包转发到物理网卡（5）
- 物理网卡（5）将数据包打上VLAN tag 101，并将其转发到物理交换机端口（6）

以下步骤涉及物理网络设备：

- 交换机从数据包中删除VLAN tag 101，并将其转发到路由器（7）
- 路由器将数据包从Provider Network 1网关（8）路由到External网络网关（9），并将数据包转发到External网络的交换机端口（10）
- 交换机将数据包转发到外部网络（11）
- 外部网络（12）接收数据包

##### 6.2.2.2、同一个网络中虚拟机东西流量分析

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/26.png)

以下步骤涉及计算节点1：

- 虚拟1机数据包由虚拟网卡（1）通过veth pair转发到Provider Bridge上的端口（2）
- Provider Bridge上的安全组规则（3）检查防火墙和记录连接跟踪
- Provider Bridge上的VLAN子接口（4）将数据包转发到物理网卡（5）
- 物理网卡（5）将数据包打上VLAN tag 101，并将其转发到物理交换机端口（6）

以下步骤涉及物理网络设备：

- 交换机将数据包转发给计算节点2所连接的交换机端口（7）

以下步骤涉及计算节点2：

- 计算节点2的物理网卡（8）从数据包中删除VLAN tag 101，然后转发给Provider Bridge的VLAN子接口（9）
- Provider Bridge上的安全组规则（10）检查防火墙和记录连接跟踪
- Provider Bridge上的虚拟网卡（11）通过veth pair将数据包转发给虚拟机2的网卡（12）

##### 6.2.2.3、不同网络中虚拟机东西流量

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/27.png)

以下步骤涉及计算节点1：

- 虚拟机1数据包由虚拟网卡（1）通过vethpair转发到Provider Bridge上的端口（2）
- Provider Bridge上的安全组规则（3）检查防火墙和记录连接跟踪
- Provider Bridge上的VLAN子接口（4）将数据包转发到物理网卡（5）
- 物理网卡（5）将数据包打上VLAN tag 101，并将其转发到物理交换机端口（6）

以下步骤涉及物理网络设备：

- 交换机从数据包中删除VLAN tag 101，并将其转发到路由器（7）
- 路由器将数据包从Provider Network 1网关（8）转发到Provider Network 2网关（9）
- 路由器将数据包发送到交换机端口（10）
- 交换机将数据包打上VLAN tag 102，然后转发给计算节点1连接的端口（11）

以下步骤涉及计算节点1：

- 计算节点1的物理网卡（12）从数据包中删除VLAN tag 102，然后转发给Provider Bridge的VLAN子接口（13）
- Provider Bridge上的安全组规则（14）检查防火墙和记录连接跟踪
- Provider Bridge上的虚拟网卡（15）通过vethpair将数据包转发给虚拟机2的网卡（16）

### 6.3、Open vSwitch + VXLAN网络

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/28.png)

VXLAN 全称是Virtual eXtensibleLocal Area Network，虚拟可扩展的局域网。它是一种overlay 技术，通过三层的网络来搭建虚拟的二层网络。

VXLAN与VLAN相比，有如下好处：

- 部署灵活：通过VXLAN封装后的2层以太网帧可以跨3层网络通信，组网部署更灵活，解决了多租户网络环境中IP地址冲突问题。
- 扩展更好：传统VLANID字段为12-bit，只支持4096个VLAN，VXLAN使用24-bit VNID (VXLAN network identifier)，可以支持16,000,000个逻辑网络。
- 网络利用率更高：传统以太网使用STP预防环路，STP阻塞网络冗余路径，VXLAN报文基于3层IP报头传输，无需阻塞网络路径，支持链路聚合协议，提升了网络利用率。

#### 6.3.1、Open vSwitch + VXLAN实现

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/29.png)

#### 6.3.2、Open vSwitch + VXLAN场景说明

使用Open vSwitch + VXLAN实现Self-service Network，网络流量可以分为如下几种：

- 南北向流量：虚拟机和外部网络（例如Internet）通信的流量

- 东西向流量：虚拟机之间的流量

- Provider Network和外部网络之间的流量：由物理网络设备负责交换和路由。

后续的网络流量分析基于如下示例：

- Provider Network 1（VLAN）：VLAN 101（tagged）

- Self-service network 1 (VXLAN)：VXLAN 101 （VNI）
- Self-service network 2 (VXLAN)：VXLAN 102 （VNI）
- Self-service router：网关在Provider network 1 上，连接Self-service network 1 和Self-service network 2

##### 6.3.2.1、使用Fixed IP的虚拟机南北流量分析

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/30.png)

场景说明：

- 虚拟机运行在计算节点1上，使用Self-service network 1
- 虚拟机将数据包发送到Internet上的主机

以下步骤涉及计算节点1：

- 实例接口（1）通过veth对将数据包转发到安全组网桥实例端口（2）
- 安全组网桥上的安全组规则（3）处理数据包的防火墙和连接跟踪
- 安全组网桥OVS端口（4）通过veth对将数据包转发到OVS集成网桥安全组端口（5）
- OVS集成网桥为数据包添加内部VLAN标记
- OVS集成桥为内部隧道ID交换内部VLAN标记
- OVS集成桥接补丁端口（6）将数据包转发到OVS隧道桥接补丁端口（7）
- OVS隧道桥（8）使用VNI 101包裹分组
- 用于覆盖网络的底层物理接口（9）经由覆盖网络（10）将分组转发到网络节点
- 覆盖网络的底层物理接口（11）将分组转发到OVS隧道桥（12）
- OVS隧道网桥解包并为其添加内部隧道ID
- OVS隧道网桥为内部VLAN标记交换内部隧道ID
- OVS隧道桥接补丁端口（13）将分组转发到OVS集成桥接补丁端口（14）
- 用于自助服务网络（15）的OVS集成桥接端口移除内部VLAN标记并将分组转发到路由器命名空间中的自助服务网络接口（16）
- 路由器将数据包转发到提供商网络的OVS集成桥接端口（18）
- OVS集成网桥将内部VLAN标记添加到数据包
- OVS集成桥接int-br-provider补丁端口（19）将数据包转发到OVS提供程序桥接phy-br-provider补丁端口（20）
- OVS提供程序桥将内部VLAN标记与实际VLAN标记101交换
- OVS提供商桥接提供商网络端口（21）将分组转发到物理网络接口（22）
- 物理网络接口通过物理网络基础设施将数据包转发到Internet（23）

##### 6.3.2.2、从外部访问带Floating IP的虚拟机

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/31.png)

场景说明：

- 虚拟机运行在计算节点1上，使用Self-service network 1
- Internet上的主机将数据包发送到虚拟机

以下步骤涉及网络节点：

- 物理网络基础设施（1）将分组转发到提供者物理网络接口（2）
- 提供商物理网络接口将数据包转发到OVS提供商网桥提供商网络端口（3）
- OVS提供程序桥将实际VLAN标记101与内部VLAN标记交换
- OVS提供者桥接phy-br-provider端口（4）将数据包转发到OVS集成桥接int-br-provider端口（5）
- 提供商网络（6）的OVS集成桥接端口删除内部VLAN标记，并将数据包转发到路由器命名空间中的提供商网络接口（6）
- 路由器将数据包转发到自助服务网络的OVS集成网桥端口（9）
- OVS集成网桥为数据包添加内部VLAN标记
- OVS集成桥为内部隧道ID交换内部VLAN标记
- OVS集成桥接patch-tun补丁端口（10）将数据包转发到OVS隧道桥接patch-int补丁端口（11）
- OVS隧道桥（12）使用VNI 101包裹分组
- 用于覆盖网络的底层物理接口（13）经由覆盖网络（14）将分组转发到网络节点
- 覆盖网络的底层物理接口（15）将分组转发到OVS隧道桥（16）
- OVS隧道网桥解包并为其添加内部隧道ID
- OVS隧道网桥为内部VLAN标记交换内部隧道ID
- OVS隧道桥接patch-int补丁端口（17）将数据包转发到OVS集成桥接patch-tun补丁端口（18）
- OVS集成桥从数据包中删除内部VLAN标记
- OVS集成桥安全组端口（19）通过veth对将数据包转发到安全组桥OVS端口（20）
- 安全组网桥上的安全组规则（21）处理数据包的防火墙和连接跟踪
- 安全组桥接实例端口（22）经由veth对将分组转发到实例接口（23）

##### 6.3.2.3、同一个网络中虚拟机东西流量

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/32.png)

场景说明：

- 虚拟机1运行在计算节点1上，使用self-service network 1
- 虚拟机2运行在计算节点2上，使用self-service network 1
- 虚拟机1将数据包发送到虚拟机2

以下步骤涉及计算节点1：

- 实例1接口（1）通过veth对将数据包转发到安全组网桥实例端口（2）
- 安全组网桥上的安全组规则（3）处理数据包的防火墙和连接跟踪
- 安全组网桥OVS端口（4）通过veth对将数据包转发到OVS集成网桥安全组端口（5）
- OVS集成网桥为数据包添加内部VLAN标记
- OVS集成桥为内部隧道ID交换内部VLAN标记
- OVS集成桥接补丁端口（6）将数据包转发到OVS隧道桥接补丁端口（7）
- OVS隧道桥（8）使用VNI 101包裹分组
- 用于覆盖网络的底层物理接口（9）经由覆盖网络（10）将分组转发到计算节点2
- 覆盖网络的底层物理接口（11）将分组转发到OVS隧道桥（12）
- OVS隧道网桥解包并为其添加内部隧道ID
- OVS隧道网桥为内部VLAN标记交换内部隧道ID
- OVS隧道桥接patch-int补丁端口（13）将分组转发到OVS集成桥接patch-tun补丁端口（14）
- OVS集成桥从数据包中删除内部VLAN标记
- OVS集成桥安全组端口（15）通过veth对将数据包转发到安全组网桥OVS端口（16）
- 安全组网桥上的安全组规则（17）处理数据包的防火墙和连接跟踪
- 安全组桥接实例端口（18）经由veth对将分组转发到实例2接口（19）

##### 6.3.2.4、不同网络中虚拟机东西流量

![neutron](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/07/33.png)

## 7、思考题

Linux有哪些网络虚拟化技术？

- Linux中主要有网卡虚拟化、交换机虚拟化和网络隔离等技术。

Neutron有哪些组件，各组件的作用是什么？



## 8、测一测

### 8.1、判断

通过网线将物理交换机和服务器物理网口连接起来，构建成物理网络；而通过虚拟网络连接将虚拟机的虚拟网卡、虚拟交换机和服务器物理网卡三者连接起来，最后通过物理网络连接访问外网，组成了虚拟化网络。

- `true 正确`
- false

TUN设备是一个三层设备，无法与物理网卡做bridge。

- `true 正确`
- false

### 8.2、单选

以下哪个选项不是OpenStack中常用的虚拟网络设备？

- TAP
- TUN
- VETH
- `ACL 正确`

### 8.3、多选

以下选项属于Neutron的基本管理对象的是？

- `Subnet`
- `Port`
- `Router`
- `Floating IP`

以下关于Neutron中典型的网络流量模型描述正确的是？

- `Linux Bridge + Flat/VLAN网络，该模型下网络简单、高效，适合中小企业私有云网络场景`

- `Open vSwitch + VXLAN网络，该模型下，可以提供多租户、大规模网络隔离能力，适合大规模私有云和公有云网络场景`

- `Linux Bridge + VLAN网络模型，该模型支持现有物理网络VLAN隔离`

- Open vSwitch + VLAN网络，更适合大规模、复杂网络环境部署