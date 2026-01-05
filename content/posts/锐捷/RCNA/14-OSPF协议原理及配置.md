+++
author = "zsjshao"
title = "14_OSPF协议原理及配置"
date = "2020-05-23"
tags = ["NA"]
categories = ["RS"]

+++

## 1、OSPF协议概述

### 1.1、OSPF的概述

OSPF是Open Shortest Path First （开放最短路径优先协议）的简称

OSPF属于链路状态路由协议，相对RIP这样的距离矢量路由协议，它有更合理开销衡量机制

OSPF的管理距离是110

OSPF报文封装在IP报文中，IP协议号为89

OSPF支持区域划分，可适应大规模网络

OSPF具有无环路、收敛快、扩展性好、支持认证等特点

OSPF目前应用中有两个版本：

- V2：适用于IPv4
- V3：扩展支持IPv6

### 1.2、OSPF的开销

**OSPF的开销计算方式**：基于物理链路的带宽来计算度量值

- Cost=计算基数（默认10的8次方）/物理链路带宽（bit为单位）
  - 100兆cost值就是:100000000/100000000=1
  - 10兆cost值就是:100000000/10000000=10

- 如结果出现小数，小数点后面的数直接舍掉， 例如带宽是1000兆cost值也是1

使用OSPF协议时，默认情况下计算基数为10的8次方，100M的cost值和1000M的cost值都为1

如图，当10.1.0.0/24访问10.2.0.0/24时，数据从F0/1出去，此时是次优路径，需要修改开销值

