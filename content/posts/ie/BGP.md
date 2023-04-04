+++
author = "zsjshao"
title = "BGP"
date = "2023-04-04"
tags = ["BGP"]
categories = ["IE"]

+++


### AS

每一个自治系统都有一个AS号

AS号由internet地址授权委员会（IANA）统一负责分配

AS号取值范围：1-65535

- 1-64511（公有）
- 64512-65535（私有）

电信AS号：4134   4809     网通AS号：9929   4837         中国教育网：4538



BGP协议是一个用来在AS之间传递路由的协议



BGP特点

- 路径（距离）矢量路由协议  BGP路由有一个路径列表，中间记录了这条路由所经过的所有AS号，BGP路由器不会接受路径列表中包含其AS号的路由选择更新，这种机制也被称为EBGP的水平分割原则。用来防环。BGP传递的一条路径信息，其描述了通过这条路径所能到达的网络。
- hop-by-hop（AS-by-AS）逐跳路由选择模式，可以决定自己的数据流去往哪一个AS，但不能决定邻接的AS如何转发你的数据流

BGP使用场景

- 允许流量流过AS到达其他AS
- 连接多个AS
- 

BGP不适用场景

- 单链路出口
- 设备性能差





BGP特性：

- 可靠更新：使用TCP协议179端口，第一次做完整更新增量更新，触发更新，减少带宽占用
- 邻居无需直连，但需手工指定邻居：使用TCP连接
- 发送keepalive消息维持邻居关系
- 丰富的metrics（属性）值，也叫路径属性：11条基本的metrics，用于选路
- 设计用于特大网络：Internet

BGP的目的是提供一种域间路由选择系统，确保自主系统能够无环路的交换路由选择信息。BGP路由器交换有关前往目标网络的路径的信息



BGP三张表

- Neighbor table（邻居表）
- BGP table（转发数据库）
- IP routing table（路由表）



BGP消息（报文）类型

- Open（建立邻居关系）：hold time（180s）、BGP router ID
- Keepalive（维持邻居关系）：60s
- Update：包含路径信息（到达多个网络）
- Notification：error（如邻居关系出错）、主动关闭连接



邻居：

- 无需直连，需手工指定，TCP可达
- IBGP邻居关系（同AS）、EBGP邻居关系（不同AS）



BGP问题：

- BGP路由黑洞
  - 物理线路的Full Mesh
  - BGP重发布进IGP
  - AS内所有路由器都运行BGP
  - MPLS/VPN
- IBGP水平分割
  - Full Mesh
  - BGP‘s Partial Mesh（路由反射器/联邦）

管理距离

- IBGP 200
- EBGP 20



EBGP机制：

- EBGP跳数：默认TTL=1
- EBGP直连检测



peer-group

```
neighbor PG名 peer-group   #定义peer-group
neighbor PG名 remote AS号  #定义peer-group的命令
neighbor PG名 update-source lo0  #定义peer-group的命令

neighbor 邻居IP peer-group PG名   #调用peer-group
```



BGP邻居状态

- Idle：空闲状态，找路由去往邻居
- Connect：TCP三次握手
- active：活动 ，协商还未成功
- Open sent：发送Open报文，等5秒，active
- Open confirm：接收回应报文，检查报文，active
- Established：建立连接



BGP认证

```
neighbor 邻居IP password 密码
```

清除BGP会话

```
clear ip bgp *          #清除所有邻居
clear ip bgp 邻居IP      #清除指定邻居
clear ip bgp * soft     #软清除
clear ip bgp * soft in  #让邻居重新发送路由
clear ip bgp * soft out #重新发送路由给邻居
```

汇总

```
aggregate-address 汇总路由 掩码                            #传递汇总和明细路由
aggregate-address 汇总路由 掩码 summary-only               #summary-only，仅传递汇总路由，不传递明细
aggregate-address 汇总路由 掩码 as-set                     #保留原有明细路由的AS号（防环）
aggregate-address 汇总路由 掩码 attribute-map              #清除聚合路由的属性（除了as-path属性），添加自己需要添加的属性
aggregate-address 汇总路由 掩码 advertrise-map             #只对匹配的路由聚合，当明细路由消失时，聚合路由也消失

# 抑制指定路由
access-list 1 permit 网络
route-map WOLF
 match ip add 1
 exit
router bgp AS号
 aggregate-address 汇总路由 掩码 suppress-map WOLF
 neighbor 邻居IP unsuppress-map  # 过滤特定的路由
```

重分布/重发布

```
IGP->BGP
router bgp AS号
 redistribute ospf 进程号 match internal external nssa-external         #默认只重分布O、OIA的路由



BGP->IGP
bgp redistribute-internal             #默认只重分布EBGP路由
router ospf 进程号
redistribute
```

默认路由

```
方法一：
ip route 0.0.0.0 0.0.0.0 null 0
router bgp AS号
 network 0.0.0.0

方法二：
ip route 0.0.0.0 0.0.0.0 null 0
router bgp AS号
 redistribute static
 default-information originate

方法三：
router bgp AS号
 neighbor x.x.x.x default-originate

router bgp AS号
 neighbor x.x.x.x default-originate route-map xx

注意：在使用条件路由时，必须用prefix来匹配路由才行，ACL不行
```

路由反射器

```
router bgp AS号
 neighbor x.x.x.x route-reflector-client  # 配置路由反射器

从非客户端学习的路由，不会传递给其他非客户端
```

路由反射器的两个防环机制：

路由反射器会为自己反射出去的IBGP路由加上两个参数，一个是originator-id，一个是cluster-id

- originator-id：反射路由时将起源路由器的router-id作为originator-id放进路由中。originator-id用来防止一个路由器去学习自己发出的一条路由
- cluster-id：路由反射器和其客户的集合被称为集群（cluster），每一个集群都有一个cluster-id，默认情况下路由反射器的router-id会被用作cluster-id，也可以手工指定。cluster-id用于集群之间的防环。
- bgp cluster-id x.x.x.x



联邦

```
router bgp 小AS号
bgp router-id x.x.x.x
bgp confederation identifier 大AS号
bgp confederation peers 联邦中的其他小AS号

联邦内的边界路由器需要next-hop-self
```



BGP路径属性

- 公认强制的
  - AS路径（AS-path）
  - 下一跳（next-hop）
  - 源头（origin）
- 公认自由决定的
  - 本地优先级（local preferent）
- 可选传递的
  - 社团属性（community）
- 可选非传递的
  - MED

一条路由信息包含了一组属性，每一个属性由三个字段组成。

- 属性类型
- 属性长度
- 属性值



AS路径（AS-path）

- 经过的AS



BGP命令

```
router bgp AS号
 bgp router-id ID号                      #指定router-id
 neighbor 邻居IP remote 邻居AS号          #建立邻居
 neighbor 邻居IP next-hop-self          #IBGP边界路由器需修改路由下一跳为自身更新源，IBGP默认下一跳不变，EGBP改变，广播网络（同网段）IBGP下一跳不变
 neighbor 邻居IP update-source lo0        #指定lo0接口为更新源
 neighbor 邻居IP disable-connected-check  #EBGP非直连需要关闭直连检测
 neighbor 邻居IP ebgp-multihop 2          #修改跳数

 network 网络 mask 掩码               #必须先有路由且宣告的网络和掩码要与路由一致，会携带metric和next-hop信息
 no auto-summary
 no synchronization                     #同步，同步给邻居的路由必须要有对应的IGP路由，用于解决路由黑洞（现不好用），默认关闭


show ip bgp summary   #查看BGP邻居
show tcp brief        #查看TCP连接
```









debug ip packet：查看IP包

























