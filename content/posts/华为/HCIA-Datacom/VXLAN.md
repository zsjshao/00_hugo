## VXLAN

趋势

- 需要更大的迁移范围（大二层）

- 东西向（横向）流量无阻塞转发，充分利用网络链路资源

### VXLAN概念

- VXLAN（Virtual Extensible Lan，虚拟可扩展局域网）是由IETF定义的NVO3（Network Virtualization over Layer 3）标准技术之一，采用L2 over L4（MAC-in-UDP）的报文封装模式，将二层报文用三层协议进行封装，可实现二层网络在三层范围内进行扩展，同时满足数据中心大二层虚拟迁移和多租户的需求。

- Vxlan是一种无控制平面，利用底层IP网络实现二层通信的隧道技术。

- 底层的IP网络称为Underlay网络，Vxlan则称为OverLayer网络。

- VXLAN本质是隧道技术，也是一种网络虚拟化技术。

NVE

- 运行NVO3的设备叫做NVE（Network Virtualization Edge），它位于overlay网络的边界，实现二、三层的虚拟化功能。

VTEP

- VXLAN网络中的NVE以VTEP进行标识，VTEP（VXLAN Tunnel Endpoint，VXLAN隧道端点）
- 每一个NVE至少有一个VTEP，VTEP使用NVE的IP地址表示
- 两个VTEP可以确定一条VXLAN隧道，VTEP间的这条VXLAN隧道将被两个NVE间的所有VNI所公用。

VNI（VXLAN Network Identifier，VXLAN网络标识符）

- 类似于传统网络中的VLAN ID，用于区分VXLAN段，不同VXLAN段的租户不能直接进行二层通信。一个租户可以有一个或多个VNI，VNI由24比特组成，支持多达16M的租户。

广播域BD（Bridge Domain）

- 类似传统网络中采用VLAN划分广播域方法，在VXLAN网络中通过BD划分广播域。
- 在VXLAN网络中，将VNI以1:1方式映射到广播域BD，一个BD就表示着一个广播域，同一个BD内的主机就可以进行二层互通。

### VXLAN报文格式

