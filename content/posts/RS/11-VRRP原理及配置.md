+++
author = "zsjshao"
title = "11_VRRP原理及配置"
date = "2020-05-23"
tags = ["NA"]
categories = ["RS"]

+++

## 1、VRRP概述

### 1.1、技术背景

通常同一网段内的所有主机都会配置相同的网关，以访问外部网络

- 网关，实际是主机上配置一条以为路由器（或者三层交换机）的接口为下一跳的默认路由

当唯一的网关设备发生故障时，所有主机都无法与外部网络通信

![01_vrrp](http://images.zsjshao.net/rs/11-vrrp/01_vrrp.png)

### 1.2、解决方案

可以增加网关设备，配置VRRP协议，为默认网关提供设备备份，提高网关的可靠性

VRRP（虚拟路由冗余协议 Virtual Router Redundancy Protocol）解决局域网网关的冗余备份问题

VRRP将一组路由器（或三层交换机）组成一个备份组，生成一台虚拟路由器，使用一个虚拟IP地址为主机提供默认网关服务

![02_vrrp](http://images.zsjshao.net/rs/11-vrrp/02_vrrp.png)

## 2、VRRP工作原理

### 2.1、VRRP相关概念

**VRRP备份组：**

- 一组运行VRRP协议的路由器划分在一起，称为一个备份组，功能上相当于一台虚拟路由器
- **备份组是基于接口，备份组中的接口必须属于同一个广播域**

**虚拟路由器号（VRID）：**

- 范围1-255，由用户配置，以区分不同备份组
- 有**相同VRID**的一组VRRP路由器组成构成一个VRRP备份组

**虚拟IP地址、MAC地址：**

- 用于标示虚拟的路由器的IP和MAC地址，该**虚拟IP地址**实际上就是用户的默认网关
- 虚拟路由器回应ARP请求时，回应的是**虚拟MAC**地址，而非接口真实的MAC地址

**MASTER路由器、BACKUP路由器：**

- MASTER路由器就是在VRRP组**实际转发数据包**的路由器
- BACKUP路由器就是在VRRP组中**处于监听状态**的路由器
- 一旦MASTER路由器出现故障， BACKUP路由器就开始接替工作

### 2.2、VRRP报文

VRRP报文是组播报文，由MASTER路由器定时发送，通告它的存在

使用VRRP报文可以检测虚拟路由器各种参数，用于MASTER路由器的选举

VRRP报文承载在IP报文之上，使用协议号112    

VRRP报文使用的IP组播地址是224.0.0.18

![03_vrrp](http://images.zsjshao.net/rs/11-vrrp/03_vrrp.png)

### 2.3、VRRP的三种状态

初始状态(Initialize)：路由器刚刚启动时进入此状态，通过VRRP报文交换数据后进入其他状态

活动状态(Master)：VRRP组中的路由器通过VRRP报文交换后确定的**当前转发**数据包的一种状态

备份状态(Backup)：VRRP组中的路由器通过VRRP报文交换后确定的**处于监听**的一种状态

![04_vrrp](http://images.zsjshao.net/rs/11-vrrp/04_vrrp.png)

### 2.4、VRRP工作原理

**优先级：**

- 备份组中**优先级最高**的路由器将成为Master路由器（优先级取值范围0-255）
- 优先级相同时，比较接口的主IP地址，地址越大，优先级越高
- 优先级**默认值100**，可配范围1-254

**抢占模式：**

- 如果抢占模式关闭，高优先级的备份路由器不会主动成为活动路由器，即使活动路由器优先级较低，只有当活动路由器失效时，备份路由器才会成为主路由器。
- 抢占模式主要应用于保证高优先级的路由器只要一接入网络就会成为活动路由器
- **默认情况下，抢占模式都是开启的**

**工作过程：**

![05_vrrp](http://images.zsjshao.net/rs/11-vrrp/05_vrrp.png)

### 2.5、VRRP接口跟踪

监视指定接口，并根据所监视接口的状态动态地调整本路由器的优先级

当上行链路不可用时，路由器VRRP优先级将降低，该路由器不再是Master，备份路由器将成为新的Master

![06_vrrp](http://images.zsjshao.net/rs/11-vrrp/06_vrrp.png)

## 3、VRRP相关配置

### 3.1、配置VRRP —— VRRP组与虚拟IP

创建VRRP组并配置虚拟IP地址

- 接口模式下：vrrp [group-number] ip [ipaddress]
- 注意：如果配置的VRRP组地址与接口的实际地址相等，那么该路由器将具有最高优先级，成为Master

示例：在汇聚交换机上部署VRRP，使得VLAN 10的主网关是SWA，备份网关是SWB

![07_vrrp](http://images.zsjshao.net/rs/11-vrrp/07_vrrp.png)

```
在SWA上配置VRRP组
  SWA(config)#interface vlan 10
  SWA(config-if-vlan10)#ip address 10.1.1.2 255.255.255.0
  SWA(config-if-vlan10)#vrrp 10 ip 10.1.1.1

在SWB上配置VRRP组
  SWB(config)#interface vlan 10
  SWB(config-if-vlan10)#ip address 10.1.1.3 255.255.255.0
  SWB(config-if-vlan10)#vrrp 10 ip 10.1.1.1
```

### 3.2、配置VRRP —— VRRP组优先级

设置VRRP Group优先级

- 进入接口模式：vrrp *[group-number]* priority [level]
- 优先级的取值范围为1-254，默认优先级为100

示例：在汇聚交换机上部署VRRP，设置优先级，使得VLAN 10的主网关是SWA，备份网关是SWB

```
在SWA上配置VRRP组
  SWA(config)#interface vlan 10
  SWA(config-if-vlan10)#ip address 10.1.1.2 255.255.255.0
  SWA(config-if-vlan10)#vrrp 10 ip 10.1.1.1

在SWA上配置接口优先级,控制Master的选举
  SWA(config-if-vlan10)# vrrp 10 priority 105

在SWB上配置VRRP组
  SWB(config)#interface vlan 10
  SWB(config-if-vlan10)#ip address 10.1.1.3 255.255.255.0
  SWB(config-if-vlan10)#vrrp 10 ip 10.1.1.1
```

### 3.3、配置VRRP —— 监视接口

设置VRRP备份组监视的接口

- 接口模式：vrrp group track *interface-type number [interface –priority]*
- 可以使用本命令监视出口链路，被监视的接口只允许是三层可路由的逻辑接口(如Routed Port ，SVI ，oopback，Tunnel 等)
- 示例：

```
在SWA上配置VRRP组
  SWA(config)#interface vlan 10
  SWA(config-if-vlan10)#ip address 10.1.1.2 255.255.255.0
  SWA(config-if-vlan10)#vrrp 10 ip 10.1.1.1

在SWA上配置接口优先级,控制Master的选举
  SWA(config-if-vlan10)# vrrp 10 priority 105

在SWA上配置监视接口，当检测到接口down，则降低优先级10
  SWA(config-if-vlan10)# vrrp 10 track fastethernet 1/0 10

在SWB上配置VRRP组
  SWB(config)#interface vlan 10
  SWB(config-if-vlan10)#ip address 10.1.1.3 255.255.255.0
  SWB(config-if-vlan10)#vrrp 10 ip 10.1.1.1
```

### 3.3、VRRP查看命令

使用命令查看VRRP组状态

- show vrrp brief 

![08_vrrp](http://images.zsjshao.net/rs/11-vrrp/08_vrrp.png)

### 3.4、VRRP负载均衡

需要在网络中进行链路的负载均衡时，VRRP可以根据链路情况进行配置

如下图所示：

![09_vrrp](http://images.zsjshao.net/rs/11-vrrp/09_vrrp.png)

