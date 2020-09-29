+++
author = "zsjshao"
title = "SDN"
date = "2020-06-09"
tags = ["SDN"]
categories = ["RS"]

+++

# SDN概述

## 1、SDN产生背景

### 1.1、应用业务快速发展

![01_sdn](http://images.zsjshao.net/sdn/01_sdn.png)

![02_sdn](http://images.zsjshao.net/sdn/02_sdn.png)

![03_sdn](http://images.zsjshao.net/sdn/03_sdn.png)

![04_sdn](http://images.zsjshao.net/sdn/04_sdn.png)



### 1.2、传统网络瓶颈

- 网络架构20多年不变，网络协议20多年不变
- 网络服务质量
- 负载均衡
- TE 流量工程
- DPI 深度包检测

## 2、SDN定义

SDN(Software Defined Networking,软件定义网络）是一种数据控制分离、软件可编程的新型网络体系架构，其基本架构如下图所示。SDN釆用了集中式的控制平面和分布式的转发平面，两个平面相互分离，控制平面利用控制一转发通信接口对转发平面上的网络设备进行集中式控制，并提供灵活的可编程能力，具备以上特点的网络架构都可以被认为是一种广义的SDN。

![05_sdn](http://images.zsjshao.net/sdn/05_sdn.png)

在SDN架构中，控制平面通过控制一转发通信接口对网络设备进行集中控制，这部分控制信令的流量发生在控制器与网络设备之间，独立于终端间通信产生的数据流量，网络设备通过接收控制信令生成转发表，并据此决定数据流量的处理，不再需要使用复杂的分布式网络协议来进行数据转发，如下图所示。

![06_sdn](http://images.zsjshao.net/sdn/06_sdn.png)

## 3、SDN架构

![07_sdn](http://images.zsjshao.net/sdn/07_sdn.png)

数据平面

- 由若干网元（Network Element)构成，每个网元可以包含一个或多个SDN Datapath（数据路径）。每个SDN Datapath是一个逻辑上的网络设备，它没有控制能力，只是单纯用来转发和处理数据，它在逻辑上代表全部或部分的物理资源。一个SDN Datapath包含控制数据平面接口代理（Control-Data-Plane Interface Agent, CDPI Agent)、转发引擎表（Forwarding Engine)和处理功能模块（Processing Function)3 部分。

![08_sdn](http://images.zsjshao.net/sdn/08_sdn.png)

控制平面

- SDN控制器（SDN Controller), SDN控制器是一个逻辑上集中的实体，它主要负责两个任务，一是将SDN应用层请求转换到SDN Datapath, 二是为SDN应用提供底层网络的抽象模型（可以是状态、事件）。一个SDN控制器包含北向接口代理（Northbound Interfaces Agent,NBI Agent)、SDN控制逻辑(Control Logic)以及控制数据平面接口驱动（CDPI Driver) 3部分。SDN控制器只要求是逻辑上完整，因此它可以由多个控制器实例协同组成，也可以是层级式的控制器集群；从地理位置上来讲，既可以是所有控制器实例在同一位置，也可以是多个实例分散在不同的位置。

![09_sdn](http://images.zsjshao.net/sdn/09_sdn.png)

应用平面

- 由若干SDN应用（SDN Application)构成，SDN应用是用户关注的应用程序，它可以通过北向接口与SDN控制器进行交互，即这些应用能够通过可编程方式把需要请求的网络行为提交给控制器。一个SDN应用可以包含多个北向接口驱动（使用多种不同的北向API),同时SDN应用也可以对本身的功能进行抽象、封装来对外提供北向代理接口，封装后的接口就形成了更为高级的北向接口。

![10_sdn](http://images.zsjshao.net/sdn/10_sdn.png)

控制管理平面

- 该平面着重负责一系列静态的工作，这些工作比较适合在应用、控制、数据平面外实现，比如对网元进行配置、指定SDN Datapath的控制器，同时负责定义SDN控制器以及SDN应用能控制的范围。

![11_sdn](http://images.zsjshao.net/sdn/11_sdn.png)

## 4、SDN数控分离

数据和控制分离是SDN的核心思想之一。在传统的网络设备中，控制平面和数据平面在物理位置上是紧密耦合的。

优点：

- 有利于两个平面之间数据的快速交互
- 实现网络设备性能的提升

缺点：

- 管理非常困难，只能逐个配置，任何错误都可能导致管理行为失效
- 难以故障定位与排查
- 灵活性也不够，当网络设备需求的功能越来越复杂时，在分布式平面上进行新功能部署的难度非常大，例如数据中心这种变化较快、管控灵活的应用场景

为此，SDN以网络设备的FIB（转发信息库）表为界分割数据控制平面，其中交换设备只是一个轻量的、“哑”的数据平面，保留Fffi和高速交换转发能力，而上层的控制决策全部由远端的统一控制器节点完成，在这个节点上，网络管理员可以看到网络的全局信息，并根据该信息做出优化的决策，数据控制平面之间采用SDN南向接口协议相连接，这个协议将提供数据平面可编程性。

SDN的数据控制分离的特征主要体现在以下两个方面：

- 釆用逻辑集中控制，对数据平面釆用开放式接口
- 需要解决分布式的状态管理问题

一个逻辑上集中的控制器必须考虑冗余副本以防止控制器故障

为更加综合客观地评述SDN数据控制分离机制的优劣，再从时间维度去看待数据控制平面的分离。SDN的数据控制分离经历了两个阶段

- 在早期刚提出SDN 概念时，SDN的代表协议仅仅是OpenFlow，此时定义的数据控制分离就是将控制平面从网络设备中完全剥离，放置于一个远端的集中节点，这个定义并未在可实现性和性能上探讨过多，仅仅描绘了一个理想的模式：远端集中节点上的全局调度控制结合本地的快速转发，可以使网络智能充分提升，使网络功能的灵活性最大化。
- 接下来，随着SDN的影响力的增加，越来越多的传统网络设备提供商也加入SDN的研究阵营中，出于自身利益考虑，他们对SDN的数据控制分离有了新的解读：远端的集中控制节点是必要的，但是控制平面的完全剥离在实现上有难度, 因此，控制平面功能哪些在远端、哪些在本地，应该是SDN发展道路上需要研究的主要内容之一。

SDN数控分离的优点：

- 全局集中控制和分布高速转发
- 实现控制平面的全局优化
- 实现高性能的网络转发能力
- 灵活可编程与性能的平衡
- 开放性和IT化

SDN数控分离产生的需要解决的问题

- 可扩展性问题
- 一致性问题
- 可用性问题

## 5、SDN网络可编程

主动网络允许开发者把具体的代码下发到交换设备或者在数据分组中添加可执行代码来提供网络的编程性。而SDN的做法不同，它通过为开发者们提供强大的编程接口，从而使网络有了很好的编程能力。对上层应用的开发者来说，SDN的编程接口主要体现在北向接口上，北向接口提供了一系列丰富的API,开发者可以在此基础上设计自己的应用而不必关心底层的硬件细节，就像目前在x86体系的计算机上编程一样，不用关心底层寄存器、驱动等具体的细节。

- SDN南向接口用于控制器和转发设备建立双向会话，通过不同的南向接口协议，SDN控制器就可以兼容不同的硬件设备，同时可以在设备中实现上层应用的逻辑。
- SDN的东西向接口主要用于控制器集群内部控制器之间的通信，用于增强整个控制平面的可靠性、可用性、稳定性和可拓展性。

# Mininet应用实战

## 1、mininet概述

虽然可以利用Open vSwitch很方便地搭建一个真正的SDN环境，然而当网络规模较大时，这样做代价太大且费时费力，这时就需要一个强大的网络仿真工具。

传统的网络仿真平台或多或少存在着某些缺陷，难以准确地模拟网络实际状态且不具备交互特性，使得基于这些平台开发的代码不能直接部署到真实网络中。斯坦福大学Nick McKeown研究小组基于Linux Container架构，开发了Mininet这一轻量级的进程虚拟化网络仿真工具。Mininet最重要的一个特点是，它的所有代码几乎可以无缝迁移到真实的硬件环境，方便为网络添加新的功能并进行相关测试。

Mininet是一个可以在有限资源的普通电脑上快速建立大规模SDN原型系统的网络仿真工具。该系统由虚拟的终端节点（End-Host)、OpenFlow交换机、控制器（也支持远程控制器）组成，这使得它可以模拟真实网络，可对各种想法或网络协议等进行开发验证。

## 2、mininet系统架构

Mininet可以实现进程级别的虚拟化。其实现进程虚拟化主要是用到了Linux内核的namespace机制。Linux 从内核版本2.6.27开始支持

namespace机制。在Linux 正是因为Linux内核支持这种namespace机制，可以在Linux内核中创建虚拟主机和定制拓扑，这也是Mininet可以在一台电脑上可创建支持OpenFlow协议的软件定义网络的关键所在。

默认所有进程都在rootnamespace中，某个进程可以通过unshare系统调用拥有一个新的namespace,通过namespace机制可以虚拟化3类系统资源。

- 网络协议栈：通俗来讲，每个namespace都可以独自拥有一块网卡（可以是虚拟出来的），root namespace看到的就是物理网卡，不同namespace里的进程看到的网卡是不一样的。
- 进程表：简单来说，就是每个namespace中的第一个进程看到自己的PID是1,以为自己是系统中的第一个进程（实际是init)。同时，不同namespace中的进程之间是不可见的。
- 挂载表：不同namespace中看到文件系统挂载情况是不一样的。

基于上述namespace机制,Mininet架构按datapath的运行权限不同，分为kernel datapath和userspacedatapath两种，其中

- kernel datapath把分组转发的逻辑编译进入Linux内核，效率非常高；
- userspacedatapath把分组转发逻辑实现为一个应用程序，叫做ofdatapalh,效率虽不及kernel datapath,但更为灵活，更容易重新编译。

**kernel datapath**

控制器和交换机的网络接口都在root命名空间中，每个主机都在自己独立的命名空间里，这也就表明每个主机在自己的命名空间中都会有自己独立的虚拟网卡eth0。

![12_sdn](http://images.zsjshao.net/sdn/12_sdn.png)

**userspace datapath**

与kernel datapath架构不同，网络的每个节点都拥有自己独立的namespace。因为分组转发逻辑是实现在用户空间，所以多出了一个进程叫ofdatapath。另外，Mininet除了支持kernel datapath和userspacedatapath这两种架构以外，还支持OVS交换机。OVS充分利用内核的高效处理能力，它的性能和kernel datapath相差无几。

![13_sdn](http://images.zsjshao.net/sdn/13_sdn.png)

**Mininet特性**

Mininet作为一个轻量级的软件定义网络的研发与测试平台得到了学术界的广泛关注，其主要特性包括以下4个方面。

- 灵活性：可通过软件的方式简单、迅速地创建一个用户自定义的网络拓扑，缩短开发测试周期，支持系统级的还原测试，且提供Python API，简单易用。
- 可移植性：Mininet支持OpenFlow、OVS等软件定义网络部件，在Mininet上运行的代码可以轻松移植到支持OpenFlow的硬件设备上。
- 可扩展性：在一台电脑上模拟的网络规模可以轻松扩展到成百上千个节点。
- 真实性：模拟真实网络环境，运行实际的网络协议栈，实时管理和配置网络，可以运行真实的程序，在Linux上运行的程序基本上都可以在Mininet上运行，如Wireshark等

## 3、mininet代码解读

Mininet网络仿真工具主要基于Python语言，其代码主要可以分为两大部分：运行文件和Python库文件。

- 在库文件中Python对网络中元素进行抽象和实现，如定义主机类来表示网络中的一台主机；
- 然后运行文件则基于这些库完成模拟过程。

Mininet的源代码中的目录结构如下图所示。

![14_sdn](http://images.zsjshao.net/sdn/14_sdn.png)

| 目录     | 功用                             |
| -------- | -------------------------------- |
| bin      | 可执行文件                       |
| custom   | 自定义topo文件                   |
| debian   | debian系统相关文件存放路径       |
| doc      | 帮助文档                         |
| examples | python样例脚本文件，如可视化脚本 |
| mininet  | mininet的python库文件            |
| utils    | 工具目录                         |

## 4、mininet安装

系统版本环境

```
root@u1:~# cat /etc/os-release 
NAME="Ubuntu"
VERSION="18.04.4 LTS (Bionic Beaver)"
ID=ubuntu
ID_LIKE=debian
PRETTY_NAME="Ubuntu 18.04.4 LTS"
VERSION_ID="18.04"
HOME_URL="https://www.ubuntu.com/"
SUPPORT_URL="https://help.ubuntu.com/"
BUG_REPORT_URL="https://bugs.launchpad.net/ubuntu/"
PRIVACY_POLICY_URL="https://www.ubuntu.com/legal/terms-and-policies/privacy-policy"
VERSION_CODENAME=bionic
UBUNTU_CODENAME=bionic
```

Mininet主要有如下几种安装方式，下面介绍vm和源码安装方式。

官网站点：http://mininet.org/download/

![15_sdn](http://images.zsjshao.net/sdn/15_sdn.png)

### 4.1、Mininet虚拟机VM安装

下载Mininet的VM

下载后直接使用VirtualBox、VMware Workstations打开虚拟机。

VM运行之后，输入用户名和密码mininet进行登录后使用

### 4.2、源码安装

#### 4.2.1、下载源码

```
root@u1:~# git clone git://github.com/mininet/mininet
Cloning into 'mininet'...
remote: Enumerating objects: 9752, done.
remote: Total 9752 (delta 0), reused 0 (delta 0), pack-reused 9752
Receiving objects: 100% (9752/9752), 3.03 MiB | 9.00 KiB/s, done.
Resolving deltas: 100% (6472/6472), done.
```

#### 4.2.2、安装源码

获取Mininet源代码后即可安装Mininet,以下命令将安装MininetVM中的所有工具，包括Open vSwitch、Wireshark抓包工具和POX,默认情况下这些工具安装在用户的主目录（root目录）下。

```
root@u1:~# cd mininet/util/
root@u1:~/mininet/util# ./install.sh -a
```

#### 4.2.3、其他安装项

以下命令默认安装Mininet、user switch和OpenvSwitch：

```
root@u1:~# mininet/util/install.sh -nfv
```

将以下命令用在上述命令之前（即install.sh -s mydir-a/nfv)，可以将Mininet安装在指定的目录下，而不是默认主目录。

```
root@u1:~# mininet/util/install.sh -s mydir
```

#### 4.2.4、获取帮助

如果想了解更多工具安装的内容，使用：

```
root@u1:~# ./install.sh –h
```

这里我们采用-a的方式安装所有组件，安装之前确保yum源为系统默认的yum源，因为在安装过程中需要从互联网下载相应的依赖包

但是需要注意一点：

```
Install.sh currently only supports Ubuntu|Debian|Fedora|RedHat Enterprise Server|SUSE LINUX.
```

#### 4.2.5、测试

Mininet安装成功后，只需用如下命令即可启动简单的Mininet环境：

```
root@u1:~# mn
```

执行上述命令后，会创建默认的一个小型测试网络。经过短暂时间的等待即可进入以“mininet>”引导的命令行界面（CLI）。进入“mininet>”命令行界面后，默认拓扑将创建成功，即将拥有一个一台控制节点(Controller）、一台交换机（Switch）和两台主机（Host）的网络。

如果要删除当前的mininet网络环境，从mininet的CLI退出后使用命令sudo mn –c清空拓扑

#### 4.2.6、mininet使用

##### 4.2.6.1、控制器指定

--controller=CONTROLLER：指定控制器类型 default|none|nox|ovsc|ref|remote|ryu[,param=value...]

- 示例：

```
--controller=remote,ip=127.0.0.1,port=6653
指定控制器为远程主机，远程主机的IP地址为127.0.0.1，端口为6653
```

##### 4.2.6.2、拓扑设置

--topo=TOPO：指定拓扑类型 ，支持linear|minimal|reversed|single|torus|tree[,param=value  ...]

- linear,m,n
  - 创建的拓扑为线型拓扑，有m个交换机，每个交换机n个主机

- minimal
  - 创建的拓扑为最小拓扑，1个交换机，2个主机

- single,m
  - 创建的拓扑为星型拓扑，单交换机，m个主机

- reversed,m
  - 创建的拓扑为星型拓扑，单交换机，m个主机

- torus,m,n,z
  - 创建的拓扑为环型拓扑，m*n个交换机，每个交换机z个主机，m=n>3

- tree,m,n
  - 创建的拓扑为树形拓扑，树的深度为m，枝干树和枝干的叶子树为n

- 示例：

```
--topo=single,3
创建单交换机，3主机的拓扑类型
```

##### 4.2.6.3、自定义拓扑

--custom=CUSTOM：从指定的py文件中创建拓扑，read custom classes or params from .py file(s)

- leftHost = self.addHost( 'h1' )：添加主机
- leftSwitch = self.addSwitch( 's3' )：添加交换机
- self.addLink( leftHost, leftSwitch )：配置设备连接
- 示例：--custom=/home/mininet/mininet/custom/topo-2sw-2host.py

```
--custom=/home/mininet/mininet/custom/topo-2sw-2host.py
使用/home/mininet/mininet/custom/topo-2sw-2host.py文件创建拓扑
```

##### 4.2.6.4、交换机类型，OF协议版本指定

--switch=SWITCH：指定交换机类型， default|ivs|lxbr|ovs|ovsbr|ovsk|user[,param=value...]

- 示例

```
--switch=ovsk,protocols=OpenFlow13
使用ovsk交换机类型,OpenFlow1.3协议
```

##### 4.2.6.5、清理mn环境

-c, --clean：clean and exit，清理mininet并退出

##### 4.2.6.6、指定IP地址前缀

-i IPBASE, --ipbase=IPBASE：指定主机采用的网段

- 示例

```
-i 172.16.0.0/30
主机使用172.16.0.0/30网段的地址
```

##### 4.2.6.7、mac地址

--mac：mac地址从00:00:00:00:00:01开始

## 5、ODL安装

### 5.1、下载安装包distribution-karaf-0.6.0-Carbon.zip

百度网盘

- 链接：https://pan.baidu.com/s/1X2Q_bOsDdiarpnY3JvMk3g 
- 提取码：hjm9

### 5.2、安装unzip、openjdk

```
root@u1:~# apt install unzip openjdk-8-jdk -y
```

### 5.3、解压

```
root@u1:~# unzip distribution-karaf-0.6.0-Carbon.zip
```

### 5.4、重命名

```
root@u1:~# mv distribution-karaf-0.6.0-Carbon ODL
```

### 5.5、配置java环境变量

```
root@u1:~# cat > /etc/profile.d/java.sh << EOF
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
EOF

root@u1:~# source /etc/profile.d/java.sh
```

### 5.6、启动ODL

```
root@u1:~# ./ODL/bin/karaf 
Apache Karaf starting up. Press Enter to open the shell now...
100% [========================================================================]

Karaf started in 4s. Bundle stats: 64 active, 64 total
                                                                                           
    ________                       ________                .__  .__       .__     __       
    \_____  \ ______   ____   ____ \______ \ _____  ___.__.|  | |__| ____ |  |___/  |_     
     /   |   \\____ \_/ __ \ /    \ |    |  \\__  \<   |  ||  | |  |/ ___\|  |  \   __\    
    /    |    \  |_> >  ___/|   |  \|    `   \/ __ \\___  ||  |_|  / /_/  >   Y  \  |      
    \_______  /   __/ \___  >___|  /_______  (____  / ____||____/__\___  /|___|  /__|      
            \/|__|        \/     \/        \/     \/\/            /_____/      \/          
                                                                                           

Hit '<tab>' for a list of available commands
and '[cmd] --help' for help on a specific command.
Hit '<ctrl-d>' or type 'system:shutdown' or 'logout' to shutdown OpenDaylight.
```

### 5.7、安装插件

```
feature:install odl-restconf
feature:install odl-l2switch-switch-ui
feature:install odl-mdsal-apidocs
feature:install odl-dluxapps-applications
```

### 5.8、访问ODL web页面

![17_sdn](http://images.zsjshao.net/sdn/17_sdn.png)

## 6、mininet案例

### 6.1、背景

使用python脚本的方式创建如下层次化的拓扑，通过控制器实现交换机的管理，并测试网络的性能和带宽。

![16_sdn](http://images.zsjshao.net/sdn/16_sdn.png)

c1和c2为核心交换机，a1-a4为汇聚交换机，e1-e4为接入交换机，h1-h8为主机。本项目主要测试及验证交换机下挂主机间的连通性以及主机间通信收发数据包的速度。Mininet中自带的iperf性能测试工具可以测试不同主机间通信的性能带宽质量，在此例中，主要是对相同接入交换机下的主机间、相同汇聚交换机下不同接入交换机间、相同核心交换机不同汇聚交换机下的主机间进行测试。

### 6.2、拓扑脚本编辑

```
root@u1:~/mininet/custom# cat topo.py 
"""Custom topology example
Adding the 'topos' dictwith a key/value pair to generate our newly defined
topology enables one to pass in '--topo=mytopo' from the command line.
"""
from mininet.topo import Topo
from mininet.net import Mininet
from mininet.node import RemoteController,CPULimitedHost
from mininet.link import TCLink
from mininet.util import dumpNodeConnections

class MyTopo( Topo ):
    "Simple topology example."

    def __init__( self ):
        "Create custom topo."

        # Initialize topology
        Topo.__init__( self )

        L1 = 2
        L2 = L1 * 2
        L3 = L2
        c = []
        a = []
        e = []

        # add core ovs
        for i in range( L1 ):
            sw= self.addSwitch( 'c{}'.format( i+ 1 ) )
            c.append( sw)
        # add aggregation ovs
        for i in range( L2 ):
            sw= self.addSwitch( 'a{}'.format( L1 + i+ 1 ) )
            a.append( sw)
        # add edge ovs
        for i in range( L3 ):
            sw= self.addSwitch( 'e{}'.format( L1 + L2 + i+ 1 ) )
            e.append( sw)
        # add links between core and aggregation ovs
        for i in range( L1 ):
            sw1 = c[i]
            for sw2 in a[i/2::L1/2]:
                self.addLink(sw2, sw1, bw=1000, delay='10ms', loss=10, max_queue_size=1000, use_htb=True)
                #self.addLink( sw2, sw1 )

        # add links between aggregation and edge ovs
        for i in range( 0, L2, 2 ):
            for sw1 in a[i:i+2]:
                for sw2 in e[i:i+2]:
                    #self.addLink( sw2, sw1 )
                    self.addLink(sw2, sw1, bw=1000, delay='10ms', loss=10, max_queue_size=1000, use_htb=True)

        #add hosts and its links with edge ovs
        count = 1
        for sw1 in e:
            for i in range(2):
                host = self.addHost( 'h{}'.format( count ) )
                self.addLink( sw1, host )
                count += 1

topos= {'mytopo':(lambda:MyTopo())}
```

**注意缩进**，python对缩进有严格要求

### 6.3、创建拓扑

指定控制器为远程控制器，ip为127.0.0.1，使用ovsk交换机，OpenFlow1.3协议版本

```
root@u1:~/mininet/custom# mn --custom=./topo.py --topo=mytopo --controller=remote,ip=127.0.0.1 --switch ovsk,protocols=OpenFlow13
*** Creating network
*** Adding controller
Connecting to remote controller at 127.0.0.1:6653
*** Adding hosts:
h1 h2 h3 h4 h5 h6 h7 h8 
*** Adding switches:
a3 a4 a5 a6 c1 c2 e7 e8 e9 e10 
*** Adding links:
(a3, c1) (a3, c2) (a4, c1) (a4, c2) (a5, c1) (a5, c2) (a6, c1) (a6, c2) (e7, a3) (e7, a4) (e7, h1) (e7, h2) (e8, a3) (e8, a4) (e8, h3) (e8, h
4) (e9, a5) (e9, a6) (e9, h5) (e9, h6) (e10, a5) (e10, a6) (e10, h7) (e10, h8) *** Configuring hosts
h1 h2 h3 h4 h5 h6 h7 h8 
*** Starting controller
c0 
*** Starting 10 switches
a3 a4 a5 a6 c1 c2 e7 e8 e9 e10 ...
*** Starting CLI:
mininet> 
注意：只有管理员才有权限创建虚拟设备

# pingall ，ping通显示主机名，不通显示X
mininet> pingall
*** Ping: testing ping reachability
h1 -> X h3 h4 h5 h6 h7 h8 
h2 -> h1 h3 h4 h5 h6 h7 h8 
h3 -> h1 h2 h4 h5 h6 h7 h8 
h4 -> h1 h2 h3 h5 h6 h7 h8 
h5 -> h1 h2 h3 h4 h6 h7 h8 
h6 -> h1 h2 h3 h4 h5 h7 h8 
h7 -> h1 h2 h3 h4 h5 h6 h8 
h8 -> h1 h2 h3 h4 h5 h6 h7 
*** Results: 1% dropped (55/56 received)
mininet> 
```

### 6.4、查看拓扑

![18_sdn](http://images.zsjshao.net/sdn/18_sdn.png)

### 6.5、测试

链路带宽测试

```
mininet> iperf h4 h7
*** Iperf: testing TCP bandwidth between h4 and h7 
*** Results: ['4.80 Gbits/sec', '4.82 Gbits/sec']
```

在host上执行命令，如查看IP

- 用法：主机  命令

```
mininet> h1 ip add
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: h1-eth0@if82: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether 06:28:e8:90:89:15 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet 10.0.0.1/8 brd 10.255.255.255 scope global h1-eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::428:e8ff:fe90:8915/64 scope link 
       valid_lft forever preferred_lft forever
```

 