+++
author = "zsjshao"
title = "04_DHCP协议原理与应用"
date = "2020-05-23"
tags = ["NA"]
categories = ["RS"]

+++

## 1、DHCP协议概述

### 1.1、场景描述1

![01_dhcp](http://images.zsjshao.net/rs/04-dhcp/01_dhcp.png)

### 1.2、场景描述2

![02_dhcp](http://images.zsjshao.net/rs/04-dhcp/02_dhcp.png)

### 1.3、场景描述3

![03_dhcp](http://images.zsjshao.net/rs/04-dhcp/03_dhcp.png)

## 2、DHCP协议工作原理

### 2.1、DHCP简介

DHCP（Dynamic Host Configuration Protocol），动态主机配置协议

定义在RFC2131中， C/S架构，为终端设备提供TCP/IP参数（IP地址、掩码、网关、DNS等）的自动配置。

DHCP报文格式和BootP（RFC951、RFC1542）报文兼容，保证了互操作

![04_dhcp](http://images.zsjshao.net/rs/04-dhcp/04_dhcp.png)

### 2.2、DHCP协议名词解释

DHCP Client

- DHCP客户机，即用户终端设备，可以是手机、电脑、打印机等需要接入网络的终端设备

DHCP Server

- DHCP服务器，为终端分配网络参数，管理地址池

![05_dhcp](http://images.zsjshao.net/rs/04-dhcp/05_dhcp.png)

### 2.3、DHCP服务器配置

```
Step 1：开启DHCP服务
service dhcp

Step 2：配置DHCP服务器
ip dhcp pool Ruijie
 network 172.16.10.0 255.255.255.0
 dns-server 8.8.8.8 
 default-router 172.16.10.254

```

### 2.4、PC的DHCP设置

![06_dhcp](http://images.zsjshao.net/rs/04-dhcp/06_dhcp.png)

释放通过DHCP方式获取到的IP地址

```
C:\Users>ipconfig /release

Windows IP 配置
```

重新通过DHCP方式获取IP地址

```
C:\Users>ipconfig /renew
以太网适配器 以太网:

   连接特定的 DNS 后缀 . . . . . . . :
   本地链接 IPv6 地址. . . . . . . . : fe80::b8e1:1be9:a15b:485%14
   IPv4 地址 . . . . . . . . . . . . : 172.18.158.133
   子网掩码  . . . . . . . . . . . . : 255.255.255.0
   默认网关. . . . . . . . . . . . . : 172.18.158.1
```

### 2.5、DHCP协议工作过程

![07_dhcp](http://images.zsjshao.net/rs/04-dhcp/07_dhcp.png)

### 2.6、DHCP协议报文及用途

| **报文类型**   | **用途**                                       |
| -------------- | ---------------------------------------------- |
| DHCP  discover | 客户端广播查找可用服务器                       |
| DHCP  offer    | 服务器响应DHCP  discover报文，分配相应配置参数 |
| DHCP  request  | 客户端请求配置参数、请求配置确认、续租约       |
| DHCP  ack      | 服务器确认DHCP  request报文                    |
| DHCP  decline  | 客户端发现地址被使用时，通知服务器             |
| DHCP release   | 客户端释放地址时通知服务器的报文               |
| DHCP  inform   | 客户端已有IP地址，请求更详细配置参数           |
| DHCP  nak      | 服务器告诉客户端地址请求不正确或租期已过期     |

### 2.7、DHCP报文介绍 

#### 2.7.1、DHCP Discover

该报文为PC发出的第一个请求报文，为`广播报文`，主要作用是用来发现DHCP服务器，但PC并不知道DHCP的IP地址，因此目的MAC和目的IP地址都为广播

![08_dhcp](http://images.zsjshao.net/rs/04-dhcp/08_dhcp.png)

#### 2.7.2、DHCP Offer

该报文为DHCP服务器返回的第一个报文，当网络中存在多台DHCP服务器时，PC只会保留先收到的DHCP Offer。DHCP Offer中包含DHCP服务器可以为PC分配的IP地址、网关IP、DNS参数等配置信息

![09_dhcp](http://images.zsjshao.net/rs/04-dhcp/09_dhcp.png)

#### 2.7.3、DHCP Request

PC发出的第二条请求报文，PC根据服务器返回的Offer中的信息，发起正式申请。

![10_dhcp](http://images.zsjshao.net/rs/04-dhcp/10_dhcp.png)

#### 2.7.4、DHCP ACK

服务器收到PC的请求报文后，从地址池中分配相应的IP地址返回给PC

![11_dhcp](http://images.zsjshao.net/rs/04-dhcp/11_dhcp.png)

### 2.8、DHCP协议的租约

租约50%时刻

- 客户端主动向服务器发送DHCP request报文，请求更新租约时间；
  - 若服务器可用，回复DHCP ack，更新租约；
  - 若服务器不可用，回复DHCP nak，不更新租约；



租约87.5%时刻

- 客户端主动向服务器发送DHCP request报文，请求更新租约时间；
  - 若服务器可用，回复DHCP ack，更新租约；
  - 若服务器不可用，回复DHCP nak，不更新租约；



待到租约时间过去，客户端会重新发送DHCP discover报文。

## 3、DHCP中继

### 3.1、校园网中常见的DHCP服务部署方式

![12_dhcp](http://images.zsjshao.net/rs/04-dhcp/12_dhcp.png)

方式一：网关交换机作为DHCP服务器

- 优势：节省一台服务器资源
- 劣势：地址池配置分散在网络中多台汇聚网关交换机上，无法集中管理

方式二：网关交换机作为DHCP中继，在服务器区部署一台专用的DHCP服务器

- 优势：集中管理，不需要每一个网段都配置一个DHCP服务器，节约资源
- 劣势：需要占用一台服务器资源

### 3.2、方式一：网关交换机作为DHCP服务器

每台汇聚网关交换机上都为其下联用户PC网段配置DHCP地址池

![13_dhcp](http://images.zsjshao.net/rs/04-dhcp/13_dhcp.png)

```
Step 1. 开启DHCP服务
service dhcp

Step 2. VLAN 内用户的DHCP地址池信息
ip dhcp pool VLAN10_POOL
   network 172.16.10.0 255.255.255.0
   default-router 172.16.10.1 
   dns-server 202.106.0.20 211.0.23.32 

Step 3. 配置VLAN 内用户的网关
interface vlan 20 
ip address 172.16.20.1 255.255.255.0
```

### 3.3、方式二：部署专用DHCP服务器

网关交换机作为DHCP中继，在服务器区部署一台专用的DHCP服务器

要保证作为DHCP中继的网关设备与DHCP服务器之间IP/路由可达

![14_dhcp](http://images.zsjshao.net/rs/04-dhcp/14_dhcp.png)

```
Step1：网关设备的DHCP中继配置：
service dhcp
int vlan 10  //需要配置中继的VLAN
  ip helper-address 192.168.1.1 //服务器地址

Step2：服务器配置DHCP服务
Windows Server/Linux/专用设备
```

## 4、DHCP相关安全设计

### 4.1、DHCP应用服务在校园网运营过程中可能存在的问题

用户使用静态IP地址接入

- 部分用户手动配置IP地址，但DHCP服务器是不知道的，因此在为DHCP用户分配IP地址的时候，用户通过DHCP获取到的IP地址，在网络中是已经使用的，导致了IP地址冲突。

用户架设非法DHCP服务器

- 在同一VLAN中，如果存在恶意用户私自架设了一台DHCP服务器，那么将会使该VLAN内的用户获取到错误的IP地址，导致无法接入进校园网

### 4.2、使用IP source guard解决用户手动配置IP地址问题

使用DHCP Snooping相关功能，可以实现防止下联用户使用静态IP地址接入网络（ip source guard功能）

![15_dhcp](http://images.zsjshao.net/rs/04-dhcp/15_dhcp.png)

```
接入交换机上配置：
ip dhcp snooping
interface f0/1
ip verify source port-security 
interface f0/2
ip verify source port-security

备注：接入交换机会窥探DHCP报文交互的过程，并从DHCP ACK报文中提取相关IP和MAC信息，将其绑定在硬件表项中，这样只有经过DHCP方式获取IP地址的主机，其IP和MAC才会被交换机所允许转发，而非DHCP方式设置IP地址，这样的报文会被交换机丢弃
```

### 4.3、使用DHCP Snooping实现防非法DHCP服务器问题

在接入交换机上使用DHCP Snooping相关功能，可以实现防止下联用户架设非法DHCP服务器

以下为DHCP Snooping配置步骤：

![16_dhcp](http://images.zsjshao.net/rs/04-dhcp/16_dhcp.png)

```
Step1：接入交换机上开启DHCP Snooping
ip  dhcp snooping

Step2：指向合法DHCP服务器的接口设置为信任接口
interface  f0/24
  ip dhcp snooping trust

备注：其他接口默认都为非信任接口
```

## 5、知识点回顾

DHCP报文的目的IP和目的MAC是多少？

DHCP报文是基于UDP还是基于TCP？

DHCP服务器返回的报文中都包含什么信息？

DHCP应用中常见的两种安全问题是什么？

在校园网中网段非常多，为每一个网段配置一台单独的DHCP服务器是不现实的，如何解决这个问题？













