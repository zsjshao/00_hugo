# OSPF基础

## OSPF协议概述

### 为什么需要动态路由协议？

• 静态路由是由工程师手动配置和维护的路由条目，命令行简单明确，适用于小型或稳定的网络。静态路由有以下问题：

-  无法适应规模较大的网络：随着设备数量增加，配置量急剧增加。
-  无法动态响应网络变化：网络发生变化，无法自动收敛网络，需要工程师手动修改。

### 动态路由分类

按工作区域分类

- IGP（Interior Gateway Protocols，内部网关协议）
  - RIP  **OSPF**  IS-IS

- EGP（Exterior Gateway Protocols，外部网关协议）
  - BGP

按工作机制及算法分类

- （Distance Vector Routing Protocols，距离矢量路由协议）
  - RIP
- （Link-State Routing Protocols，链路状态路由协议）
  - **OSPF**  IS-IS 

BGP使用一种基于距离矢量算法修改后的算法，该算法被称为路径矢量（Path Vector）算法。因此在某些场合下，BGP也被称为路径矢量路由协议。

### 距离矢量路由协议

• 运行距离矢量路由协议的路由器周期性的泛洪自己的路由表。通过路由的交互，每台路由器都从相邻的路由器学习到路由，并且加载进自己的路由表中。

• 对于网络中的所有路由器而言，路由器并不清楚网络的拓扑，只是简单的知道要去往某个目的方向在哪里，距离有多远。这即是距离矢量算法的本质。

```
 <-Routing Table->         <-Routing Table->         <-Routing Table->
   |---------|               |---------|               |---------|
---|   R1    |---------------|   R2    |---------------|   R3    |-------| 3.3.3.3
   |---------|               |---------|               |---------|
    /
  /
去3.3.3.3，走R2！
```

### 链路状态路由协议 - LSA泛洪

与距离矢量路由协议不同，链路状态路由协议通告的的是链路状态而不是路由表。运行链路状态路由协议的路由器之间首先会建立一个协议的邻居关系，然后彼此之间开始交互LSA（Link State Advertisement，链路状态通告）。

```
                             |---------|
                             |   R2    |
                             |---------|
                       ->  /            \ <-
                     L   /                \  L
                       /                    \           ++++++++++++++++++++++++++++++++++++++++++++++++++++
                  S  /                        \  S      |不再通告路由信息，而是LSA。                           |
                   /                            \       |LSA描述了路由器接口的状态信息，例如接口的开销、连接的对象等。|
              A  /                                \  A  ++++++++++++++++++++++++++++++++++++++++++++++++++++
          <-   /                                    \  ->
   |---------|                                        |---------|
   |   R1    |                                        |   R3    |
   |---------|                                        |---------|
          <-   \                                    /  ->
              A  \                                /  A
                   \                            /
                  S  \                        /  S
                       \                    /
                     L   \                /  L
                       ->  \            / <-
                            |---------|
                            |   R4    |
                            |---------|
```

链路状态通告，可以简单的理解为每台路由器都产生一个描述自己直连接口状态（包括接口的开销、与邻居路由器之间的关系等）的通告。

链路属性（LSA）：

- 链路上的邻居
- 链路开销
- 直连网络号
- 接口的地址
- 链路的类型

### 链路状态路由协议 - LSDB组建

•每台路由器都会产生LSAs，路由器将接收到的LSAs放入自己的LSDB（Link State DataBase，链路状态数据库）。路由器通过LSDB，掌握了全网的拓扑。

```
                               【LSDB】
                             |---------|
                             |   R2    |
                             |---------|
                       ->  /            \ <-
                     L   /                \  L          ++++++++++++++++++++++++++++++++++++
                       /                    \           |路由器将LSA存放在LSDB中              |
                  S  / 100M            1.544M \  S      |LSDB汇总了网络中路由器对于自己接口的描述 |
                   /                            \       |LSDB包含全网拓扑的描述               |
              A  /                                \  A  ++++++++++++++++++++++++++++++++++++
          <-   /                                    \  ->
       |---------|                                 |---------|
【LSDB】|   R1    |                                 |   R3    |【LSDB】
       |---------|                                 |---------|
          <-   \                                    /  ->
              A  \                                /  A
                   \                            /
                  S  \  1000M           1000M /  S
                       \                    /
                     L   \                /  L
                       ->  \            / <-
                            |---------|
                            |   R4    |
                            |---------|
                              【LSDB】
```

