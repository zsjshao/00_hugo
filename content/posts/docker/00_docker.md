+++
author = "zsjshao"
title = "00_docker"
date = "2020-04-26"
tags = ["docker"]
categories = ["容器"]
+++


# 什么是容器

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

| 隔离类型                                   | 功能                               | 系统调用参数  | 内核版本     |
| ------------------------------------------ | ---------------------------------- | ------------- | ------------ |
| MNT Namespace（mount）                     | 提供磁盘挂载点和文件系统的隔离能力 | CLONE_NEWNS   | Linux 2.4.19 |
| IPC Namespace(Inter-Process Communication) | 提供进程间通信的隔离能力           | CLONE_NEWIPC  | Linux 2.6.19 |
| UTS Namespace（UNIX Timesharing System     | 提供主机名与域名隔离能力           | CLONE_NEWUTS  | Linux 2.6.19 |
| PID Namespace（Process Identification）    | 提供进程隔离能力                   | CLONE_NEWPID  | Linux 2.6.24 |
| Net Namespace（network）                   | 提供网络隔离能力                   | CLONE_NEWNET  | Linux 2.6.29 |
| User Namespace（user）                     | 提供用户隔离能力                   | CLONE_NEWUSER | Linux 3.8    |

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

![docker_01](http://images.zsjshao.net/docker/docker_01.png)

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

![docker_02](http://images.zsjshao.net/docker/docker_02.png)

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

![docker_03](http://images.zsjshao.net/docker/docker_03.png)

#### 6.8.3、grpc简介

grpc是google开发的一款高性能、开源和通用的RPC框架，支持众多语言客户端。

![docker_04](http://images.zsjshao.net/docker/docker_04.png)

### 6.9、docker镜像管理

docker镜像含有启动容器所需要的文件系统及所需要的文件内容， 因此镜像主要用于创建并启动docker容器。

docker镜像里面是一层层文件系统，叫做Union FS（联合文件系统），联合文件系统可以将几层目录挂载到一起，形成一个虚拟文件系统，虚拟文件系统的目录结构就像普通linux的目录结构一样，docker通过这些文件再加上宿主机的内核提供了一个linux的虚拟环境，每一层文件系统叫做一层layer，联合文件系统可以对每一层文件系统设置三种权限，只读（readonly）、读写（readwrite）和写出（writeout-able），但是docker镜像中每一层文件系统都是只读的，构建镜像的时候，从一个最基本的操作系统开始，每个构建的操作都相当于做一层的修改，增加了一层文件系统，一层层往上叠加，上层的修改会覆盖底层该位置的可见性，当使用镜像的时候，我们只会看到一个完整的整体，不知道里面有几层也不需要知道里面有几层，结构如下：

![docker_05](http://images.zsjshao.net/docker/docker_05.png)

一个典型的linux文件系统由bootfs和rootfs两部分组成，bootfs（boot file system）主页包含bootloader和kernel，bootloader主要用于引导加载kernel，当kernel别加载到内存后bootfs会被umount掉，rootfs（root file system）包含的就是典型的linux系统中的/dev、/proc、/bin、/etc等标准目录和文件，下图就是docker image中最基础的两层结构，不同的linux发行版（如ubuntu和CentOS）在rootfs这一层会有所区别。

![docker_06](http://images.zsjshao.net/docker/docker_06.png)

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

# docker镜像与制作

## 1、镜像的生成途径

基于容器制作（commit）,基本不用

- docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]

Dockerfile

![docker_07](http://images.zsjshao.net/docker/docker_07.png)

## 2、Dockerfile

https://docs.docker.com/engine/reference/builder/

### FROM

```
ɝ FROM指令是最重的一个且必须为Dockerfile文件开篇的第一个非注释行，用于为映像文件构建过程指定基准镜像，后续的指令运行于此基准镜像所提供的运行环境
ɝ 实践中，基准镜像可以是任何可用镜像文件，默认情况下，docker build会在docker主机上查找指定的镜像文件，在其不存在时，则会从Docker Hub Registry上拉取所需的镜像文件ɰ 如果找不到指定的镜像文件，docker build会返回一个错误信息
ɝ Syntax
  ɰ FROM <image>[:<tag>] 或
  ɰ FROM <image>@<digest>
    l <image>：指定作为base image的名称；
    l <tag>：base image的标签，为可选项，省略时默认为latest；
```

### MAINTAINER(depreacted)

```
ɝ 用于让镜像制作者提供本人的详细信息
ɝ Dockerfile并不限制MAINTAINER指令可在出现的位置，但推荐将其放置于FROM指令之后,不能放置于FROM之前。
ɝ Syntax
  ɰ MAINTAINER <authtor's detail>
    l <author's detail>可是任何文本信息，但约定俗成地使用作者名称及邮件地址
    l MAINTAINER "zsjshao <zsjshao@163.com>"
ɝ 建议使用LABEL
  ɰ LABEL maintainer="zsjshao@163.com"
```

### LABEL

```
The LABEL instruction adds metadata to an image
  l Syntax: LABEL <key>=<value> <key>=<value> <key>=<value> ...
  l The LABEL instruction adds metadata to an image.
  l A LABEL is a key-value pair.
  l To include spaces within a LABEL value, use quotes and backslashes as you would in command-line parsing.
  l An image can have more than one label.
  l You can specify multiple labels on a single line.
```

### COPY

```
ɝ 用于从Docker主机复制文件至创建的新映像文件
ɝ Syntax
  ɰ COPY <src> ... <dest> 或
  ɰ COPY ["<src>",... "<dest>"]
    l <src>：要复制的源文件或目录，支持使用通配符
    l <dest>：目标路径，即正在创建的image的文件系统路径；建议为<dest>使用绝对路径，否则，COPY指定则以WORKDIR为其起始路径；
  ɰ 注意：在路径中有空白字符时，通常使用第二种格式
ɝ 文件复制准则
  ɰ <src>必须是build上下文中的路径，不能是其父目录中的文件
  ɰ 如果<src>是目录，则其内部文件或子目录会被递归复制，但<src>目录自身不会被复制
  ɰ 如果指定了多个<src>，或在<src>中使用了通配符，则<dest>必须是一个目录，且必须以/结尾
  ɰ 如果<dest>事先不存在，它将会被自动创建，这包括其父目录路径
```

复制时采用通配符方式可创建.dockerignore文件忽略不想复制的文件。

### ADD

```
ɝ ADD指令类似于COPY指令，ADD支持使用TAR文件和URL路径
ɝ Syntax
  ɰ ADD <src> ... <dest> 或
  ɰ ADD ["<src>",... "<dest>"]
ɝ 操作准则
  ɰ 同COPY指令
  ɰ 如果<src>为URL且<dest>不以/结尾，则<src>指定的文件将被下载并直接被创建为<dest>；如果<dest>以/结尾，则文件名URL指定的文件将被直接下载并保存为<dest>/<filename>
  ɰ 如果<src>是一个本地系统上的压缩格式的tar文件，它将被展开为一个目录，其行为类似于“tar -x”命令；然而，通过URL获取到的tar文件将不会自动展开；
  ɰ 如果<src>有多个，或其间接或直接使用了通配符，则<dest>必须是一个以/结尾的目录路径；如果<dest>不以/结尾，则其被视作一个普通文件，<src>的内容将被直接写入到<dest>；
```

### WORKDIR

```
ɝ 用于为Dockerfile中所有的RUN、CMD、ENTRYPOINT、COPY和ADD指定设定工作目录
ɝ Syntax
  ɰ WORKDIR <dirpath>
    l 在Dockerfile文件中，WORKDIR指令可出现多次，其路径也可以为相对路径，不过，其是相对此前一个WORKDIR指令指定的路径
    l 另外，WORKDIR也可调用由ENV指定定义的变量
  ɰ 例如
    l WORKDIR /var/log
    l WORKDIR $STATEPATH
```

### VOLUME

```
ɝ 用于在image中创建一个挂载点目录，以挂载Docker host上的卷或其它容器上的卷
ɝ Syntax
  ɰ VOLUME <mountpoint> 或
  ɰ VOLUME ["<mountpoint>"]
ɝ 如果挂载点目录路径下此前在文件存在，docker run命令会在卷挂载完成后将此前的所有文件复制到新挂载的卷中
```

### EXPOSE

```
ɝ 用于为容器打开指定要监听的端口以实现与外部通信
ɝ Syntax
  ɰ EXPOSE <port>[/<protocol>] [<port>[/<protocol>] ...]
    l <protocol>用于指定传输层协议，可为tcp或udp二者之一，默认为TCP协议
ɝ EXPOSE指令可一次指定多个端口，例如
  ɰ EXPOSE 11211/udp 11211/tcp
```

### ENV

```
ɝ 用于为镜像定义所需的环境变量，并可被Dockerfile文件中位于其后的其它指令（如ENV、ADD、COPY、CMD等）所调用
ɝ 调用格式为$variable_name或${variable_name}
ɝ Syntax
  ɰ ENV <key> <value> 或
  ɰ ENV <key>=<value> ...
ɝ 第一种格式中，<key>之后的所有内容均会被视作其<value>的组成部分，因此，一次只能设置一个变量；
ɝ 第二种格式可用一次设置多个变量，每个变量为一个"<key>=<value>"的键值对，如果<value>中包含空格，可以以反斜线(\)进行转义，也可通过对<value>加引号进行标识；另外，反斜线也可用于续行；
ɝ 定义多个变量时，建议使用第二种方式，以便在同一层中完成所有功能
ɝ ENV变量可被-e/--env list 声明的变量进行替换
```

### ARG

```
l The ARG instruction defines a variable that users can pass at build-time to the builder with the docker build command using the --build-arg <varname>=<value> flag.
l If a user specifies a build argument that was not defined in the Dockerfile, the build outputs a warning.
l Syntax: ARG <name>[=<default value>]
l A Dockerfile may include one or more ARG instructions.
l An ARG instruction can optionally include a default value:
  ü ARG version=1.14
  ü ARG user=zsjshao
```

### RUN

```
ɝ 用于指定docker build过程中运行的程序，其可以是任何命令
ɝ Syntax
  ɰ RUN <command> 或
  ɰ RUN ["<executable>", "<param1>", "<param2>"]
ɝ 第一种格式中，<command>通常是一个shell命令，且以“/bin/sh -c”来运行它，这意味着此进程在容器中的PID不为1，不能接收Unix信号，因此，当使用docker stop <container>命令停止容器时，此进程接收不到SIGTERM信号；
ɝ 第二种语法格式中的参数是一个JSON格式的数组，其中<executable>为要运行的命令，后面的<paramN>为传递给命令的选项或参数；然而，此种格式指定的命令不会以“/bin/sh -c”来发起，因此常见的shell操作如变量替换以及通配符(?,*等)替换将不会进行；不过，如果要运行的命令依赖于此shell特性的话，可以将其替换为类似下面的格式。
  ɰ RUN ["/bin/bash", "-c", "<executable>", "<param1>"]
ɝ 注意：json数组中，要使用双引号
```

### CMD

```
ɝ 类似于RUN指令，CMD指令也可用于运行任何命令或应用程序，不过，二者的运行时间点不同
  ɰ RUN指令运行于映像文件构建过程中，而CMD指令运行于基于Dockerfile构建出的新映像文件启动一个容器时
  ɰ CMD指令的首要目的在于为启动的容器指定默认要运行的程序，且其运行结束后，容器也将终止；不过，CMD指定的命令其可以被docker run的命令行选项所覆盖
  ɰ 在Dockerfile中可以存在多个CMD指令，但仅最后一个会生效
ɝ Syntax
  ɰ CMD <command> 或
  ɰ CMD [“<executable>”, “<param1>”, “<param2>”] 或
  ɰ CMD ["<param1>","<param2>"]
ɝ 前两种语法格式的意义同RUN
ɝ 第三种则用于为ENTRYPOINT指令提供默认参数
```

### ENTRYPOINT

```
ɝ 类似CMD指令的功能，用于为容器指定默认运行程序，从而使得容器像是一个单独的可执行程序
ɝ 与CMD不同的是，由ENTRYPOINT启动的程序不会被docker run命令行指定的参数所覆盖，而且，这些命令行参数会被当作参数传递给ENTRYPOINT指定指定的程序
  ɰ 不过，docker run命令的--entrypoint选项的参数可覆盖ENTRYPOINT指令指定的程序
ɝ Syntax
  ɰ ENTRYPOINT <command>
  ɰ ENTRYPOINT ["<executable>", "<param1>", "<param2>"]
ɝ docker run命令传入的命令参数会覆盖CMD指令的内容并且附加到ENTRYPOINT命令最后做为其参数使用
ɝ Dockerfile文件中也可以存在多个ENTRYPOINT指令，但仅有最后一个会生效
```

### USER

```
ɝ 用于指定运行image时的或运行Dockerfile中任何RUN、CMD或ENTRYPOINT指令指定的程序时的用户名或UID
ɝ 默认情况下，container的运行身份为root用户
ɝ Syntax
  ɰ USER <UID>|<UserName>
  ɰ 需要注意的是，<UID>可以为任意数字，但实践中其必须为/etc/passwd中某用户的有效UID，否则，docker run命令将运行失败
```

### HEALTHCHECK

```
l The HEALTHCHECK instruction tells Docker how to test a container to check that it is still working.
l This can detect cases such as a web server that is stuck in an infinite loop and unable to handle new connections, even though the server process is still running.
l The HEALTHCHECK instruction has two forms:
  ü HEALTHCHECK [OPTIONS] CMD command (check container health by running a command inside the container)
  ü HEALTHCHECK NONE (disable any healthcheck inherited from the base image)
l The options that can appear before CMD are:
  ü --interval=DURATION (default: 30s)
  ü --timeout=DURATION (default: 30s)
  ü --start-period=DURATION (default: 0s)
  ü --retries=N (default: 3)
l The command’s exit status indicates the health status of the container. The possible values are:
  ü 0: success - the container is healthy and ready for use
  ü 1: unhealthy - the container is not working correctly
  ü 2: reserved - do not use this exit code
l For example
  ü HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost/ || exit 1
```

### SHELL

```
l The SHELL instruction allows the default shell used for the shell form of commands to be overridden.
l The default shell on Linux is ["/bin/sh", "-c"], and on Windows is ["cmd", "/S", "/C"].
l The SHELL instruction must be written in JSON form in a Dockerfile.
  ü Syntax: SHELL ["executable", "parameters"]
l The SHELL instruction can appear multiple times.
l Each SHELL instruction overrides all previous SHELL instructions, and affects all subsequent instructions.
```

### STOPSIGNAL

```
l The STOPSIGNAL instruction sets the system call signal that will be sent to the container to exit.
l This signal can be a valid unsigned number that matches a position in the kernel’s syscall table, for instance 9, or a signal name in the format SIGNAME, for instance SIGKILL.
l Syntax: STOPSIGNAL signal
```

### ONBUILD

```
ɝ 用于在Dockerfile中定义一个触发器
ɝ Dockerfile用于build映像文件，此映像文件亦可作为base image被另一个Dockerfile用作FROM指令的参数，并以之构建新的映像文件
ɝ 在后面的这个Dockerfile中的FROM指令在build过程中被执行时，将会“触发”创建其base image的Dockerfile文件中的ONBUILD指令定义的触发器
ɝ Syntax
  ɰ ONBUILD <INSTRUCTION>
ɝ 尽管任何指令都可注册成为触发器指令，但ONBUILD不能自我嵌套，且不会触发FROM和MAINTAINER指令
ɝ 使用包含ONBUILD指令的Dockerfile构建的镜像应该使用特殊的标签，例如ruby:2.0-onbuild
ɝ 在ONBUILD指令中使用ADD或COPY指令应该格外小心，因为新构建过程的上下文在缺少指定的源文件时会失败
```

**尽量采用分层的方式构建镜像**

## 3、示例：

### 3.1、centos7.7 base镜像制作

```
# 提供Dockerfile文件
vim Dockerfile
FROM centos:7.7.1908
MAINTAINER zsjshao
RUN yum install -y epel-release && \
    yum install -y openssh-server vim iproute passwd iotop bc gcc gcc-c++ glibc glibc-devel pcre pcre-devel openssl openssl-devel zip unzip zlib-devel lrzsz tree ntpdate telnet lsof tcpdump wget libevent libevent-devel bc systemd-devel bash-completion traceroute rsync -y && \        
    yum clean all && \
    rm -rf /var/cache/yum/ && \
    /usr/bin/ssh-keygen -f /root/.ssh/id_rsa -P '' && \
    /usr/bin/ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' && \
    /usr/bin/ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    /usr/bin/ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N ''  && \
    sed -i 's/^#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config && \
    sed -i 's/^UseDNS.*/UseDNS no/' /etc/ssh/sshd_config && \
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA2gTNkkedvVQyIhzcu1m33wlgoMQRT0BJ5IZDI0Bb7y3yZQ7ntOaYLWXMXRwRdc8paHUpE6XmxqYs3rKAWuRPi8BV9Kh4krsPjpDzl7qHOWxvTy167hGQkoccHkE6UHgNBcWDL8BrQfN6/RARxhw3PvQdvEgam97oeMiMpmjp2bd29mUELjByy3RIDM04GOklBgE4SQjm4n9LOK4Ojp7nUGGv1hPK1fP0YW/Qi21wyK41fXhsRB8d61IYrD76RAVqwoJtuoflNCZJf+EaXn8I7t0sus10Z3znsKSOREsWkMvNZ+dIpVa5O/FeJ0GJ0xMuMlFfk930ENuWiwdVyUNu6w==' >> /root/.ssh/authorized_keys && \
    rm -f /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ADD docker-entrypoint.sh /bin/
EXPOSE 22/tcp
CMD [ "/usr/sbin/sshd","-D" ]
ENTRYPOINT [ "/bin/docker-entrypoint.sh" ]
```

```
# 提供entrypoint脚本文件
vim docker-entrypoint.sh
#!/bin/bash

exec "$@"

chmod +x docker-entrypoint.sh
```

```
# 制作镜像
root@u1:/data/dockerfile/centos/7.7.1908# docker build -t centos7.7-base:latest .
```

### 3.2、基于centos7.7 base制作nginx镜像

```
文件准备
wget http://nginx.org/download/nginx-1.16.1.tar.gz
编辑nginx.conf，添加daemon off;配置参数，让nginx工作在前台
echo "nginx test page" > index.html

# 所需文件列表
root@u1:/data/dockerfile/nginx# ls -lA
total 1024
-rw-r--r-- 1 root root     516 Mar 26 22:11 Dockerfile
-rw-r--r-- 1 root root      16 Mar 26 22:07 index.html
-rw-r--r-- 1 root root 1032630 Aug 14  2019 nginx-1.16.1.tar.gz
-rw-r--r-- 1 root root    2671 Mar 26 22:05 nginx.conf
```

```
# 提供Dockerfile文件
FROM centos7.7-base
MAINTAINER zsjshao
ADD nginx-1.16.1.tar.gz /usr/local/src/
RUN cd /usr/local/src/nginx-1.16.1/ && \
    ./configure --prefix=/apps/nginx --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-pcre && \
    useradd -r -s /sbin/nologin nginx && \
    make && make install && \
    chown nginx.nginx -R /apps/nginx/
COPY index.html /apps/nginx/html/
COPY nginx.conf /apps/nginx/conf/
EXPOSE 80/tcp
CMD [ "/apps/nginx/sbin/nginx" ]
```

```
root@u1:/data/dockerfile/nginx# docker built -t centos7.7-nginx:v1 .
```

测试

```
root@u1:/data/dockerfile/nginx# docker run -d --rm -p 80:80 centos7.7-nginx:v1
d5b231f8e80a6beadaf5b6183ea1b127ddadd6512e3382f12a16e8dac3fdebd5
root@u1:/data/dockerfile/nginx# docker ps -a
CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                        NAMES
d5b231f8e80a        centos7.7-nginx:v1   "/bin/docker-entrypo…"   49 seconds ago      Up 48 seconds       22/tcp, 0.0.0.0:80->80/tcp   jolly_euclid
root@u1:/data/dockerfile/nginx# curl localhost
nginx test page
```

# docker仓库 Harbor

harbor是一个用于存储和分发Docker镜像的企业级Registry服务器，由vmware开源，其通过添加一些企业必需的功能特性，例如安全、标识和管理等，扩展了开源Docker Distribution。作为一个企业级私有Registry服务器，harbor提供了更好的性能和安全。提升用户使用Registry构建和运行环境传输的效率。harbor支持安装在多个Registry节点的镜像资源复制，镜像全部保存在私有Registry中，确保数据和知识产权在公司内部网络中管控，另外，harbor也提供了高级的安全特性，诸如用户管理，访问控制和活动审计等。

官网地址：https://vmware.github.io/harbor/cn/

官方github地址：https://github.com/goharbor/harbor

## 1、下载离线Harbor安装包

```
wget https://github.com/goharbor/harbor/releases/download/v1.10.1/harbor-offline-installer-v1.10.1.tgz
```

手动安装docker-compose

```
https://github.com/docker/compose/releases
```

## 2、配置Harbor

证书异常，文档需更新

### 2.1、安装harbor1

```
#!/bin/bash

DOMAIN=zsjshao.net
HARBOR1=harbor1.zsjshao.net
HARBOR2=harbor2.zsjshao.net
HARBOR1_NODE_IP=192.168.3.71          #当前节点
HARBOR2_NODE_IP=192.168.3.72
PASS=shaoji

rpm -q yum-utils || yum install -y yum-utils
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
rpm -q docker-ce || yum -y install docker-ce docker-compose

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
	  "registry-mirrors": ["https://jr0tl680.mirror.aliyuncs.com"]
  }
EOF
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

mkdir /etc/certs -p
rm -rf /etc/certs/*
cd /etc/certs/
openssl genrsa -out harbor_ca.key 4096
openssl req -x509 -new -nodes -sha512 -days 3650 -subj "/C=CN/ST=GD/L=GZ/O=${DOMAIN}/OU=devops/CN=${DOMAIN}" -key harbor_ca.key -out harbor_ca.crt
openssl genrsa -out ${HARBOR1}.key 4096
openssl genrsa -out ${HARBOR2}.key 4096
openssl req -sha512 -new -subj "/C=CN/ST=GD/L=GZ/O=${DOMAIN}/OU=devops/CN=${HARBOR1}" -key ${HARBOR1}.key -out ${HARBOR1}.csr
openssl req -sha512 -new -subj "/C=CN/ST=GD/L=GZ/O=${DOMAIN}/OU=devops/CN=${HARBOR2}" -key ${HARBOR2}.key -out ${HARBOR2}.csr
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=${HARBOR1}
DNS.2=${HARBOR2}
DNS.3=${DOMAIN}
IP.1=${HARBOR1_NODE_IP}
IP.2=${HARBOR2_NODE_IP}
EOF
openssl x509 -req -sha512 -days 3650 -extfile v3.ext -CA harbor_ca.crt -CAkey harbor_ca.key -CAcreateserial -in ${HARBOR1}.csr -out ${HARBOR1}.crt
openssl x509 -req -sha512 -days 3650 -extfile v3.ext -CA harbor_ca.crt -CAkey harbor_ca.key -CAcreateserial -in ${HARBOR2}.csr -out ${HARBOR2}.crt
openssl x509 -inform PEM -in ${HARBOR1}.crt -out ${HARBOR1}.cert
openssl x509 -inform PEM -in ${HARBOR2}.crt -out ${HARBOR2}.cert

mkdir /etc/docker/certs.d/${HARBOR1}/ -p
rm -rf /etc/docker/certs.d/${HARBOR1}/*
\cp -f ${HARBOR1}* /etc/docker/certs.d/${HARBOR1}/
\cp -f harbor_ca.crt /etc/docker/certs.d/${HARBOR1}/
\cp -f harbor_ca.crt /etc/ssl/certs/

systemctl restart docker

# 安装Harbor
cd /usr/local/src/
if [ ! -f harbor-offline-installer-v1.10.1.tgz ] ; then
  echo "file not exist"
  exit 1
fi
rm -rf harbor
rm -rf /data/*
tar xf harbor-offline-installer-v1.10.1.tgz
cd harbor
sed -i "s@^hostname.*@hostname: ${HARBOR1}@" harbor.yml
sed -i "s@^  certificate.*@  certificate: /etc/certs/${HARBOR1}.crt@" harbor.yml
sed -i "s@^  private_key.*@  private_key: /etc/certs/${HARBOR1}.key@" harbor.yml
sed -i "s@^harbor_admin_password.*@harbor_admin_password: $PASS@" harbor.yml
./prepare 
./install.sh --with-clair
```

### 2.2、安装Harbor2

```
#!/bin/bash

DOMAIN=zsjshao.net
HARBOR1=harbor1.zsjshao.net
HARBOR2=harbor2.zsjshao.net
HARBOR1_NODE_IP=192.168.3.71          #当前节点
HARBOR2_NODE_IP=192.168.3.72
PASS=shaoji

rpm -q yum-utils || yum install -y yum-utils
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
rpm -q docker-ce || yum -y install docker-ce docker-compose

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
	  "registry-mirrors": ["https://jr0tl680.mirror.aliyuncs.com"]
  }
EOF
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

mkdir /etc/certs -p
cd /etc/certs/
rm -rf /etc/certs/*
rsync -avlogp ${HARBOR1_NODE_IP}:/etc/certs/* /etc/certs/
\cp -f harbor_ca.crt /etc/ssl/certs/

mkdir /etc/docker/certs.d/${HARBOR2}/ -p
rm -rf /etc/docker/certs.d/${HARBOR2}/*
\cp -fv ${HARBOR2}* /etc/docker/certs.d/${HARBOR2}/
\cp -fv harbor_ca.crt /etc/docker/certs.d/${HARBOR2}/

systemctl restart docker
systemctl enable docker

# 安装Harbor
cd /usr/local/src/
if [ ! -f harbor-offline-installer-v1.10.1.tgz ] ; then
  echo "file not exist"
  exit 1
fi
rm -rf harbor
rm -rf /data/*
tar xf harbor-offline-installer-v1.10.1.tgz
cd harbor
sed -i "s@^hostname.*@hostname: ${HARBOR2}@" harbor.yml
sed -i "s@^  certificate.*@  certificate: /etc/certs/${HARBOR2}.crt@" harbor.yml
sed -i "s@^  private_key.*@  private_key: /etc/certs/${HARBOR2}.key@" harbor.yml
sed -i "s@^harbor_admin_password.*@harbor_admin_password: $PASS@" harbor.yml
./prepare 
./install.sh --with-clair
```

### 2.3、web界面访问

https://FQDN

![harbor_01](http://images.zsjshao.net/docker/harbor/harbor_01.png)

创建项目

![harbor_02](http://images.zsjshao.net/docker/harbor/harbor_02.png)

客户端登录harbor

```
root@u1:~# docker login harbor.zsjshao.net -u admin
Password: 

Login Succeeded
```

证书配置

Error response from daemon: Get https://harbor.zsjshao.net/v2/: x509: certificate signed by unknown authority

若提示证书不被信任，需将ca证书导入受信任的根证书颁发机构

```
scp harbor.zsjshao.net:/data/cert/ca.crt /etc/ssl/certs/
```

上传镜像

```
root@u1:~# docker tag 448f83a26c2d harbor1.zsjshao.net/osbase/centos8.1-base:latest
root@u1:~# docker push harbor1.zsjshao.net/osbase/centos8.1-base:latest
The push refers to repository [harbor1.zsjshao.net/osbase/centos8.1-base]
c905c3521389: Pushed 
e67b282d2de5: Pushed 
0683de282177: Pushed 
latest: digest: sha256:ffeb1fa839bd7741ab39354eb4fcf50b95d96211720cdd98f102461302c56917 size: 949
```

创建复制目标

![harbor_03](http://images.zsjshao.net/docker/harbor/harbor_03.png)

注意：使用域名需要配置DNS提供解析功能，并修改宿主机的DNS配置文件，不能使用/etc/hosts文件进行解析。

创建复制规则

![harbor_04](http://images.zsjshao.net/docker/harbor/harbor_04.png)

查看复制任务

![harbor_05](http://images.zsjshao.net/docker/harbor/harbor_05.png)

在harbor2配置复制harbor1的复制规则，实现镜像同步。

## 3、Harbor管理

```
# 重新安装
docker-compose down -v
docker rmi `docker images | awk '{print $3}'`
./prepare 
./install.sh --with-clair

# 重新启动
docker-compose down -v
docker-compose up -d
```

# docker 数据管理

Docker镜像由多个只读层叠加而成，启动容器时，Docker会加载只读镜像层并在镜像栈顶部添加一个读写层

如果运行中的容器修改了现有的一个已经存在的文件，那该文件将会从读写层下面的只读层复制到读写层，该文件的只读版本仍然存在，只是已经被读写层中该文件的副本所隐藏，此即“写时复制(COW)”机制

![volumes_01](http://images.zsjshao.net/docker/volumes/volumes_01.png)

关闭并重启容器，其数据不受影响；但删除Docker容器，则其更改将会全部丢失

## 1、数据类型

目前docker的数据类型分为两种：一是数据卷，二是容器卷，Volume的初衷是独立于容器的生命周期实现数据持久化，因此删除容器之时既不会删除卷，也不会对哪怕未被引用的卷做垃圾回收操作；

### 1.1、数据卷

数据卷实际上就是宿主机上的目录或者是文件，可以直接被mount到容器当中使用。

实际生产环境中，需要针对不同类型的服务、不同类型的数据存储要求做相应的规划，最终保证服务的可扩展性、稳定性以及数据的安全性。

### 1.2、容器卷

容器卷是将数据保存在一个容器上

## 2、在容器中使用Volumes

```
为docker run命令使用-v选项即可使用Volume，挂载的卷默认是可读写(rw)的，可修改为只读(ro)
用法：
  -v VOLUMEDIR
  -v HOSTDIR:VOLUMEDIR[:ro]
  -v HOSTFILE:FIEL[:ro]
  --volumes-from

 Docker-managed volume
  ~]# docker run -it --name bbox1 -v /data busybox
  ~]# docker inspect -f {{.Mounts}} bbox1
 查看bbox1容器的卷、卷标识符及挂载的主机目录
 Bind-mount Volume
  ~]# docker run -it -v HOSTDIR:VOLUMEDIR --name bbox2 busybox
  ~]# docker inspect -f {{.Mounts}} bbox2

There are two ways to share volumes between containers
 多个容器的卷使用同一个主机目录，例如
  ~]# docker run –it --name c1 -v /docker/volumes/v1:/data busybox
  ~]# docker run –it --name c2 -v /docker/volumes/v1:/data busybox

 复制使用其它容器的卷，为docker run命令使用--volumes-from选项
  ~]# docker run -it --name bbox1 -v /docker/volumes/v1:/data busybox
  ~]# docker run -it --name bbox2 --volumes-from bbox1 busybox
 
v 删除容器之时删除相关的卷
  ɝ 为docker rm命令使用-v选项
v 删除指定的卷
  ɝ docker volume rm
```

# docker 网络管理

## 1、docker网络类型

docker的网络有四种类型：分别是

- Bridge(Bridged containers)
- none(Closed containers)
- container(Joined containers)
- host(Open containers)

![network_01](http://images.zsjshao.net/docker/network/network_01.png)

### 1.1、Bridged containers

桥接式容器一般拥有两个接口：一个环回接口和一个连接至主机上某桥设备的以太网接口
docker daemon启动时默认会创建一个名为docker0的网络桥，并且创建的容器为桥接式容器，其以太网接口桥接至docker0

```
可以为docker run命令使用
  “--hostname HOSTNAME”选项为容器指定主机名，例如
   ~]# docker run --rm --net bridge --hostname bbox.zsjshao.net busybox nslookup
     bbox.zsjshao.net
  
  “--dns DNS_SERVER_IP”选项能够为容器指定所使用的dns服务器地址，例如
   ~]# docker run --rm --dns 172.16.0.1 busybox nslookup docker.com
  
  “--add-host HOSTNAME:IP”选项能够为容器指定本地主机名解析项，例如
   ~]# docker run --rm --dns 172.16.0.1 --add-host "docker.com:172.16.0.100" busybox
     nslookup docker.com
```

docker0桥为NAT桥，容器一般获得的是私有网络地址，可以把容器想像为宿主机NAT服务背后的主机，因此，桥接式容器可通过此桥接口访问外部网络，但防火墙规则阻止了一切从外部网络访问桥接式容器的请求

如果开放容器或其上的服务为外部网络访问，需要在宿主机上为其定义DNAT规则，例如

```
• 对宿主机某IP地址的访问全部映射给某容器地址
 • 主机IP 容器IP
  • -A PREROUTING -d 主机IP -j DNAT --to-destination 容器IP
• 对宿主机某IP地址的某端口的访问映射给某容器地址的某端口
 • 主机IP:PORT 容器IP:PORT
  • -A PREROUTING -d 主机IP -p {tcp|udp} --dport 主机端口 -j DNAT --to-destination 容器IP:容器端口
```

为docker run命令使用-p选项即可实现端口映射，无须手动添加规则

```
•-p选项的使用格式
 • -p <containerPort>
  • 将指定的容器端口映射至主机所有地址的一个动态端口
 
 • -p <hostPort>:<containerPort>
  • 将容器端口<containerPort>映射至指定的主机端口<hostPort>
 
 • -p <ip>::<containerPort>
  • 将指定的容器端口<containerPort>映射至主机指定<ip>的动态端口
 
 • -p <ip>:<hostPort>:<containerPort>
  • 将指定的容器端口<containerPort>映射至主机指定<ip>的端口<hostPort>
 
 • “动态端口”指随机端口，具体的映射结果可使用docker port命令查看
```

“-P”选项或“--publish-all”将容器的所有计划要暴露端口全部映射至主机端口

计划要暴露的端口使用使用--expose选项指定

```
• 例如
 • ~]# docker run -d -P --expose 2222 --expose 3333 --name web busybox /bin/httpd -p 2222 -f
 
• 查看映射结果
 • ~]# docker port web
```

如果不想使用默认的docker0桥接口，或者需要修改此桥接口的网络属性，可通过为docker daemon命令使用-b、--bip、--fixed-cidr、--default-gateway、--dns以及--mtu等选项进行设定

### 1.2、Closed containers

不参与网络通信，运行于此类容器中的进程仅能访问本地环回接口

仅适用于进程无须网络通信的场景中，例如备份、进程诊断及各种离线任务等

```
~]# docker run --rm --net none busybox ifconfig -a
```

### 1.3、Joined containers

联盟式容器是指使用某个已存在容器的网络接口的容器，接口被联盟内的各容器共享使用；因此，联盟式容器彼此间完全无隔离，例如

```
创建一个监听于2222端口的http服务容器
  ~]# docker run -d -it --rm -p 2222 busybox /bin/httpd -p 2222 -f
创建一个联盟式容器，并查看其监听的端口
  ~]# docker run -it --rm --net container:web --name joined busybox netstat -tan
```

联盟式容器彼此间虽然共享同一个网络名称空间，但其它名称空间如User、Mount等还是隔离的

联盟式容器彼此间存在端口冲突的可能性，因此，通常只会在多个容器上的程序需要程序loopback接口互相通信、或对某已存的容器的网络属性进行监控时才使用此种模式的网络模型

### 1.4、Open containers

开放式容器共享主机网络名称空间的容器，它们对主机的网络名称空间拥有全部的访问权限，包括访问那些关键性服务，这对宿主机安全性有很大潜在威胁

为docker run命令使用“--net host”选项即可创建开放式容器，例如：

```
~]# docker run -it --rm --net host busybox /bin/sh
```

# 容器资源限制

## 1、内存限制

对于Linux 主机，如果没有足够的内容来执行重要的系统任务，将会抛出 OOM 或者 Out of Memory Exception(内存溢出、内存泄漏、内存异常), 随后系统会开始杀死进程以释放内存。每个进程都有可能被 kill，包括Dockerd和其它的应用程序。如果重要的系统进程被Kill,会导致整个系统宕机。

产生 OOM 异常时，Docker尝试通过调整Docker守护程序上的OOM优先级来减轻这些风险，以便它比系统上的其他进程更不可能被杀死。 容器上的OOM优先级未调整，这使得单个容器被杀死的可能性比Docker守护程序或其他系统进程被杀死的可能性更大，不推荐通过在守护程序或容器上手动设置--oom-score-adj为极端负数，或通过在容器上设置--oom-kill-disable来绕过这些安全措施。

### 1.1、限制容器对内存的访问

Docker 可以强制执行硬性内存限制，即只允许容器使用给定的内存大小。 

Docker 也可以执行非硬性内存限制，即容器可以使用尽可能多的内存，除非内核检测到主机上的内存不够用了。

内存限制参数：

- -m or --memory=   :容器可以使用的最大内存量，如果您设置此选项，则允许的最小值为4m （4兆字节）。
- --memory-swap *   :容器可以使用的交换分区大小，要在设置物理内存限制的前提才能设置交换分区的限制
- --memory-swappiness :设置容器使用交换分区的倾向性，值越高表示越倾向于使用swap分区，范围为0-100，0为能不用就不用，100为能用就用
- --memory-reservation :允许您指定小于--memory的软限制，当Docker检测到主机上的争用或内存不足时会激活该限制，如果使用--memory-reservation，则必须将其设置为低于--memory才能使其优先。 因为它是软限制，所以不能保证容器不超过限制。
- --kernel-memory ：容器可以使用的最大内核内存量，最小为4m，由于内核内存与用户空间内存隔离，因此无法与用户空间内存直接交换，因此内核内存不足的容器可能会阻塞宿主主机资源，这会对主机和其他容器产生副作用。
- --oom-kill-disable：默认情况下，发生OOM时，kernel会杀死容器内进程，但是可以使用--oom-kill-disable参数，可以禁止oom发生在指定的容器上，即仅在已设置-m / --memory选项的容器上禁用OOM，如果-m 参数未配置，产生OOM时，主机为了释放内存还会杀死容器进程

swap限制：

- swap限制参数--memory-swap 只有在设置了 --memory 后才会有意义。使用Swap,可以让容器将超出限制部分的内存置换到磁盘上。
- WARNING：经常将内存交换到磁盘的应用程序会降低性能

不同的设置会产生不同的效果：

- --memory-swap：值为正数， 那么--memory和--memory-swap都必须要设置，--memory-swap表示你能使用的内存和swap分区大小的总和，例如： --memory=300m, --memory-swap=1g, 那么该容器能够使用 300m 内存和 700m swap，即--memory是实际物理内存大小值不变，而实际的计算方式为(--memory-swap)-(--memory)=容器可用swap
- --memory-swap：如果设置为0，则忽略该设置，并将该值视为未设置，即未设置交换分区。
- --memory-swap：如果等于--memory的值，并且--memory设置为正整数，容器无权访问swap即也没有设置交换分区
- --memory-swap：如果设置为unset，如果宿主机开启了swap，则实际容器的swap值为2x( --memory)，即两倍于物理内存大小，但是并不准确。
- --memory-swap：如果设置为-1，如果宿主机开启了swap，则容器可以使用主机上swap的最大空间。

## 2、CPU限制

优先级

- 实时优先级：0-99
- 非实时优先级(nice)：-20-19，对应100-139的进程优先级

Linux kernel进程的调度基于CFS(Completely Fair Scheduler)，完全公平调度

CPU密集型的场景：

- 优先级越低越好，计算密集型任务的特点是要进行大量的计算，消耗CPU资源，比如计算圆周率、对视频进行高清解码等等，全靠CPU的运算能力

IO密集型的场景：

- 优先级值高点，涉及到网络、磁盘IO的任务都是IO密集型任务，这类任务的特点是CPU消耗很少，任务的大部分时间都在等待IO操作完成（因为IO的速度远远低于CPU和内存的速度），比如Web应用，高并发，数据量大的动态网站来说，数据库应该为IO密集型。

磁盘调度算法

```
[root@c72 harbor]# cat /sys/block/sda/queue/scheduler 
noop [deadline] cfq
```

默认情况下，每个容器对主机CPU周期的访问权限是不受限制的，但是我们可以设置各种约束来限制给定容器访问主机的CPU周期，大多数用户使用的是默认的CFS调度方式，在Docker 1.13及更高版本中，还可以配置实时优先级。

cpu限制参数

- --cpus= 指定容器可以使用多少可用CPU资源。例如，如果主机有两个CPU，并且您设置了--cpus =“1.5”，那么该容器将保证最多可以访问一个半的CPU。这相当于设置--cpu-period =“100000”和--cpu-quota =“150000”。在Docker 1.13和更高版本中可用。
- --cpuset-cpus  主要用于指定容器运行的CPU编号，也就是我们所谓的绑核。
- --cpuset-mem  设置使用哪个cpu的内存，仅对 非统一内存访问(NUMA)架构有效
- --cpu-shares   主要用于cfs中调度的相对权重，,cpushare值越高的，将会分得更多的时间片，默认的时间片1024，最大262144

## 3、示例

```
运行容器进行压力测试：
root@u1:~# docker pull lorel/docker-stress-ng

获取帮助： docker run -it --rm lorel/docker-stress-ng --help

测试内存资源，限制容器最大可用内存为256m，默认一个vm占用256m内存
docker run -it --rm -m 256m lorel/docker-stress-ng --vm 4

测试CPU资源，限制最多使用两核心，默认一个cpu会占满
docker run -it --rm --cpus 2 lorel/docker-stress-ng --cpu 4

测试CPU资源，限制只能使用指定的核心
docker run -it --rm --cpuset-cpus 0,2 lorel/docker-stress-ng --cpu 4

测试CPU资源，限制cpu为2:3
docker run -it --rm --cpu-shares 200 lorel/docker-stress-ng --cpu 2
docker run -it --rm --cpu-shares 300 lorel/docker-stress-ng --cpu 2

动态观察容器的资源占用状态
docker stats
```

实际上这些限制都体现在宿主机的CGroup上

```
-m 256m 等于 memory.limit_in_bytes 268435456
--cpus 3 等于 cpu.cfs_quota_us 300000
--cpuset-cpus 0,2 等于 cpuset.cpus 0,2
--cpu-shares 200 等于 cpu.shares 200

cpu.cfs_period_us，默认值为100000，表示将一颗cpu时间片分成100000份
cpu.cfs_quota_us，默认值为-1，表示不受限制。

查看当前CGroup管理的进程
cat /sys/fs/cgroup/cpu/docker/容器ID/tasks

可使用echo命令直接修改，一般只能改大不能改小
例如 echo 300 > /sys/fs/cgroup/cpu/docker/容器ID/cpu.shares
```