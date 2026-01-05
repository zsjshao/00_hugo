## 什么是VLAN

### 传统以太网的问题

在典型交换网络中，当某台主机发送一个广播帧或未知单播帧时，该数据帧会被泛洪，甚至传递到整个广播域。

广播域越大，产生的网络安全问题、垃圾流量问题就越严重。

交换机不隔离广播域

### 虚拟局域网(VLAN, Virtual LAN)

为了解决广播域带来的问题，人们引入了VLAN (Virtual Local Area Network)，即虚拟局域网技术:

- 通过在交换机上部署VLAN，可以将一个规模较大的广播域在逻辑上划分成若干个不同的、规模较小的广播域，由此可以有效地提升网络的安全性，同时减少垃圾流量，节约网络资源。

VLAN的特点:

- 一个VLAN就是一个广播域，所以在同一个VLAN内部，计算机可以直接进行二层通信;而不同VLAN内的计算机，无法直接进行二层通信，只能进行三层通信来传递信息，即广播报文被限制在一个VLAN内。
- VLAN的划分不受地域的限制。

VLAN的好处:

- 灵活构建虚拟工作组:用VLAN可以划分不同的用户到不同的工作组，同一工作组的用户也不必局限于某一固定的物理范围，网络构建和维护更方便灵活。
- 限制广播域:广播域被限制在一个VLAN内，节省了带宽，提高了网络处理能力。
- 增强局域网的安全性:不同VLAN内的报文在传输时是相互隔离的，即一个VLAN内的用户不能和其它VLAN内的用户直接通信。
- 提高了网络的健壮性:故障被限制在一个VLAN内，本VLAN内的故障不会影响其他VLAN的正常工作。

注:二层，即数据链路层。

## VLAN的基本原理

### VLAN标签(VLAN Tag)

IEEE 802.1Q协议规定，在以太网数据帧中加入4个字节的VLAN标签，又称VLAN Tag,简称Tag。

### VLAN数据帧

```
           +-----------+----------+--------+-----------+
           |   TPID    |   PRI    |  CFI   |    VID    |
           |  2 Bytes  |  3 Bits  | 1 Bits |  12 Bits  |
           +-----------+----------+--------+-----------+
           |                                           |
                |                                   |
                    |                          |
                        |              |
+-----------+-----------+--------------+---------------+------+-----------+----------+
|   DMAC    |   SMAC    |  802.1Q Tag  |  Length/Type  |       Data       |   FCS    |
|  6 Bytes  |  6 Bytes  |   4 Bytes    |    2 Bytes    |  Variable length | 4 Bytes  |
+-----------+-----------+--------------+---------------+------+-----------+----------+
|                                                                                    |
             |                                                                     |
                              |                                                 |
                                                    |                      |
+--------------------+-----------------+-------------+---------------------+
|        帧间隙       |      前同步码     |  帧开始定界符 |    Ethernet Frame   |
|    至少12Bytes      |    7 Bytes      |   1 Byte    |  Variable length    |
+--------------------+-----------------+-------------+---------------------+
```

在一个VLAN交换网络中，以太网帧主要有以下两种形式:

有标记帧(Tagged帧):IEEE802.1Q协议规定，在以太网数据帧的目的MAC地址和源MAC地址字段之后、协议类型字段之前加入4个字节的VLAN标签(又称VLAN Tag，简称Tag)的数据帧。
无标记帧( Untagged帧):原始的、未加入4字节VLAN标签的数据帧。

VLAN数据帧中的主要字段:

- TPID:2字节，Tag Protocolldentifier(标签协议标识符)，表示数据帧类型.
  - 取值为0x8100时表示IEEE802.1Q的VLAN数据帧。如果不支持802.1Q的设备收到这样的帧，会将其丢弃。
  - 各设备厂商可以自定义该字段的值。当邻居设备将TPID值配置为非0x8100时，为了能够识别这样的报文，实现互通，必须在本设备上修改TPID值，确保和邻居设备的TPID值配置一致。
- PRl:3 bit，Priority，表示数据帧的优先级，用于QoS。
  - 取值范围为0~7，值越大优先级越高。当网络阻塞时，交换机优先发送优先级高的数据帧。

- CFl:1bit，Canonical Format Indicator(标准格式指示位)，表示MAC地址在不同的传输介质中是否以标准格式进行封装，用于兼容以太网和令牌环网
  - CFI取值为0表示MAC地址以标准格式进行封装，为1表示以非标准格式封装。
  - 在以太网中，CFI的值为0。
- VID:12 bit，VLAN ID，表示该数据帧所属VLAN的编号。
  - VLAN ID取值范围是0~4095。由于0和4095为协议保留取值，所以VLAN ID的有效取值范围是1~4094。
  - 交换机利用VLAN标签中的VID来识别数据帧所属的VLAN，广播帧只在同VLAN内转发，这就将广播域限制在一个VLAN内。

