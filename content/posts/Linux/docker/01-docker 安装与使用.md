+++
author = "zsjshao"
title = "01_docker 安装与使用"
date = "2020-04-26"
tags = ["docker"]
categories = ["容器"]

+++

# 一、什么是容器

## 1、简介：

容器是一种基础工具；泛指任何可以用于容纳其它物品的工具，可以部分或完全封闭，被用于容纳、储存、运输物品；物体可以被放置在容器中，而容器则可以保护内容物；

人类使用容器的历史至少有十万年，甚至可能有数百万年的历史；

容器的类型

```
ɝ 瓶 - 指口部比腹部窄小、颈长的容器。
ɝ 罐 - 指那些开口较大、一般为近圆筒形的器皿。
ɝ 箱 - 通常是立方体或圆柱体。形状固定。
ɝ 篮 - 以条状物编织而成。
ɝ 桶 - 一种圆柱形的容器。
ɝ 袋 - 柔性材料制成的容器，形状会受内容物而变化。
ɝ 瓮 - 通常是指陶制，口小肚大的容器。
ɝ 碗 - 用来盛载食物的容器。
ɝ 柜 - 指一个由盒组成的家俱。
ɝ 鞘 - 用于装载刀刃的容器。
```

一句话概括容器：容器就是将软件打包成标准化单元，以用于开发、交付和部署。

- 容器镜像是轻量的、可执行的独立软件包 ，包含软件运行所需的所有内容：代码、运行时环境、系统工具、系统库和设置。
- 容器化软件适用于基于Linux和Windows的应用，在任何环境中都能够始终如一地运行。
- 容器赋予了软件独立性，使其免受外在环境差异（例如，开发和预演环境的差异）的影响，从而有助于减少团队间在相同基础设施上运行不同软件时的冲突。

容器技术是虚拟化、云计算大数据之后的一门新兴的并且炙手可热的新技能，容器技术提高了硬件资源利用率、 方便了企业的业务快速横向扩容、 实现了业务宕机自愈功能 ，因此未来数年会是一个容器愈发流行的时代，这是一个对于IT行业来说非常有影响和价值的技术，而对于IT行业的从业者来说， 熟练掌握容器技术无疑是一个很有前景的行业工作机会。

容器技术最早出现在freebsd叫做jail 。

## 2、容器对比虚拟机：

```
                                                              +-----+------+------+------+
                               +------+------+------+-----+   |App A| App B| App C| App D|
+------+------+------+-----+   | App A| App B| App C|App D|   +-----+------+------+------+
| App A  App B  App C App D|   +------+------+------+-----+   |Guest| Guest| Guest| Guest|
+------+------+------+-----+   | Lib A| Lib B| Lib C|Lib D|   | OS0 |  OS1 | OS2  |  OS3 |
|+------------------------+|   +------+------+------+-----+   +-----+------+------+------+
||     Runtime Library    ||   |     Container Engine     |   |         Hypervisor       |
|+------------------------+|   +--------------------------+   +--------------------------+
||         Kernel         ||   |          Kernel          |   |          Kernel          |
|+------------------------+|   +--------------------------+   +--------------------------+
|     Operating System     |   |     Operating System     |   |     Operating System     |
+--------------------------+   +--------------------------+   +--------------------------+
| CPU | Memory | IO Device |   | CPU | Memory | IO Device |   | CPU | Memory | IO Device |
+--------------------------+   +--------------------------+   +--------------------------+
      Physical Machine                   Container                  Type II Hypervisor

+--------+---------------------+--------------+
|  特性  ||         容器        ||    虚拟机    |          
+--------+---------------------+--------------+
|  启动  ||        秒级         ||    分钟级    |
+--------+---------------------+--------------+
|  大小  ||      一般为MB       ||    一般为GB  |
+--------+---------------------+--------------+
|  性能  ||       接近原生      ||      弱于    |
+--------+---------------------+--------------+
|  数量  ||   单机支持上千个容器  ||   一般几十个  |
+--------+---------------------+--------------+

容器是一个应用层抽象，用于将代码和依赖资源打包在一起。 多个容器可以在同一台机器上运行，共享操作系统内核，但各自作为独立的进程在用户空间中运行 。与虚拟机相比， 容器占用的空间较少（容器镜像大小通常只有几十兆），瞬间就能完成启动 。
虚拟机（VM）是一个物理硬件层抽象，用于将一台服务器变成多台服务器。 管理程序允许多个VM在一台机器上运行。每个VM都包含一整套操作系统、一个或多个应用、必要的二进制文件和库资源，因此占用大量空间。而且VM启动也十分缓慢 。
```

使用虚拟机是为了更好的实现服务运行环境隔离，每个虚拟机都有独立的内核，虚拟化可以实现不同操作系统的虚拟机，但是通常一个虚拟机只运行一个服务，很明显资源利用率比较低且造成不必要的性能损耗，我们创建虚拟机的目的是为了运行应用程序，比如Nginx、PHP、Tomcat等web程序，使用虚拟机无疑带来了一些不必要的资源开销，但是容器技术则基于减少中间运行环节带来较大的性能提升。

