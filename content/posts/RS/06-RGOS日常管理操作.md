+++
author = "zsjshao"
title = "06_RGOS日常管理操作"
date = "2020-05-23"
tags = ["NA"]
categories = ["RS"]

+++

## 1、RGOS平台登陆方式

### 1.1、RGOS平台概述

RGOS全称“锐捷通用操作系统”，即网络设备的操作系统

- 基于RGOS开发的软件版本目前为11.x，又被称为11.x平台

优势

- 模块化设计，方便运维管理
- 故障隔离，提升新功能开发测试效率和系统稳定性
- 对于硬件平台透明，兼容性高

![01_rgos](http://images.zsjshao.cn/images/rs/06-rgos/01_rgos.png)

### 1.2、锐捷设备的常用登陆方式

#### 1.2.1、本地登陆：

- **Console**登陆：全新或配置清空的设备，需要使用Console口的方式

#### 1.2.2、远程登陆

- **Telnet登陆**：使用IP网络远程登陆，但传输的数据未加密
- **SSH登陆**：使用IP网络远程登陆，传输数据加密，安全性高，常用SSHv2版本
- **Web登陆**：使用网页登录，操作可视化较便捷

备注：大部分设备开局需要使用Console登陆，部分设备可直接Telnet/Web登陆

#### 1.2.3、常用登陆软件

- SecureCRT、xshell、Putty、超级终端（仅XP有）

![02_rgos](http://images.zsjshao.cn/images/rs/06-rgos/02_rgos.png)

#### 1.2.4、使用Console登入

Console概述

- 通过配置线连接设备的Console接口
- 使用终端软件进行设备管理配置
- 初始化，带外管理

Console管理配置

- 波特率：9600
- 数据位：8
- 奇偶校验：无
- 停止位：1
- 数据流控：无

![03_rgos](http://images.zsjshao.cn/images/rs/06-rgos/03_rgos.png)

![04_rgos](http://images.zsjshao.cn/images/rs/06-rgos/04_rgos.png)

#### 1.2.5、Telnet远程管理

Telnet概述

- 指通过Windows命令行提示符中的Telnet程序或其他第三方Telnet程序进行设备管理配置
- 远程管理，带内管理
- 依赖于设备IP地址与Telnet密码
- 数据不进行加密

Telnet配置

- 协议：Telnet
- 默认端口：23
- 设备默认开启Telnet服务

```
C:\Users\zengs>telnet 10.1.1.254 23
使用CMD直接telnet（需要开启telnet功能）
```

![05_rgos](http://images.zsjshao.cn/images/rs/06-rgos/05_rgos.png)

#### 1.2.6、SSH远程管理

SSH概述

- 使用支持SSH协议程序（SecureCRT）进行设备管理配置
- 远程管理，带内管理
- 依赖于管理IP地址
- 依赖于全局用户名密码
- 数据加密

SSH管理配置

- 协议：SSH
- 默认端口：22  

网络设备上开启SSH服务配置:

```
Ruijie(config)#enable service ssh-server
Ruijie(config)#crypto key generate {rsa|dsa}
```

![06_rgos](http://images.zsjshao.cn/images/rs/06-rgos/06_rgos.png)

#### 1.2.7、登陆软件：xshell

##### 1.2.7.1、日志管理

- 根据锐捷网络技术服务部《JSZD-001技术服务部员工行为奖惩条例》工程师在网操作规范第3条：携带工程师个人电脑进入客户网络时，需要提前做好电脑的杀毒等工作，以避免由于电脑病毒影响客户网络正常使用，**且开启记录功能（包括Telnet的控制台开启Log日志打印功能）**

![07_rgos](http://images.zsjshao.cn/images/rs/06-rgos/07_rgos.png)

##### 1.2.7.2、撰写栏

- 当日志快速滚动刷屏无法键入时可以使用撰写栏
- 在撰写栏键入命令，可以在多个会话窗口执行

![08_rgos](http://images.zsjshao.cn/images/rs/06-rgos/08_rgos.png)

## 2、CLI命令行操作

### 2.1、CLI命令行基础

使用Console、Telnet、SSH登陆设备后，将会出现CLI命令行界面，类似DOS的命令行

相对CMD的命令行，RGOS的CLI使用便捷，具备丰富提示信息与错误信息

![09_rgos](http://images.zsjshao.cn/images/rs/06-rgos/09_rgos.png)

### 2.2、CLI模式

用户模式

- 字符光标前是一个“>”符号
- 有限查看设备信息

特权模式

- 字符光标前是一个“#”符号
- 查看设备所有信息

全局配置模式

- 字符光标前由“(config)#”组成
- 配置设备全局参数

接口配置模式

- 字符光标前由“(config-if-xx)#”组成
- 配置设备接口参数

### 2.3、CLI模式互换

![10_rgos](http://images.zsjshao.cn/images/rs/06-rgos/10_rgos.png)

### 2.4、命令行特性-分屏显示

在命令行界面，显示的内容如果超过一页的范围，则会进行分屏显示

在命令行出现“--more--”的提示

- 使用“回车”键可以逐行显示
- 使用“空格”键可以翻页

![11_rgos](http://images.zsjshao.cn/images/rs/06-rgos/11_rgos.png)

### 2.5、命令行特性-命令缩写及获取帮助

- RGOS的命令行支持命令缩写，在能够唯一识别该命令的情况下，可以使用该命令的缩写
- 但是在命令不唯一的情况下，需要写到能够唯一识别

```
RCMS-4#configure terminal 
Enter configuration commands, one per line.  End with CNTL/Z.
RCMS-4(config)#exit

RCMS-4#conf t
Enter configuration commands, one per line.  End with CNTL/Z.
RCMS-4(config)#
```

- 对命令有遗忘或者疑问，可以随时输入“？”进行提示

```
RCMS-4#conf?
configure

RCMS-4#conf
Enter configuration commands, one per line.  End with CNTL/Z.
RCMS-4(config)#in?
interface
```

### 2.6、命令行特性-错误提示

当命令输入错误时，系统将进行提示

- “% Unrecognized host or address, or protocol not running”代表命令无法识别，没有这个协议
- “% Incomplete command.”代表输入命令不完整
- “% Invalid input detected at ‘^’ marker.”代表所示位置命令有错
- 还有许多其他提示，建议在配置命令行的时候多关注控制台的消息以及错误提示

```
RCMS-4(config)#show aaq
                     ^
% Invalid input detected at '^' marker.
```

### 2.7、命令行特性-历史记录及TAB补全

- 在命令行配置过程中，使用“TAB”键可以对目前的命令进行补全操作
- 熟练应用“TAB”键以及“？”提示帮助，可以有效记忆命令

```
RCMS-4(config)#int fa
RCMS-4(config)#int fastEthernet 
```

## 3、设备基本操作

### 3.1、设备命名

设备命名用于标识设备信息

配置规范

- 一般参照客户规范
- 如果自定义：参考设备的地理位置、网络位置、设备型号、设备编号等因素，制定统一的命名规范 （ AA-BB-CC-DD ）
  - AA：表示该设备的地理位置
  - BB：表示设备的网络位置
  - CC：表示设备的型号
  - DD： 表示设备的编号

```
配置命令
Ruijie(config)# hostname wlzx-core-8610-1
```

### 3.2、配置网络设备的管理IP

- 配置管理IP后，能方便对设备进行远程管理
- 二层交换机通过配置管理VLAN实现，并且交换机可以理解为一台终端，需要配置网关
- 多层设备的任意一个三层接口IP可以作为管理IP

```
管理IP配置命令
Ruijie(config)#vlan 10
Ruijie(config)#int vlan 10
Ruijie(config-if-VLAN 10)#ip add 10.1.1.254 255.255.255.0  //管理IP地址
Ruijie(config-if-VLAN 10)#no shutdown
Ruijie(config)#ip default-gateway 10.1.1.200 //当前设备的网关，将被管理设备理解为一台PC终端
```

### 3.3、配置网络设备的登陆密码

通过配置密码可以设备管理的安全性

- 配置特权模式密码

```
Ruijie(config)#enable secret level 15 0 ruijie
```

- 配置Telnet密码

```
Ruijie(config)#line vty 0 4
Ruijie(config-line)#password ruijie
```

- 配置全局用户密码

```
Ruijie(config)#username admin password ruijie
```

- 密文显示密码

```
Ruijie(config)#service password-encryption
```

### 3.4、常用show命令

| **命令**                 | **解释**          |
| ------------------------ | ----------------- |
| Show  running-config     | 查看设备当前配置  |
| Show  version            | 查看设备版本信息  |
| Show  cpu                | 查看设备CPU利用率 |
| Show  interface counters | 查看设备接口统计  |
| Show  log                | 查看设备日志      |
| Show  arp                | 查看设备ARP表     |
| Show  mac-address-table  | 查看设备mac表     |
| Show  clock              | 查看当前时间      |

#### 3.4.1、设备状态查看

- Show命令是操作RGOS时，最常用的命令之一
- 任意命令行模式均可以使用show命令查看当前设备的配置或状态
- 注意：show run命令查看的是当前设备的配置，不是保存的配置
  - 配置查看：show run-config

```
RCMS-4#show run

Building configuration...
Current configuration : 549 bytes

!
version 8.52 (building 6)
hostname RCMS-4
enable secret 5 $1$Lhrk$30wEry3yurx6qw46
```

- 管道符应用概述
  - 在Show命令后面可以加上管道符“|”指定信息的输出

- 管道符类型
  - | begin xyz ：输出信息从xyz开始
  - | exclude xyz：输出信息排除xyz
  - | include xyz：输出信息包含xyz

```
NTC-4#show run | begin ip
 no ip proxy-arp
 ip address 192.168.158.72 255.255.255.0
!
interface GigabitEthernet 1/0/51
!
interface GigabitEthernet 1/0/52
!
switch virtual domain 100
```

### 3.5、接口描述

- 接口描述用于标识设备接口信息，方便在查看接口状态时识别接口的用途
- 配置规范
  - 根据客户的规范
  - 自定义：to-对端设备名-对端接口名

```
配置命令
WLZX-core-8610-2(config)#int giga 6/1
WLZX-core-8610-2(config)#description to-wlzx-core-8610-1-giga6/1
```

### 3.6、Banner配置

- 登陆设备时，输出提示或警告信息，禁止使用欢迎语
- 配置规范
  - 客户规范
  - 自定义

```
配置命令
Ruijie(config)#banner login ^
Enter TEXT message.  End with the character '^'.
Warning: Unauthorized access are forbidden!!
Your behavior will be recorded!!
^
```

### 3.7、时间配置

- NTP协议的作用是让网络设备显示准确的时间，便于监控和维护
- 手工设置通过clock set设置时间

```
Ruijie#clock set hh:mm:ss day month year
```

- 自动设置/同步时间(依赖于NTP/SNTP服务器)

```
Ruijie（config）# {sntp|ntp} enable
Ruijie（config）# {sntp|ntp} server ip_addr
```

### 3.8、SNMP配置

Simple Notwork Management，网管软件通过该协议获取设备运行信息、配置设备、故障定位

- SNMP有版本v1/v2c/v3，默认使用v2c
- v1/v2c 使用团体名进行认证
- V3版本的安全性更高

```
SNMP配置：
Ruijie(config)#snmp-server community ruijie {ro|rw}
//ro表示只读属性，网管软件通过该团体名只能获取相关信息
//rw表示可读写属性，网管软件通过该团体名可以执行设备配置操作
snmp-server host 172.16.0.254 traps version 2c ruijie
snmp-server enable traps
```

### 3.9、日志应用

- 日志记录了设备运行过程中的一些关键信息，在出现故障时显得尤为重要
- 日志功能默认开启，并将信息记录在内存中，重启后日志将丢失
- 项目中，建议搭建syslog服务器，记录关键设备（汇聚/核心）日志信息

```
日志服务配置：
Ruijie(config)#service sequence-numbers     //在日志中添加序列号 
Ruijie(config)#service sysname              //在日志中添加主机名
Ruijie(config)#logging userinfo command-log	//记录用户在配置模式下所使用的命令
Ruijie(config)#logging server ip_addr       //配置log服务器的地址
Ruijie(config)#logging source interface loopback 0	//在三层设备上往往有多个地址可以作为发送设备的源地址，配置日志发送的源端口，可以有效的控制发送的源地址
Ruijie#terminal monitor     //在telnet管理时，无法看到系统自动输出的日志信息，可以使用该命令打开这个功能。通常在远程debug时使用
```

### 3.10、网络通讯测试

ping用于测试网络的连通性，可使用组合命令进行丰富的网络测试

```
 Ruijie#ping 192.168.100.10 source 10.1.1.1 ntime 100 length 1500 timeout 3
//测试从源10.1.1.1到达192.168.100.10的连通性，连续ping100次，每个包长度1500字节，超时时间3秒
```

Tracertoute用于显示数据包从源地址到目的地址， 所经过的所有网络设备

- 用于检查网络的连通性，在网络故障发生时，准确地定位故障发生的位置。

```
Ruijie#traceroute 192.168.100.10 source 10.1.1.1 probe 10 ttl 1 3 timeout 3
//测试从源10.1.1.1到192.168.100.10的连通性，并显示路径上的网络设备，探测数据包每跳最多跟踪10条路由（例如负载均衡时，会朝多个方向进行探测），TTL值范围是1-3（最多3跳），超时时间3秒
```

## 4、系统文件管理

### 4.1、RGOS的文件系统

![12_rgos](http://images.zsjshao.cn/images/rs/06-rgos/12_rgos.png)

flash中保存的数据时掉电不丢失的数据：

- 配置文件：config.text
- RGOS系统文件：rgos.bin
- 日志文件：syslog.text
- 其他运行文件

当设备开机运行时，会将RGOS以及配置文件全部都加载到内存中运行

### 4.2、设备配置管理

设备启动时，从Flash介质中读取config.text文件，并作为当前设备的配置

Running config是当前正在运行的配置，保存后，将写入config.text

| **命令**                                         | **解释**                                   |
| ------------------------------------------------ | ------------------------------------------ |
| Ruijie#write                                     | 保存配置                                   |
| Ruijie(config)#no  *command*                     | 删除某条具体命令                           |
| Ruijie#delete  config.text                       | 恢复出产配置（锐捷设备不需要单独删除VLAN） |
| Ruijie#copy  flash:config.text  flash:config.bak | 将当前保存的配置进行备份                   |
| Ruijie#copy  flash:config.bak  flash:config.text | 将备份配置恢复至当前保存的配置             |
| Ruijie#reload                                    | 重启设备（是否要保存，需要注意）           |

