+++
author = "zsjshao"
title = "10_VPN"
date = "2022-08-04"
tags = ["windows"]
categories = ["windows"]

+++

## VPN是什么

虚拟专用网络 (VPN) 是专用网络的扩展，包含跨共享或公共网络（如 Internet）的链接。通过使用 VPN 连接，您可以通过共享或公共网络以模拟点对点专用链接的方式在两台计算机之间安全地发送数据。

远程访问客户端建立连接到专用网络的远程访问 VPN 连接。VPN 服务器充当路由器，提供对 VPN 服务器所连接的整个网络的访问。

远程访问 VPN 客户端向 VPN 服务器验证自己，为了相互验证，服务器也向客户端验证自己。

## VPN vs 端口映射

服务器远程访问

- vpn
- 端口映射

### vpn

技术特点：

- 用户访问内网是使用非固定端口
- 用户远程访问的时候对安全要求比较高

应用场景：

- 用户在Internet上访问公司文件服务器
- 用户在Internet上登录域

加密情况：

- 所有VPN协议都是安全加密的

### 端口映射

技术特点：

- 用户访问服务器使用的固定的端口

应用场景：

- 用户在Internet上访问公司的Web Server，Mail Server，RDP Server等

加密情况：

- 端口映射本身不负责加密，只负责转发，是否加密取决于协议本身

## VPN两种应用场景

Client-to-Site VPN

- 主要面向个人用户实现在下班回家、出差在外需要访问公司内部服务器需求，需要用户手工拨号。

Site-to-Site VPN

- 主要面向总部和分支机构的环境，Site-to-Site VPN是由总部和分支机构的VPN设备建立的。建立成功后，所有的用户访问对方的局域网使用已建立的VPN隧道，本身不需要任何的VPN拨号。

## VPN三种协议

### PPTP (Point-to-Point Tunneling Protocol)

比较基础和简单的VPN协议，支持TCP/IP网络

使用1723端口

加密是使用ppp内置MPPE加密协议（128位加密）

适用于Client-to-Site和Site-to-Site的类型

### L2TP（Layer Two Tunneling Protocal）

是PPTP升级的一个协议，除了支持TCP/IP网络，还支持Frame-Relay，X.25等网络

使用1701端口

使用IPSEC协议进行加密和身份验证，更加安全。

适用于Site-to-Site的类型

### SSTP（Secure Socket Tunneling Protocal）

是Windows Server 2008/2008R2中新支持的功能

使用443端口

加密使用SSL协议

适用于Client-to-Site的类型

## 实验演示：VPN综合案例





