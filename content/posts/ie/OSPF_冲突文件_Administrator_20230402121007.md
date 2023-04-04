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



**LSA4（Summary Net Link States）**



**LSA5（External LSA）**