![vxlan](https://download.huawei.com/mdl/image/download?uuid=3db2850c77ec4affa6246d58ff4d1451)

- MAC DA：目的MAC地址，为到达目的VTEP的路径上，下一跳设备的MAC地址。

- MAC SA：源MAC地址，发送报文的源端VTEP的MAC地址。

- 802.1Q Tag：可选字段，该字段为报文中携带的VLAN Tag。

- Ethernet Type：以太报文类型，IP协议报文中该字段取值为0x0800。

  

- IP SA：源IP地址，VXLAN隧道源端VTEP的IP地址。

- IP DA：目的IP地址，VXLAN隧道目的端VTEP的IP地址。

  

- DestPort：目的UDP端口号，设置为4789。

- Source Port：源UDP端口号。对于含有IP头的以太报文，源UDP端口号根据**ecmp load-balance**配置的因子进行HASH计算。对于不含IP头的以太报文，源UDP端口号根据报文的源MAC和目的MAC进行HASH计算得出。

  

- VXLAN Flags：标记位，8比特，取值为00001000。

- Group ID：用户组ID，16比特。当VXLAN Flags字段第一位取1时，该字段的值为Group ID。取0时，该字段的值为全0。

- VNI：VXLAN网络标识，用于区分VXLAN段，由24比特组成，支持多达16M的租户。一个租户可以有一个或多个VNI，不同VNI的租户之间不能直接进行二层相互通信。

- Reserved：保留未用，分别由8比特和8比特组成，设置为0

  

- Original Ethernet Frame：按照标准建议，报文进行VXLAN封装后，需要剥掉原始报文的VLAN TAG，即使不剥掉，在egress NVE也仅仅基于VNI转发（忽略原始报文的VLAN）。

### VXLAN接入方式

在VXLAN网络中，将VNI以1:1方式映射到广播域BD。当报文到达VTEP后，VTEP只要能够识别出报文所属的BD，就能够选择正确的VXLAN隧道进行转发。VTEP有两种方式识别报文所属的VXLAN。

#### 基于VLAN识别报文所属的VXLAN

基于网络规划，在VTEP上建立VLAN与BD的一对一或多对一的映射。这样，当VTEP收到业务侧报文后，根据VLAN与BD以及BD与VNI的对应关系即能够选择相应的VXLAN隧道进行转发。

#### 基于报文流封装类型识别报文所属的VXLAN

报文的流封装类型可概括地分为携带指定VLAN Tag与不携带VLAN Tag两种。基于此，在VTEP连接下行业务的物理接口上创建二层子接口，并配置二层子接口对报文的不同处理方式，同时将二层子接口与BD进行一一映射。这样业务侧报文到达VTEP后，即会进入指定的二层子接口。VTEP即能够根据二层子接口与BD的映射关系，以及BD与VNI的映射关系，选择正确的VXLAN隧道进行报文转发。

| 流封装类型  | 允许进入VXLAN隧道的报文类型                           | 对VXLAN报文进行封装处理                                     | 对VXLAN报文进行解封装处理                                    |
| ----------- | ----------------------------------------------------- | ----------------------------------------------------------- | ------------------------------------------------------------ |
| **dot1q**   | 只允许携带指定的一层VLAN Tag的报文进入VXLAN隧道。     | 进行VXLAN封装时，会剥离原始报文的VLAN Tag。                 | 进行VXLAN解封装后，会根据子接口上dot1q终结配置的vid为报文添加VLAN Tag，再转发。 |
| **untag**   | 只允许不携带VLAN Tag的报文进入VXLAN隧道。             | 进行VXLAN封装时，不对原始报文做处理，即不添加任何VLAN Tag。 | 进行VXLAN解封装后，不对报文做处理，包括VLAN Tag的添加、替换或剥离。 |
| **default** | 允许所有报文进入VXLAN隧道，不论报文是否携带VLAN Tag。 | 进行VXLAN封装时，不对原始报文做处理，包括添加、替换或剥离。 | 进行VXLAN解封装后，不对报文做处理，包括VLAN Tag的添加、替换或剥离。 |
| **qinq**    | 只允许带有指定的两层VLAN Tag的报文进入VXLAN隧道。     | 进行VXLAN封装时，会剥离原始报文的所有VLAN Tag。             | 进行VXLAN解封装后：X系列单板：根据子接口上QinQ终结配置的ce-vid和pe-vid为报文添加两层VLAN Tag，再转发。其他单板：若报文不带VLAN Tag，则先根据子接口上QinQ终结配置的ce-vid和pe-vid为报文添加两层VLAN Tag，再转发；若报文带VLAN Tag，则先剥掉外层VLAN Tag再根据子接口上QinQ终结配置的ce-vid和pe-vid为报文添加两层VLAN Tag，再转发。 |

### VXLAN隧道建立方式

VXLAN隧道由一对VTEP IP地址确定，报文在VTEP设备进行封装之后在VXLAN隧道中依靠路由进行传输。在进行VXLAN隧道的配置之后，只要VXLAN隧道的两端VTEP IP是三层路由可达的，VXLAN隧道就可以建立成功

根据VXLAN隧道的创建方式将VXLAN隧道分为以下两种：

- 静态隧道：通过用户手工配置本端和远端的VNI、VTEP IP地址和头端复制列表来完成。静态配置隧道的方式仅支持VXLAN集中式网关场景。具体过程请参见[静态方式部署集中式网关](https://support.huawei.com/enterprise/zh/doc/EDOC1100300875?section=j00d)。
- 动态隧道：通过BGP EVPN方式动态建立VXLAN隧道。在两端VTEP之间建立BGP EVPN对等体，然后对等体之间利用BGP EVPN路由来互相传递VNI和VTEP IP地址信息，从而实现动态建立的VXLAN隧道。通过BGP EVPN动态建立隧道的方式既支持VXLAN集中式网关场景，同时也支持VXLAN分布式网关场景。具体过程请依据网关的部署方式参见[BGP EVPN方式部署集中式网关](https://support.huawei.com/enterprise/zh/doc/EDOC1100300875?section=j00e)、[BGP EVPN方式部署分布式网关](https://support.huawei.com/enterprise/zh/doc/EDOC1100300875?section=j00f)。

### [BGP EVPN基本原理](https://support.huawei.com/enterprise/zh/doc/EDOC1100300875?section=j00a)

#### 介绍

EVPN（Ethernet Virtual Private Network）是一种用于二层网络互联的VPN技术。EVPN技术采用类似于BGP/MPLS IP VPN的机制，在BGP协议的基础上定义了一种新的网络层可达信息NLRI（Network Layer Reachability Information）即EVPN NLRI，EVPN NLRI定义了几种新的BGP EVPN路由类型，用于处在二层网络的不同站点之间的MAC地址学习和发布。

原有的VXLAN实现方案没有控制平面，是通过数据平面的流量泛洪进行VTEP发现和主机信息（包括IP地址、MAC地址、VNI、网关VTEP IP地址）学习的，这种方式导致VXLAN网络存在很多泛洪流量。为了解决这一问题，VXLAN引入了EVPN作为控制平面，通过在VTEP之间交换BGP EVPN路由实现VTEP的自动发现、主机信息相互通告等功能，从而避免了不必要的数据流量泛洪。

综上所述，EVPN通过扩展BGP协议新定义了几种BGP EVPN路由，这些BGP EVPN路由可以用于传递VTEP地址和主机信息，因此EVPN应用于VXLAN网络中，可以使VTEP发现和主机信息学习从数据平面转移到控制平面。

#### BGP EVPN路由

在EVPN NLRI中定义了如下几种应用于VXLAN控制平面的BGP EVPN路由类型：

**Type2路由——MAC/IP路由**

**Type3路由——Inclusive Multicast路由**

**Type5路由——IP前缀路由**

### 同网段互通（静态方式）

#### 拓扑



#### 配置

##### 基础网络配置

CE1

```
sysname CE1
interface GE1/0/0
 undo portswitch
 undo shutdown
 ip address 12.1.1.1 255.255.255.0
#
interface GE1/0/1
 undo portswitch
 undo shutdown
 ip address 13.1.1.1 255.255.255.0
#
interface LoopBack0
 ip address 1.1.1.1 255.255.255.255
#
ospf 1 router-id 1.1.1.1
 area 0.0.0.0
  network 1.1.1.1 0.0.0.0
  network 12.1.1.1 0.0.0.0
  network 13.1.1.1 0.0.0.0
```

CE2

```
sysname CE2
interface GE1/0/1
 undo portswitch
 undo shutdown
 ip address 12.1.1.2 255.255.255.0
#
interface LoopBack0
 ip address 2.2.2.2 255.255.255.255
#
ospf 1 router-id 2.2.2.2
 area 0.0.0.0
  network 2.2.2.2 0.0.0.0
  network 12.1.1.2 0.0.0.0
```

CE3

```
sysname CE3
interface GE1/0/1
 undo portswitch
 undo shutdown
 ip address 13.1.1.3 255.255.255.0
#
interface LoopBack0
 ip address 3.3.3.3 255.255.255.255
#
ospf 1 router-id 3.3.3.3
 area 0.0.0.0
  network 3.3.3.3 0.0.0.0
  network 13.1.1.3 0.0.0.0
```

CE4

```
sysname CE4
vlan batch 10
#
interface GE1/0/0
 undo shutdown
 port default vlan 10
#
interface GE1/0/1
 undo shutdown
 port link-type trunk
 port trunk allow-pass vlan 2 to 4094
```

CE5

```
sysname CE5
vlan batch 10
#
interface GE1/0/0
 undo shutdown
 port default vlan 10
#
interface GE1/0/1
 undo shutdown
 port link-type trunk
 port trunk allow-pass vlan 2 to 4094
```

VPC1

```
VPCS> ip 192.168.10.1/24
Checking for duplicate address...
VPCS : 192.168.10.1 255.255.255.0

VPCS> show

NAME   IP/MASK              GATEWAY                             GATEWAY
VPCS1  192.168.10.1/24      0.0.0.0
       fe80::250:79ff:fe66:6806/64
```

VPC2

```
VPCS> ip 192.168.10.2
Checking for duplicate address...
VPCS : 192.168.10.2 255.255.255.0

VPCS> show

NAME   IP/MASK              GATEWAY                             GATEWAY
VPCS1  192.168.10.2/24      0.0.0.0
       fe80::250:79ff:fe66:6807/64
```

##### VXLAN配置

CE2

```
bridge-domain 10
 vxlan vni 10
#
interface GE1/0/0
 undo shutdown
 port link-type trunk
#
interface GE1/0/0.1 mode l2
 encapsulation dot1q vid 10
 bridge-domain 10
#
interface Nve1
 source 2.2.2.2
 vni 10 head-end peer-list 3.3.3.3
```

CE3

```
bridge-domain 10
 vxlan vni 10
#
interface GE1/0/0
 undo shutdown
 port link-type trunk
#
interface GE1/0/0.1 mode l2
 encapsulation dot1q vid 10
 bridge-domain 10
#
interface Nve1
 source 3.3.3.3
 vni 10 head-end peer-list 2.2.2.2
```

#### 验证

```
[CE2]display vxlan vni
Number of vxlan vni : 1
VNI            BD-ID            State
---------------------------------------
10             10               up

[CE2]display vxlan tunnel
Number of vxlan tunnel : 1
Tunnel ID   Source                Destination           State  Type     Uptime
-----------------------------------------------------------------------------------
4026531841  2.2.2.2               3.3.3.3               up     static   00:55:48

VPCS> ping 192.168.10.2

84 bytes from 192.168.10.2 icmp_seq=1 ttl=64 time=6.584 ms
84 bytes from 192.168.10.2 icmp_seq=2 ttl=64 time=6.114 ms
84 bytes from 192.168.10.2 icmp_seq=3 ttl=64 time=7.095 ms
84 bytes from 192.168.10.2 icmp_seq=4 ttl=64 time=6.429 ms
84 bytes from 192.168.10.2 icmp_seq=5 ttl=64 time=6.543 ms
```

集中式网关跨网段互通（静态方式）

CE1配置

```
bridge-domain 10
 vxlan vni 10
#
interface Vbdif10
 ip address 192.168.10.254 255.255.255.0
#
interface Nve1
 source 1.1.1.1
 vni 10 head-end peer-list 2.2.2.2
 vni 10 head-end peer-list 3.3.3.3
```

CE2配置

```
interface Nve1
 source 2.2.2.2
 vni 10 head-end peer-list 1.1.1.1
```

CE3配置

```
interface Nve1
 source 3.3.3.3
 vni 10 head-end peer-list 1.1.1.1
```