### 链路状态路由协议 - SPF计算

• 每台路由器基于LSDB，使用SPF（Shortest Path First，最短路径优先）算法进行计算。每台路由器都计算出一棵以自己为根的、无环的、拥有最短路径的“树”。有了这棵“树”，路由器就已经知道了到达网络各个角落的优选路径。



```
                               【LSDB】
                             |---------|
                             |   R2    |
                             |---------|
                           /            \
                         /                \             ++++++++++++++++++++++++++++++++++++++++++++++++++++
                       /                    \           |每台路由器都计算出一棵以自己为根的、无环的、拥有最短路径的“树”|                      / 100M            1.544M \         ++++++++++++++++++++++++++++++++++++++++++++++++++++
                   /                            \
                 /                                \
               /                                    \
       |---------|                                 |---------|
【LSDB】|   R1    |                                 |   R3    |【LSDB】
       |---------|                                 |---------|  \
               \                                    /     \       \
                 \                                /        \   SPF  \
                   \                            /           \         \
                     \  1000M           1000M /              \      R2  \
                       \                    /                 \    /
                         \                /                    \  R1  R3
                           \            /                          \  /
                            |---------|                             R4
                            |   R4    |
                            |---------|
                              【LSDB】
```

SPF是OSPF路由协议的一个核心算法，用来在一个复杂的网络中做出路由优选的决策。

### 链路状态路由协议 - 路由表生成

• 最后，路由器将计算出来的优选路径，加载进自己的路由表（Routing Table）。

```
                                        【LSDB】【Routing Table】
                                      |---------|
                                      |   R2    |
                                      |---------|
                                    /            \
                                  /                \             ++++++++++++++++++++++++++++++++++++++++
                                /                    \           |每台路由器根据SPF计算结果，将路由加载入路由表。|
                              / 100M            1.544M \         ++++++++++++++++++++++++++++++++++++++++
                            /                            \           /
                          /                                \       /
                        /                                    \   /
                |---------|                                 |---------|
【LSDB】         |   R1    |                                 |   R3    |【LSDB】【Routing Table】
【Routing Table】|---------|                                 |---------|
                        \                                    /
                          \                                /
                            \                            /
                              \  1000M           1000M /
                                \                    /
                                  \                /
                                    \            /
                                     |---------|
                                     |   R4    |
                                     |---------|
                                       【LSDB】【Routing Table】
```

### 链路状态路由协议总结

```
                                          |    【LSDB】                    【LSDB】
   |---------|  建立邻居关系   |---------|  |   |---------|   链路状态信息   |---------| 
   |   R1    |---------------|   R2    |  |   |   R1    |---------------|   R2    |
   |---------|               |---------|  |   |---------|               |---------|
          \                  /            |          \                  /            
 建立邻居关系 \              / 建立邻居关系    | 链路状态信息 \              / 链路状态信息   
              \          /                |              \          /           
              |---------|                 |              |---------|                 
              |   R3    |                 |              |   R3    |   
              |---------|               Ⅰ | Ⅱ           |---------| 【LSDB】
------------------------------------------|-------------------------------------------
     路径计算                    路径计算 Ⅲ | Ⅳ  【RIB】                    【RIB】
   |---------|               |---------|  |   |---------|   生成路由表项  |---------| 
   |   R1    |---------------|   R2    |  |   |   R1    |---------------|   R2    |
   |---------|               |---------|  |   |---------|               |---------|
          \                  /            |          \                  /            
            \              /              |            \              /
              \          /   /            |              \          /
              |---------|  /    R1——R2    |              |---------|
              |   R3    |  \     \  /     |              |   R3    |
      路径计算 |---------|    \     R3     |              |---------| 【RIB】
                                          | RIB：Routing Information Base
```

• 链路状态路由协议有四个步骤：

- 第一步是建立相邻路由器之间的邻居关系。
- 第二步是邻居之间交互链路状态信息和同步LSDB。
- 第三步是进行优选路径计算。
- 第四步是根据最短路径树生成路由表项加载到路由表。

### OSPF简介

• OSPF是典型的链路状态路由协议，是目前业内使用非常广泛的IGP协议之一。

