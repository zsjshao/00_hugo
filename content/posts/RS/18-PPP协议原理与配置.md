+++
author = "zsjshao"
title = "18_PPP协议原理与配置"
date = "2020-05-23"
tags = ["NA"]
categories = ["RS"]
+++

## 1、PPP协议简介

### 1.1、PPP协议简介

广域网中的PPP协议：

- 通常使用在专线的点对点线路中，因此不需要使用MAC地址
- 工作在OSI模型的数据链路层，使用PPP协议封装数据帧
- PPP与以太网一样工作在数据链路层

![01_ppp](http://images.zsjshao.net/rs/18-ppp/01_ppp.png)

![02_ppp](http://images.zsjshao.net/rs/18-ppp/02_ppp.png)

### 1.2、PPP协议层次介绍

PPP协议层次介绍：

- PPP协议包含两个子协议：链路层控制协议LCP、网络层控制协议NCP
- PPP协议的NCP部分上跨到了OSI参考模型的三层，因此PPP还具有部分网络层的功能

![03_ppp](http://images.zsjshao.net/rs/18-ppp/03_ppp.png)

## 2、PPP协议工作原理

### 2.1、PPP协议工作原理

PPP会话建立：

- LCP链路建立协商阶段
- 认证阶段（可选）：PAP和CHAP两种认证方式
- NCP网络层协议协商阶段

![04_ppp](http://images.zsjshao.net/rs/18-ppp/04_ppp.png)

### 2.2、PPP会话建立协商过程

阶段1：LCP协商阶段

![05_ppp](http://images.zsjshao.net/rs/18-ppp/05_ppp.png)

阶段2：身份认证阶段（可选）

![06_ppp](http://images.zsjshao.net/rs/18-ppp/06_ppp.png)

阶段3：IPCP协商阶段

![07_ppp](http://images.zsjshao.net/rs/18-ppp/07_ppp.png)

## 3、PPP协议基础配置

### 3.1、PPP基础命令

双方接口封装PPP

```
Router(config-if)# encapsulation ppp
```

认证方配置对端的用户名和密码

```
Router(config)# username name password password
```

认证方配置PPP认证方式（启用PAP或者CHAP认证）

```
Router(config-if)# ppp authentication {chap | chap pap | pap chap | pap}
```

### 3.2、PPP典型配置案例（PAP单向认证）

ppp authentication pap命令指定本地为验证方，验证方需要配置被验证方的用户名密码列表。

![08_ppp](http://images.zsjshao.net/rs/18-ppp/08_ppp.png)

PAP认证，接口状态验证

```
R1#show interface serial 1/0
Index(dec):35 (hex):23
Serial 1/0 is UP  , line protocol is UP
Hardware is  Serial
Interface address is: 1.1.1.1/24
  MTU 1500 bytes, BW 2000 Kbit
  Encapsulation protocol is PPP, loopback not set
  Keepalive interval is 10 sec ,retries 10.
  Carrier delay is 2 sec
  Rxload is 1/255, Txload is 1/255
  LCP Open
  Queueing strategy: FIFO
    Output queue 0/40, 0 drops;
    Input queue 0/75, 0 drops
  5 minutes input rate 0 bits/sec, 0 packets/sec
  5 minutes output rate 0 bits/sec, 0 packets/sec
    38021 packets input, 5656110 bytes, 0 no buffer, 0 dropped
    Received 23488 broadcasts, 0 runts, 0 giants
    0 input errors, 0 CRC, 0 frame, 0 overrun, 0 abort
    38097packets output, 2135697bytes, 0 underruns , 0 dropped

R1#show interface serial 2/0
Index(dec):35 (hex):23
Serial 2/0 is UP  , line protocol is UP
Hardware is  Serial
Interface address is: 1.1.1.2/24
  MTU 1500 bytes, BW 2000 Kbit
  Encapsulation protocol is PPP, loopback not set
  Keepalive interval is 10 sec ,retries 10.
  Carrier delay is 2 sec
  Rxload is 1/255, Txload is 1/255
  LCP Open
  Queueing strategy: FIFO
    Output queue 0/40, 0 drops;
    Input queue 0/75, 0 drops
  5 minutes input rate 0 bits/sec, 0 packets/sec
  5 minutes output rate 0 bits/sec, 0 packets/sec
    38325 packets input, 5655320 bytes, 0 no buffer, 0 dropped
    Received 23358 broadcasts, 0 runts, 0 giants
    0 input errors, 0 CRC, 0 frame, 0 overrun, 0 abort
    38235packets output, 2135895bytes, 0 underruns , 0 dropped
```

### 3.3、PPP典型配置案例（PAP双向认证）

ppp authentication pap命令指定本地为验证方，验证方需要配置被验证方的用户名密码列表。

![09_ppp](http://images.zsjshao.net/rs/18-ppp/09_ppp.png)

### 3.4、PPP典型配置案例（CHAP单向认证）

ppp authentication chap命令指定本地为验证方，验证方需要配置被验证方的用户名密码列表。

![10_ppp](http://images.zsjshao.net/rs/18-ppp/10_ppp.png)

接口状态信息验证

```
R1#show interface serial 1/0
Index(dec):35 (hex):23
Serial 1/0 is UP  , line protocol is UP
Hardware is  Serial
Interface address is: 1.1.1.1/24
  MTU 1500 bytes, BW 2000 Kbit
  Encapsulation protocol is PPP, loopback not set
  Keepalive interval is 10 sec ,retries 10.
  Carrier delay is 2 sec
  Rxload is 1/255, Txload is 1/255
  LCP Open
  Queueing strategy: FIFO
    Output queue 0/40, 0 drops;
    Input queue 0/75, 0 drops
  5 minutes input rate 0 bits/sec, 0 packets/sec
  5 minutes output rate 0 bits/sec, 0 packets/sec
    38021 packets input, 5656110 bytes, 0 no buffer, 0 dropped
    Received 23488 broadcasts, 0 runts, 0 giants
    0 input errors, 0 CRC, 0 frame, 0 overrun, 0 abort
    38097packets output, 2135697bytes, 0 underruns , 0 dropped

R1#show interface serial 2/0
Index(dec):35 (hex):23
Serial 2/0 is UP  , line protocol is UP
Hardware is  Serial
Interface address is: 1.1.1.2/24
  MTU 1500 bytes, BW 2000 Kbit
  Encapsulation protocol is PPP, loopback not set
  Keepalive interval is 10 sec ,retries 10.
  Carrier delay is 2 sec
  Rxload is 1/255, Txload is 1/255
  LCP Open
  Queueing strategy: FIFO
    Output queue 0/40, 0 drops;
    Input queue 0/75, 0 drops
  5 minutes input rate 0 bits/sec, 0 packets/sec
  5 minutes output rate 0 bits/sec, 0 packets/sec
    38325 packets input, 5655320 bytes, 0 no buffer, 0 dropped
    Received 23358 broadcasts, 0 runts, 0 giants
    0 input errors, 0 CRC, 0 frame, 0 overrun, 0 abort
    38235packets output, 2135895bytes, 0 underruns , 0 dropped
```

### 3.5、PPP典型配置案例（CHAP双向认证）

ppp authentication chap命令指定本地为验证方，验证方需要配置被验证方的用户名密码列表。

![11_ppp](http://images.zsjshao.net/rs/18-ppp/11_ppp.png)

接口状态信息验证

```
R1#show interface serial 1/0
Index(dec):35 (hex):23
Serial 1/0 is UP  , line protocol is UP
Hardware is  Serial
Interface address is: 1.1.1.1/24
  MTU 1500 bytes, BW 2000 Kbit
  Encapsulation protocol is PPP, loopback not set
  Keepalive interval is 10 sec ,retries 10.
  Carrier delay is 2 sec
  Rxload is 1/255, Txload is 1/255
  LCP Open
  Queueing strategy: FIFO
    Output queue 0/40, 0 drops;
    Input queue 0/75, 0 drops
  5 minutes input rate 0 bits/sec, 0 packets/sec
  5 minutes output rate 0 bits/sec, 0 packets/sec
    38021 packets input, 5656110 bytes, 0 no buffer, 0 dropped
    Received 23488 broadcasts, 0 runts, 0 giants
    0 input errors, 0 CRC, 0 frame, 0 overrun, 0 abort
    38097packets output, 2135697bytes, 0 underruns , 0 dropped

R1#show interface serial 2/0
Index(dec):35 (hex):23
Serial 2/0 is UP  , line protocol is UP
Hardware is  Serial
Interface address is: 1.1.1.2/24
  MTU 1500 bytes, BW 2000 Kbit
  Encapsulation protocol is PPP, loopback not set
  Keepalive interval is 10 sec ,retries 10.
  Carrier delay is 2 sec
  Rxload is 1/255, Txload is 1/255
  LCP Open
  Queueing strategy: FIFO
    Output queue 0/40, 0 drops;
    Input queue 0/75, 0 drops
  5 minutes input rate 0 bits/sec, 0 packets/sec
  5 minutes output rate 0 bits/sec, 0 packets/sec
    38325 packets input, 5655320 bytes, 0 no buffer, 0 dropped
    Received 23358 broadcasts, 0 runts, 0 giants
    0 input errors, 0 CRC, 0 frame, 0 overrun, 0 abort
    38235packets output, 2135895bytes, 0 underruns , 0 dropped
```

