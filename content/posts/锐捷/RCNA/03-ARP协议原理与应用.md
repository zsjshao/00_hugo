+++
author = "zsjshao"
title = "03_ARP协议原理与应用"
date = "2020-05-23"
tags = ["NA"]
categories = ["RS"]

+++

## 1、ARP协议概述

### 1.1、场景描述

数据要在以太网中传输，需要完成以太网封装，这项工作由网络层负责；

要完成以太网的数据封装，需要知道目的设备的MAC地址；

![01_arp](http://images.zsjshao.cn/images/rs/03-arp/01_arp.png)

### 1.2、ARP协议概述

ARP

- Address Resolution Protocol 地址解析协议
- 作用：将 IP地址解析为 MAC地址
- 注意：ARP报文不能穿越路由器，不能被转发到其他广播域

ARP缓存表

- 用于存储IP地址及其经过解析的MAC地址的对应关系

ARP报文格式

![02_arp](http://images.zsjshao.cn/images/rs/03-arp/02_arp.png)

网络设备通过ARP报文来发现目的MAC地址。ARP报文中包含以下字段：

```
1.Hardware Type表示硬件地址类型，一般为以太网；
2.Protocol Type表示三层协议地址类型，一般为IP；
3.Hardware Length和Protocol Length为MAC地址和IP地址的长度，单位是字节；
4.Operation Code指定了ARP报文的类型，包括ARP request和ARP reply；
5.Source Hardware Address指的是发送ARP报文的设备MAC地址；
6.Source Protocol Address指的是发送ARP报文的设备IP地址；
7.Destination Hardware Address指的是接收者MAC地址，在ARP request报文中，该字段值为0；
8.Destination Protocol Address指的是指接收者的IP地址。
```

## 2、ARP协议工作原理

### 2.1、ARP工作流程

![03_arp](http://images.zsjshao.cn/images/rs/03-arp/03_arp.png)

PC1查看ARP表，如果ARP表中没有PC3的IP地址对应的表项，则发送ARP请求包，ARP请求PC3的MAC地址；

同一个广播域中的所有主机都能收到ARP请求，但只有被PC3才会发送ARP应答，PC3回复自己的MAC地址；

PC1收到来自PC3的ARP应答数据包，将PC3的IP-MAC映射信息加载到本地ARP缓存表中。

### 2.2、ARP工作原理

先查看ARP表，如果ARP表中没有目的IP地址对应的MAC表项，则发送ARP请求包；

源主机广播发送ARP request 数据包，请求目的主机的MAC地址；

同网段内的所有主机都能收到ARP request请求包，但只有目的主机才会回复ARP reply数据包；

源主机收到ARP reply后，将目的主句的IP-MAC对应关系添加进ARP表中，完成数据的以太网封装，进行数据交互

![04_arp](http://images.zsjshao.cn/images/rs/03-arp/04_arp.png)

### 2.3、ARP缓存表

动态表项

- 通过ARP协议学习，能被更新，缺省老化时间120s

静态表项

- 手工配置，不能被更新，无老化时间的限制

```
Windows系统查看ARP表项：
C:\>arp -a
接口: 192.168.1.1 --- 0x5
  Internet 地址         物理地址                类型
  192.168.1.100        00:21:5E:C7:4D:88   静态

Linux系统查看ARP表项：
[root@localhost ~]# arp -v
Address                  HWtype      HWaddress             Flags Mask            Iface
192.168.1.100            ether       00:21:5E:C7:4D:88     C                     eth1
Entries: 1      Skipped: 0      Found: 1

RGOS查看ARP表项：
Ruijie#show arp
Protocol  Address            Age(min)  Hardware        Type   Interface       
Internet  192.168.1.100      0         1414.4b1b.546d  arpa   VLAN 1          
Internet  192.168.1.1        --        001a.a9be.c570  arpa   VLAN 1          
Total number of ARP entries: 2
```

网络设备一般都有一个ARP缓存（ARP Cache），ARP缓存用来存放IP地址和MAC地址的关联信息。在发送数据前，设备会先查找ARP缓存表。如果缓存表中存在对方设备的MAC地址，则直接采用该MAC地址来封装帧，然后将帧发送出去。如果缓存表中不存在相应信息，则通过发送ARP request报文来获得它。学习到的IP地址和MAC地址的映射关系会被放入ARP缓存表中存放一段时间。在有效期内，设备可以直接从这个表中查找目的MAC地址来进行数据封装，而无需进行ARP查询。过了这段有效期，ARP表项会被自动删除。

如果目标设备位于其他网络，则源设备会在ARP缓存表中查找网关的MAC地址，然后将数据发送给网关，网关再把数据转发给目的设备。

## 3、ARP协议分类

### 3.1、免费ARP（Gratuitous ARP ）

发送ARP请求，请求本机IP对应的MAC

免费ARP的作用作用

- 确定其它设备的 IP地址是否与本机 IP地址冲突
- 更改了地址，通知其他设备更新 ARP表项

![05_arp](http://images.zsjshao.cn/images/rs/03-arp/05_arp.png)

### 3.2、代理ARP（Proxy ARP ）

由启动了代理ARP功能的网关/下一跳设备代为应答ARP请求，该ARP请求的是其他IP对应的MAC地址.

回应ARP请求的条件

- 本地有去往目的IP的路由表

- 收到该ARP请求的接口与路由表下一跳不是同一个接口

![06_arp](http://images.zsjshao.cn/images/rs/03-arp/06_arp.png)

### 3.3、RARP

Reverse Address Resolution Protocol 反向地址解析协议

把MAC地址解析为IP地址

应用场景：常用于无盘工作站

### 3.4、IARP

Inverse Address Resolution Protocol 逆向地址解析协议

在帧中继网络中解析对端IP地址和本地DLCL的映射关系

应用场景：应用于帧中继网络