• 目前针对IPv4协议使用的是OSPF Version 2（RFC2328）；针对IPv6协议使用OSPF Version 3（RFC2740）。如无特殊说明本章后续所指的OSPF均为OSPF Version 2。

• 运行OSPF路由器之间交互的是LS（Link State，链路状态）信息，而不是直接交互路由。LS信息是OSPF能够正常进行拓扑及路由计算的关键信息。

• OSPF路由器将网络中的LS信息收集起来，存储在LSDB中。路由器都清楚区域内的网络拓扑结构，这有助于路由器计算无环路径。

• 每台OSPF路由器都采用SPF算法计算达到目的地的最短路径。路由器依据这些路径形成路由加载到路由表中。

• OSPF支持VLSM（Variable Length Subnet Mask，可变长子网掩码），支持手工路由汇总。

• 多区域的设计使得OSPF能够支持更大规模的网络。

### OSPF基础术语：区域

• OSPF Area用于标识一个OSPF的区域。

• 区域是从逻辑上将设备划分为不同的组，每个组用区域号（Area ID）来标识。

```
++++++++++++++++++++++++++++++++++++++++++++++++
|    |---------|               |---------|     |
|    |   R1    |---------------|   R2    |     |
|    |---------|               |---------|     |
|          \                  /                |
|           \               /                  |
|            \            /                    |
|             |---------|                      |
|             |   R3    |                      |
|             |---------|               Area0  |
++++++++++++++++++++++++++++++++++++++++++++++++
```

### OSPF基础术语：Router-ID

• Router-ID（Router Identifier，路由器标识符），用于在一个OSPF域中唯一地标识一台路由器。
• Router-ID的设定可以通过手工配置的方式，或使用系统自动配置的方式。

```
++++++++++++++++++++++++++++++++++++++++++++++++
|  Router-id 1.1.1.1       Router-id 2.2.2.2   |
|    |---------|               |---------|     |
|    |   R1    |---------------|   R2    |     |
|    |---------| ->            |---------|     |
|          \  I'm 1.1.1.1     /                |
|           \ ->            /                  |
|            \            /                    |
|             |---------|                      |
|             |   R3    | Router-id 3.3.3.3                     |
|             |---------|               Area0  |
++++++++++++++++++++++++++++++++++++++++++++++++
```

• 在实际项目中，通常会通过手工配置方式为设备指定OSPF Router-ID。请注意必须保证在OSPF域中任意两台设备的Router-ID都不相同。通常的做法是将Router-ID配置为与该设备某个接口（通常为Loopback接口）的IP地址一致。

### OSPF的基础术语：度量值

• OSPF使用Cost（开销）作为路由的度量值。每一个激活了OSPF的接口都会维护一个接口Cost值，缺省时接口Cost值 = 100 Mbit/s / 接口带宽 。其中100 Mbit/s为OSPF指定的缺省参考值，该值是可配置的。

```
bandwidlh-reference 5000
```

• 笼统地说，一条OSPF路由的Cost值可以理解为是从目的网段到本路由器沿途所有入接口的Cost值累加。

```
# OSPF接口Cost值
                | Serial接口（1.544Mbit/s)
                | 默认Cost=64
           |---------|
-----------|    R    |-----------
   FE接口   |---------| GE接口
 默认Cost=1             默认Cost=1
 
 OSPF不同接口因其带宽不同，有不同的Cost。


# OSPF路径累计Cost值
    1.1.1.0/24
     -------
        | 
Cost=10 |
   |---------|               |---------|               |---------|
---|   R1    |---------------|   R2    |---------------|   R3    |
   |---------|        Cost=1 |---------|       Cost=64 |---------|
在R3的路由表中，到达1.1.1.0/24的OSPF路由的Cost值=10+1+64，即75。
```

### OSPF协议报文类型

OSPF有五种类型的协议报文。这些报文在OSPF路由器之间交互中起不同的作用。

|报文名称| 报文功能|
|--|--|
|Hello |周期性发送，用来发现和维护OSPF邻居关系。|
|Database Description| 描述本地LSDB的摘要信息，用于两台设备进行数据库同步。|
|Link State Request |用于向对方请求所需要的LSA。设备只有在OSPF邻居双方成功交换DD报文后才会向对方发出LSR报文。|
|Link State Update |用于向对方发送其所需要的LSA。|
|Link State ACK |用来对收到的LSA进行确认。|

### OSPF三大表项 - 邻居表