如何识别带VLAN标签的数据帧:

- 数据帧的Length/Type=0x8100。

注意:计算机无法识别Tagged数据帧，因此计算机处理和发出的都是Untagged数据帧;为了提高处理效率，交换机内部处理的数据帧一律都是Tagged帧。

### VLAN的划分方式

计算机发出的数据帧不带任何标签。对已支持VLAN特性的交换机来说，当计算机发出的Untagged帧一旦进入交换机后，交换机必须通过某种划分原则把这个划分到某个特定的VLAN中去。

VLAN的划分包括如下5种方法:

- 基于接口划分:根据交换机的接口来划分VLAN。
  - 网络管理员预先给交换机的每个接口配置不同的PVID，当一个数据帧进入交换机时，如果没有带VLAN标签，该数据帧就会被打上接口指定PVID的标签，然后数据帧将在指定VLAN中传输。
- 基于MAC地址划分:根据数据帧的源MAC地址来划分VLAN。
  - 网络管理员预先配置MAC地址和VLANID映射关系表，当交换机收到的是Untagged帧时，就依据该表给数据帧添加指定VLAN的标签，然后数据帧将在指定VLAN中传输。
- 基于IP子网划分:根据数据帧中的源IP地址和子网掩码来划分VLAN。
  - 网络管理员预先配置IP地址和VLANID映射关系表，当交换机收到的是Untagged帧，就依据该表给数据帧添加指定VLAN的标签，然后数据将在指定VLAN中传输。
- 基于协议划分:根据数据帧所属的协议(族)类型及封装格式来划分VLAN。
  - 网络管理员预先配置以太网帧中的协议域和VLANID的映射关系表，如果收到的是Untagged帧，就依据该表给数据帧添加指定VLAN的标签，然后数据帧将在指定VLAN中传输。
- 基于策略划分:根据配置的策略划分VLAN，能实现多种组合的划分方式，包括接口、MAC地址、IP地址等。
  - 网络管理员预先配置策略，如果收到的是Untagged帧，且匹配配置的策略时给数据帧添加指定VLAN的标签，然后数据帧将在指定VLAN中传输。

### 基于接口的VLAN划分

划分原则:

- 将VLAN ID配置到交换机的物理接口上，从某一个物理接口进入交换机的、由终端计D算机发送的Untagged数据帧都被划分到该接口的VLANID所表明的那个VLAN。

特点:

- 这种划分原则简单而直观，实现容易，是目前实际的网络应用中最为广泛的划分VLAN的方式。
  当计算机接入交换机的端口发生了变化时，该计算机发送的帧的VLAN归属可能会发D生变化。

缺省VLAN，PVID(Port VLAN ID)

- 每个交换机的接口都应该配置一个PVID，到达这个端口的Untagged帧将一律被交换D机划分到PVID所指代的VLAN。
- 默认情况下，PVID的值为1。

### 以太网二层接口类型

Access接口

- 交换机上常用来连接用户PC、服务器等终端设备的接口。Access接口所连接的这些设备的网卡往往只收发无标记帧。Access接口只能加入一个VLAN。

Trunk接口

- Trunk接口允许多个VLAN的数据帧通过，这些数据帧通过802.1QTag实现区分。Trunk接口常用于交换机之间的互联，也用于连接路由器、防火墙等设备的子接口。

Hybrid接口

- Hybrid接口与Trunk接口类似，也允许多个VLAN的数据帧通过，这些数据帧通过802.1QTag实现区分。用户可以灵活指定Hybrid接口在发送某个(或某些)VLAN的数据帧时是否携带Tag。

华为设备默认的接口类型是Hybrid。



各类接口添加或剥除VLAN标签的处理过程总结如下:

- 当接收数据帧时:
  - 当接收到不带VLAN标签的数据帧时，Access接口、Trunk接口、Hybrid接口都会给数据帧打上VLAN标签，但Trunk接口、Hybrid接口会根据数据帧的VID是否为其允许通过的VLAN来判断是否接收，而Access接口则无条件接收。
  - 当接收到带VLAN标签的数据帧时，Access接口、Tmunk接口、Hybrid接口都会根据数据帧的VD是否为其允许通过的VLAN(Access接口允许通过的VLAN就是缺省VLAN)来判断是否接收。
- 当发送数据帧时:
  - Access接口直接剥离数据帧中的VLAN标签
  - Trunk接口只有在数据帧中的VID与接口的PVID相等时才会剥离数据帧中的VLAN标签。
  - Hybrid接口会根据接口上的配置判断是否剥离数据帧中的VLAN标签。

因此，Access接口发出的数据帧肯定不带Tag;Trunk接口发出的数据帧只有一个VLAN的数据帧不带Tag，其他都带VLAN标签;Hybrid接口发出的数据帧可根据需要设置某些VLAN的数据帧带Tag，某些VLAN的数据帧不带Tag。

