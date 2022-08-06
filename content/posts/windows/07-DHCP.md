+++
author = "zsjshao"
title = "07_DHCP"
date = "2022-08-04"
tags = ["windows"]
categories = ["windows"]

+++

## 1、DHCP介绍

### 1.1、为什么要使用DHCP

减少工作量

避免出错

方便管理

### 1.2、常见DHCP服务器

Windows平台

Linux平台

网络设备

### 1.3、DHCP: （Dynamic Host Configuration Protocol）

- 动态主机配置协议
- 局域网协议，UDP协议，使用67、68端口

主要用途：

- 用于内部网络和网络服务供应商自动分配IP地址给用户
- 用于内部网络管理员作为对所有电脑作集中管理的手段

使用场景

- 自动化安装系统
- 解决IPV4资源不足问题

## 2、DHCP工作模式

### 2.1、DHCP获得地址过程（4次广播）

| IP地址请求 | DHCP Discover |
| ---------- | ------------- |
| IP地址提供 | DHCP Offer    |
| IP地址选择 | DHCP Request  |
| IP地址确定 | DHCP ACK      |

### 2.2、DHCP报文

DHCP共有八种报文

- DHCP DISCOVER：客户端到服务器
- DHCP OFFER ：服务器到客户端
- DHCP REQUEST：客户端到服务器
- DHCP ACK ：服务器到客户端
- DHCP NAK：服务器到客户端,通知用户无法分配合适的IP地址
- DHCP DECLINE ：客户端到服务器，指示地址已被使用
- DHCP RELEASE：客户端到服务器，放弃网络地址和取消剩余的租约时间
- DHCP INFORM：客户端到服务器, 客户端如果需要从DHCP服务器端获取更为详细的配置信息，则发送Inform报文向服务器进行请求，极少用到

### 2.3、续租

- 50% ：租赁时间达到50%时来续租，刚向DHCP服务器发向新的DHCPREQUEST请求。如果dhcp服务没有拒绝的理由，则回应DHCPACK信
  息。当DHCP客户端收到该应答信息后，就重新开始新的租用周期
- 87.5%：如果之前DHCP Server没有回应续租请求，等到租约期的7/8时，主机会再发送一次广播请求
- 100%：如果租期时间到时都没有收到服务器的回应，客户端停止使用此IP地址，重新发送DHCP DISCOVER报文请求新的IP地址。

## 3、DHCP常规演示

| 服务器名称          | IP地址       | 网关       |
| ------------------- | ------------ | ---------- |
| app-01.zsjshao.cn   | 10.0.0.10/8  | 10.0.0.254 |
| app-02.zsjshao.cn   | 10.0.0.11/8  | 10.0.0.254 |
| client01.zsjshao.cn | DHCP自动获取 |            |

> 注意：以上主机都已加域，域环境配置参考AD域配置

### 3.1、安装DHCP服务

1、添加角色和功能