• OSPF有三张重要的表项，OSPF邻居表、LSDB表和OSPF路由表。对于OSPF的邻居表，需要了解：

- OSPF在传递链路状态信息之前，需先建立OSPF邻居关系。
- OSPF的邻居关系通过交互Hello报文建立。
- OSPF邻居表显示了OSPF路由器之间的邻居状态，使用display ospf peer查看。

```
Router ID:1.1.1.1                       Router ID:2.2.2.2
|---------|                             |---------|
|   R1    |-----------------------------|   R2    |
|---------|GE1/0/0               GE1/0/0|---------|
          10.1.1.1/30            10.1.1.2/30

<R1> display ospf peer
OSPF Process 1 with Router ID 1.1.1.1
  Neighbors
Area 0.0.0.0 interface 10.1.1.1(GigabitEthernet1/0/0)'s neighbors
Router ID:2.2.2.2 Address:10.1.1.2 GR State: Normal
  State: Full Mode:Nbr is Master Priority: 1
  DR: 10.1.1.1 BDR:10.1.1.2 MTU:0
  Dead timer due in 35 sec
  Retrans timer interval: 5
  Neighbor is up for 00:00:05
  Authentication Sequence: [ 0 ]
```

### OSPF三大表项 - LSDB表

对于OSPF的LSDB表，需要了解：

- LSDB会保存自己产生的及从邻居收到的LSA信息，本例中R1的LSDB包含了三条LSA。
- Type标识LSA的类型，AdvRouter标识发送LSA的路由器。
- 使用命令行display ospf lsdb查看LSDB表。

```
Router ID:1.1.1.1                       Router ID:2.2.2.2
|---------|                             |---------|
|   R1    |-----------------------------|   R2    |
|---------|GE1/0/0               GE1/0/0|---------|
          10.1.1.1/30            10.1.1.2/30

<R1> display ospf lsdb
            OSPF Process 1 with Router ID 1.1.1.1
                   Link State Database
                      Area: 0.0.0.0
Type     LinkState ID  AdvRouter Age Len Sequence Metric
Router   2.2.2.2       2.2 2 2   98  36  8000000B 1
Router   1.1.1.1       1.1.1.1   92  36  80000005 1
Network  10.1.1.2      2.2.2.2   98  32  80000004 0
```

### OSPF三大表项 - OSPF路由表

• 对于OSPF的路由表，需要了解：

- OSPF路由表和路由器路由表是两张不同的表项。本例中OSPF路由表有三条路由。
- OSPF路由表包含Destination、Cost和NextHop等指导转发的信息。
- 使用命令display ospf routing查看OSPF路由表。

```
Router ID:1.1.1.1                       Router ID:2.2.2.2
|---------|                             |---------|
|   R1    |-----------------------------|   R2    |
|---------|GE1/0/0               GE1/0/0|---------|
          10.1.1.1/30            10.1.1.2/30

<R1> display ospf routing
OSPF Process 1 with Router ID 1.1.1.1
Routing Tables
Routing for Network
Destination   Cost   Type     NextHop    AdvRouter  Area
1.1.1.1/32    0      stub     1.1.1.1    1.1.1.1    0.0.0.0
10.1.1.0/32   1      Transit  10.1.1.1   1.1.1.1    0.0.0.0
2.2.2.2/32    1      stub     10.1.1.2   2.2.2.2    0.0.0.0

Total Nets: 3
Intra Area: 3 Inter Area:0 ASE:O NSSA: 0
```

## OSPF协议工作原理

关于OSPF路由器之间的关系有两个重要的概念，邻居关系和邻接关系。

考虑一种简单的拓扑，两台路由器直连。在双方互联接口上激活OSPF，路由器开始发送及侦听Hello报文。在通过Hello报文发现彼此后，这两台路由器便形成了邻居关系。

邻居关系的建立只是一个开始，后续会进行一系列的报文交互，例如前文提到的DD、LSR、LSU和LS ACK等。当两台路由器LSDB同步完成，并开始独立计算路由时，这两台路由器形成了邻接关系。

### 初识OSPF邻接关系建立过程

OSPF完成邻接关系的建立有四个步骤，建立邻居关系、协商主/从、交互LSDB信息，同步LSDB。

