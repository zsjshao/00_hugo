+++
author = "zsjshao"
title = "20_FAT组网与FIT组网方案"
date = "2020-05-23"
tags = ["NA"]
categories = ["RS"]
+++

## 1、无线“胖瘦”组网模式简介

### 1.1、FAT AP概述

Fat AP俗称“胖AP”，下文也称“胖AP”

Fat AP的特点：

- 将WLAN物理层、数据加密、认证、QoS、网络管理、L2漫游集于一身
- 通常AP都会有单独的网页或者命令行配置页面
- 用户使用时，无需其他附属设备，采用单独的AP即可提供无线接入功能，组网相对简

![01_ap](http://images.zsjshao.net/rs/20-ap/01_ap.png)

### 1.2、FAT AP组网模式

胖AP组网模式

- 家庭或者SOHO组网通常采用胖AP的组网方式；每个AP需要单独的配置操作，出现网络问题需要单独进行排查。
- 传统的企业无线网采用的是胖AP的组网模式，管理操作极为困难。
- 大型的胖AP组网中，可使用MACC进行统一的管理操作。

![02_ap](http://images.zsjshao.net/rs/20-ap/02_ap.png)

### 1.3、FIT AP概述

Fit AP俗称“瘦AP”，下文也称“瘦AP”

**Access Point**：无线控制器，对AP进行统一管控，包括接入管理，认证安全，报文转发，射频管理，漫游等

Fit AP的特点：

- 集中管理，配置统一下发
- 射频统一优化管理
- 安全认证策略全面
- L2、L3漫游，适合大规模组网

![03_ap](http://images.zsjshao.net/rs/20-ap/03_ap.png)

### 1.4、FIT AP组网模式

瘦AP在使用中必须和AC配合使用

瘦AP负责无线接入、加密、认证中的部分功能

射频管理、用户接入、AP控制，漫游控制都在无线控制器上完成

AC通过和AP之间建立CAPWAP隧道来控制和管理AP

![04_ap](http://images.zsjshao.net/rs/20-ap/04_ap.png)

### 1.5、组网模式优劣势比较

Fat AP与Fit AP组网模式优劣势比较

| **属性**         | **Fat** **AP**                                     | **Fit** **AP**                                               |
| ---------------- | -------------------------------------------------- | ------------------------------------------------------------ |
| **技术模式**     | 传统                                               | 新型，管理加强                                               |
| **安全性**       | 单点安全，无整网统一安全能力                       | 统一的安全防护体系，无线入侵检测                             |
| **网络管理能力** | 单台管理                                           | 统一管理                                                     |
| **配置管理**     | 每个AP需要单独配置，管理复杂                       | 配置统一下发，AP零配置                                       |
| **自动RF调节**   | 没有RF自动调节能力                                 | 自动优化无线网络配置                                         |
| **漫游能力**     | 支持2层漫游功能，适合小规模组网                    | 支持2层、3层快速安全漫游                                     |
| **可扩展性**     | 无扩展能力                                         | 方便扩展，对于新增AP无需任何配置管理                         |
| **高级功能**     | 对于基于WiFi的高级功能，如安全、语音等支持能力很差 | 可针对用户提供安全、语音、位置业务、个性化页面推送、基于用户的业务/完全/服务质量控制等等 |

## 2、胖AP配置

### 2.1、胖AP配置环境说明

**适用场景**

​    无线网络中的AP数量较少，不需要花费太大时间和精力去管理和配置AP。此时胖AP工作模式类似一台二层交换机，担任有线和无线数据转换的角色，没有路由和NAT功能。

- 优点：无需改变现有有线网络结构，配置简单
- 缺点：无法统一管理和配置

AP默认是瘦AP模式。

- 对于有两个以太网接口的AP, 11.X AP默认管理地址192.168.110.1；胖模式时g0/0默认地址192.168.110.1，g0/1口默认地址192.168.111.1

AP120-W等其他WALL-AP

- Fit模式下，LAN口和uplink口IP地址均为192.168.110.1/24
- Fat模式下，LAN口（前面板接口）IP地址为192.168.111.1/24；uplink口（后面板接口）IP地址为192.168.110.1/24

AP110-W

- 后面板地址：192.168.110.1/24 （173487之前的P2版本是192.168.1.1）
- 前面板地址：192.168.111.1/24（173487之前的P2版本是192.168.2.1）

默认情况下锐捷胖AP web管理地址为192.168.110.1，telnet密码是admin，无enable密码

![05_ap](http://images.zsjshao.net/rs/20-ap/05_ap.png)

**信息规划**：

- AP的地址为172.16.1.253/24，网关172.16.1.254/24
- 无线用户地址段为172.16.1.0/24，网关172.16.1.254/24
- 无线用户和AP vlan都使用vlan1
- 无线ssid名称 ruijie

### 2.2、胖AP配置注意事项

配置要点

- 连接好网络拓扑，保证AP 能正常供电，正常开机；
- 保证要接AP的网线接在电脑上，电脑可以使用网络，使用ping测试；
- 完成AP基本配置后验证无线SSID 能否被无线用户端正常搜索发现到；
- 配置无线用户端的IP 地址为静态IP，并验证网络连通性；
- AP其他可选配置（DHCP 服务、无线的认证及加密方式）

**注意：第一次登陆AP配置时，需要切换AP为胖模式工作，切换命令：ruijie>ap-mode fat**

**10.X版本AP切换模式不会重启，11.X版本AP切换模式会自动重启动**

### 2.3、胖AP配置 —— 步骤一

切换AP为胖模式并创建用户VLAN

```
Ruijie#ap-mode fat
Ruijie(config)#Vlan 1
```

配置无线信号

- 创建指定ssid的wlan，在指定无线子接口绑定该wlan以使能发出无线信号）

```
Ruijie(config)#dot11 wlan 1
Ruijie(dot11-wlan-config)#ssid ruijie                       //无线信号名称为ruijie
Ruijie(dot11-wlan-config)#exit
```

- 在指定无线子接口绑定该wlan以使能发出无线信号：

```
Ruijie(config)#interface Dot11radio 1/0.1
Ruijie(config-if-Dot11radio 1/0.1)#encapsulation dot1Q 1    //指定AP射频子接口VLAN
Ruijie(config-if-Dot11radio 1/0.1)#wlan-id 1                //在AP射频子接口使能VLAN
Ruijie(config-if-Dot11radio 1/0.1)#exit
```

配置AP接口、管理地址和路由

- 配置AP的以太网接口,让无线用户的数据可以正常传输

```
Ruijie(config)#interface GigabitEthernet 0/1
Ruijie(config-if-GigabitEthernet 0/1)#encapsulation dot1Q 1       //指定AP有线口VLAN
Ruijie(config-if-GigabitEthernet 0/1)#exit
注意：要封装相应的vlan，否则无法通信
```

- 配置interface vlan地址

```
Ruijie(config)#interface BVI 1                            //配置管理地址接口，VLAN 1对应BVI 1
Ruijie(config-if-BVI 1)#ip address 172.16.1.253 255.255.255.0     //该地址只能用于管理
```

- 配置静态路由

```
Ruijie(config)#ip route 0.0.0.0 0.0.0.0 172.16.1.254
```

配置无线用户DHCP

- 给连接的无线分配地址
  - 如网络中已经存在DHCP服务器可跳过此配置，一般接入部署时上联设备都已经配置好无线用户的dhcp池

```
Ruijie(config)#service dhcp                            //开启DHCP服务
Ruijie(config)#ip dhcp excluded-address 172.16.1.253 172.16.1.254      //不下发地址范围
Ruijie(config)#ip dhcp pool test                        //配置DHCP地址池，名称是 “test”
Ruijie(dhcp-config)#network 172.16.1.0 255.255.255.0    //下发172.16.1.0地址段给无线用户
Ruijie(dhcp-config)#dns-server 8.8.8.8                  //下发DNS地址
Ruijie(dhcp-config)#default-router 172.16.1.254         //下发网关
```

确认配置正确，保存配置

```
Ruijie(config)#end
Ruijie#write    （胖AP配置完后需要保存配置，否则重启配置丢失）
```

10.X软件版本对应的配置如下：

```
Ruijie(config)#dot11 wlan 1
Ruijie(dot11-wlan-config)#ssid ruijie   无线信号名称为ruijie
Ruijie(dot11-wlan-config)#broadcast-ssid    广播SSID，10.x需配置
Ruijie(dot11-wlan-config)#exit

Ruijie(config)#interface Dot11radio 1/0.1
Ruijie(config-if-Dot11radio 1/0.1)#encapsulation dot1Q 1   指定AP射频子接口vlan
Ruijie(config-if-Dot11radio 1/0.1)#mac-mode fat
Ruijie(config-if-Dot11radio 1/0.1)#exit
Ruijie(config)#interface Dot11radio 1/0
Ruijie(config-if-Dot11radio 1/0)#wlan-id 1   在AP射频主接口使能wlan
Ruijie(config-if-Dot11radio 1/0)#exit
```

## 3、瘦AP配置

Fit模式的AP，如同一台刚装完操作系统的PC，在接入网络后会通过DHCP自动获取IP地址。

AC可以使用获取到的IP地址，可以访问到AC，并主动与AC建立CAPWAP隧道（端口号为5426，CAPWAP-CONTROL）

AP与AC建立CAPWAP隧道后，在AC上完成AP的配置，AC会将这些配置信息通过CAPWAP隧道下放到AP上

AP收到配置信息后，开始工作，广播SSID，接入无线用户

### 3.1、瘦AP架构工作原理（集中式转发）

工作原理简介，9个步骤

- 1.有线网络搭建（VLAN、DHCP、路由等）
- 2.AP零配置启动，通过DHCP获取IP地址及网关IP，同时通过option138获取AC IP地址
- 3.AP主动建立到达AC的CAPWAP隧道
- 4.AP与AC建立隧道成功后，AC下发配置信息给AP
- 5.AP获取配置后，广播SSID供STA关联并接入STA
- 6.AP将STA发出的802.11数据转换为以太数据并通过CAPWAP隧道转发给AC
- 7.AC将收到的数据解封装并进行转发至有线网络中
- 8.有线网络返回数据到AC，AC将数据通过CAPWAP隧道转发至AP
- 9.AP根据配置信息将以太数据转换为802.11数据，转发给STA

### 3.2、瘦AP集中转发工作原理 

#### 3.2.1、有线网络搭建

有线网络搭建（VLAN、DHCP、路由等）

![06_ap](http://images.zsjshao.net/rs/20-ap/06_ap.png)

#### 3.2.2、ap启动

AP零配置启动，通过DHCP获取IP地址及网关IP，同时通过option138获取AC IP地址![07_ap](http://images.zsjshao.net/rs/20-ap/07_ap.png)

#### 3.2.3、capwap隧道建立

AP主动建立到达AC的CAPWAP隧道

- **CAPWAP：无线接入点控制与配置协议**

![08_ap](http://images.zsjshao.net/rs/20-ap/08_ap.png)

#### 3.2.4、配置下发

AP与AC建立隧道成功后，AC下发配置信息给AP

![09_ap](http://images.zsjshao.net/rs/20-ap/09_ap.png)

#### 3.2.5、信号发射

AP获取配置后，广播SSID供STA关联并接入STA

![10_ap](http://images.zsjshao.net/rs/20-ap/10_ap.png)

#### 3.2.6、AP数据转发

AP将STA发出的802.11数据转换为以太数据并通过CAPWAP隧道转发给AC

![11_ap](http://images.zsjshao.net/rs/20-ap/11_ap.png)

#### 3.2.7、AC数据转发

AC将收到的数据解封装并进行转发至有线网络中

![12_ap](http://images.zsjshao.net/rs/20-ap/12_ap.png)

有线网络返回数据到AC，AC将数据通过CAPWAP隧道转发至AP

![13_ap](http://images.zsjshao.net/rs/20-ap/13_ap.png)

#### 3.2.8、AP数据转发

AP根据配置信息将以太数据转换为802.11数据，转发给STA

![14_ap](http://images.zsjshao.net/rs/20-ap/14_ap.png)

### 3.3、瘦AP架构配置步骤（集中式转发）

配置过程介绍，5个步骤

- 1.根据有线网络结构确定AC的部署位置及连接方式
- 2.制作AP信息表，包括：AP位置、命名、型号、MAC地址、SSID、AP所属VLAN及网段、无线用户VLAN及网段、所连接POE交换机及端口等信息
- 3.DHCP规划、路由规划
- 4.WLAN设备配置
  - ①AC的接口及路由配置
  - ②AC、AP的软件升级
  - ③AC上完成AP配置信息
  - ④POE交换机对AP供电

- 5.WLAN设备配置总结

#### 3.3.1、根据有线网络结构确定AC的部署位置及连接方式

- 单核心二层结构：**AC与核心之间双线互连**

![15_ap](http://images.zsjshao.net/rs/20-ap/15_ap.png)

- 单核心二层结构：AC与核心之间单线互连

![16_ap](http://images.zsjshao.net/rs/20-ap/16_ap.png)

#### 3.3.2、制作AP信息表

![17_ap](http://images.zsjshao.net/rs/20-ap/17_ap.png)

#### 3.3.3、DHCP及路由规划

AP网段和无线用户网段的DHCP服务器规划

- 网关交换机作为DHCP服务器
- AP的地址池中需要定义Option 138选项，内容为AC的Loopback0地址
- 配置STA的地址池（略）

![18_ap](http://images.zsjshao.net/rs/20-ap/18_ap.png)

```
核心交换机：
ip dhcp pool AP_address
 option 138 ip 1.1.1.1
 network 20.0.0.0 255.255.255.0
 default-router 20.0.0.254 

ip route 1.1.1.1 255.255.255.255 下一跳地址(AC端)

AC：
Ip route 0.0.0.0 0.0.0.0 下一跳地址（核心端） 
```

#### 3.3.4、WLAN设备配置

在AC定义WLAN

![19_ap](http://images.zsjshao.net/rs/20-ap/19_ap.png)

在AC上定义VLAN

```
vlan 10               //创建无线用户VLAN
interface vlan 10     //创建无线用户VLAN的三层SVI接口
```

在AC上定义AP Group

- 将无线用户所属的WLAN与VLAN进行关联映射
- 一个group下面可以配置多个WLAN与VLAN的映射关系

![20_ap](http://images.zsjshao.net/rs/20-ap/20_ap.png)

在POE交换机连接AP的接口上打开POE供电

```
interface FastEthernet 0/1
 poe enable                     //开启POE供电功能
 switchport access vlan 1000    //AP所属VLAN
```

AP加组

- 等待AP与AC建立CAPWAP隧道后，AP的信息会自动出现在AC的配置中
- 如下所示,为一台RG-AP520-I关联上AC之后,在AC配置中自动出现的信息

![21_ap](http://images.zsjshao.net/rs/20-ap/21_ap.png)

定义WLAN的安全参数（可选）

- RSN(WPA 2)---**推荐使用**
  - PSK认证和AES加密

```
wlansec 100
 security rsn enable
 security rsn ciphers aes enable
 security rsn akm psk enable
 security rsn akm psk set-key ascii 1234567890
```

查看CAPWAP隧道状态

![22_ap](http://images.zsjshao.net/rs/20-ap/22_ap.png)

- 如果上述信息为空或者缺少部分信息:
  - 1、检查POE交换机是否对相应AP供电,接口是否poe enable
  - 2、检查AP的DHCP分配信息show ip dhcp bindings
  - 3、路由是否可达（AP到AC lo0地址的路由）： telnet 至AP,密码为ruijie，在AP上ping AC的Loopback0

查看AP上线

![23_ap](http://images.zsjshao.net/rs/20-ap/23_ap.png)

查看无线用户上线

![24_ap](http://images.zsjshao.net/rs/20-ap/24_ap.png)

#### 3.3.5、瘦AP配置小结

目前企业组网采用AC+FIT AP架构；

FIT AP分为集中转发与本地两种工作方式；

AC与AP之间运行CAPWAP协议，AC与AP之间可以是二层组网、三层组网、穿透NAT等；

CAPWAP隧道由控制隧道和数据隧道组成，控制隧道负责AP的升级、配置、射频管理等功能，数据隧道负责数据业务的封装转发

CAPWAP建立过程分为：AP获取IP地址与AC的IP地址、AP发现AC、AP请求加入AC、AP自动升级、AP配置下发、AP配置确认、通过CAPWAP隧道转发数据；

集中转发：数据流通过AC，并且由AC解封装CAPWAP协议；

本地转发：数据流不通过AC，没有CAPWAP数据隧道；