![01_ospf](http://images.zsjshao.cn/images/rs/14-ospf/01_ospf.png)

- 方案一：在OSPF进程中使用该命令可以修改度量值计算基数，避免这种问题，1000指链路带宽为1000M

```
Ruijie(config)#router ospf 10
Ruijie(config-router)#auto-cost reference-bandwidth 1000 
```

- 方案二：在接口下，使用该命令，直接修改cost值为200，来影响OSPF路径计算结果

```
Ruijie(config)#int f0/1
Ruijie(config-if)#ip ospf cost 200 
```

### 1.3、OSPF相关术语

**自治系统（Autonomous System）** ：指使用同一种路由协议交换路由信息的一组路由器，简称AS

**路由器ID（Router-ID）**：在AS中唯一标识一台运行OSPF的路由器的ID

- 每个运行OSPF的路由器都必须有一个Router ID
- Router ID可以手动命令配置，也可以系统自动选举（优先Loopback最大IP，其次物理接口最大IP）

**邻居（Neighbor）**：设备启动OSPF 路由协议后，便会通过接口向外发送Hello 报文，收到Hello 报文的其它启动OSPF 路由协议的设备会检查报文中所定义的一些参数，如果双方一致就会形成邻居关系

**邻接（Adjacency）**：形成邻居关系的双方不一定都能形成邻接关系，当两台路由设备之间交换链路状态信息，并根据形成的数据库计算出OSPF路由，才能称为邻接关系

![02_ospf](http://images.zsjshao.cn/images/rs/14-ospf/02_ospf.png)

### 1.4、OSPF的关键要素之五种报文

![03_ospf](http://images.zsjshao.cn/images/rs/14-ospf/03_ospf.png)

### 1.5、OSPF的关键要素之三张表

邻居表（neighbor table）：

- 通过**Hello报文**形成邻居
- 用邻居机制来维持路由
- 邻居表存储双向通信的OSPF路由器列表信息

```
R2#show ip ospf neighbor 
Neighbor ID     Pri   State          Dead Time   Address      Interface
172.16.2.254     0   FULL/  -        00:00:33    10.1.0.1     Serial0/1/0
10.3.0.254       1   FULL/BDR        00:00:31    10.2.0.2     FastEthernet0/0
```

链路状态数据库（LSDB）：

- 通过**LSU报文**更新LSDB
- 描述拓扑信息的LSA存储在LSDB中

```
R2#show ip ospf database 
            OSPF Router with ID (10.2.0.1) (Process ID 10)
                Router Link States (Area 0)
Link ID         ADV Router      Age         Seq#       Checksum Link count
172.16.2.254    172.16.2.254    352         0x80000004 0x00097c 4
10.2.0.1        10.2.0.1        310         0x80000004 0x005554 3
10.3.0.254      10.3.0.254      310         0x80000003 0x006a97 2
                Net Link States (Area 0)
Link ID         ADV Router      Age         Seq#       Checksum
10.2.0.1        10.2.0.1        310         0x80000001 0x004303
```

路由表：

- OSPF计算出来的路由将会加载到路由表
- 路由优先级 O>O IA>O E1/2>O N1/2

```
R2#show ip route 
O   10.3.0.0 [110/2] via 10.2.0.2, 00:06:42, FastEthernet0/0
O   172.16.1.0 [110/65] via 10.1.0.1, 00:07:27, Serial0/1/0
O   172.16.2.0 [110/65] via 10.1.0.1, 00:07:27, Serial0/1/0
```

### 1.6、OSPF的关键要素之三个阶段

**邻居发现，形成邻居：**（成功的标志：2-way状态）

- 通过Hello报文发现并形成邻居关系
- 形成邻居表



**形成邻接，路由通告：**（成功的标志：full状态，LSDB同步）

- 邻接路由器之间通过LSU洪泛LSA，通告拓扑信息，通过DBD、LSR、LSACK辅助LSA的同步
- 最终同一个区域内所有路由器LSDB完全相同
- 形成邻接表



**路由计算阶段：** 

- LSDB同步后，每台路由器独立进行SPF运算
- 把计算出的最佳路由信息放进路由表

### 1.7、OSPF的工作过程

![04_ospf](http://images.zsjshao.cn/images/rs/14-ospf/04_ospf.png)

### 1.8、OSPF的邻居发现过程

![05_ospf](http://images.zsjshao.cn/images/rs/14-ospf/05_ospf.png)

通过Hello报文发现邻居，记录在邻居表

每隔10s发送一次Hello报文，维护邻居关系，超过40s认为失效

此时Two-way状态，还不能交换链路状态信息

### 1.9、OSPF的Hello报文结构和影响邻居建立的7个因素

Hello报文对OSPF邻居建立至关重要，其中对应字段必须匹配才能够正常建立关系：

- 路由器ID：必须不一致
- Hello/Dead Time ：必须一致
- Area ID ：ID值必须一致
- 认证：密钥必须一致
- stub存根标记：末节区域类型必须一致
- 接口子网掩码：在以太网环境下，掩码必须一致
- 接口网络类型：必须一致，影响路由计算

![06_ospf](http://images.zsjshao.cn/images/rs/14-ospf/06_ospf.png)

### 1.10、OSPF的链路状态摘要交换过程

![07_ospf](http://images.zsjshao.cn/images/rs/14-ospf/07_ospf.png)

### 1.11、OSPF的详细链路状态信息同步过程

![08_ospf](http://images.zsjshao.cn/images/rs/14-ospf/08_ospf.png)

### 1.12、OSPF的路由计算与路由表加载

每台OSPF路由器都会使用SPF算法，根据自己的LSDB独立地计算去往每个目的网络的最短路径

- 同步后，同一区域的OSPF路由器，LSDB一定是相同的

![09_ospf](http://images.zsjshao.cn/images/rs/14-ospf/09_ospf.png)



### 1.13、OSPF的DR、BDR机制

OSPF在每段以太网（广播多路访问）链路上都会进行DR与BDR的选举

- DR与BDR的节点能够与该链路上其他节点建立邻接关系，进入Full状态
- DR other（非DR/BDR ）的节点之间建立邻居，停留在two-way状态，不会交换LSA

DR、BDR的机制减少了在同一广播域中邻接的数量，减少了该链路上LSA的泛洪，节省带宽

- 在园区网络的广域网出口位置DR、BDR的机制可以有一定作用
- 在点到点的链路中，DR机制作用甚微

右图的广域网出口案例中

- 如果两两建立邻接需要15对邻接
- 如果DR机制，只需要8对邻接

![10_ospf](http://images.zsjshao.cn/images/rs/14-ospf/10_ospf.png)

### 1.14、OSPF的DR、BDR的选举

Hello包携带路由设备优先级，默认=1

优先级高的成为DR，其次成为BDR

优先级为0的路由设备不具备选举资格，未来也不可能为DR或者BDR

DR和BDR一旦选定，即使OSPF区域内新增优先级更高的路由设备，DR和BDR也不会重新选举，只有当DR和BDR都失效后，才参与选举

优先级是基于接口的，修改命令如下

![11_ospf](http://images.zsjshao.cn/images/rs/14-ospf/11_ospf.png)

```
config)#int vlan 10
(config-if-VLAN 10)#ip ospf priority 10
```

### 1.15、OSPF的状态机

OSPF的状态随着邻居建立、数据库同步、邻接建立、路由计算四个阶段的进行，按状态机发生变化

其中Down、Two-way、Full为稳定状态，其余为中间过渡状态

若状态停留在过渡状态，需要根据信息判断故障点

![12_ospf](http://images.zsjshao.cn/images/rs/14-ospf/12_ospf.png)

## 2、OSPF的基本配置

### 2.1、OSPF的单区域问题

同一个区域内所有路由器为了LSDB保持完全相同，在链路发生变动的时候需要更新LSA

每台路由器收到的LSA通告太多了

内部链路动荡会引起全网路由器的完全SPF计算

区域内路由无法汇总，需要维护的路由表越来越大，资源消耗过多，性能下降，影响数据转发

![13_ospf](http://images.zsjshao.cn/images/rs/14-ospf/13_ospf.png)

#### 2.1.1、OSPF的单区域问题解决方案

把大型网络分隔为多个较小，可管理的单元 ：区域 area

网络类型影响邻居关系、邻接关系的形成及路由计算：

- 控制LSA只在区域内洪泛，有效地把拓扑变化控制在区域内，拓扑的变化影响限制在本区域
- 提高了网络的稳定性和的扩展性，有利于组建大规模的网络
- 在区域边界可以做路由汇总，减小了路由表

![14_ospf](http://images.zsjshao.cn/images/rs/14-ospf/14_ospf.png)

### 2.2、OSPF多区域层次化

Area 0为骨干区域，所有其他区域设备都至少有一个接口属于Area 0

同区域通过区域ID标识，其中骨干区域必须是area 0，常见区域分类如下

- 骨干区域
- 常规区域
- 末节区域(特殊)

![15_ospf](http://images.zsjshao.cn/images/rs/14-ospf/15_ospf.png)

### 2.3、OSPF多区域环境路由器类型

**内部路由器IR（Internal Area Router）：**

- 所有接口在同一个Area内
- 同一区域内的所有内部路由器的 LSDB完全相同

**区域边界路由器ABR（ Area Border Router）：**

- 接口分属于两个或两个以上的区域，并且有一个活动接口属于area 0
- ABR为它们所连接的每个区域分别维护单独的LSDB
- 区域间路由信息必须通过ABR才能进出区域
- ABR是区域路由信息的进出口,也是区域间数据的进出口

![16_ospf](http://images.zsjshao.cn/images/rs/14-ospf/16_ospf.png)

### 2.4、单区域OSPF案例

OSPF路由案例1需求

- 在三台路由器上配置OSPF路由，配置OSPF进程号为10
- 配置OSPF区域全为0，使PC1和PC2能ping通PC3

![17_ospf](http://images.zsjshao.cn/images/rs/14-ospf/17_ospf.png)

#### 2.4.1、基础配置

启动OSPF进程：

- (config)# router ospf *[process ID]*

配置OSPF运行的接口以及接口的区域ID （建议使用精确宣告）：

- (config-router)# network *network* *mask* area *[area ID]*

```
R1(config)#router ospf 10
R1(config-router)#network  172.16.2.254  0.0.0.0  area 0
R1(config-router)#network  172.16.1.254  0.0.0.0  area 0
R1(config-router)#network  10.1.0.1  0.0.0.0  area 0

R2(config)#router ospf 10
R2(config-router)#network  10.1.0.2  0.0.0.0   area 0
R2(config-router)#network  10.2.0.1  0.0.0.0   area 0

R3(config)#router ospf 10
R3(config-router)#network  10.2.0.2   0.0.0.0  area 0
R3(config-router)#network  10.3.0.254   0.0.0.0  area 0
```

#### 2.4.2、路由表

查看R1、R2和R3的路由表

- 使用特权用户模式命令show ip route，显示IP路由表

```
R1#show ip route
10.0.0.0/24 is subnetted, 3 subnets
C 10.1.0.0 is directly connected, Serial0/1/0
O 10.2.0.0 [110/65] via 10.1.0.2, 00:08:38, Serial0/1/0
O 10.3.0.0 [110/66] via 10.1.0.2, 00:07:54, Serial0/1/0
      172.16.0.0/24 is subnetted, 2 subnets
C 172.16.1.0 is directly connected, FastEthernet0/1
C 172.16.2.0 is directly connected, FastEthernet0/0

R2#show ip route
10.0.0.0/24 is subnetted, 3 subnets
C 10.1.0.0 is directly connected, Serial0/1/0
C 10.2.0.0 is directly connected, FastEthernet0/1
O 10.3.0.0 [110/2] via 10.2.0.2, 00:09:10, FastEthernet0/0
172.16.0.0/24 is subnetted, 2 subnets
O 172.16.1.0 [110/65] via 10.1.0.1, 00:09:46, Serial0/1/0
O 172.16.2.0 [110/65] via 10.1.0.1, 00:09:46, Serial0/1/0

R3#show ip route
10.0.0.0/24 is subnetted, 3 subnets
O 10.1.0.0 [110/65] via 10.2.0.1, 00:09:39, FastEthernet0/0
C 10.2.0.0 is directly connected, FastEthernet0/0
C 10.3.0.0 is directly connected, FastEthernet0/1
172.16.0.0/24 is subnetted, 2 subnets
O 172.16.1.0 [110/66] via 10.2.0.1, 00:09:39, FastEthernet0/0
O 172.16.2.0 [110/66] via 10.2.0.1, 00:09:39, FastEthernet0/0
```

#### 2.4.3、连通性测试

测试网络连通性

- PC1和PC2能ping通PC3

```
PC1>ping 10.3.0.1
Pinging 10.3.0.1 with 32 bytes of data:
Reply from 10.3.0.1: bytes=32 time=2ms TTL=125
Reply from 10.3.0.1: bytes=32 time=1ms TTL=125
Reply from 10.3.0.1: bytes=32 time=3ms TTL=125
Reply from 10.3.0.1: bytes=32 time=3ms TTL=125

Ping statistics for 10.3.0.1:
Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
Minimum = 1ms, Maximum = 3ms, Average = 2ms

PC2>ping 10.3.0.1
Pinging 10.3.0.1 with 32 bytes of data:
Reply from 10.3.0.1: bytes=32 time=2ms TTL=125
Reply from 10.3.0.1: bytes=32 time=1ms TTL=125
Reply from 10.3.0.1: bytes=32 time=3ms TTL=125
Reply from 10.3.0.1: bytes=32 time=3ms TTL=125

Ping statistics for 10.3.0.1:
Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
Minimum = 1ms, Maximum = 3ms, Average = 2ms
```

#### 2.4.4、状态查看

查看OSPF 协议状态：show ip protocols

- FULL/BDR ：表示邻接状态已经建立，并且此时本路由器为BDR角色



```
R2#show ip protocols 
Routing Protocol is "ospf 10"
  Outgoing update filter list for all interfaces is not set 
  Incoming update filter list for all interfaces is not set 
  Router ID 10.2.0.1
  Number of areas in this router is 1. 1 normal 0 stub 0 nssa
  Maximum path: 4
  Routing for Networks:
    10.1.0.0 0.0.0.255 area 0
    10.2.0.0 0.0.0.255 area 0
  Routing Information Sources:  
    Gateway         Distance      Last Update 
    10.2.0.1             110      00:13:18
    10.3.0.254           110      00:13:18
    172.16.2.254         110      00:13:57
  Distance: (default is 110)
```

查看OSPF邻居表：show ip ospf neighbor

```
R2#show ip ospf neighbor
Neighbor ID     Pri   State           Dead Time   Address         Interface
10.3.0.254        1   FULL/BDR        00:00:30    10.2.0.2        FastEthernet0/0
172.16.2.254      0   FULL/  -        00:00:37    10.1.0.1        Serial0/1/0
```

查看接口OSPF相关信息： Show ip ospf interface

```
R2#Show ip ospf interface

FastEthernet0/0 is up, line protocol is up
  Internet address is 10.2.0.1/24, Area 0
  Process ID 10, Router ID 10.2.0.1, Network Type BROADCAST, Cost: 1
  Transmit Delay is 1 sec, State DR, Priority 1
  Designated Router (ID) 10.2.0.1, Interface address 10.2.0.1
  Backup Designated Router (ID) 10.3.0.254, Interface address 10.2.0.2
  Timer intervals configured, Hello 10, Dead 40, Wait 40, Retransmit 5
    Hello due in 00:00:07
  Index 2/2, flood queue length 0
  Next 0x0(0)/0x0(0)
  Last flood scan length is 1, maximum is 1
  Last flood scan time is 0 msec, maximum is 0 msec
  Neighbor Count is 1, Adjacent neighbor count is 1
    Adjacent with neighbor 10.3.0.254  (Backup Designated Router)
  Suppress hello for 0 neighbor(s)
```

### 2.5、多区域OSPF案例

OSPF路由案例2需求：

- 在三台路由器上配置OSPF路由，配置OSPF进程号为10
- 按照拓扑图配置OSPF区域，使PC1和PC2能ping通PC3

![18_ospf](http://images.zsjshao.cn/images/rs/14-ospf/18_ospf.png)

#### 2.5.1、基本配置

启动OSPF进程：

- Router(config)# router ospf 进程号

配置OSPF运行的接口以及接口的区域ID ：

- Router (config-router)# network 网络号 反掩码 area 区域id

```
R1(config)#router ospf 10
R1(config-router)#network  172.16.2.254  0.0.0.0  area 1
R1(config-router)#network  172.16.1.254  0.0.0.0  area 1
R1(config-router)#network  10.1.0.1  0.0.0.0  area 1

R2(config)#router ospf 10
R2(config-router)#network  10.1.0.2  0.0.0.0   area 1
R2(config-router)#network  10.2.0.1  0.0.0.0   area 0

R3(config)#router ospf 10
R3(config-router)#network  10.2.0.2   0.0.0.0  area 0
R3(config-router)#network  10.3.0.254   0.0.0.0  area 0
```

#### 2.5.2、路由表

使用特权用户模式命令show ip route，显示IP路由表

- “O”表示区域内部路由
- “O IA”表示区域间路由

查看R1、R2和R3的路由表

```
R1#show ip route
10.0.0.0/24 is subnetted, 3 subnets
C    10.1.0.0 is directly connected, Serial0/1/0
O IA 10.2.0.0 [110/65] via 10.1.0.2, 00:00:49, Serial0/1/0
O IA 10.3.0.0 [110/66] via 10.1.0.2, 00:00:49, Serial0/1/0
     172.16.0.0/24 is subnetted, 2 subnets
C    172.16.1.0 is directly connected, FastEthernet0/1
C    172.16.2.0 is directly connected, FastEthernet0/0

R2#show ip route
    10.0.0.0/24 is subnetted, 3 subnets
C   10.1.0.0 is directly connected, Serial0/1/0
C   10.2.0.0 is directly connected, FastEthernet0/1
O   10.3.0.0 [110/2] via 10.2.0.2, 00:09:10, FastEthernet0/0
    172.16.0.0/24 is subnetted, 2 subnets
O   172.16.1.0 [110/65] via 10.1.0.1, 00:09:46, Serial0/1/0
O   172.16.2.0 [110/65] via 10.1.0.1, 00:09:46, Serial0/1/0

R3#show ip route
  10.0.0.0/24 is subnetted, 3 subnets
O IA 10.1.0.0 [110/65] via 10.2.0.1, 00:17:17, FastEthernet0/0
C 10.2.0.0 is directly connected, FastEthernet0/0
C 10.3.0.0 is directly connected, FastEthernet0/1
  172.16.0.0/24 is subnetted, 2 subnets
O IA 172.16.1.0 [110/66] via 10.2.0.1, 00:01:32, FastEthernet0/0
O IA 172.16.2.0 [110/66] via 10.2.0.1, 00:01:32, FastEthernet0/0
```

#### 2.5.3、连通性测试

测试网络连通性

- PC1和PC2能ping通PC3

```
PC1>ping 10.3.0.1
Pinging 10.3.0.1 with 32 bytes of data:
Reply from 10.3.0.1: bytes=32 time=2ms TTL=125
Reply from 10.3.0.1: bytes=32 time=1ms TTL=125
Reply from 10.3.0.1: bytes=32 time=3ms TTL=125
Reply from 10.3.0.1: bytes=32 time=3ms TTL=125

Ping statistics for 10.3.0.1:
Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
Minimum = 1ms, Maximum = 3ms, Average = 2ms

PC2>ping 10.3.0.1
Pinging 10.3.0.1 with 32 bytes of data:
Reply from 10.3.0.1: bytes=32 time=2ms TTL=125
Reply from 10.3.0.1: bytes=32 time=1ms TTL=125
Reply from 10.3.0.1: bytes=32 time=3ms TTL=125
Reply from 10.3.0.1: bytes=32 time=3ms TTL=125

Ping statistics for 10.3.0.1:
Packets: Sent = 4, Received = 4, Lost = 0 (0% loss),
Approximate round trip times in milli-seconds:
Minimum = 1ms, Maximum = 3ms, Average = 2ms
```