```
|---------|                             |---------|
|   R1    |-----------------------------|   R2    |
|---------|                             |---------|
          <-------建立双向邻居关系--------->
          <----协商主/从(Master/Slave)---->
          <---相互描述各自的LSDB(摘要信息)--->
          <-----更新LSA，同步双方LSDB------>
          计算路由                   计算路由
最后一步计算路由各自独立完成
```

### OSPF邻接关系建立流程

当一台OSPF路由器收到其他路由器发来的首个Hello报文时会从初始Down状态切换为Init状态。
当OSPF路由器收到的Hello报文中的邻居字段包含自己的RouterID时，从Init切换2-way状态



邻居状态机从2-way转为Exstart状态后开始主从关系选举:

- R1向R2发送的第一个DD报文内容为空，其Seq序列号假设为X。
- R2也向R1发出第一个DD报文，其Seq序列号假设为Y。
- 选举主从关系的规则是比较RouterID，越大越优。R2的RouterID比R1大，因此R2成为真正的主设备。主从关系比较结束后，R1的状态从Exstart转变为Exchange。

R1邻居状态变为Exchange后，R1发送一个新的DD报文，包含自己LSDB的描述信息，其序列号采用主设备R2的序列号。R2收到后邻居状态从Exstart转变为Exchange。

R2向R1发送一个新的DD报文，包含自己LSDB的描述信息，序列号为Y+1。

R1作为从路由器需要对主路由R2发送的每个DD报文进行确认，回复报文的序列号与主路由R2一致。

发送完最后一个DD报文后，R1将邻居状态切换为Loading。



邻居状态转变为Loading后，R1向R2发送LSR报文，请求那些在Exchange状态下通过DD报文发现的，但是在本地LSDB中没有的LSA。

R2收到后向R1回复LSU。在LSU报文中包含被请求的LSA的详细信息。R1收到LSU报文后，向R2回复LS ACK报文，确认已接收到，确保信息传输的可靠性。

此过程中R2也会向R1发送LSA请求。当两端LSDB完全一致时，邻居状态变为Full，表示成功建立邻接关系。

### OSPF邻居表回顾

```
Router ID:1.1.1.1                       Router ID:2.2.2.2
|---------|                             |---------|
|   R1    |-----------------------------|   R2    |
|---------|GE1/0/0               GE1/0/0|---------|
          10.1.1.1/30            10.1.1.2/30

<R1> display ospf peer
OSPF Process 1 with Router ID 1.1.1.1
  Neighbors
Area 0.0.0.0 interface 10.1.1.1(GigabitEthernet1/0/0)'s neighbors
Router ID:2.2.2.2 Address:10.1.1.2 GR State: Normal
  State: Full Mode:Nbr is Master Priority: 1
  DR: 10.1.1.1 BDR:10.1.1.2 MTU:0
  Dead timer due in 35 sec
  Retrans timer interval: 5
  Neighbor is up for 00:00:05
  Authentication Sequence: [ 0 ]
```

如上所示输入display ospf peer命令之后，各项参数含义如下