## 3、Linux Namespace技术

linux内核提拱了6种namespace隔离的系统调用，如下图所示，但是真正的容器还需要处理许多其他工作。

|隔离类型|功能|系统调用参数|内核版本|
|---|---|---|---|
|MNT Namespace（mount）|提供磁盘挂载点和文件系统的隔离能力|CLONE_NEWNS|Linux 2.4.19|
|IPC Namespace(Inter-Process Communication)|提供进程间通信的隔离能力|CLONE_NEWIPC|Linux 2.6.19|
|UTS Namespace（UNIX Timesharing System|提供主机名与域名隔离能力|CLONE_NEWUTS|Linux 2.6.19|
|PID Namespace（Process Identification）|提供进程隔离能力|CLONE_NEWPID|Linux 2.6.24|
|Net Namespace（network）|提供网络隔离能力|CLONE_NEWNET|Linux 2.6.29|
|User Namespace（user）|提供用户隔离能力|CLONE_NEWUSER|Linux 3.8|

## 4、linux control groups

Linux Cgroup的全程是Linux Control Groups，它最主要的作用，就是限制一个进程组能够使用的资源上限，包括CPU、内存、磁盘、网络带宽等等。此外，还能够对进程进行优先级设置，以及将进程挂起和恢复等操作。

### 4.1、Cgroup在内核层默认以及开启

```
root@u1:~# grep CGROUP /boot/config-4.15.0-91-generic 
CONFIG_CGROUPS=y
CONFIG_BLK_CGROUP=y
# CONFIG_DEBUG_BLK_CGROUP is not set
CONFIG_CGROUP_WRITEBACK=y
CONFIG_CGROUP_SCHED=y
CONFIG_CGROUP_PIDS=y
CONFIG_CGROUP_RDMA=y
CONFIG_CGROUP_FREEZER=y
CONFIG_CGROUP_HUGETLB=y
CONFIG_CGROUP_DEVICE=y
CONFIG_CGROUP_CPUACCT=y
CONFIG_CGROUP_PERF=y
CONFIG_CGROUP_BPF=y
# CONFIG_CGROUP_DEBUG is not set
CONFIG_SOCK_CGROUP_DATA=y
CONFIG_NETFILTER_XT_MATCH_CGROUP=m
CONFIG_NET_CLS_CGROUP=m
CONFIG_CGROUP_NET_PRIO=y
CONFIG_CGROUP_NET_CLASSID=y
```

### 4.2、cgroup具体实现

```
ɝ blkio：块设备IO
ɝ cpu：CPU
ɝ cpuacct：CPU资源使用报告
ɝ cpuset：多处理器平台上的CPU集合
ɝ devices：设备访问
ɝ freezer：挂起或恢复任务
ɝ memory：内存用量及报告
ɝ ns：命名空间子系统
ɝ perf_event：对cgroup中的任务进行统一性能测试
ɝ net_cls：cgroup中的任务创建的数据报文的类别标识符
```

### 4.3、查看系统cgroups

```
root@u1:~# ll /sys/fs/cgroup/
total 0
drwxr-xr-x 15 root root 380 Mar 25 14:37 ./
drwxr-xr-x 10 root root   0 Mar 25 14:37 ../
dr-xr-xr-x  4 root root   0 Mar 25 14:37 blkio/
lrwxrwxrwx  1 root root  11 Mar 25 14:37 cpu -> cpu,cpuacct/
dr-xr-xr-x  4 root root   0 Mar 25 14:37 cpu,cpuacct/
lrwxrwxrwx  1 root root  11 Mar 25 14:37 cpuacct -> cpu,cpuacct/
dr-xr-xr-x  2 root root   0 Mar 25 14:37 cpuset/
dr-xr-xr-x  4 root root   0 Mar 25 14:37 devices/
dr-xr-xr-x  2 root root   0 Mar 25 14:37 freezer/
dr-xr-xr-x  2 root root   0 Mar 25 14:37 hugetlb/
dr-xr-xr-x  4 root root   0 Mar 25 14:37 memory/
lrwxrwxrwx  1 root root  16 Mar 25 14:37 net_cls -> net_cls,net_prio/
dr-xr-xr-x  2 root root   0 Mar 25 14:37 net_cls,net_prio/
lrwxrwxrwx  1 root root  16 Mar 25 14:37 net_prio -> net_cls,net_prio/
dr-xr-xr-x  2 root root   0 Mar 25 14:37 perf_event/
dr-xr-xr-x  4 root root   0 Mar 25 14:37 pids/
dr-xr-xr-x  2 root root   0 Mar 25 14:37 rdma/
dr-xr-xr-x  5 root root   0 Mar 25 14:37 systemd/
dr-xr-xr-x  5 root root   0 Mar 25 14:37 unified/
```

