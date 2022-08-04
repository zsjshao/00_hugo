+++
author = "zsjshao"
title = "13_RIP协议原理及配置"
date = "2020-05-23"
tags = ["NA"]
categories = ["RS"]
+++

## 1、RIP协议概述

### 1.1、RIP的概述

- RIP是Routing Information Protocol（路由信息协议）的简称
- RIP是一种基于距离矢量（Distance-Vector）算法的路由协议，
- 使用跳数作为度量值来衡量路径的优劣，取值范围0-15，16跳表示路由不可达，RIP每经过一台路由器为一跳
- 相对于静态路由来说，RIP可以自动发现拓扑的变化，更新路由，不需要管理员干预，配置简单，适合小型网络
- RIP支持水平分割、毒性逆转和触发更新等工作机制防止路由环路
- RIP协议的管理距离120
- RIP信息交互使用两种报文，一种是请求包，另外一种是应答包
- RIP定期更新、全路由表更新、协议收敛慢

### 1.2、RIPv1与RIPv2的对比

RIP协议适用于中小型网络，分为RIPv1和RIPv2 ：

- V1有类路由协议，广播更新，不通告掩码信息
- ØV2无类路由协议，组播更新，通告掩码信息

| **RIPv1**                        | **RIPv2**                                    |
| -------------------------------- | -------------------------------------------- |
| 有类别路由协议，不支持VLSM和CIDR | 无类别路由协议，支持路由聚合、支持VLSM和CIDR |
| 广播                             | 广播/组播（224.0.0.9）                       |
| 不支持认证                       | 支持明文认证和MD5密文认证                    |

![01_rip](http://images.zsjshao.cn/images/rs/13-rip/01_rip.png)

### 1.3、RIPv1的报文格式

![02_rip](http://images.zsjshao.cn/images/rs/13-rip/02_rip.png)

### 1.4、RIPv2的报文格式

![03_rip](http://images.zsjshao.cn/images/rs/13-rip/03_rip.png)

### 1.5、RIPv2的认证

- RIPv2支持对协议报文进行认证，认证方式有明文认证和MD5认证两种

![04_rip](http://images.zsjshao.cn/images/rs/13-rip/04_rip.png)

## 2、RIP的原理与配置

### 2.1、RIP协议的工作原理

RIP路由表的初始化

- 每台三层设备，RIP协议一运行便发送路由请求报文（Request）
- 收到请求报文（Request）的三层设备便将包含路由信息的相应报文（Response）回复给请求者。

![05_rip](http://images.zsjshao.cn/images/rs/13-rip/05_rip.png)

RIP路由表的更新

- 请求者收到相应报文（Response） 后，更新路由表。

![06_rip](http://images.zsjshao.cn/images/rs/13-rip/06_rip.png)

RIP路由表的定期更新

- 网络稳定之后，RIP路由协议每过**30s**向邻居更新一次路由。

![07_rip](http://images.zsjshao.cn/images/rs/13-rip/07_rip.png)

### 2.2、RIP路由环路问题

- 链路正常时，R3的路由表项正常
- 10.4.0.0的路由失效了之后，R3将该路由从路由表中删除

![08_rip](http://images.zsjshao.cn/images/rs/13-rip/08_rip.png)

- 但R3未能及时通告给R2，R2又将10.4.0.0的路由通告给R3
- R3接收并且使用错误路由，导致路由环路

![09_rip](http://images.zsjshao.cn/images/rs/13-rip/09_rip.png)

#### 2.2.1、RIP协议环路防护机制：水平分割

- 运行RIP协议的设备会记住每一条路由信息来源，并且不会在收到这条信息的端口上再次发送它

![10_rip](http://images.zsjshao.cn/images/rs/13-rip/10_rip.png)

#### 2.2.2、RIP协议环路防护机制：路由毒化与毒性反转

- 毒性反转是指三层设备从某个接口学到RIP路由后，将该路由的跳数设置为16，并从原接口发回给邻居
- 16跳表示路由不可达

```
R1的路由表
Destination/Mask   Nexthop     metric
1.0.0.0/8          2.0.0.2       16

R3的路由表
Destination/Mask   Nexthop     metric
4.0.0.0/8          3.0.0.1       16
```

![11_rip](http://images.zsjshao.cn/images/rs/13-rip/11_rip.png)

#### 2.2.3、RIP协议环路防护机制：触发更新

- 触发更新是指当路由信息发生变化时，立即向邻居设备发送触发更新报文

![12_rip](http://images.zsjshao.cn/images/rs/13-rip/12_rip.png)

### 2.3、RIP路由协议配置案例

- 根据拓扑图，配置设备的IP地址、掩码和默认网关
- 在三台路由器上配置RIP路由，使PC1和PC2能ping通PC3

![13_rip](http://images.zsjshao.cn/images/rs/13-rip/13_rip.png)

```
启动RIP进程：
 switch(config)# router rip

定义RIP使用 V2版本：
 switch (config-router)# version 2

宣告网段：
 switch (config-router)# network 网络号

关闭RIPv2自动汇总：
 switch (config-router)# no auto-summary
```

- network命令后面跟的是主类网络号，配置时为了方便可以直接写接口IP地址，设备会自动更正

```
R1(config)#router rip 
R1(config-router)#version 2
R1(config-router)#no auto-summary 
R1(config-router)#network 172.16.2.254
R1(config-router)#network 172.16.1.254
R1(config-router)#network 10.1.0.1

R2(config)#router rip 
R2(config-router)#version 2
R2(config-router)#no auto-summary 
R2(config-router)#network 10.1.0.2
R2(config-router)#network 10.2.0.1

R3(config)#router rip 
R3(config-router)#version 2
R3(config-router)#no auto-summary 
R3(config-router)#network 10.2.0.2
R3(config-router)#network 10.3.0.254
```

- 使用特权用户模式命令show ip route，显示IP路由表

```
R1#show ip route
R   10.2.0.0 [120/1] via 10.1.0.2, 00:00:02, Serial0/1/0
R   10.3.0.0 [120/2] via 10.1.0.2, 00:00:02, Serial0/1/0

R2#show ip route
R   10.3.0.0 [120/1] via 10.2.0.2, 00:00:01, FastEthernet0/1
R   172.16.1.0 [120/1] via 10.1.0.1, 00:00:23, Serial0/1/0
R   172.16.2.0 [120/1] via 10.1.0.1, 00:00:23, Serial0/1/0

R3#show ip route
R   10.1.0.0 [120/1] via 10.2.0.1, 00:00:29, FastEthernet0/0
R   172.16.1.0 [120/2] via 10.2.0.1, 00:00:29, FastEthernet0/0
R   172.16.2.0 [120/2] via 10.2.0.1, 00:00:29, FastEthernet0/0
```

### 2.4、RIPv2的自动汇总

- 如果不使用命令no auto-summary，R2作为主类网络的边界，将会对子网进行汇总

![14_rip](http://images.zsjshao.cn/images/rs/13-rip/14_rip.png)

## 3、RIP协议的缺陷

### 3.1、RIP路由协议应用中的缺陷1

- 以跳数评估的路由并非最优路径
- 如果SW1选择F0/2传输，实际传输需要的时间更少

![15_rip](http://images.zsjshao.cn/images/rs/13-rip/15_rip.png)

### 3.2、RIP路由协议应用中的缺陷2

- 收敛速度慢
- R1和R2收到路由不可达信息后进入抑制时间
- 抑制时间结束前，即使收到新的设备发布路由，R1与R2的路由也不能更新

![16_rip](http://images.zsjshao.cn/images/rs/13-rip/16_rip.png)