- OSPF Process 1 with Router ID 1.1.1.1:本地OSPF进程号为1与本端OSPF Router lD为1.1.1.1
- Router lD:邻居OSPF路由器ID
- Address:邻居接口地址
- GR State:使能OSPF GR功能后显示GR的状态(GR为优化功能)，默认为Normal
- State:邻居状态，正常情况下LSDB同步完成之后，稳定停留状态为Full
- Mode:用于标识本台设备在链路状态信息交互过程中的角色是Master还是Slave
- Priority:用于标识邻居路由器的优先级(该优先级用于后续DR角色选举）
- DR:指定路由器
- BDR:备份指定路由器
- MTU:邻居接口的MTU值
- Retrans timer interval:重传LSA的时间间隔，单位为秒
- Authentication Sequence:认证序列号

### OSPF网络类型简介

在学习DR和BDR的概念之前，需要首先了解OSPF的网络类型。

OSPF网络类型是一个非常重要的接口变量，这个变量将影响OSPF在接口上的操作，例如采用什么方式发送OSPF协议报文，以及是否需要选举DR、BDR等。

接口默认的OSPF网络类型取决于接口所使用的数据链路层封装。

如图所示，OSPF的有四种网络类型，Broadcast、NBMA、P2MP和P2P。

```
Router ID:1.1.1.1                       Router ID:2.2.2.2
|---------|                             |---------|
|   R1    |-----------------------------|   R2    |
|---------|GE1/0/0               GE1/0/0|---------|
          10.1.1.1/30            10.1.1.2/30

[R1-GigabitEthernet1/0/0] ospf network-type ?
broadcast  Specify OSPF broadcast network
nbma       Specify OSPF NBMA network
p2mp       Specify OSPF point-to-multipoint network
p2p        Specify OSPF point-to-point network
```

OSPF网络类型

一般情况下，链路两端的OSPF接口网络类型必须一致，否则双方无法建立邻居关系。

OSPF网络类型可以在接口下通过命令手动修改以适应不同网络场景，例如可以将BMA网络类型修改为P2P。

```
P2P(Point-to-Point，点对点)
|---------| Serial0/0/0    Serial0/0/0  |---------|
|   R1    |-----------------------------|   R2    |
|---------|  ppp                   ppp  |---------|
P2P指的是在一段链路上只能连接两台网络设备的环境。曲型的例子是PPP/HDLC链路。当接口采用PPP封装时，OSPF在该接口上采用的缺省网络类型为P2P。
组播224.0.0.5形式发送报文


BMA(Broadcast Multiple Access，广播式多路访问)
                                        |---------| 
                                        |   R2    |
                                       /|---------|
                                     /  GE0/0/0
                                   /
                                 /
|---------| GE1/0/0   |--------|
|   R1    |-----------|   SW   |
|---------| Ethernet  |--------|
                                 \
                                   \    
                                     \   GE0/0/0  
                                       \ |---------|
                                         |   R3    |
                                         |---------|
BMA也被称为Broadcast，指的是一个允许多台设备接入的、支持广播的环境。
典型的例子是Ethemmet(以太网)。当接口采用Ethemnet封装时，OSPF在该接口上采用的缺省网络类型为BMA。
组播发送Hello、LSU、LSAck报文，单播发送DD、LSR报文
DR、BDR使用224.0.0.6组播地址


NBMA(Non-Broadcast Multiple Access，非广播式多路访问)
|---------|                             |---------|
|   R1    |------   Frame-Relay   ------|   R2    |
|---------|                             |---------|
NBMA指的是一个允许多台网络设备接入且不支持广播的环境。
典型的例子是帧中继(Frame-Relay)网络和ATM。
单播发送报文


P2MP(Point to Multi-Point，点到多点)
                                        |---------| 
                                        |   R2    |
                                       /|---------|
                                     /
                                   /
                                 /
|---------|           |--------|
|   R1    |-----------|  Cloud |
|---------|           |--------|
                                 \
                                   \    
                                     \ 
                                       \ |---------|
                                         |   R3    |
                                         |---------|
P2MP相当于将多条P2P链路的一端进行捆绑得到的网络。
没有一种链路层协议会被缺省的认为是P2MP网络类型。该类型必须由其他网络类型手动更改。
常用做法是将非全连通的NBMA改为点到多点的网络。
组播224.0.0.5发送Hello报文，单播发送DD、LSR、LSU、LSAck报文
```

### DR与BDR的背景

MA(Multi-Access)多路访问网络有两种类型:广播型多路访问网络(BMA)及非广播型多路访问网络(NBMA)。以太网(Ethernet)是一种典型的广播型多路访问网络。

在MA网络中，如果每台OSPF路由器都与其他的所有路由器建立OSPF邻接关系，便会导致网络中存在过多的OSPF邻接关系，增加设备负担，也增加了网络中泛洪的OSPF报文数量。

当拓扑出现变更，网络中的LSA泛洪可能会造成带宽的浪费和设备资源的损耗。



为优化MA网络中OSPF邻接关系，OSPF指定了三种OSPF路由器身份，

- DR(Designated Router，指定路由器)
- BDR(Backup Designated Router，备用指定路由器)
- DRother路由器

只允许DR、BDR与其他OSPF路由器建立邻接关系。DRother之间不会建立全毗邻的OSPF邻接关系，双方停滞在2-way状态。

BDR会监控DR的状态，并在当前DR发生故障时接替其角色。DR/BDR监听224.0.0.6组播地址

 

选举规则:OSPF DR优先级更高的接口成为该MA的DR，如果优先级相等(默认为1)，则具有更高的OSPF Router-ID的路由器(的接口)被选举成DR，并且DR具有非抢占性。优先级为0不参与选举。



DR/BDR：全连接优化成星型连接



### OSPF域与单区域

OSPF域(Domain):一系列使用相同策略的连续OSPF网络设备所构成的网络。

OSPF路由器在同一个区域(Area)内网络中泛洪LSA。为了确保每台路由器都拥有对网络拓扑的一致认知，LSDB需要在区域内进行同步。

如果OSPF域仅有一个区域，随着网络规模越来越大，OSPF路由器的数量越来越多，这将导致诸多问题:

- LSDB越来越庞大，同时导致OSPF路由表规模增加。路由器资源消耗多设备性能下降，影响数据转发。
- 基于庞大的LSDB进行路由计算变得困难。
- 当网络拓扑变更时，LSA全域泛洪和全网SPF重计算带来巨大负担。

### OSPF多区域

OSPF引入区域(Area)的概念，将一个OSPF域划分成多个区域，可以使OSPF支撑更大规模组网。

OSPF多区域的设计减小了LSA泛洪的范围，有效的把拓扑变化的影响控制在区域内，达到网络优化的目的。

在区域边界可以做路由汇总，减小了路由表规模多区域提高了网络扩展性，有利于组建大规模的网络。

区域的分类:区域可以分为骨干区域与非骨干区域。骨干区域即Area0，除Area0以外其他区域都称为非骨干区域。

多区域互联原则:基于防止区域间环路的考虑，非骨干区域与非骨干区域不能直接相连所有非骨干区域必须与骨干区域相连。

### OSPF路由器类型

OSPF路由器根据其位置或功能不同，有这样几种类型:

- 区域内路由器(Internal Router)
- 区域边界路由器ABR(Area Border Router)
- 骨干路由器(Backbone Router)
- 自治系统边界路由器ASBR(AS Boundary Router)

区域内路由器(Internal Router):该类路由器的所有接口都属于同一个OSPF

区域区域边界路由器ABR(Area Border Router):该类路由器的接口同时属于两个以上的区域但至少有一个接口属于骨干区域。

骨干路由器(Backbone Router):该类路由器至少有一个接口属于骨干区域。

自治系统边界路由器ASBR(AS Boundary Router):该类路由器与其他AS交换路由信息。
只要一台OSPF路由器引入了外部路由的信息，它就成为ASBR。

### OSPF单区域&多区域典型组网

中小型企业网络规模不大，路由设备数量有限，可以考虑将所有设备都放在同一个OSPF区域。

大型企业网络规模大，路由设备数量很多，网络层次分明，建议采用OSPF多区域的方式部者。

## OSPF协议典型配置

### OSPF基础配置命令

1、(系统视图)创建并运行OSPF进程

```
[Huaweil ospf[ process-id|router-id router-id]
```

porcess-id用于标识OSPF进程，默认进程号为1。0SPF支持多进程，在同一台设备上可以运行多个不同的OSPF进程它们之间互不影响，彼此独立。router-id用于手工指定设备的ID号。如果没有通过命令指定ID号，系统会从当前接口的IP地址中自动选取一个作为设备的ID号。

Router ID的选择顺序是:优先从Loopback地址中选择最大的IP地址作为设备的ID号，如果没有配置Loopback接口，则在接口地址中选取最大的IP地址作为设备的ID号。



2、(OSPF视图)创建并进入OSPF区域

```
[Huawei-ospf-1] area area-id
```

area命令用来创建OSPF区域，并进入OSPF区域视图。

area-id可以是十进制整数或点分十进制格式。采取整数形式时，取值范围是0~4294967295。



3、(OSPF区域视图)指定运行OSPF的接口

```
[Huawei-ospf-1-area-0.0.0.0] network network-address wildcard-mask
```

network命令用来指定运行OSPF协议的接口和接口所属的区域。network-address为接口所在的网段地址。

wildcard-mask为IP地址的反码，相当于将IP地址的掩码反转(0变1，1变0)，例如0.0.0.255表示掩码长度24 bit。



4、(接口视图)配置OSPF接口开销

```
[Huawei-GigabitEthernet0/0/0] ospf cost cost
```

ospf cost命令用来配置接口上运行OSPF协议所需的开销。缺省情况下，OSPF会根据该接口的带宽自动计算其开销值cost取值范围是1~65535。



5、（OSPF视图)设置OSPF带宽参考值

