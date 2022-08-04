+++
author = "zsjshao"
title = "22_园区网中的VLAN规划"
date = "2020-05-23"
tags = ["NP"]
categories = ["RS"]
+++

## 1、园区网IP地址规划和VLAN设计原则

### 1.1、中小型园区网项目生命周期

IP地址规划和VLAN设计是园区网建设规划阶段的一项重要内容，不合理的规划会直接影响日后的管理和维护

![01_vlan](http://images.zsjshao.cn/images/rs/22-vlan/01_vlan.png)

### 1.2、什么是IP/VLAN规划设计？

IP / VLAN规划，就是为接入园区网的所有设备，包括交换机、路由器、防火墙、服务器、客户机、打印服务器等，分配一个惟一的IP地址，并为其指定适当的VLAN。

考虑到日后的扩展、维护等问题，园区网的IP/VLAN规划不仅应符合网络设计规范，还要有规律、易记忆，可扩展性强、能反映园区网的特点。

### 1.3、园区网IP/VLAN规划设计的取值范围

IP地址取值范围（常规局域网内网场景）。根据业务需求和网络规模进行合理子网划分。

![02_vlan](http://images.zsjshao.cn/images/rs/22-vlan/02_vlan.png)

VLAN规划取值范围：1-4094。（VLAN 1默认存在）

![03_vlan](http://images.zsjshao.cn/images/rs/22-vlan/03_vlan.png)

### 1.4、如何进行IP/VLAN规划设计？

Step 1：明确客户需求和各功能区网络场景，以及用户规模，制定网络拓扑。

![04_vlan](http://images.zsjshao.cn/images/rs/22-vlan/04_vlan.png)

Step 2：规划设备命名、以及接口互联描述。

- 【设备命令规范】
  - 客户规范
  - 自定义：参考设备的地理位置、网络位置、设备型号、设备编号等因素，制定统一的命名规范（ AA-BB-CC-DD ）
    - AA：表示该设备的地理位置
    - BB：表示设备的网络位置
    - CC：表示设备的型号
    - DD： 表示设备的编号
    - 配置命令：Ruijie(config)# hostname WLZX-Core-S8610-1

- 【接口互联描述规范】
  - 客户规范
  - 自定义：to-对端设备名-对端接口名
    - 配置命令WLZX-Core-S8610-2(config-if-Gig1/20)#description to-WLZX-Core-S8610-1-Gig6/1

Step 3：设备互联及互联IP地址规划.XLS

![05_vlan](http://images.zsjshao.cn/images/rs/22-vlan/05_vlan.png)

Step 4：有线IP/VLAN规划设计.XLS

![06_vlan](http://images.zsjshao.cn/images/rs/22-vlan/06_vlan.png)

Step 5：无线IP/VLAN规划设计.XLS

![07_vlan](http://images.zsjshao.cn/images/rs/22-vlan/07_vlan.png)

Step 6：设备管理IP/VLAN规划设计.XLS

![08_vlan](http://images.zsjshao.cn/images/rs/22-vlan/08_vlan.png)

Step 7：服务器及设备登录管理方式.XLS

![09_vlan](http://images.zsjshao.cn/images/rs/22-vlan/09_vlan.png)

Step 8：整理汇总

- 完成上述规划设计之后整理汇总成《 【规划设计类】XXX园区玩建设项目IP/VLAN规划设计表.xls 》。以便项目转运维之后资料交接以及网络运维。

## 2、Super VLAN 

### 2.1、Super VLAN是什么？

是一种IP地址优化技术

由super vlan和sub vlan组成，各sub vlan在同一子网

不同的sub vlan是不同的广播域，三层通信借助super vlan的SVI接口，通过代理arp完成

![10_vlan](http://images.zsjshao.cn/images/rs/22-vlan/10_vlan.png)

### 2.2、Super VLAN的配置步骤

创建vlan并命名

指定super vlan并关联sub vlan(在super vlan 下)

- Ruijie（config-vlan）# super vlan 指定super vlan
- Ruijie（config-vlan）# subvlan vlan-id-list 关联sub vlan

为super vlan创建SVI接口

为sub vlan 配置地址范围（在sub-vlan下）

- Ruijie（config-vlan）#subvlan-address-range start-ip end-ip

把接口和sub vlan绑定

查看

- Ruijie#Show supervlan

### 2.3、Super VLAN的限制

Super VLAN不包含任何成员口，只能包含Sub VLAN，由Sub VLAN包含实际的物理接口。 

Super VLAN不能做为其它 Super VLAN的 Sub VLAN。 

VLan 1 不能作为 SuperVLAN。

Sub VLAN不能配置路由口，不能配置 IP 地址。 

基于 Super VLAN接口的 ACL和 QOS 配置不对 Sub VLAN 生效。

### 2.4、Super VLAN的应用

以QinQ部署场景为例：

接入层：接入VLAN 每端口隔离，24口交换机则用户VLAN为VLAN1-24，48口交换机则为VLAN1-48.实现用户隔离，每台交换机的配置实现标准化，大大降低配置规划、维护工作量。

汇聚层：汇聚交换机封装的外层VLAN每端口隔离，例如从VLAＮ1001开始，第一个端口封装的QinQ外层VLAN为1001，第二个端口为1002，依次省略，第24口端口为1024；第二台汇聚交换机封装的外层VLAN一致。从而实现所有接入用户的内外层VLAN　ID的唯一性，轻松实现用户定位和每用户隔离。

核心层：核心交换机N18K启用SuperVLAN，子VLAN为VLAN1001-2000（所有汇聚封装的外层VLAN），实现IP地址统一管理，简化配置的目的。

#### 2.4.1、QinQ部署模型

![11_vlan](http://images.zsjshao.cn/images/rs/22-vlan/11_vlan.png)

#### 2.4.2、QinQ场景通信实现原理

- 访问外网-arp学习过程

![12_vlan](http://images.zsjshao.cn/images/rs/22-vlan/12_vlan.png)

- 访问外网-三层报文转发

![13_vlan](http://images.zsjshao.cn/images/rs/22-vlan/13_vlan.png)

#### 2.4.3、QinQ部署案例

![14_vlan](http://images.zsjshao.cn/images/rs/22-vlan/14_vlan.png)

| **位置**   | **学生上网OVID** | **学生上网IVID** | **网管** | **一卡通** | **监控** | **门禁** | **其它** |
| ---------- | ---------------- | ---------------- | -------- | ---------- | -------- | -------- | -------- |
| 楼宇汇聚1  | 101-148          | 1-48（灵活QINQ） | 100      | 1001       | 1002     | 1003     | 1000+n   |
| 楼宇汇聚2  | 101-148          | 1-48（灵活QINQ） | 100      | 1001       | 1002     | 1003     | 1000+n   |
| 楼宇汇聚3  | 101-148          | 1-48（灵活QINQ） | 100      | 1001       | 1002     | 1003     | 1000+n   |
| 楼宇1接入1 | NA               | 1-48             | 100      | 1001       | 1002     | 1003     | 1000+n   |
| 楼宇1接入2 | NA               | 1-48             | 100      | 1001       | 1002     | 1003     | 1000+n   |
| 楼宇N接入N | NA               | 1-48             | 100      | 1001       | 1002     | 1003     | 1000+n   |

## 3、Native VLAN 

属于Native VLAN的数据帧在trunk链路上不携带VLAN 标签传输

不带标签的数据经过trunk链路时会打上Native VLAN所属的VLAN ID TAG形成802.1Q数据帧。

若同一条trunk链路两端配置不同的native VLAN，将造成不同VLAN的数据合并

锐捷交换机默认情况下native VLAN为1，建议实际项目中将trunk端口的native VLAN设置为非业务VLAN

![15_vlan](http://images.zsjshao.cn/images/rs/22-vlan/15_vlan.png)

### 3.1、Native VLAN的应用案例

无线本地转发模式下，POE下联AP的接口需要配置Native VLAN为AP所在的VLAN。本地转发即AP将STA的802.11数据转换为以太数据后，不再将其通过CAPWAP隧道转发给AC，而是直接通过上联口将数据转发至有线网络中。

![16_vlan](http://images.zsjshao.cn/images/rs/22-vlan/16_vlan.png)

