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

## 3、Private VLAN

### 应用场景：

Private VLAN的主要功能就是能够实现节约IP地址，隔离广播风暴，病毒攻击，控制端口二层互访。特别适用于大二层结构的环境，用户多，vlan多，但是IP地址又是同一个网段，又要实现彼此之间二层隔离，个别VLAN之间又有互访的需求。常见的场景有宾馆酒店，小区宽带接入，运营商与高校共建的校园网等，他们的特点是一个房间或者一户人家一个vlan，彼此隔离，但是IP地址有限，无法给数量庞大的vlan每个分一个网段IP，只能共用一个IP地址段，比如vlan 10的IP地址段10.10.10.0/24，这样一户人家可能就使用了1-2个IP，造成剩余200多个ip地址浪费。  

另一种比较典型的PVLAN应用类似于端口隔离功能（[switchport protected](https://search.ruijie.com.cn:8902/kq/h52018092015040500221.html)），即将所有用户端口设置为隔离VLAN（**(**Isolated Port），这样即使同一vlan，同一网段的IP之间的用户也无法访问，可以有效隔离病毒传播。  



服务提供商如果给每个用户一个VLAN，则由于一台设备支持的VLAN数最大只有4096而限制了服务提供商能支持的用户数；在三层设备上，每个VLAN被分配一个子网地址或一系列地址，这种情况导致IP地址的浪费；另外同一个vlan内的广播风暴，病毒攻击等安全问题让维护人员非常头疼，等等的这些问题的一种解决方法就是应用Private VLAN 技术。

### 功能简介：

Private VLAN将一个VLAN 的二层广播域划分成多个子域，每个子域都由一个私有VLAN对组成：主VLAN(Primary VLAN)和辅助VLAN(Secondary VLAN)。

在一个Private VLAN域中所有的私有VLAN对共享同一个主VLAN，每个子域的辅助VLAN ID 不同。一个Private VLAN域中只有一个主VLAN，有两种类型的辅助VLAN：

**隔离VLAN(Isolated VLAN)：**同一个隔离VLAN 中的端口不能互相进行二层通信，一个私有VLAN 域中只有一个隔离VLAN。

**群体VLAN(Community VLAN)：**同一个群体VLAN 中的端口可以互相进行二层通信，但不能与其它群体VLAN 中的端口进行二层通信。一个Private VLAN域中可以有多个群体VLAN。

  

在一个Private VLAN域内通常有三种常见的端口角色，通过定义交换机上面不通的端口的角色可以实现各用户间的二层互访，还是隔离的效果：

**混杂端口（Promiscuous Port），**属于主VLAN 中的端口，可以与任意端口通讯，包括同一个Private VLAN域中辅助VLAN的隔离端口和群体端口，通常是交换机上联网关设备的端口。

**隔离端口(Isolated Port)，**隔离VLAN 中的端口彼此之间不能通信，只能与混杂口通讯。通常是下联接入用户端的接口。

**群体端口(Community port)，**属于群体VLAN 中的端口，同一个群体VLAN 的群体端口可以互相通讯，也可以与混杂口通讯，不能与其它群体VLAN 中的群体端口及隔离VLAN 中的隔离端口通讯。通常是下联接入用户端的接口。

  

Private VLAN域中，只有主VLAN 可以创建SVI 接口，配置IP作为网关使用，辅助VLAN 不可以创建SVI。

### 配置命令

```
SWITCHA(config)#vlan 20
SWITCHA(config-vlan)#private-vlan community   ------>创建团体vlan20
SWITCHA(config)#vlan 30
SWITCHA(config-vlan)#private-vlan isolated    ------>创建隔离vlan30
SWITCHA(config)#vlan 10
SWITCHA(config-vlan)#private-vlan primary     ------>创建主vlan，并关联secondary vlan
SWITCHA(config-vlan)#private-vlan association 20,30

SWITCHA(config)#int range g0/10-11
SWITCHA(config-if-range)#switchport mode private-vlan host
SWITCHA(config-if-range)#switchport private-vlan host-association 10 20 ------>将10,11端口加入团体vlan20
SWITCHA(config)#int g0/12
SWITCHA(config-if-GigabitEthernet 0/12)#switchport mode private-vlan host
SWITCHA(config-if-GigabitEthernet 0/12)#switchport private-vlan host-association 10 30    ------>将12端口加入隔离vlan30

同级别交换机设为普通trunk
SWITCHA(config)#interface g0/1
SWITCHA(config-if-GigabitEthernet 0/1)#switchport mode trunk

同网关交换机设为混杂trunk
SWITCHA(config)#interface g0/24
SWITCHA(config-if-GigabitEthernet 0/24)#switchport mode private-vlan promiscuous
SWITCHA(config-if-GigabitEthernet 0/24)#switchport private-vlan mapping 10 add 20,30
```

## 4、Native VLAN 

属于Native VLAN的数据帧在trunk链路上不携带VLAN 标签传输

不带标签的数据经过trunk链路时会打上Native VLAN所属的VLAN ID TAG形成802.1Q数据帧。

若同一条trunk链路两端配置不同的native VLAN，将造成不同VLAN的数据合并

锐捷交换机默认情况下native VLAN为1，建议实际项目中将trunk端口的native VLAN设置为非业务VLAN

![15_vlan](http://images.zsjshao.cn/images/rs/22-vlan/15_vlan.png)

### 4.1、Native VLAN的应用案例

无线本地转发模式下，POE下联AP的接口需要配置Native VLAN为AP所在的VLAN。本地转发即AP将STA的802.11数据转换为以太数据后，不再将其通过CAPWAP隧道转发给AC，而是直接通过上联口将数据转发至有线网络中。

![16_vlan](http://images.zsjshao.cn/images/rs/22-vlan/16_vlan.png)