## VLAN的配置示例

### VLAN的基础配置命令

创建VLAN

```
[Huawel] vlan vlan-id
```

通过此命令创建VLAN并进入VLAN视图，如果VLAN已存在，直接进入该VLAN的视图。
vlan-id是整数形式，取值范围是1~4094。

```
[Huawel] vlan batch { vlan-id1 [ to vlan-id2 ]}
```

通过此命令批量创建VLAN。其中:

- batch:指定批量创建的VLANID。
- vlan-id1:表示第一个VLAN的编号。
- vlan-id2:表示最后一个VLAN的编号。

查看vlan

```
[Huawel] display vlan
```

### Access接口的基础配置命令

配置接口类型

```
[Huawei-GigabitEthernet0/0/1] port link-type access
```

- 在接口视图下，配置接口的链路类型为Access。

配置Access接口的缺省VLAN

```
[Huawei-GigabitEthernet0/0/1] port default vlan vlan-id
或
[Huawei-vlan20] port GigabitEthernet0/0/1
```

在接口视图下，配置接口的缺省VLAN并同时加入这个VLAN。

- vlan-id:配置缺省VLAN的编号。整数形式，取值范围是1-4094。

### Trunk接口的基础配置命令

配置接口类型

```
[Huawei-GigabitEthernet0/0/1] port link-type trunk
```

- 在接口视图下，配置接口的链路类型为Trunk。

配置Trunk接口加入指定VLAN

```
[Huawei-GigabitEthernet0/0/1] port trunk allow-pass vlan {{ vlan-id1 [ to vlan-id2 ] }| all }
```

- 在接口视图下，配置Trunk类型接口加入的VLAN。

(可选)配置Trunk接口的缺省VLAN
```
[Huawei-GigabitEthernet0/0/1] port trunk pvid vlan vlan-id
```

- 在接口视图下，配置Trunk类型接口的缺省VLAN。

### Hybrid接口的基础配置命令

配置接口类型

```
[Huawei-GigabitEthernet0/0/1] port link-type hybrid
```

- 在接口视图下，配置接口的链路类型为Hybrid。

配置Hybrid接口加入指定VLAN

```
[Huawei-GigabitEthernet0/0/1] port hybrid untagged vlan { { vlan-id1 [ to vlan-id2 ] } | all }
```

- 在接口视图下，配置Hybrid类型接口加入的VLAN，这些VLAN的帧以Untagged方式通过接口。

```
[Huawei-GigabitEthernet0/0/1] port hybrid tagged vlan { { vlan-id1 [ to vlan-id2 ] } | all }
```

- 在接口视图下，配置Hybrid类型接口加入的VLAN，这些VLAN的帧以Tagged方式通过接口。

(可选)配置Hybrid接口的缺省VLAN

```
[Huawei-GigabitEthernet0/0/1] port hybrid pvid vlan vlan-id
```

- 在接口视图下，配置Hybrid类型接口的缺省VLAN。

### 基于MAC划分vlan

关联MAC地址与VLAN

```
[Huaweivlan10] macvlan mac-address mac-address [ mac-address-mask | mac-address-mask-length ]
```

通过此命令配置MAC地址与VLAN关联。

- mac-address:指定与VLAN关联的MAC地址。
  - 格式为H-H-H。其中H为4位的十六进制数，可以输入1~4位，如00e0、fc01。当输入不足4位时，表示前面的几位为0，如:输入e0，等同于00e0。
  - MAC地址不可设置为0000-0000-0000、FFFF-FFFF-FFFF和组播地址。
- mac-address-mask:指定MAC地址掩码。格式为H-H-H，其中H为1至4位的十六进制数。
- mac-address-mask-length:指定MAC地址掩码长度。整数形式，取值范围是1~48。

使能MAC地址与VLAN

```
[Huawei-GigabitEthernet0/0/1] mac-vlan enable
```

通过此命令使能接口的MAC VLAN功能。

查看mac-vlan

```
display mac-vlan { mac-address { all | mac-address[ mac-address-mask | mac-address-mask-length]} | vlan van-id 
```

## 思考题

1、(多选)下列关于VLAN的描述中，错误的是?()

A.VLAN技术可以将一个规模较大的冲突域隔离成若干个规模较小的冲突域

B.VLAN技术可以将一个规模较大的二层广播域隔离成若干个规模较小的二层广播域

C.位于不同VLAN的计算机之间无法进行通信

D.位于同一VLAN中的计算机之间可以进行二层通信

2、如果一个Trunk接口的PVID是5，且端口下配置port trunk alow-pass vlan 2 3，那么哪些VLAN的流量可以通过该Trunk接口进行传输?



1.AC 2.VLAN1,2,3