```
[Huawei-ospf-1] bandwidth-reference value
```

bandwidth-reference命令用来设置通过公式计算接口开销所依据的带宽参考值。value取值范围是1~2147483648单位是Mbit/s，缺省值是100Mbit/s。



6、（接口视图)设置接口在选举DR时的优先级

```
[Huawei-GigabitEthernet0/0/0] ospf dr-priority priority
```

ospf dr-priority命令用来设置接口在选举DR时的优先级。priority值越大，优先级越高，取值范围是0~255。



### OSPF配置案例

案例描述:
有三台路由器R1、R2和R3，其中R1和R3分别连接网络1.1.1.1/32和3.3.3.3/32(LoopBack0模拟)，现需要使用OSPF实现这两个网络的互通。

配置过程分为三个步骤:配置设备接口、配置OSPF和验证结果。

配置接口

```
#配置R1的接口
[R1] interface LoopBack 0
[R1-LoopBack0] ip address 1.1.1.1 32
[R1-LoopBack0] interface GigabitEthernet 0/0/0
[R1-GigabitEthernet0/0/0] ip address 10.1.12.1 30

#配置R2的接口
[R2]interface GigabitEthernet 0/0/0
[R2-GigabitEthernet0/0/0] ip address 10.1.12.2 30
[R2-GigabitEthernet0/0/0] interface GigabitEthernet 0/0/1
[R2-GigabitEthernet0/0/1] ip address 10.1.23.1 30

#配置R3的接口
[R3] interface LoopBack 0
[R3-LoopBack0] ip address 3. 3.3.3 32
[R3-LoopBack0] interface GigabitEthernet 0/0/1
[R3-GigabitEthernet0/0/1] ip address 10.1.23.2 30
```

