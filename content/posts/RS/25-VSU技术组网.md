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



检测出双主机以后，系统将根据双主机检测规则选出最优VSU和非最优VSU。最优VSU一方没有受到影响；非最优VSU一方进入恢复（recovery）模式，系统将会关闭除VSL端口和管理员指定的例外端口（管理员可以用config-vs-domain模式下的命令“dual-active exclude interface”指定哪些端口不被关闭）以外的所有物理端口。

目前支持用BFD和聚合口检测双主机箱。如图所示，需要在两台交换机之间建立一条双主机检测链路，当VSL断开时，两台交换机开始通过双主机检测链路发送检测报文，收到对端发来的双主机检测报文，就说明对端仍在正常运行，存在两台主机
