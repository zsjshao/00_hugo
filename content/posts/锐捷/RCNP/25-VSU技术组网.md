+++
author = "zsjshao"
title = "25_VSU技术组网"
date = "2023-04-17"
tags = ["NP"]
categories = ["RS"]

+++

## VSU概述

传统可靠性网络

- 传统网络中，为了增强网络的可靠性，在核心层部署两台交换机，分别连接所有汇聚层交换机
- 为了消除环路，在核心层交换机和汇聚层交换机上配置MSTP协议，阻塞一部分链路
- 为了提供冗余网关，在核心层交换机上配置VRRP协议

![01_vsu](http://images.zsjshao.cn/images/rs/25-vsu/01_vsu.png)

缺陷：

- 网络拓扑复杂，管理困难
- 故障恢复时间一般在秒级
- 部分链路阻塞，链路带宽资源浪费

VSU高可靠性网络

- VSU（ Virtual Switch Unit ），一种把两台物理交换机组合成一台虚拟交换机的新技术
- 如下图把传统网络中两台核心层交换机用VSU替换，VSU和汇聚层交换机通过聚合链路连接。在外围设备看来，VSU相当于一台交换机 

![02_vsu](http://images.zsjshao.cn/images/rs/25-vsu/02_vsu.png)

VSU与传统相比技术优势

- 简化管理
  - 管理员只需要连接一台设备，就可以进行统一管理
- 简化网络拓扑
  - 通过聚合链路和外围设备连接，不存在二层环路，没必要配置MSTP协议
  - 减少协议报文交互，例如OSPF、PIM、SNMP等协议
- 故障恢复时间缩短到毫秒级
  - 故障切换时间50到200毫秒
- 提高带宽利用率
  - 既提供了冗余链路，又可以实现负载均衡，充分利用所有带宽

VSU基本概念：工作模式

- 交换机有两种工作模式：单机模式（默认）、VSU模式

```
切换为单机模式：（特权模式下）switch convert mode standalone
切换为VSU模式：（特权模式下）switch convert mode virtual 
```

![03_vsu](http://images.zsjshao.cn/images/rs/25-vsu/03_vsu.png)

- 组建VSU，必须把交换机的工作模式从单机模式切换到VSU模式

VSU基本概念：Switch ID

- 设备编号Switch ID是交换机在VSU中的成员编号，取值是1到8（缺省为1）
- 在单机模式，接口编号采用二维格式（如GigabitEthernet 2/3）
- 在VSU模式中，接口编号采用三维格式（如GigabitEthernet 1/2/3）
  - 第一维（数字1）表示机箱成员编号
  - 后面两维（数字2和3）分别表示槽位号和该槽位上的接口编号

```
VSU#show switch virtual 
Switch_id   Domain_id   Priority    Status     Role          Description
-----------------------------------------------------------------------------
1(1)           1(1)             200(200)    OK        ACTIVE        
2(2)           1(1)             150(150)    OK        STANDBY 
3(3)           1(1)             100(100)    OK        CANDIDATE
4(4)           1(1)             100(100)    OK        CANDIDATE
```

- 1（1）中的数值表示，1表示为当前运行的设备号，（1）中的1表示为当前配置的设备号（重启后生效）

VSU基本概念：Domain ID

- 域编号（Domain ID）是VSU的标识符，用来区分不同的VSU
- 两台交换机的domain ID相同，才能组成VSU，取值范围是1到255（缺省100）
  - 在非VSU状态下，修改命令：switch virtual domain XX
  - 在VSU状态下，进入VSU域配置，修改命令：switch XX domain XX，保存命令重启后生效

```
VSU#show switch virtual 
Switch_id   Domain_id   Priority    Status     Role          Description
-----------------------------------------------------------------------------
1(1)           1(1)             200(200)    OK        ACTIVE        
2(2)           1(1)             150(150)    OK        STANDBY 
3(3)           1(1)             100(100)    OK        CANDIDATE
4(4)           1(1)             100(100)    OK        CANDIDATE
```

- 1（1）中的数值表示，1表示为当前运行的域编号，（1）中的1表示为当前配置的域编号（重启后生效）

- 注意：一台设备只能处于一个domain下

VSU基本概念：优先级

- 优先级是成员设备的一个属性，在角色选举过程用到
- 优先级值越大，被选举为主设备的可能性越大，取值范围是1到255（缺省为100）

```
VSU#show switch virtual 
Switch_id   Domain_id   Priority    Status     Role          Description
-----------------------------------------------------------------------------
1(1)           1(1)             200(200)    OK        ACTIVE        
2(2)           1(1)             150(150)    OK        STANDBY 
3(3)           1(1)             100(100)    OK        CANDIDATE
4(4)           1(1)             100(100)    OK        CANDIDATE
```

- 200（200）中的数值表示，200表示为当前运行的优先级，（200）表示为当前配置的优先级（重启后生效） 

VSU基本概念：4种状态

- OK 状态： 设备 VSU 运行正常，属于最终的稳定态
- Recovery 状态： 
  - 在 VSU 系统分裂，且配置有 BFD 或者链路聚合检测时，备机设备会处于该状态
  - 当两个分裂的 VSU 系统合并时，选举失败的那一方也会短暂性的处于该状态
- Leave 离开状态：属于过程状态， 只在设备重启过程中会存在
- Isolate 孤立状态： 当switch id一致时，优先级低的那台 VSU 状态将为isolate，此时 VSL 链路全为 down 状态

```
VSU#show switch virtual 
Switch_id   Domain_id   Priority    Status     Role          Description
-----------------------------------------------------------------------------
1(1)           1(1)             200(200)    OK        ACTIVE        
2(2)           1(1)             150(150)    OK        STANDBY 
3(3)           1(1)             100(100)    OK        CANDIDATE
4(4)           1(1)             100(100)    OK        CANDIDATE
```

- 处于 Recovery 状态的设备将会把处于 VSL 接口和例外口之外的所有接口都置为 shutdown 状态当 Recovery 状态的设备检测到有非 Recovery 状态的邻居时，会自动重启

关于VSU的分裂

- 当VSL断开导致Active设备和Standby设备分到不同的VSU时，就会产生VSU分裂，网络上会出现两个配置相同的VSU
- 在三层，两个VSU的任何一个虚接口（VLAN接口和环回接口等等）的配置相同，网络中出现IP地址冲突
- 解决方案是采用检测机制，发现分裂现象，让其中一方进入recovery状态
  - 检测机制1：基于BFD检测
  - 检测机制2：基于聚合口检测

![04_vsu](http://images.zsjshao.cn/images/rs/25-vsu/04_vsu.png)

- 检测出双主机以后，系统将根据双主机检测规则选出最优VSU和非最优VSU。最优VSU一方没有受到影响；非最优VSU一方进入恢复（recovery）模式，系统将会关闭除VSL端口和管理员指定的例外端口（管理员可以用config-vs-domain模式下的命令“dual-active exclude interface”指定哪些端口不被关闭）以外的所有物理端口。

- 目前支持用BFD和聚合口检测双主机箱。如图所示，需要在两台交换机之间建立一条双主机检测链路，当VSL断开时，两台交换机开始通过双主机检测链路发送检测报文，收到对端发来的双主机检测报文，就说明对端仍在正常运行，存在两台主机

VSU基本概念：3种角色

- VSU中每台设备都称为成员设备，成员设备按照功能不同，分为三种角色：
  - Active 主设备（有且仅有一个）：管理整个VSU，负责同步配置、时间等到所有成员设备
  - Standby 从设备（有且仅有一个） ：当Active故障时，Standby会自动升级为Active接替原Active工作
  - Candidate 候选设备：
    - 当Standby故障时，系统会自动从Candidate中选举一个新的Standby接替原Standby工作
    - 当Active故障时，在Standby自动升级为Active接替原Active工作的同时，系统也会自动从Candidate中选举一个新的Standby接替原Standby工作

```
VSU#show switch virtual 
Switch_id   Domain_id   Priority    Status     Role          Description
-----------------------------------------------------------------------------
1(1)           1(1)             200(200)    OK        ACTIVE        
2(2)           1(1)             150(150)    OK        STANDBY 
3(3)           1(1)             100(100)    OK        CANDIDATE
4(4)           1(1)             100(100)    OK        CANDIDATE
```

VSU基本概念：VSL链路

- 虚拟交换链路（Virtual Switching Link，简称VSL）是VSU系统的设备间传输控制信息和数据流的特殊聚合链路
- VSL端口以聚合端口组的形式存在
- VSL成员端口：用于VSL端口连接的物理端口
- VSL成员端口可以是堆叠端口、以太网接口、光口

![05_vsu](http://images.zsjshao.cn/images/rs/25-vsu/05_vsu.png)

- 部署时，建议至少要配置两条VSL
- 如果是高端设备组建VSU，建议使用不同线卡组建VSL

虚拟交换链路（Virtual Switching Link，简称VSL）是VSU系统的设备间传输控制信息和数据流的特殊聚合链路

VSL端口以聚合端口组的形式存在，由VSL传输的数据流根据流量平衡算法在聚合端口的各个成员之间就进行负载均衡

设备上可以用于VSL端口连接的物理端口称之为VSL成员端口。VSL成员端口可能是堆叠端口、以太网接口或者光口

## VSU工作原理

VSU控制面原理

- VSU组建时，经过VSL链路的数据报文非普通的以太网报文，而是内部通信使用的HG报文
- 报文格式如下图：

![06_vsu](http://images.zsjshao.cn/images/rs/25-vsu/06_vsu.png)

- 逻辑上，VSU各成员已看做出一台设备，及表项只有一个
- 实际上，各个成员设备依然各自维护着各个表项信息，各成员表项信息一致

![07_vsu](http://images.zsjshao.cn/images/rs/25-vsu/07_vsu.png)

本地转发

- 转发报文的入接口和出接口在同一台成员设备上
- 当成员设备收到报文后，查找本地转发表，发现出接口就在本机上，则成员设备直接将报文从这个出接口发送出去

![08_vsu](http://images.zsjshao.cn/images/rs/25-vsu/08_vsu.png)

- VSU 采用分布式转发技术实现报文的二/三层转发，最大限度的发挥了每个成员的处理能力。VSU 系统中的每个成员设备都有完整的二/三层转发能力，当它收到待转发的二/三层报文时，可以通过查询本机的二/三层转发表得到报文的出接口（以及下一跳），然后将报文从正确的出接口送出去，这个出接口可以在本机上也可以在其它成员设备上，并且将报文从本机送到另外一个成员设备是一个纯粹内部的实现，对外界是完全屏蔽的，即对于三层报文来说，不管它在 VSU 系统内部穿过了多少成员设备，在跳数上只增加1，即表现为只经过了一个网络设备。

本地优先转发

- 默认情况下，该功能均为开启，即默认都是本地转发
  - 如果关闭该功能，当报文的出口分布在多台设备中，则根据AP 配置规则或者ECMP配置规则转发流量。那将有可能导致报文从非本机转发，这样有可能导致转发不优。 

- 优先本地转发功能有两种模式：

  - AP本地优先转发
    - 使用 switch virtual aggregateport-lff enable 命令打开AP本地转发优先LFF(Local Forward First)

  - ECMP本地优先转发
    - 用switch virtual ecmp-lff enable 命令打开ecmp 本地转发优先 LFF(Local Forward First)

- 三层设备若部署 VSU，建议用户配置基于IP 的AP 负载均衡模式src-ip，dst-ip，src-dst-ip 等

单播报文转发

- 转发报文的入接口和出接口在不同的成员设备上
  - 当成员设备1 收到报文后，查找本地转发表，发现出接口在成员设备2上
  - 成员设备1根据单播最优路径将报文转发给成员设备2，而成员设备2最终将报文转发出去

组播报文转发

- 成员设备1收到一个组播报文，它通过两个VSL通道将组播报文转发出去
- 在组播报文经过成员设备2和3时，由于成员设备2和3上均有组播接入，因此成员设备2和3会将报文转发出去
- 根据组播转发原理，组播流量会分别截止于成员设备3和成员设备4，自动避免报文环路

![09_vsu](http://images.zsjshao.cn/images/rs/25-vsu/09_vsu.png)

## VSU配置

VSU配置思路

- 确定VSU连接方式
  - VSL连线：首选环型连接、多VSL链路互联
  - BFD连线：单独连线，不做业务使用
- 明确VSU成员版本
  - 将VSU成员版本升级为一致
- 配置VSU
- 修改设备模式为VSU
- 配置双主机检测（建议使用BFD检测）

配置VSU

- 配置域（默认为100，无需变更，成员间域要一致）
- 配置设备ID（默认为1，需要变更，成员间设备ID应设置为不同）
- 配置优先级（默认为100，建议变更，根据实际需求，配置主备优先级）
- 配置VSL端口（根据实际连接情况将端口加入到VSL中）
  - VSL链路至少需要2条，一条链路可靠性较低，当出现链路震荡时，VSU会非常不稳定。配置VSL链路，VSU主备核心之间的心跳链路和流量通道

```
Switch1(config)# switch virtual domain 1
Switch1(config-vs-domain)# switch 1
Switch1(config-vs-domain)# switch 1 priority 200  
Switch1(config)#vsl-port  
//10.X版本 vsl-aggregateport
Switch1(config-vsl-ap)#port-member interface tenGigabitEthernet 0/15
Switch1(config-vsl-ap)#port-member interface tenGigabitEthernet 0/16

Switch2(config)# switch virtual domain 1  
Switch2(config-vs-domain)# switch 2
Switch2(config-vs-domain)# switch 2 priority 150
Switch2(config-vs-domain)# exit
Switch2(config)#vsl-port 
Switch2(config-vsl-ap)#port-member interface tenGigabitEthernet 0/15
Switch2(config-vsl-ap)#port-member interface tenGigabitEthernet 0/16
```

修改设备模式为VSU

- 同时将成员设备模式配置为VSU

```
核心交换机1
Switch1# wr
Switch1# switch convert mode virtual         ------>转换为VSU模式
Are you sure to convert switch to virtual mode[yes/no]：yes
Do you want to recovery“config.text”from“virtual_switch.text”[yes/no]：no  
 
核心交换机2
Switch2# wr
Switch2# switch convert mode virtual  ------>转换为VSU模式
Are you sure to convert switch to virtual mode[yes/no]：yes
Do you want to recovery“config.text”from“virtual_switch.text”[yes/no]：no
 
选择转换模式后，设备会重启启动，并组建VSU。
```

配置双主机检测（建议使用BFD检测）

- 添加BFD端口（根据实际BFD连接情况将端口添加进BFD）
- 启用BFD

```
等待VSU建立成功后，进行BFD配置
Ruijie#configure terminal
Ruijie(config)#interface GigabitEthernet 1/0/13  ------>第一台VSU设备的第0槽第13个接口
Ruijie(config-if-GigabitEthernet 1/3/1)#no switchport   ------>只需要在BFD接口上敲no sw，无需其他配置

Ruijie(config)#interface GigabitEthernet 2/0/13  ------>第二台VSU设备的第0槽第13个接口
Ruijie(config-if-GigabitEthernet 2/3/1)#no switchport  ------>只需要在BFD接口上敲no sw，无需其他配置

Ruijie(config)#switch virtual domain 1
Ruijie(config-vs-domain)#dual-active detection bfd
Ruijie(config-vs-domain)#dual-active bfd interface GigabitEthernet 1/0/13
Ruijie(config-vs-domain)#dual-active bfd interface GigabitEthernet 2/0/13
```

VSU检查命令

- VSU的管理需要在其中的主机上进行
- VSU主机的引擎Primary灯绿色常亮，VSU从机的Primary灯灭，可以用来判断主从机关系

```
Core#show switch virtual 
Switch_id   Domain_id   Priority    Status     Role          Description
-----------------------------------------------------------------------------
1(1)        1(1)        200(200)    OK         ACTIVE        
2(2)        1(1)        150(150)    OK         STANDBY 
```

- VSU组建后从机Console口默认不能进行管理，建议使用session device  slot 登录其它设备查看信息

```
Core#session device 2
Trying tipc...

Core-STANDBY-2>
```

查看VSU的VSL链路状态

- 使用show switch virtual link查看VSL链路状态

```
Core#show switch virtual link 
VSL-AP   State    Peer-VSL   Rx                   Tx                   Uptime        
------------------------------------------------------------------------------------------
1/1      UP       2/1        17016                13918                0d,0h,28m     
2/1      UP       1/1        13989                17072                0d,0h,28m 
```

- 使用show switch virtual topology查看VSU拓扑信息

```
Core#show switch virtual topology 
Introduction: '[num]' means switch num, '(num/num)' means vsl-aggregateport num.

Chain Topology:
[1](1/1)---(2/1)[2]

Switch[1]: ACTIVE, MAC: 0074.9c96.28aa, Description: 
Switch[2]: STANDBY, MAC: 0074.9c96.28ea, Description: 
```

查看VSU负载均衡状态

- 查看交换机VSU的负载均衡模式

```
SW1#show switch virtual balance 
Aggregate port LFF: enable
```

- 查看交换机链路捆绑的负载均衡模式

```
SW1#show aggregatePort load-balance 
Load-balance   : Source MAC and Destination MAC
```

思考题

- VSU可以使用于什么场景？
- 配置VSU时，配置步骤是什么？
- 如何检查当前VSU的状态是否正常？
- 当两台设备配置了VSU以后，如果分裂会产生什么后果？如何防止分裂？