配置OSPF

```
#配置R1 OSPF协议
[R1] ospf 1 router-id 1.1.1.1
[R1-ospf-1] area 0
[R1-ospf-1-area-0.0.0.0] network 1.1.1.1 0.0.0.0
[R1-ospf-1-area-0.0.0.0] network 10.1.12.0 0.0.0.3

#配置R2 OSPF协议
[R2] ospf 1 router-id 2.2.2.2
[R2-ospf-1] area 0
[R2-ospf-1-area-0.0.0.0] network 10.1.12.0 0.0.0.3
[R2-ospf-1-area-0.0.0.0] area 1
[R2-ospf-1-area-0.0.0.1] network 10.1.23.0 0.0.0.3

#配置R3 OSPF协议
[R3] ospf 1 router-id 3.3.3.3
[R3-ospf-1] area 1
[R3-ospf-1-area-0.0.0.1] network 3.3.3. 3 0.0.0.0
[R3-ospf-1-area-0.0.0.1] network 10.1.23.0 0.0.0.3
```

结果验证

```
<R2> display ospf peer brief
        OSPF Process 1 with Router ID 2.2.2.2
             Peer Statistic information
-------------------------------------
Area ld    Interface               Neighbor id    State
0.0.0.0    GigabitEthernet0/0/0    1.1.1.1        Full
0.0.0.1    GigabitEthernet0/0/1    3.3.3.3        Full
--------------------------------------


<R1>display ip routing-table
Route Flags: R - relay, D - download to fib
-----------------------------------------------
Routing Tables: Public
Destinations :10  Routes :10
Destination/Mask Proto  Pre Cost Flags NextHop    Interface
1.1.1.1/32       Direct 0   0    D     127.0.0.1  LoopBack0
3.3.3.3/32       OSPF   10  2    D     10.1.12.0  GigabitEthemet 0/0/0 
10.1.12.0/30     Direct 0   0    D     10.1.12.2  GigabitEthemet 0/0/0

<R1>ping -a 1.1.1.1 3.3.3.3
PING 3.3.3.3: 56 data bytes, press CTRL C to break
Reply from 3.3.3.3: bytes=56 Sequence=1 tt=254 time=50 ms
...
```

## 思考题

1.(多选)在建立OSPF邻居和邻接关系的过程中，稳定的状态是(    )

A. Exstart

B. Two-way

C. Exchange

D. Full

2.(多选)以下哪种情况下路由器之间会建立邻接关系(    ）

A.点到点链路上的两台路由器

B.广播型网络中的DR和BDR

C.NBMA网络中的DRother和DRother

D.广播型网络中的BDR和DRother



1.BD

2.ABD