![dhcp01](http://images.zsjshao.cn/images/windows/dhcp01.png)

2、完成DHCP配置

![dhcp02](http://images.zsjshao.cn/images/windows/dhcp02.png)

3、授权

![dhcp03](http://images.zsjshao.cn/images/windows/dhcp03.png)

```
# 命令安装
Install-WindowsFeature -Name dhcp -IncludeManagementTools

# 域授权
netsh dhcp add securitygroups
Add-DhcpServerInDC -DnsName app-01.zsjshao.cn -IPAddress 10.0.0.10

# 非域环境执行下面命令授权
netsh dhcp add securitygroups
Restart-Service dhcpserver
```

### 3.2、作用域

1、新建作用域

![dhcp04](http://images.zsjshao.cn/images/windows/dhcp04.png)

2、设置作用域名称

![dhcp05](http://images.zsjshao.cn/images/windows/dhcp05.png)

3、设置IP地址范围和子网掩码长度

![dhcp06](http://images.zsjshao.cn/images/windows/dhcp06.png)

4、设置排除地址（不排除）和子网延迟

![dhcp07](http://images.zsjshao.cn/images/windows/dhcp07.png)

5、设置租用期限

![dhcp08](http://images.zsjshao.cn/images/windows/dhcp08.png)

6、配置DHCP选项

![dhcp09](http://images.zsjshao.cn/images/windows/dhcp09.png)

7、配置路由器（默认网关）

![dhcp10](http://images.zsjshao.cn/images/windows/dhcp10.png)

11、配置域名称和DNS服务器

![dhcp11](http://images.zsjshao.cn/images/windows/dhcp11.png)

8、配置WINS服务器

![dhcp12](http://images.zsjshao.cn/images/windows/dhcp12.png)

> 注意：WINS服务基本已废弃

9、激活作用域

![dhcp13](http://images.zsjshao.cn/images/windows/dhcp13.png)

10、客户端设置网卡为自动获得IP地址和DNS服务器地址

![dhcp14](http://images.zsjshao.cn/images/windows/dhcp14.png)

11、使用ifcofig /all命令查看地址

![dhcp15](http://images.zsjshao.cn/images/windows/dhcp15.png)

12、在服务器上查看地址租用

![dhcp16](http://images.zsjshao.cn/images/windows/dhcp16.png)

### 3.3、用户类

1、定义用户类

![dhcpclass01](http://images.zsjshao.cn/images/windows/dhcpclass01.png)

2、添加IT用户类

![dhcpclass02](http://images.zsjshao.cn/images/windows/dhcpclass02.png)

3、新建策略

![dhcpclass03](http://images.zsjshao.cn/images/windows/dhcpclass03.png)

4、为策略配置条件

![dhcpclass04](http://images.zsjshao.cn/images/windows/dhcpclass04.png)

5、为策略配置IP地址范围

![dhcpclass05](http://images.zsjshao.cn/images/windows/dhcpclass05.png)

6、为策略配置DNS服务器

![dhcpclass06](http://images.zsjshao.cn/images/windows/dhcpclass06.png)

> 注意：也可配置其他选项，如路由器等

7、完成策略配置

![dhcpclass07](http://images.zsjshao.cn/images/windows/dhcpclass07.png)

8、客户端配置用户类，重新获取IP地址

```
C:\Users\administrator>ipconfig /setclassid Ethernet0 IT

Windows IP 配置

成功地设置了适配器 Ethernet0 的 DHCPv4 类 ID。

C:\Users\administrator>ipconfig /release & ipconfig /renew

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . :
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   默认网关. . . . . . . . . . . . . :

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . : zsjshao.cn
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   IPv4 地址 . . . . . . . . . . . . : 10.0.0.131
   子网掩码  . . . . . . . . . . . . : 255.0.0.0
   默认网关. . . . . . . . . . . . . : 10.0.0.254

C:\Users\administrator>
```

### 3.4、保留地址

1、获取客户端MAC地址

![dhcpsave01](http://images.zsjshao.cn/images/windows/dhcpsave01.png)

2、新建保留

![dhcpsave02](http://images.zsjshao.cn/images/windows/dhcpsave02.png)

> 注意：保留地址可以不在DHCP地址池中

3、查看保留设置

![dhcpsave03](http://images.zsjshao.cn/images/windows/dhcpsave03.png)

> 注意：可以修改选项设置，如路由器、DNS服务器等

4、客户端重新获取IP地址

```
C:\Users\administrator>ipconfig /release & ipconfig /renew

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . :
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   默认网关. . . . . . . . . . . . . :

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . : zsjshao.cn
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   IPv4 地址 . . . . . . . . . . . . : 10.1.2.3
   子网掩码  . . . . . . . . . . . . : 255.0.0.0
   默认网关. . . . . . . . . . . . . : 10.0.0.254
```

### 3.5、超级作用域

1、新建作用域

![dhcpsupper01](http://images.zsjshao.cn/images/windows/dhcpsupper01.png)

> 创建过程参考[作用域](###3.2、作用域)章节

2、新建超级作用域

![dhcpsupper02](http://images.zsjshao.cn/images/windows/dhcpsupper02.png)

3、设置超级作用域名称

![dhcpsupper03](http://images.zsjshao.cn/images/windows/dhcpsupper03.png)

4、选择作用域

![dhcpsupper04](http://images.zsjshao.cn/images/windows/dhcpsupper04.png)

5、完成

![dhcpsupper05](http://images.zsjshao.cn/images/windows/dhcpsupper05.png)

6、客户端地址获取

```
C:\Users\administrator>ipconfig /release & ipconfig /renew

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . :
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   默认网关. . . . . . . . . . . . . :

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . : zsjshao.cn
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   IPv4 地址 . . . . . . . . . . . . : 10.1.2.3
   子网掩码  . . . . . . . . . . . . : 255.0.0.0
   默认网关. . . . . . . . . . . . . : 10.0.0.254
```

7、停用10.x/8作用域

![dhcpsupper06](http://images.zsjshao.cn/images/windows/dhcpsupper06.png)

8、客户端重新获取地址

```
C:\Users\administrator>ipconfig /release & ipconfig /renew

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . :
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   默认网关. . . . . . . . . . . . . :

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . : zsjshao.cn
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   IPv4 地址 . . . . . . . . . . . . : 20.0.0.102
   子网掩码  . . . . . . . . . . . . : 255.0.0.0
   默认网关. . . . . . . . . . . . . : 20.0.0.254
```

9、查看地址详细信息

```
C:\Users\administrator>ipconfig /all

Windows IP 配置

   主机名  . . . . . . . . . . . . . : client01
   主 DNS 后缀 . . . . . . . . . . . : zsjshao.cn
   节点类型  . . . . . . . . . . . . : 混合
   IP 路由已启用 . . . . . . . . . . : 否
   WINS 代理已启用 . . . . . . . . . : 否
   DNS 后缀搜索列表  . . . . . . . . : zsjshao.cn

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . : zsjshao.cn
   描述. . . . . . . . .. . . . . : Intel(R) 82574L Gigabit Network Connection
   物理地址. . . . . . . . . . . . . : 00-0C-29-4E-45-E7
   DHCP 已启用 . . . . . . . . . . . : 是
   自动配置已启用. . . . . . . . . . : 是
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4(首选)
   IPv4 地址 . . . . . . . . .. . . : 20.0.0.102(首选)
   子网掩码  . . . . . . . . . . . . : 255.0.0.0
   获得租约的时间  . . . . . . . . . : 2022年8月1日 12:44:22
   租约过期的时间  . . . . . . . . . : 2022年8月9日 12:44:22
   默认网关. . . . . . . . . . . . . : 20.0.0.254
   DHCPv4 类 ID . . . . . . . . . : IT
   DHCP 服务器 . . . . . . . . . . . : 10.0.0.10
   DHCPv6 IAID . . . . . . . . . . . : 117443625
   DHCPv6 客户端 DUID  . . . . . .  : 00-01-00-01-2A-75-42-C0-00-0C-29-4E-45-E7
   DNS 服务器  . . . . . . . . . . . : 10.0.0.1
   TCPIP 上的 NetBIOS  . . . . . . . : 已启用
```

> 注意：需要删除保留地址

### 3.7、案例分析

在租约期内，DHCP故障无法启动，客户端重启后地址是否能继续使用？

> 不能，重启客户端需要重新联系服务器

在没有DHCP的环境下，两台主机均设置成自动获取IP地址，问这两台主机能相互访问不？

> 能，169地址也能实现通信

多台DHCP服务器的环境下，客户端将获取哪个服务器的地址？

> 哪个快用哪个

在多作用域的情况下，客户端将获取到哪个地址池的地址？

> 服务器从哪个端口收到DHCP广播报文，就分配和此端口同一网段的IP地址

## 4、DHCP中继代理

| 服务器名称          |             IP地址             |    网关    |
| :------------------ | :----------------------------: | :--------: |
| app-01.zsjshao.cn   |          10.0.0.10/8           | 10.0.0.254 |
| router.zsjshao.cn   | 10.0.0.254/8<br />20.0.0.254/8 |            |
| client01.zsjshao.cn |          DHCP自动获取          |            |

> 注意：以上主机都已加域，域环境配置参考AD域配置

1、在app-01服务器上创建20.x/8作用域

![dhcprelay01](http://images.zsjshao.cn/images/windows/dhcprelay01.png)

2、在router上安装远程访问角色

![dhcprelay02](http://images.zsjshao.cn/images/windows/dhcprelay02.png)

3、勾选路由

![dhcprelay03](http://images.zsjshao.cn/images/windows/dhcprelay03.png)

4、打开“开始向导”

![dhcprelay04](http://images.zsjshao.cn/images/windows/dhcprelay04.png)

5、仅步骤VPN

![dhcprelay05](http://images.zsjshao.cn/images/windows/dhcprelay05.png)

6、配置并启用路由和远程访问

![dhcprelay06](http://images.zsjshao.cn/images/windows/dhcprelay06.png)

7、自定义配置

![dhcprelay07](http://images.zsjshao.cn/images/windows/dhcprelay07.png)

8、LAN路由

![dhcprelay08](http://images.zsjshao.cn/images/windows/dhcprelay08.png)

9、新增路由协议

![dhcprelay09](http://images.zsjshao.cn/images/windows/dhcprelay09.png)

10、DHCP Relay Agent

![dhcprelay10](http://images.zsjshao.cn/images/windows/dhcprelay10.png)

11、新增接口

![dhcprelay11](http://images.zsjshao.cn/images/windows/dhcprelay11.png)

12、设置跃点计数和启动阈值

![dhcprelay12](http://images.zsjshao.cn/images/windows/dhcprelay12.png)

> 跃点计数：表示能通过的路由器数量
>
> 启动阈值：优先本地DHCP服务器，阈值过后在转发给远程DHCP服务器

13、DHCP中继代理服务器设置

![dhcprelay13](http://images.zsjshao.cn/images/windows/dhcprelay13.png)

14、客户端地址获取

```c
C:\Users\administrator>ipconfig /release & ipconfig /renew

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . :
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   默认网关. . . . . . . . . . . . . :

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . : zsjshao.cn
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   IPv4 地址 . . . . . . . . . . . . : 20.0.0.101
   子网掩码  . . . . . . . . . . . . : 255.0.0.0
   默认网关. . . . . . . . . . . . . : 20.0.0.254
```

## 5、DHCP高可用

| 服务器名称          | IP地址       | 网关       |
| ------------------- | ------------ | ---------- |
| app-01.zsjshao.cn   | 10.0.0.10/8  | 10.0.0.254 |
| app-02.zsjshao.cn   | 10.0.0.11/8  | 10.0.0.254 |
| client01.zsjshao.cn | DHCP自动获取 |            |

### 5.1、拆分作用域

1、在两台服务器分别安装dhcp服务

![dhcpsplit01](http://images.zsjshao.cn/images/windows/dhcpsplit01.png)

> 安装过程参考[安装DHCP服务](###3.1、安装DHCP服务)章节

2、拆分10.x/8作用域

![dhcpsplit02](http://images.zsjshao.cn/images/windows/dhcpsplit02.png)

> 创建过程参考[作用域](###3.2、作用域)章节，拆分作用域需要删除策略

3、添加其他DHCP服务器

![dhcpsplit03](http://images.zsjshao.cn/images/windows/dhcpsplit03.png)

4、设置拆分百分比

![dhcpsplit04](http://images.zsjshao.cn/images/windows/dhcpsplit04.png)

5、设置延迟

![dhcpsplit05](http://images.zsjshao.cn/images/windows/dhcpsplit05.png)

> 注意：相同为主主模式，不同为主备模式

6、完成

![dhcpsplit06](http://images.zsjshao.cn/images/windows/dhcpsplit06.png)

7、激活作用域

![dhcpsplit07](http://images.zsjshao.cn/images/windows/dhcpsplit07.png)

8、查看

![dhcpsplit08](http://images.zsjshao.cn/images/windows/dhcpsplit08.png)

9、客户端获取IP地址

```
C:\Users\administrator>ipconfig /release & ipconfig /renew

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . :
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   默认网关. . . . . . . . . . . . . :

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . : zsjshao.cn
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   IPv4 地址 . . . . . . . . . . . . : 10.0.0.101
   子网掩码  . . . . . . . . . . . . : 255.0.0.0
   默认网关. . . . . . . . . . . . . : 10.0.0.254
```

### 5.2、dhcp故障转移

1、创建10.x/8作用域

![dhcpfailover01](http://images.zsjshao.cn/images/windows/dhcpfailover01.png)

> 创建过程参考[作用域](###3.2、作用域)章节

2、配置故障转移

![dhcpfailover02](http://images.zsjshao.cn/images/windows/dhcpfailover02.png)

3、设置伙伴服务器

![dhcpfailover03](http://images.zsjshao.cn/images/windows/dhcpfailover03.png)

4、新建故障转移关系

![dhcpfailover04](http://images.zsjshao.cn/images/windows/dhcpfailover04.png)

> 最长客户端前期：故障转移服务器能为已经连接到故障服务器设备延长DHCP租期的最长期限
>
> 模式：负载平衡（主主模式）、热备用服务器
>
> 伙伴服务器角色：待机、活动，伙伴待机则自身活动，伙伴活动则自身待机
>
> 状态切换间隔：主DHCP无法提供服务时，到达指定时间切换成待机模式

5、完成故障转移配置

![dhcpfailover05](http://images.zsjshao.cn/images/windows/dhcpfailover05.png)

6、客户端地址获取测试

```
C:\Users\administrator>ipconfig /release & ipconfig /renew

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . :
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   默认网关. . . . . . . . . . . . . :

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . : zsjshao.cn
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   IPv4 地址 . . . . . . . . . . . . : 10.0.0.101
   子网掩码  . . . . . . . . . . . . : 255.0.0.0
   默认网关. . . . . . . . . . . . . : 10.0.0.254
```

7、关闭app主服务器，客户端重新获取IP地址

```
C:\Users\administrator>ipconfig /release & ipconfig /renew

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . :
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   默认网关. . . . . . . . . . . . . :

Windows IP 配置

以太网适配器 Ethernet0:

   连接特定的 DNS 后缀 . . . . . . . : zsjshao.cn
   本地链接 IPv6 地址. . . . . . . . : fe80::586e:b16:4480:84fe%4
   IPv4 地址 . . . . . . . . . . . . : 10.0.0.149
   子网掩码  . . . . . . . . . . . . : 255.0.0.0
   默认网关. . . . . . . . . . . . . : 10.0.0.254
```

DHCP导入导出

netsh dhcp server export C:\dhcpback.txt all

netsh dhcp server import C:\dhcpback.txt all

## 6、DHCP和NAP整合功能介绍









动态主机配置协议：

https://docs.microsoft.com/zh-cn/windows-server/networking/technologies/dhcp/dhcp-top

动态主机配置协议故障排除指南 (DHCP)

https://docs.microsoft.com/zh-cn/windows-server/troubleshoot/troubleshoot-dhcp-issue