## 5、容器管理工具

目前主要使用docker，早期有使用lxc。

### 5.1、LXC

LXC：LXC为linux container的简写。可以提供轻量级的虚拟化，以便隔离进程和资源

官方网站：https://linuxcontainers.org/

### 5.2、pouch

https://www.infoq.cn/article/alibaba-pouch

https://github.com/alibaba/pouch

### 5.3、docker

#### 5.3.1、docker简介

Docker 是一个开放源代码软件项目，让应用程序部署在软件货柜下的工作可以自动化进行，借此在 Linux 操作系统上，提供一个额外的软件抽象层，以及操作系统层虚拟化的自动管理机制。 

- Docker是世界领先的软件容器平台。
- Docker使用Google公司推出的Go语言进行开发实现，基于Linux内核的cgroup，namespace，以及AUFS类的UnionFS等技术，对进程进行封装隔离，属于操作系统层面的虚拟化技术。 由于隔离的进程独立于宿主和其它的隔离的进程，因此也称其为容器。Docke最初实现是基于LXC。
- Docker能够自动执行重复性任务，例如搭建和配置开发环境，从而解放了开发人员以便他们专注在真正重要的事情上：构建杰出的软件。
- 用户可以方便地创建和使用容器，把自己的应用放入容器。容器还可以进行版本管理、复制、分享、修改，就像管理普通的代码一样。

#### 5.3.2、docker容器的特点

- 轻量，在一台机器上运行的多个Docker容器可以共享这台机器的操作系统内核；它们能够迅速启动，只需占用很少的计算和内存资源。镜像是通过文件系统层进行构造的，并共享一些公共文件。这样就能尽量降低磁盘用量，并能更快地下载镜像。
- 标准，Docker容器基于开放式标准，能够在所有主流Linux版本、Microsoft Windows以及包括VM、裸机服务器和云在内的任何基础设施上运行。
- 安全，Docker赋予应用的隔离性不仅限于彼此隔离，还独立于底层的基础设施。Docker默认提供最强的隔离，因此应用出现问题，也只是单个容器的问题，而不会波及到整台机器。

#### 5.3.3、docker的组成

https://docs.docker.com/engine/docker-overview/

docker主机（Host）：一个物理机或虚拟机，用于运行Docker服务进程和容器。

docker服务端（Server）：Docker守护进程，运行docker容器

docker客户端（Client）：客户端使用docker命令或其他工具调用docker API接口。

docker仓库（Registry）：保存镜像的仓库

docker镜像（Images）：镜像可以理解为创建实例使用的模板

docker容器（Container）：容器是从镜像生成对外提供服务的一个或一组服务。

官方仓库：https://hub.docker.com

