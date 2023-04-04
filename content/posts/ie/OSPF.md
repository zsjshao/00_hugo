+++
author = "zsjshao"
title = "OSPF"
date = "2023-04-04"
tags = ["OSPF"]
categories = ["IE"]

+++

### OSPF的基本特性

OSPF属于IGP，是Link-State协议，基于IP Pro 89

采用SPF算法（Dijkstra算法）计算最佳路径。

快速响应网络变化

比较低频率（每隔30分钟）发送定期更新，被称为链路状态刷新

网络变化时是触发更新

支持等价的负载均衡，默认4条

### OSPF三种表

邻居表

- hello包：10s，30s，40s

拓扑表：

- LSDB：同区域所有路由器LSDB一致

路由表：

- LSDB通过spf算法计算出的最佳路由

### 区域

核心区域（Transit area）：backbone or area 0

非核心区域（Regular areas）：nonbackbone areas



ABR：区域边界路由器

为啥非要有area 0区域：防环



区域划分的作用：

- 减少路由表条目数量
- 拓扑变更仅影响当前区域
- 减少LSA泛洪





OSPF Neighbor（邻居）：hello包正常收发就能形成邻居关系

OSPF Adjacencies（邻接）：

- 点对点：能形成邻居就能形成邻接
- 点对多点、广播网络：DR、BDR和DROther形成邻接关系，DROther之间处于two-way状态（邻居）

邻接之间才同步LSAs



DR选举：

- 比较接口优先级（默认为1）
- 比较Router ID，选大

BDR：



Router ID：

- 最大的物理接口IP地址。接口无须参加OSPF进程，但必须是活跃的（up）
- 优先使用环回口
- 使用命令router-id手工设置路由器ID（最优）



DR、BDR、Router ID具有非抢占性



### 链路成本

链路成本=10^8 / 带宽







LSA ：30分钟泛洪

LSDB

SPF





### LSA

**LSA1**

```
show ip ospf database router
```

特点：

- 域内路由，仅在本区域传递，不会穿越ABR。
- 每台路由器都会产生
- 包含本路由器的直连的邻居，以及直连接口的信息

Link ID：router ID

ADV router：router ID

三种信息：

- Another router
- stub network
- transit network（ma网络的一些信息）

**LSA2（Net Link States）**

```
show ip ospf database network
```

特点：

- 仅在本区域传递
- 只有MA网络才会产生LSA2，由DR发出
- 标识出本MA网络中有哪些路由器以及本网的掩码信息

Link ID： DR的接口IP

ADV router：DR的router ID

**LSA3（Summary Net Link States）**

```
show ip ospf database summary
```

特点：

- 域间路由，能泛洪到整个AS
- 由ABR发出，每穿越一个ABR，其ADV Router就会变成此ABR的Router-id
- 包含本区域中的路由信息，包括网络号和掩码

Link ID：路由Router（网络号）

ADV router：ABR的router ID（经过一个ABR，就会改为这个ABR的router ID）

三类LSA会被一个区域的边界ABR路由器重新产生并泛洪进下一个区域，所以每穿越一个ABR，其通告路由器就会发生改变。

**LSA4（Summary ASB Link States）**

```
show ip ospf database asbr-summary
```

特点：

- 把ASBR的Router-id传播到其他区域，让其他区域的路由器得知ASBR的位置。
- 由ABR产生并发出，穿越一个ABR，其ADV Router就会变成此ABR的Router-id

Link ID：ASBR的Router ID

ADV router：ABR的Router ID（经过一个ABR，就会改为这个ABR的router ID）

在ASBR直连的区域内，不会产生4类LSA，因为ASBR会发出一类的LSA，其中会指明自己是ASBR

**LSA5（Type-5 AS External Link States）**

```
show ip ospf database external
```

特点：

- 域外路由，不属于某个区域
- ASBR产生，泛洪到整个AS，不会改变ADV Router
- 包含域外的路由

Link ID：路由（网络号）

ADV Router：ASBR的router ID（unchange）

**LSA7（Type-7 AS External Link States）**

```
show ip ospf database nssa-external
```

特点：

- 特殊的域外路由，只存在于NSSA区域中。

Link ID：路由（网络号）

ADV router：ASBR的Router ID（只在NSSA区域中）

### OSPF的四种路径类型

域内路由

域间路由

E1的外部路由

E2的外部路由

外部路由重分布进OSPF有两种类型

OE1：重分布进OSPF的路由默认为E2，Cost=20，且传递过程中不改变COST。

OE2：如果改为E1类型，则在传输过程中会累加每个入接口的cost值

### OSPF的选路原则

1、域内路由优于域间路由

2、域间路由优于外部路由

3、OE1的路由优于OE2的路由

如果一台路由器收到两条相同的域间路由，一条是area 0 区域传过来的，一条是普通区域传过来的，则优选area 0区域传过来的。

如果有一台路由器从两个不同的ASBR收到相同的外部路由，OSPF在选择外部路由的时候，遵循的原则是：

【1】OE1优于OE2

【2】在类型相同的情况下，Cost越小越优先

【3】对OE2来说，在Cost相同的情况下，选择到达ASBR最优的路径

OE2的路由传递时带有一个参数--forward metric，这个参数记录了OE2的路由所穿越链路的总COST值，如果一个路由器收到两条COST相同的OE2路由，将比较它们的forward metric来选出最优路由。



```
router(config-router)#
max-lsa maximum-number
```

### Cost

修改接口开销值

```
Router（config-if）#
ip ospf cost interface-cost

ifterface-cost: 1-65535

ip ospf cost 20
```

修改计算公式分子

```
Router（config-router）#
auto-cost reference-bandwidth ref-bw

ref-bw: 默认为1*10^6

auto-cost reference-bandwidth 1000   #1000*10^6=10^9
```

### 路由汇总和默认路由注入

汇总位置：

- 域间路由汇总ABR
- 外部路由汇总ASBR

优点：

- 减少路由表条目数
- 降低拓扑变更的影响
- 减少3类和5类LSA的泛洪

域间路由汇总

```
Router（config-router）#
area AS range NET MASK [advertise] [cost] [not-advertise]

cost：开销值
advertise：默认值，传递汇总路由
not-advertise：不通告路由，包含汇总和明细的路由

area 1 range 172.16.0.0 255.255.0.0
```

外部路由汇总

```
Router（config-router）#
summary-address NET MASK
```

默认路由

```
Router（config-router）#
default-information originate always [metric 1] [metric-type 2]
```

### 特殊区域

在OSPF中共有四类特殊区域，都是用来对OSPF做优化的。可以减少一个区域中的LSA3和LSA5。

1、Stub

2、Totally Stub

3、NSSA

4、Totally NSSA

Stub

将某区域设为Stub可阻止LSA4/5进入Stub区域，缩小了区域内路由器的LSDB，降低内存消耗。



非正常连接区域



OSPF认证
