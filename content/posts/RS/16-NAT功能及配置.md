+++
author = "zsjshao"
title = "16_NAT功能及配置"
date = "2020-05-23"
tags = ["NA"]
categories = ["RS"]
+++

## 1、NAT概述

### 1.1、NAT的背景

![01_nat](http://images.zsjshao.cn/images/rs/16-nat/01_nat.png)

### 1.2、网络地址转换NAT的概念

NAT （Network Address Translation）是一种把内部私有网络地址翻译成合法公网IP地址的技术

它是一种大型网络中节约注册IP地址数量，并简化IP寻址管理任务的机制

允许一个整体机构以一个公用IP地址出现在Internet上

![02_nat](http://images.zsjshao.cn/images/rs/16-nat/02_nat.png)

### 1.3、NAT的用途

解决地址空间不足的问题

- IPv4的空间已经严重不足，NAT可以大量节省公网IP



私有IP地址网络与公网互联

- 私有IP网络无法直接在公网上通信，NAT技术可以将其转化为合法的公网地址使私有网络与公网实现互联



使用未注册的公网IP地址与公网互联

- 内网使用的是未注册的公网IP，通过NAT技术也能正常与internet互联



网络改造中，避免更改地址带来的风险

- 内网改造不需要重新更换与外网互联地址，只需更改映射关系
- 内网改造出现地址重叠，NAT技术可以屏蔽重叠

### 1.4、NAT术语

| **术语**           | **定义**                                                     |
| ------------------ | ------------------------------------------------------------ |
| **内部本地IP地址** | 内部主机在内网中的IP地址（私网IP）                           |
| **内部全局IP地址** | 内部主机对外的外网IP地址（公网IP）                           |
| **外部全局IP地址** | 外部网络中的主机的IP地址（公网IP）                           |
| **外部本地IP地址** | 在内部网络中看到的外部主机的IP地址（私网IP）                 |
| **简单转换条目**   | 将一个IP地址映射到另一个IP地址的转换条目（通常被称为网络地址转换） |
| **扩展转换条目**   | 将一个IP地址和端口映射到另一个IP地址和端口的转换条目（通常被称为端口地址转换） |

![03_nat](http://images.zsjshao.cn/images/rs/16-nat/03_nat.png)

### 1.5、NAT的分类

静态NAT：手动建立一个内部IP地址到一个外部IP地址的映射关系

- 该方式经常用于企业网的内部设备需要能够被外部网络访问到的场合



动态NAT：将一个内部IP地址转换为一组外部IP地址（地址池）中的一个IP地址

- 常用于整个公司共用多个公网IP地址访问Internet时



超载NAT：动态NAT的一种特殊形式，利用不同端口号将多个内部IP地址转换为一个外部IP地址，也称为PAT、NAPT或端口复用NAT

- 常用于整个公司共用1个公网IP地址访问Internet时



端口映射NAT

- 常用于内部网络中的服务器，将某个服务端口映射到外网地址上，一个公网IP可以映射多个内网的服务

## 2、静态NAT

### 2.1、静态NAT

静态NAT实现了私有地址和公有地址的一对一映射，内网设备对外完全占有一个固定的公有IP地址

缺点是映射之后的用户如果不是一直在访问互联网，将造成IP地址的浪费

未做映射的用户无法访问互联网，有多少个内网IP地址就需要多少个公网IP地址进行映射，成本较高

![04_nat](http://images.zsjshao.cn/images/rs/16-nat/04_nat.png)

### 2.2、静态NAT的工作过程

配置静态NAT，实现私有地址（PC1的IP地址）和公有地址（R1的F0/1接口IP）的一对一映射，使PC1能ping通PC3

- 第1-3步，数据包从PC1（源IP=192.168.1.100）发出，经过R1时进行源地址转换后，源IP变为100.1.1.100
- 第4-6步，从PC3（目的IP=100.1.1.100）进行回包，到达R1时，根据NAT转换表进行目的地址转换，目的IP变为了原来的192.168.1.100

![05_nat](http://images.zsjshao.cn/images/rs/16-nat/05_nat.png)

### 2.3、静态NAT的配置步骤

指定接口类型为内部接口或外部接口

- (config-if)# **ip** **nat** { inside | outside } 

配置静态转换条目

- (config-if)# **ip** **nat** **inside source static** *local-ip* { interface *interface* | *global-ip* }

```
路由器R1上，NAT相关配置：

R1(config)#interface fastEthernet 0/0
R1(config-if)#ip address 192.168.1.254 255.255.255.0
R1(config-if)#ip nat inside

R1(config)#interface fastEthernet 0/1
R1(config-if)#ip address 100.1.1.100 255.0.0.0
R1(config-if)#ip nat outside

R1(config)#ip nat inside source static 192.168.1.100 10.1.1.100 
```

### 2.4、静态NAT的验证

PC1能ping通PC3

```
PC1>ping 100.1.1.1

Pinging 100.1.1.1 with 32 bytes of data:
Reply from 100.1.1.1: bytes=32 time=1ms TTL=127
Reply from 100.1.1.1: bytes=32 time=0ms TTL=127
Reply from 100.1.1.1: bytes=32 time=1ms TTL=127
Reply from 100.1.1.1: bytes=32 time=0ms TTL=127
Ping statistics for 100.1.1.1:
Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
Minimum = 0ms, Maximum = 1ms, Average = 0ms
```

**此时，PC3 访问 PC1 该怎么 ping** **？**

**A.ping** **192.168.1.100**

**B.ping** **100.1.1.100** 

## 3、动态NAT

### 3.1、动态NAT

动态NAT需要配置地址池，地址池中公网IP地址可以“租用”给内网主机访问外网

动态NAT的地址池中的IP在被映射时，等于完全被租用被某个内网主机，因此其他主机无法使用

- 例如下图，此时PC1、PC2正使用地址池中仅有的两个公网IP地址进行动态NAT，那么此时PC4将不能访问互联网
- 需要等待PC1或者PC2释放地址之后，PC4才能通过动态NAT上网

![06_nat](http://images.zsjshao.cn/images/rs/16-nat/06_nat.png)

### 3.2、动态NAT的工作过程

根据拓扑图，配置动态NAT，基于地址池来实现私有地址（PC1和PC2的IP地址）和公有地址的转换

R1的公有地址池为100.1.1.101-100.1.1.105

- PC1访问PC3时的地址转换，在R1的NAT转换表中出现临时的转换条目，PC1占用IP地址100.1.1.101

![07_nat](http://images.zsjshao.cn/images/rs/16-nat/07_nat.png)

- PC2访问PC3时的地址转换，在R1的NAT转换表中出现临时的转换条目，PC2占用IP地址100.1.1.102

![08_nat](http://images.zsjshao.cn/images/rs/16-nat/08_nat.png)

### 3.3、动态NAT的配置步骤

定义IP访问控制列表（定义进行NAT地址转换的私有地址）

- **(config)# access-list** *access-list-number* { **permit** | **deny** }

定义一个地址池（定义进行NAT地址转换的公有地址）

- **(config)# ip nat pool** *pool-name* *start-**ip* *end-**ip* { **netmask** *netmask* | **prefix-length** *prefix-length* }

配置动态转换条目

- **(config)# ip nat inside source list** *access-list-number* { **interface** *interface* | **pool** *pool-name* }

```
R1(config)#interface fastEthernet 0/0
R1(config-if)#ip address 192.168.1.254 255.255.255.0
R1(config-if)#ip nat inside

R1(config)#interface fastEthernet 0/1
R1(config-if)#ip address 100.1.1.100 255.0.0.0
R1(config-if)#ip nat outside

R1(config)#access-list 10 permit 192.168.1.0 0.0.0.255 
R1(config)#ip nat pool ruijie 100.1.1.100 100.1.1.105 netmask 255.0.0.0 
R1(config)#ip nat inside source list 10 pool ruijie
```

### 3.4、动态NAT的验证

PC1和PC2能ping通PC3

```
PC1>ping 100.1.1.1
Pinging 100.1.1.1 with 32 bytes of data:
Reply from 100.1.1.1: bytes=32 time=1ms TTL=127
Reply from 100.1.1.1: bytes=32 time=0ms TTL=127
Reply from 100.1.1.1: bytes=32 time=1ms TTL=127
Reply from 100.1.1.1: bytes=32 time=0ms TTL=127
Ping statistics for 100.1.1.1:
Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
Minimum = 0ms, Maximum = 1ms, Average = 0ms

PC2>ping 100.1.1.1
Pinging 100.1.1.1 with 32 bytes of data:
Reply from 100.1.1.1: bytes=32 time=1ms TTL=127
Reply from 100.1.1.1: bytes=32 time=0ms TTL=127
Reply from 100.1.1.1: bytes=32 time=1ms TTL=127
Reply from 100.1.1.1: bytes=32 time=0ms TTL=127
Ping statistics for 100.1.1.1:
Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
Minimum = 0ms, Maximum = 1ms, Average = 0ms
```

### 3.5、动态NAT的地址转换表

R1上使用命令show ip nat translations 可以查看NAT地址转换信息

```
R1#show ip nat translations 
Pro  Inside global     Inside local       Outside local      Outside global
icmp 100.1.1.100:17    192.168.1.100:17   100.1.1.1:17       100.1.1.1:17
icmp 100.1.1.100:18    192.168.1.100:18   100.1.1.1:18       100.1.1.1:18
icmp 100.1.1.100:19    192.168.1.100:19   100.1.1.1:19       100.1.1.1:19
icmp 100.1.1.101:20    192.168.1.100:20   100.1.1.1:20       100.1.1.1:20
icmp 100.1.1.101:5     192.168.1.200:5    100.1.1.1:5        100.1.1.1:5
icmp 100.1.1.101:6     192.168.1.200:6    100.1.1.1:6        100.1.1.1:6
icmp 100.1.1.101:7     192.168.1.200:7    100.1.1.1:7        100.1.1.1:7
icmp 100.1.1.102:8     192.168.1.200:8    100.1.1.1:8        100.1.1.1:8
```

## 4、超载NAT

### 4.1、超载NAT的概念

超载NAT可以将公网地址的端口映射给内网地址的端口，实现多个私有地址映射为一个公有地址

超载NAT可以配置地址池，也可以直接使用外网接口的IP地址

如果直接使用外网接口的IP地址，多个内网机器访问外网时，会使用同一个外网地址的不同端口号进行访问

- 如下图，只配置了一个用于转换的外网IP地址（即F0/1的IP地址），通过超载NATP使PC1和PC2能ping通PC3，但对外来说，都是100.1.1.100的IP地址与外部进行通信

![09_nat](http://images.zsjshao.cn/images/rs/16-nat/09_nat.png)

### 4.2、超载NAT的工作过程

如下图，描述PC1与PC2访问PC3的NAT转换过程

- PC1的数据包到达R1后，将PC1的源端口与源IP映射为外网接口IP与它的一个端口号，替换为新的源IP与源端口

![10_nat](http://images.zsjshao.cn/images/rs/16-nat/10_nat.png)

- PC2的数据包到达R1后，将PC2的源端口与源IP映射为外网接口IP与它的一个端口号，替换为新的源IP与源端口

![11_nat](http://images.zsjshao.cn/images/rs/16-nat/11_nat.png)

### 4.3、超载NAT的配置

超载NAT与动态NAT配置基本一致，唯一不同是必须要指定overload关键字，路由器才会将源端口也进行转换，以达到地址超载的目的，如果不指定**overload** **关键字**，路由器将执行动态NAT转换

配置动态转换关键命令

- **(config)# ip nat inside source list** *access-list-number*  { **interface** *interface* *|* **pool** *pool-name* } **overload**

```
R1(config)#interface fastEthernet 0/0
R1(config-if)#ip address 192.168.1.254 255.255.255.0
R1(config-if)#ip nat inside

R1(config)#interface fastEthernet 0/1
R1(config-if)#ip address 100.1.1.100 255.0.0.0
R1(config-if)#ip nat outside

R1(config)#access-list 10 permit 192.168.1.0 0.0.0.255 
R1(config)#ip nat inside source list 10 interface fastEthernet 0/1 overload
```

### 4.4、超载NAT的验证

PC1和PC2能ping通PC3

```
PC1>ping 100.1.1.1
Pinging 100.1.1.1 with 32 bytes of data:
Reply from 100.1.1.1: bytes=32 time=1ms TTL=127
Reply from 100.1.1.1: bytes=32 time=0ms TTL=127
Reply from 100.1.1.1: bytes=32 time=1ms TTL=127
Reply from 100.1.1.1: bytes=32 time=0ms TTL=127
Ping statistics for 100.1.1.1:
Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
Minimum = 0ms, Maximum = 1ms, Average = 0ms

PC2>ping 100.1.1.1
Pinging 100.1.1.1 with 32 bytes of data:
Reply from 100.1.1.1: bytes=32 time=1ms TTL=127
Reply from 100.1.1.1: bytes=32 time=0ms TTL=127
Reply from 100.1.1.1: bytes=32 time=1ms TTL=127
Reply from 100.1.1.1: bytes=32 time=0ms TTL=127
Ping statistics for 100.1.1.1:
Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
Minimum = 0ms, Maximum = 1ms, Average = 0ms
```

### 4.5、超载NAT的地址转换表

R1上使用命令show ip nat translations 可以查看NAT地址转换信息。

```
R1#show ip nat translations 
Pro  Inside global     Inside local         Outside local      Outside global
icmp 100.1.1.100:1024  192.168.1.200:1      100.1.1.1:1        100.1.1.1:1024
icmp 100.1.1.100:1025  192.168.1.200:2      100.1.1.1:2        100.1.1.1:1025
icmp 100.1.1.100:1026  192.168.1.200:3      100.1.1.1:3        100.1.1.1:1026
icmp 100.1.1.100:1027  192.168.1.200:4      100.1.1.1:4        100.1.1.1:1027
icmp 100.1.1.100:3000  192.168.1.100:2000   100.1.1.1:1        100.1.1.1:1
icmp 100.1.1.100:3001  192.168.1.101:2000   100.1.1.1:2        100.1.1.1:2
icmp 100.1.1.100:3     192.168.1.100:3      100.1.1.1:3        100.1.1.1:3
icmp 100.1.1.100:4     192.168.1.100:4      100.1.1.1:4        100.1.1.1:4
```

## 5、服务器端口映射

### 5.1、服务器端口映射的应用场景

动态NAT与超载NAT适用于大量内网用户访问外网，但是外网用户却无法主动访问内网的主机

静态NAT虽然可以将内网服务器一对一映射到外网，但是浪费公网地址

企业中常有多种服务应用需要映射到公网，服务器端口映射可以使得这些服务都固定映射到同一个公网IP的不同端口

![12_nat](http://images.zsjshao.cn/images/rs/16-nat/12_nat.png)

### 5.2、服务器端口映射的配置

- R1的配置

```
R1(config)#interface fastEthernet 0/0
R1(config-if)#ip address 192.168.1.254 255.255.255.0
R1(config-if)#ip nat inside

R1(config)#interface fastEthernet 0/1
R1(config-if)#ip address 100.1.1.100 255.0.0.0
R1(config-if)#ip nat outside

R1(config)#ip nat inside source static tcp 192.168.1.1 80 100.1.1.100 80
R1(config)#ip nat inside source static tcp 192.168.1.2 21 100.1.1.100 21
R1(config)#ip nat inside source static tcp 192.168.1.3 23 100.1.1.100 23
R1(config)#ip nat inside source static tcp 192.168.1.4 8080 100.1.1.100 8080
                                       协议 内部地址   内部端口 外网接口地址  对外的端口
```

### 5.3、服务器端口映射的验证

验证映射的Telnet服务是否成功

- PC3执行命令 telnet100.1.1.100

```
PC3>telnet 100.1.1.100
Trying 100.1.1.100 ...Open

User Access Verification

Username: admin
Password: 
R3>
```

- R1上使用命令show ip nat translations 可以查看NAT地址转换信息。

```
R1r#sh ip nat translations 
Pro Inside global Inside local Outside local Outside global
tcp 100.1.1.100:23 192.168.1.3:23 --- ---
tcp 100.1.1.100:23 192.168.1.3:23 100.1.1.1:1026 100.1.1.1:1026
```