![docker_01](http://images.zsjshao.cn/images/docker/docker_01.png)

#### 5.3.4、docker的优势

- 快速部署 ：短时间内可以部署成百上千个应用 ，更快速交付到线上 。
- 高效虚拟化 ：不需要额外的 hypervisor支持，直接基于linux实现应用虚拟化，相比虚拟机大幅提高性能和效率。
- 节省开支 ：提高服务器利用率，降低 IT支出
- 简化配置 ：将运行环境打包保存至容器，使用时直接启动即可。
- 快速迁移和扩展： 可跨平台运行在物理机、虚拟机、公有云等环境， 良好的兼容性可以方便将应用从A宿主机迁移到B宿主机 ，甚至是A平台迁移到B平 台。

#### 5.3.5、docker缺点

- 隔离性 ：各应用之间的隔离不如虚拟机彻底 。

#### 5.3.6、docker（容器）的核心技术

**容器规范**

- 除了docker之外的容器技术，还有coreOS的rkt，阿里的Pouch，为了保证容器生态的标准性和健康可持续发展，包括linux基金会、Docker、微软、红帽、谷歌和IBM等公司在2015年6月共同成立了一个叫open container（OCI）的组织，其目的就是制定开放的标准的容器规范，目前OCI一共发布了两个规范，分别是runtime spec和image format spec，有了这两个规范，不同的容器公司开发的容器只要兼容这两个规范，就可以保证容器的可移植性和相互可操作性。

**容器runtime：**

- runtime是真正运行容器的地方，因此为了运行不同的容器，runtime需要和操作系统内核紧密合作相互支持，以便为容器提供相应的运行环境。

目前主流的三种runtime：

- lxc：linux上早期的runtime，Docker早期就是采用lxc作为runtime。
- runc：目前docker默认的runtime，runc遵守OCI规范，因此可以兼容lxc。
- rkt：是CoreOS开发的容器runtime，也符号OCI规范，所以使用rktruntime也可以运行docker容器。

**容器管理工具**

- 管理工具连接runtime与用户，对用户提供图形或命令方式操作，然后管理工具将用户操作传递给runtime执行。
- lxc是lxd的管理工具
- runc的管理工具是docker engine，docker engine包含后台daemon和cli两部分，大家经常提到的docker就是指的docker engine。
- rkt的管理工具是rkt cli。

**容器定义工具**

- 容器定义工具允许用户定义容器的属性和内容，以方便容器能够被保存、共享和重建。
- docker image：是docker容器的模板，runtime依据docker image创建容器。
- dockerfile：包含N个命令的文本文件，通过dockerfile创建出docker image。
- ACI（App container image）：与docker image类似，是CoreOS开发的rkt容器的镜像格式。

**Registry**

- 统一保存镜像而且是多个不同镜像版本的地方，叫做镜像仓库。
- image registry：docker官方提供的私有仓库部署工具。
- docker hub：docker官方的公共仓库，已经保存了大量的常用镜像，可以方便大家直接使用。
- harbor：vmware提供的自带web界面自动认证功能的镜像仓库，目前有很多公司使用。

**编排工具**

- 容器编排通常包括容器管理、调度、集群定义和服务发现等功能。
- docker swarm：docker开发的容器编排引擎
- kubernetes：google领导开发的容器编排引擎，内部项目为Borg，且其同时支持docker和CoreOS。
- Mesos+Marathon：通用的集群组员调度平台，mesos（资源分配）与marathon（容器编排平台）一起提供容器编排引擎功能。

![docker_02](http://images.zsjshao.cn/images/docker/docker_02.png)

#### 5.3.7、docker（容器）的依赖技术

**容器网络**

- docker自带的网络docker network仅支持管理单机上的容器网络，当多主机运行的时候需要使用第三方开源网络，例如calico、flannel等。

**服务发现**

- 容器的动态扩容特性决定了容器IP也会随之变化，因此需要有一种机制开源自动识别并将用户请求动态转发到新创建的容器上，kubernetes自带服务发现功能，需要结合kube-dns服务解析内部域名。

**容器监控**

- 可以通过原生命令docker ps/top/stats查看容器的运行状态，另外也可以使用heapster/Prometheus等第三方监控工具监控容器的运行状态。

**数据管理**

- 容器的动态迁移会导致其在不通的Host之前迁移，因此如何保证与容器相关的数据也能随之迁移或随时访问，可以使用逻辑卷/存储挂载等方式解决。

**日志收集**

- docker原生的日志查看工具docker logs，但是容器内部的日志需要通过ELK等专门的日志收集分析和展示工具进行处理。

## 6、docker安装及基础命令介绍

官方地址：https://www.docker.com/

### 6.1、**系统版本选择**

docker目前已经支持多种操作系统的安装运行，比如[Ubuntu](https://ubuntu.com/)、CentOS、RedHat、Debian、Fedora，甚至还支持了Mac和Windows，在linux系统上需要内核版本在3.10或以上，docker版本号之前一直是0.X版本或1.X版本，但是从2017年3月1号开始改为每个季度发布一次稳定版，其版本号规则也统一变更为YY.MM，例如17.03表示是2017年9月份发布的。

### 6.2、**docker版本选择**

docker之前没有区分版本，但是2017年推出（将docker更名为）新的项目Moby，github地址：https://github.com/moby/moby ,Moby项目属于Docker项目的全新上游，Docker将是一个隶属于moby的子产品，而且之后的版本开始区分为CE版本（社区版本）和EE（企业收费版），CE社区版本和EE企业版本都是每个季度发布一个新版本，但是EE版本提供后期安全维护1年，而CE是4个月，以下为官方原文：https://www.docker.com/blog/docker-enterprise-edition/

Docker CE and EE are released quarterly, and CE also has a monthly “Edge” option. Each Docker EE release is supported and maintained for one year and receives security and critical bugfixes during that period. We are also improving Docker CE maintainability by maintaining each quarterly CE release for 4 months. That gets Docker CE users a new 1-month window to update from one version to the next.

### 6.3、安装docker

阿里：https://developer.aliyun.com/mirror/

```
# step 1: 安装必要的一些系统工具
sudo apt-get update
sudo apt-get -y install apt-transport-https ca-certificates curl software-properties-common
# step 2: 安装GPG证书
curl -fsSL https://mirrors.aliyun.com/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
# Step 3: 写入软件源信息
sudo add-apt-repository "deb [arch=amd64] https://mirrors.aliyun.com/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
# Step 4: 更新并安装Docker-CE
sudo apt-get -y update
sudo apt-get -y install docker-c

# 安装指定版本的Docker-CE:
# Step 1: 查找Docker-CE的版本:
# apt-cache madison docker-ce
#   docker-ce | 17.03.1~ce-0~ubuntu-xenial | https://mirrors.aliyun.com/docker-ce/linux/ubuntu xenial/stable amd64 Packages
#   docker-ce | 17.03.0~ce-0~ubuntu-xenial | https://mirrors.aliyun.com/docker-ce/linux/ubuntu xenial/stable amd64 Packages
# Step 2: 安装指定版本的Docker-CE: (VERSION例如上面的17.03.1~ce-0~ubuntu-xenial)
# sudo apt-get -y install docker-ce=[VERSION]
```

### 6.4、配置镜像加速

阿里：https://cr.console.aliyun.com/

```
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://jr0tl680.mirror.aliyuncs.com"]
}
EOF
sudo systemctl daemon-reload
sudo systemctl restart docker
```

### 6.5、验证docker版本

```
root@u1:~# docker version
Client: Docker Engine - Community
 Version:           19.03.8
 API version:       1.40
 Go version:        go1.12.17
 Git commit:        afacb8b7f0
 Built:             Wed Mar 11 01:25:46 2020
 OS/Arch:           linux/amd64
 Experimental:      false

Server: Docker Engine - Community
 Engine:
  Version:          19.03.8
  API version:      1.40 (minimum version 1.12)
  Go version:       go1.12.17
  Git commit:       afacb8b7f0
  Built:            Wed Mar 11 01:24:19 2020
  OS/Arch:          linux/amd64
  Experimental:     false
 containerd:
  Version:          1.2.13
  GitCommit:        7ad184331fa3e55e52b890ea95e65ba581ae3429
 runc:
  Version:          1.0.0-rc10
  GitCommit:        dc9208a3303feef5b3839f4323d9beb36df0a9dd
 docker-init:
  Version:          0.18.0
  GitCommit:        fec3683
```

### 6.6、验证docker信息

```
root@u1:~# docker info
Client:
 Debug Mode: false

Server:
 Containers: 5
  Running: 0
  Paused: 0
  Stopped: 5
 Images: 2
 Server Version: 19.03.8
 Storage Driver: overlay2
  Backing Filesystem: <unknown>
  Supports d_type: true
  Native Overlay Diff: true
 Logging Driver: json-file
 Cgroup Driver: cgroupfs
 Plugins:
  Volume: local
  Network: bridge host ipvlan macvlan null overlay
  Log: awslogs fluentd gcplogs gelf journald json-file local logentries splunk syslog
 Swarm: inactive
 Runtimes: runc
 Default Runtime: runc
 Init Binary: docker-init
 containerd version: 7ad184331fa3e55e52b890ea95e65ba581ae3429
 runc version: dc9208a3303feef5b3839f4323d9beb36df0a9dd
 init version: fec3683
 Security Options:
  apparmor
  seccomp
   Profile: default
 Kernel Version: 4.15.0-91-generic
 Operating System: Ubuntu 18.04.4 LTS
 OSType: linux
 Architecture: x86_64
 CPUs: 4
 Total Memory: 3.83GiB
 Name: u1.zsjshao.net
 ID: OGUG:UZEH:ZUVW:3TYE:NN67:D6E5:LF2B:BPWS:MMGF:EXNP:GSY5:2A2G
 Docker Root Dir: /var/lib/docker
 Debug Mode: false
 Registry: https://index.docker.io/v1/
 Labels:
 Experimental: false
 Insecure Registries:
  127.0.0.0/8
 Registry Mirrors:
  https://jr0tl680.mirror.aliyuncs.com/
 Live Restore Enabled: false
```

### 6.7、docker存储引擎

目前docker的默认存储引擎为overlay2，需要磁盘分区支持d-type文件分层功能，因此需要系统磁盘的额外支持。

官方文档关于存储引擎的选择文档：

https://docs.docker.com/storage/storagedriver/select-storage-driver/

docker官方推荐首选存储引擎为overlay2，其次为devicemapper，后续将统一使用overlay2存储引擎。

https://www.cnblogs.com/youruncloud/p/5736718.html

使用xfs文件系统需要在格式化是使用-n ftype=1，否则后期在启动容器的时候会报错不支持d-type

```
[root@c71 ~]# xfs_info /
meta-data=/dev/mapper/centos-root isize=512    agcount=4, agsize=12943104 blks
         =                       sectsz=512   attr=2, projid32bit=1
         =                       crc=1        finobt=0 spinodes=0
data     =                       bsize=4096   blocks=51772416, imaxpct=25
         =                       sunit=0      swidth=0 blks
naming   =version 2              bsize=4096   ascii-ci=0 ftype=1
log      =internal               bsize=4096   blocks=25279, version=2
         =                       sectsz=512   sunit=0 blks, lazy-count=1
realtime =none                   extsz=4096   blocks=0, rtextents=0
```

### 6.8、docker服务进程

```
root@u1:~# pstree -p 1
systemd(1)─┬─VGAuthService(681)
           ├─accounts-daemon(994)─┬─{accounts-daemon}(1019)
           │                      └─{accounts-daemon}(1046)
           ├─agetty(1258)
           ├─atd(1083)
           ├─containerd(1165)─┬─containerd-shim(2927)─┬─nginx(2951)───nginx(2993)
           │                  │                       ├─{containerd-shim}(2928)
           │                  │                       ├─{containerd-shim}(2929)
           │                  │                       ├─{containerd-shim}(2930)
           │                  │                       ├─{containerd-shim}(2931)
           │                  │                       ├─{containerd-shim}(2932)
           │                  │                       ├─{containerd-shim}(2933)
           │                  │                       ├─{containerd-shim}(2984)
           │                  │                       ├─{containerd-shim}(2985)
           │                  │                       └─{containerd-shim}(2986)
           │                  ├─containerd-shim(3194)─┬─nginx(3220)───nginx(3261)
           │                  │                       ├─{containerd-shim}(3195)
           │                  │                       ├─{containerd-shim}(3196)
           │                  │                       ├─{containerd-shim}(3197)
           │                  │                       ├─{containerd-shim}(3198)
           │                  │                       ├─{containerd-shim}(3199)
           │                  │                       ├─{containerd-shim}(3200)
           │                  │                       ├─{containerd-shim}(3202)
           │                  │                       ├─{containerd-shim}(3203)
           │                  │                       └─{containerd-shim}(3254)
           │                  ├─containerd-shim(3306)─┬─nginx(3330)───nginx(3375)
           │                  │                       ├─{containerd-shim}(3307)
           │                  │                       ├─{containerd-shim}(3308)
           │                  │                       ├─{containerd-shim}(3309)
           │                  │                       ├─{containerd-shim}(3310)
           │                  │                       ├─{containerd-shim}(3311)
           │                  │                       ├─{containerd-shim}(3312)
           │                  │                       ├─{containerd-shim}(3314)
           │                  │                       ├─{containerd-shim}(3365)
           │                  │                       └─{containerd-shim}(3366)
           │                  ├─{containerd}(1333)
           │                  ├─{containerd}(1334)
           │                  ├─{containerd}(1335)
           │                  ├─{containerd}(1337)
           │                  ├─{containerd}(1389)
           │                  ├─{containerd}(1390)
           │                  ├─{containerd}(1391)
           │                  ├─{containerd}(1392)
           │                  ├─{containerd}(1422)
           │                  ├─{containerd}(1423)
           │                  ├─{containerd}(1424)
           │                  ├─{containerd}(1429)
           │                  ├─{containerd}(2646)
           │                  ├─{containerd}(3088)
           │                  └─{containerd}(3265)
           ├─cron(1071)
           ├─dbus-daemon(998)
           ├─dockerd(1183)─┬─docker-proxy(3185)─┬─{docker-proxy}(3186)
           │               │                    ├─{docker-proxy}(3187)
           │               │                    ├─{docker-proxy}(3188)
           │               │                    ├─{docker-proxy}(3189)
           │               │                    ├─{docker-proxy}(3190)
           │               │                    ├─{docker-proxy}(3191)
           │               │                    ├─{docker-proxy}(3192)
           │               │                    └─{docker-proxy}(3193)
           │               ├─docker-proxy(3298)─┬─{docker-proxy}(3299)
           │               │                    ├─{docker-proxy}(3300)
           │               │                    ├─{docker-proxy}(3301)
           │               │                    ├─{docker-proxy}(3302)
           │               │                    ├─{docker-proxy}(3303)
           │               │                    ├─{docker-proxy}(3304)
           │               │                    └─{docker-proxy}(3305)
           │               ├─{dockerd}(1346)
           │               ├─{dockerd}(1347)
           │               ├─{dockerd}(1349)
           │               ├─{dockerd}(1350)
           │               ├─{dockerd}(1351)
           │               ├─{dockerd}(1361)
           │               ├─{dockerd}(1385)
           │               ├─{dockerd}(1412)
           │               ├─{dockerd}(1425)
           │               ├─{dockerd}(1432)
           │               ├─{dockerd}(1433)
           │               ├─{dockerd}(1434)
           │               ├─{dockerd}(1513)
           │               ├─{dockerd}(1514)
           │               └─{dockerd}(1523)
```

dockerd：被client直接访问，其父进程为宿主机的systemd守护进程

docker-proxy：实现容器通信，其父进程为dockerd

containerd：被dockerd进程调用以实现与runc交互

containerd-shim：真正运行容器的载体，其其父进程为containerd。

```
root@u1:~# ps -ef | grep containerd
root       1165      1  0 14:37 ?        00:00:01 /usr/bin/containerd
root       1183      1  0 14:37 ?        00:00:01 /usr/bin/dockerd -H fd:// --containerd=/run/containerd/containerd.sock
root       2927   1165  0 16:14 ?        00:00:00 containerd-shim -namespace moby -workdir /var/lib/containerd/io.containerd.runtime.v1.linux/moby/85c7579e2de85718e0fb01da52ef85ccd3d8e56a942cb32a1917ec8954500cbf -address /run/containerd/containerd.sock -containerd-binary /usr/bin/containerd -runtime-root /var/run/docker/runtime-runc
root       3194   1165  0 16:20 ?        00:00:00 containerd-shim -namespace moby -workdir /var/lib/containerd/io.containerd.runtime.v1.linux/moby/6f4e9f1b8ab5f913db3a0be1c252749e0709425fe959db9209aba3acf0ef3c19 -address /run/containerd/containerd.sock -containerd-binary /usr/bin/containerd -runtime-root /var/run/docker/runtime-runc
root       3306   1165  0 16:22 ?        00:00:00 containerd-shim -namespace moby -workdir /var/lib/containerd/io.containerd.runtime.v1.linux/moby/2b6fa1d5a51a90003267299151931edefba56f1e0beb186da6c729175bd6069c -address /run/containerd/containerd.sock -containerd-binary /usr/bin/containerd -runtime-root /var/run/docker/runtime-runc
```

#### 6.8.1、containerd-shim命令使用

```
root@u1:~# containerd-shim -h
Usage of containerd-shim:
  -address string
    	grpc address back to main containerd
  -containerd-binary containerd publish
    	path to containerd binary (used for containerd publish) (default "containerd")
  -criu string
    	path to criu binary
  -debug
    	enable debug output in logs
  -namespace string
    	namespace that owns the shim
  -runtime-root string
    	root directory for the runtime (default "/run/containerd/runc")
  -socket string
    	abstract socket path to serve
  -systemd-cgroup
    	set runtime to use systemd-cgroup
  -workdir string
    	path used to storge large temporary data
```

#### 6.8.2、容器的创建与管理过程：

通信流程

- 1、docker通过grpc和containerd模块通信，dockerd由libcontainerd负责和containerd进行交换，dockerd和containerd通信socket文件：/run/containerd/containerd.sock。
- 2、containerd在dockerd启动时被启动，然后containerd启动grpc请求监听，containerd处理grpc请求，根据请求做相应动作。
- 3、若是start或是exec容器，containerd拉起一个container-shim，并进行相应的操作。
- 4、containerd-shim被拉起后，start/exec/create拉起runC进程，通过exit、control文件和containerd通信，通过父子进程关系和SIGCHLD监控容器中进程状态。
- 5、在整个容器生命周期中，containerd通过epoll监控容器文件，监控容器事件。

![docker_03](http://images.zsjshao.cn/images/docker/docker_03.png)

#### 6.8.3、grpc简介

grpc是google开发的一款高性能、开源和通用的RPC框架，支持众多语言客户端。

![docker_04](http://images.zsjshao.cn/images/docker/docker_04.png)

### 6.9、docker镜像管理

docker镜像含有启动容器所需要的文件系统及所需要的文件内容， 因此镜像主要用于创建并启动docker容器。

docker镜像里面是一层层文件系统，叫做Union FS（联合文件系统），联合文件系统可以将几层目录挂载到一起，形成一个虚拟文件系统，虚拟文件系统的目录结构就像普通linux的目录结构一样，docker通过这些文件再加上宿主机的内核提供了一个linux的虚拟环境，每一层文件系统叫做一层layer，联合文件系统可以对每一层文件系统设置三种权限，只读（readonly）、读写（readwrite）和写出（writeout-able），但是docker镜像中每一层文件系统都是只读的，构建镜像的时候，从一个最基本的操作系统开始，每个构建的操作都相当于做一层的修改，增加了一层文件系统，一层层往上叠加，上层的修改会覆盖底层该位置的可见性，当使用镜像的时候，我们只会看到一个完整的整体，不知道里面有几层也不需要知道里面有几层，结构如下：

![docker_05](http://images.zsjshao.cn/images/docker/docker_05.png)

一个典型的linux文件系统由bootfs和rootfs两部分组成，bootfs（boot file system）主页包含bootloader和kernel，bootloader主要用于引导加载kernel，当kernel别加载到内存后bootfs会被umount掉，rootfs（root file system）包含的就是典型的linux系统中的/dev、/proc、/bin、/etc等标准目录和文件，下图就是docker image中最基础的两层结构，不同的linux发行版（如ubuntu和CentOS）在rootfs这一层会有所区别。

![docker_06](http://images.zsjshao.cn/images/docker/docker_06.png)

docker镜像通常都比较小，官方提供的centos基础镜像在200MB左右，一些其他版本的镜像甚至只有几MB，docker镜像直接调用宿主机的内核，镜像中只提供rootfs，也就是只需要包括最基本的命令、工具和程序库就可以了，比如alpine镜像在5M左右。

### 6.10、docker命令

官方文档：https://docs.docker.com/engine/reference/commandline/docker/

docker命令是最常使用的docker客户端命令，在后面可以加不同的参数以实现相应的功能，常用命令如下：

```
docker search：Search the Docker Hub for images

image相关的命令
docker image --help

docker pull：Pull an image or a repository from a registry
docker images：List images
docker rmi：Remove one or more images

container相关的命令
docker container --help

docker create：Create a new container
docker start：Start one or more stopped containers
docker run：Run a command in a new container
docker attach：Attach to a running container
docker ps：List containers
docker logs：Fetch the logs of a container
docker restart：Restart a container
docker stop：Stop one or more running containers
docker kill：Kill one or more running containers
docker rm：Remove one or more containers
```

#### 6.10.1、镜像示例：

下载nginx镜像，不指定tag默认为latest

```
root@u1:~# docker pull nginx
```

查看镜像

```
root@u1:~# docker image ls
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
nginx               latest              6678c7c2e56c        3 weeks ago         127MB
centos              latest              470671670cac        2 months ago        237MB
root@u1:~# docker images 
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
nginx               latest              6678c7c2e56c        3 weeks ago         127MB
centos              latest              470671670cac        2 months ago        237MB
```

导出centos镜像

```
root@u1:~# docker save -o /opt/centos.tar.gz centos
root@u1:~# ll -h /opt/centos.tar.gz 
-rw------- 1 root root 234M Mar 25 17:59 /opt/centos.tar.gz
```

删除centos镜像，镜像没有使用才可删除

```
root@u1:~# docker rmi centos
```

导入centos镜像

```
root@u1:~# docker load < /opt/centos.tar.gz 
0683de282177: Loading layer [==================================================>]  244.9MB/244.9MB
Loaded image: centos:latest

或
root@u1:~# docker load -i /opt/centos.tar.gz 
```

#### 6.10.2、容器操作示例

启动容器

```
docker run --help
  -p, --publish list ：绑定地址和端口，如0.0.0.0:80:80、80:80、192.168.3.71:80:80
  -P, --publish-all  ：动态绑定端口，需在Dockerfile中进行EXPOSE

  -it, --interactive  ：交互模式，分配tty终端
 

  -d, --detach        ：后台运行，默认容器在前台运行
  --rm                ：容器退出后立即删除该容器
  --name              ：指定容器名称
  --dns list          ：指定DNS服务器

root@u1:~# docker run -it --rm --name centos-test centos echo hello world
hello world

root@u1:~# docker run -it --name centos-01 centos /bin/bash
[root@bb1bc265e56f /]# 

# 退出容器不注销
ctrl+p+q
```

显示容器

```
docker ps --help
  -a, --all             ：显示所有容器
  -f, --filter filter   ：根据条件过滤，如status=exited、running
      --format string   ：自定义输出格式
  -n, --last int        ：输出的条目，默认为-1，即输出所有
  -l, --latest          ：最后创建的容器
      --no-trunc        ：输出详细信息
  -q, --quiet           ：仅显示容器ID
  -s, --size            ：显示容器所占空间大小

root@u1:~# docker ps -aqf status=exited
2b6fa1d5a51a
```

删除容器

```
docker rm --help
  -f, --force     ：强制删除容器
  -v, --volumes   ：删除容器时删除数据目录
  
root@u1:~# docker rm -fv `docker ps -aqf status=exited`
2b6fa1d5a51a
```

查看容器已经映射的端口

```
root@u1:~# docker port 6f4e9f1b8ab5
80/tcp -> 0.0.0.0:80
```

停止容器

```
root@u1:~# docker stop dd2e7c69244f
dd2e7c69244f
```

查看容器信息

```
docker inspect [OPTIONS] NAME|ID [NAME|ID...]
 -f   ：根据go模板输出信息，如{{.State.Pid}}、{{.NetworkSettings.IPAddress}}

root@u1:~# docker inspect 6f4e9f1b8ab5
root@u1:~# docker inspect -f "{{.State.Pid}}" 6f4e9f1b8ab5
3220
root@u1:~# docker inspect -f "{{.NetworkSettings.IPAddress}}" 6f4e9f1b8ab5
172.17.0.3
```

进入正在运行的容器

```
attach
exec
nsenter(推荐)

获取容器的PID，在使用nsenter连接
root@u1:~# nsenter -t `docker inspect -f "{{.State.Pid}}" 6f4e9f1b8ab5` -m -u -i -n -p

创建脚本
vim docker_in.sh
#!/bin/bash
docker_in(){
  CONTAINER_ID=$1
  PID=$(docker inspect -f "{{.State.Pid}}" ${CONTAINER_ID})
  nsenter -t ${PID} -m -u -i -n -p
}

docker_in $1

chmod +x docker_in.sh
./docker_in.sh 6f4e9f1b8ab5
```

批量关闭正在运行的容器

```
root@u1:~# docker stop $(docker ps -q)
dd2e7c69244f
bb1bc265e56f
85c7579e2de8
6f4e9f1b8ab5
```

批量强制关闭正在运行的容器

```
root@u1:~# docker kill $(docker ps -q)
```

