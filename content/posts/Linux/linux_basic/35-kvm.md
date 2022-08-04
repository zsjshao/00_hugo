+++
author = "zsjshao"
title = "35_kvm"
date = "2020-05-01"
tags = ["linux_basic"]
categories = ["linux_basic"]

+++


## 一、虚拟化基础

https://www.vmware.com/cn/solutions/virtualization.html

### 1.1、传统的物理机部署方案

服务器选型及采购—IDC选择及上架-系统选择及安装–应用规划及部署–域名选择及注册–DNS映射–外网访问： 工信部备案-公安部备案–ICP备案(电子商务网站–>ICP证经营性ICP备案)，游戏公司文化部(文网文)备案等，在备案没有成功之前网站是不能上线访问的，论坛BBS有BBS公告备案是备案的前置审批，没有的话备案不成功，还要在公安局系统备案，另外域名接入到一个地方比如机房还要做接入备案，备案在个人名下的备案不能直接转公司，个人注销后网站属于未备案状态随时可能会被封，域名备案一般可以找代理，因为过程比较复杂：

传统数据中心面临的问题：

```
服务器资源利用率低下，CPU、内存等不能共享
资源分配不合理
初始化成本高
自动化能力差
集群环境需要大量的服务器主机
```

### 1.2、什么是虚拟化和虚拟机：

#### 1.2.1、虚拟化：

虚拟化是为一些组件（例如虚拟应用、服务器、存储和网络）创建基于软件的（或虚拟）表现形式的过程。它是降低所有规模企业的 IT 开销，同时提高其效率和敏捷性的最有效方式。

虚拟化可以提高 IT 敏捷性、灵活性和可扩展性，同时大幅节约成本。更高的工作负载移动性、更高的性能和资源可用性、自动化运维 - 这些都是虚拟化的优势，虚拟化技术可以使 IT 部门更轻松地进行管理以及降低拥有成本和运维成本。其他优势包括：

```
降低资金成本和运维成本。
最大限度减少或消除停机。
提高 IT 部门的工作效率、效益、敏捷性和响应能力。
加快应用和资源的调配速度。
提高业务连续性和灾难恢复能力。
简化数据中心管理。
真正的 Software-Defined Data Center 的可用性。
```

虚拟化的由来：

```
1964年，IBM推出了专为 System/360 Mainframe 量身订造的操作系统 CP-40，首次实现了虚拟内存和虚拟机。
1967 年，第一个管理程序(hypervisor)诞生，5年之后，IBM 发布用于创建灵活大型主机的虚拟机(VM)技术，该技术可根据动态的需求快速而有效地使用各种资源。从此，虚拟化这一词汇正式被引入了IT的现实世界。
20世纪 90 年代 Windows 的广泛使用以及 Linux 作为服务器系统的出现奠定了 x86 服务器的行业标准地位。
1998年VMware公司在美国成立，1999年VMware发布了它的第一款产品VMware Workstation、 2001年发布VMware GSX Server和VMware ESXI Server宣布进入服务器虚拟化市场， 2003年VMware推出了VMware Virtual Center， 2004年推出了64位支持版本，同年被EMC收购，2013年收入52.1亿美元。
2007年8月21日，思杰宣布5亿美元收购XenSource公司，并推出服务器虚拟化XenServer、桌面虚拟化XenDesktop和应用虚拟化XenApp，2013年收入29亿美元。
2008年3月13日微软在北京发布Windows Server 2008，内置虚拟化技术hyper-v。
2008年9月，红帽以1.07亿美元的价格收购KVM的母公司Qumranet，并推出企业级虚拟化解决方案RHEV，目前最新版本3.3，2013年收入超过13亿美元
```

![kvm_01](http://images.zsjshao.net/kvm/kvm_01.png)

#### 1.2.2、虚拟机：

虚拟计算机系统称为“虚拟机”(VM)，它是一种严密隔离且内含操作系统和应用的软件容器。每个自包含虚拟机都是完全独立的。通过将多台虚拟机放置在一台计算机上，可仅在一台物理服务器或“主机”上运行多个操作系统和应用，名为“hypervisor”的精简软件层可将虚拟机与主机分离开来，并根据需要为每个虚拟机动态分配计算资源。
虚拟机的主要特性

```
分区
可在一台物理机上运行多个操作系统。
可在虚拟机之间分配系统资源。

隔离
可在硬件级别进行故障和安全隔离。
可利用高级资源控制功能保持性能。

封装
可将虚拟机的完整状态保存到文件中。
移动和复制虚拟机就像移动和复制文件一样轻松。

独立于硬件
可将任意虚拟机调配或迁移到任意物理服务器上。
```

#### 1.2.3、虚拟化类型：

##### 1.2.3.1、服务器虚拟化：

服务器虚拟化支持将多个操作系统作为高效的虚拟机在单个物理服务器上运行。主要优势包括：

```
提升 IT 效率
降低运维成本
更快地部署工作负载
提高应用性能
提高服务器可用性
消除服务器数量剧增情况和复杂性
```

##### 1.2.3.2、网络虚拟化：

通过完全复制物理网络，网络虚拟化支持应用在虚拟网络上运行，就像在物理网络上运行一样 - 但它具有更大的运维优势并可实现虚拟化的所有硬件独立性。（网络虚拟化为连接的工作负载提供逻辑网络连接设备和服务，包括逻辑端口、交换机、路由器、防火墙、负载均衡器、VPN 等。

##### 1.2.3.3、桌面虚拟化：

将桌面部署为代管服务使 IT 组织能够更快地响应不断变化的工作场所需求和新出现的机会。还可以将虚拟化桌面和应用快速、轻松地交付给分支机构、外包和离岸员工以及使用 iPad 和 Android 平板电脑的移动员工。

##### 1.2.3.4、应用虚拟化：

将办公软件虚拟化，最典型的就是office

##### 1.2.3.5、存储虚拟化：

SAN(基于磁盘)/NAS(NFS/Samba)/GlusterFS/ceph等

##### 1.2.3.6、库虚拟化

在linux上运行windows 程序使用 wine，在mac系统运行windows程序使用CrossOver等

##### 1.2.3.7、容器虚技术

被称为下一代虚拟化技术，典型的就是docker、Linux Container(LXC)、pouch

#### 1.2.4、虚拟化技术厂商：

![kvm_02](http://images.zsjshao.net/kvm/kvm_02.png)

#### 1.2.5、云计算

云计算是概念最早是由Google 前首席执行官埃里克•施密特（Eric Schmidt）在2006 年8 月9 日的搜索引擎大会上首次提出的一种构想，而“云计算”就是这种构想的代名词，云计算以虚拟化为基础，以网络为中心，为用户提供安全、快速、便捷的数据存储和网络计算服务，包括所需要的硬件、平台、软件及服务等资源，而提供资源的网络就被称为“云”。

##### 1.2.6.1、云计算分类：

```
公有云：比如aws、阿里云以及azure、金山云、腾讯云等都属于公有云，每个人都可以付费使用，不需要自己关心底层硬件，但是数据安全需要考利。
私有云：在自己公司内部或IDC自建Openstack、VMware等环境
混合云：既要使用公有云，又要使用私有云，即自己的私有云的部分业务和公有云有交接，这部分称为混合云
```

##### 1.2.6.2、云计算分层：

IaaS：基础设施服务，Infrastructure-as-a-service #自建机房 

PaaS：平台服务，Platform-as-a-service #公有云上的Redis、RDS等服务，甚至是手机上的APP 

SaaS：软件服务，Software-as-a-service #企业邮箱、OA系统等

![kvm_03](http://images.zsjshao.net/kvm/kvm_03.png)

#### 1.2.7、虚拟化技术分类：

模拟器：在一个host之上通过虚拟化模拟器软件，模拟出一个硬件或者多个硬件环境，每个环境都是一个独立的虚拟机，CPU、IO、内存等都是模拟出来的，可以在宿主机模拟出不同于当前物理机CPU指令集的虚拟机，比如可以在Windows 模拟出mac OS、unix系统，比较出名的模拟器有：pearpc、QEMU、Bochs。

全虚拟机化/准虚拟化：full virtualization/native virtualization，全虚拟化不做CPU和内存模拟，只对CPU和内存做相应的分配等操作，完全虚拟化需要物理硬件的支持，比如需要CPU必须支持并且打开虚拟化功能，例如Intel的 Intel VT-X/EPT，AMD的AMD-V/RVI，以在CPU 层面支持虚拟化功能和内存虚拟化技术，因此完全虚拟化是基于硬件辅助的虚拟化技术，vmware workstation、vmware esxi、paralles desktop、KVM、Microsoft Hyper-V。

半虚拟化：para virtualization，半虚拟化要求guest OS 的内核是知道自己运行在虚拟化环境当中的，因此guestOS的系统架构必须和宿主机的系统架构相同，并且要求对guest OS的内核做相应的修改，因此半虚拟化只支持开源内核的系统，不支持闭源的系统，比较常见的半虚拟化就是早期版本的XEN，但是Xen 从其3.0 版本开始，可以支持利用硬件虚拟化技术的支持(http://www-archive.xenproject.org/files/xen_3.0_datasheet.pdf)，实现了完全虚拟化，可以在其平台上不加修改的直接运行如Linux/Windows 等系列的操作系统，使得系统具备了更好的兼容性。

![kvm_04](http://images.zsjshao.net/kvm/kvm_04.png)

#### 1.2.8、hypervisor类型：

直接运行到物理机：vmware esxi、rhev hypervisor

需要运行到操作系统：KVM，XEN，vmware workstation

## 二、虚拟化技术之KVM：

KVM 是Kernel-based Virtual Machine的简称，是一个开源的系统虚拟化模块，自Linux 2.6.20之后集成在Linux的各个主要发行版本中。它使用Linux自身的调度器进行管理，所以相对于Xen（https://zhuanlan.zhihu.com/p/33324585），其核心源码很少。KVM目前已成为学术界的主流VMM之一。 KVM的虚拟化需要硬件支持（如Intel VT技术或者AMD V技术)。是基于硬件的完全虚拟化。而Xen早期则是基于软件模拟的Para-Virtualization，新版本则是基于硬件支持的完全虚拟化。但Xen本身有自己的进程调度器，存储管理模块等，所以代码较为庞大。广为流传的商业系统虚拟化软件VMware ESXI系列是Full-Virtualization，IBM文档：http://www.ibm.com/developerworks/cn/linux/l-using-kvm/

```
Guest：客户机系统，包括CPU（vCPU）、内存、驱动（Console、网卡、I/O 设备驱动等），被KVM置于一种受限制的CPU模式下运行。
KVM：运行在内核空间，提供 CPU 和内存的虚级化，以及客户机的 I/O拦截，Guest的部分I/O被KVM拦截后，交给 QEMU处理。
QEMU：修改过的被KVM虚机使用的QEMU代码，运行在用户空间，提供硬件I/O虚拟化，通过IOCTL/dev/kvm设备和KVM交互，但是，KVM本身不执行任何硬件模拟，需要用户空间程序通过 /dev/kvm 接口设置一个客户机虚拟服务器的地址空间，向它提供模拟I/O，并将它的视频显示映射回宿主的显示屏。目前这个应用程序是QEMU
```

![kvm_05](http://images.zsjshao.net/kvm/kvm_05.png)

### 2.1、宿主机环境准备：

KVM需要宿主机CPU必须支持虚拟化功能，因此如果是在vmware workstation上使用虚拟机做宿主机，那么必须
要在虚拟机配置界面的处理器选项中开启虚拟机化功能。

#### 2.1.1、CPU开启虚拟化：
![kvm_06](http://images.zsjshao.net/kvm/kvm_06.png)

#### 2.1.2、确认CPU指令集：

X86/x86_64-Intel、AMD
ARM-手机、pad、机顶盒，https://baike.baidu.com/item/ARM/5907?fr=aladdin
Power-IBM
http://tech.sina.com.cn/it/2005-06-07/0701628180.shtml

```
[root@c81 ~]# grep -E "vmx|svm" /proc/cpuinfo | wc -l
4
```

#### 2.1.3、安装KVM工具包：

```
[root@c81 ~]# dnf install qemu-kvm libvirt virt-install acpid -y
[root@c81 ~]# systemctl start libvirtd
[root@c81 ~]# systemctl enable libvirtd
[root@c81 ~]# ip addr show virbr0
4: virbr0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN group default qlen 1000
    link/ether 52:54:00:63:ac:89 brd ff:ff:ff:ff:ff:ff
    inet 192.168.122.1/24 brd 192.168.122.255 scope global virbr0
       valid_lft forever preferred_lft forever

修改默认nat网卡
[root@c81 ~]# virsh net-edit default
[root@c81 ~]# cat /etc/libvirt/qemu/networks/default.xml
```

### 2.2、创建NAT网络虚拟机：

#### 2.2.1、创建磁盘：

```
[root@c81 ~]# ll /var/lib/libvirt/images/   #默认保存虚拟机磁盘的路径
[root@c81 ~]# qemu-img create -f raw /var/lib/libvirt/images/centos-8-x86_64.raw 10G
Formatting '/var/lib/libvirt/images/centos-8-x86_64.raw', fmt=raw size=10737418240

[root@c81 ~]# qemu-img create -f qcow2 /var/lib/libvirt/images/centos-8-x86_64.qcow2 10G
Formatting '/var/lib/libvirt/images/centos-8-x86_64.qcow2', fmt=qcow2 size=10737418240 cluster_size=65536 lazy_refcounts=off refcount_bits=16

[root@c81 ~]# ll -h /var/lib/libvirt/images/
total 200K
-rw-r--r--. 1 root root 193K Mar 11 17:05 centos-8-x86_64.qcow2
-rw-r--r--. 1 root root  10G Mar 11 17:04 centos-8-x86_64.raw
```

#### 2.2.2、virsh-install命令使用帮助：

```
[root@c81 ~]# virt-install --help
usage: virt-install --name NAME --memory MB STORAGE INSTALL [options]

Create a new virtual machine from specified install media.

optional arguments:
  -h, --help            show this help message and exit
  --version             show program's version number and exit
  --connect URI         Connect to hypervisor with libvirt URI

General Options:
  -n NAME, --name NAME  Name of the guest instance
  --memory MEMORY       Configure guest memory allocation. Ex:
                        --memory 1024 (in MiB)
                        --memory memory=1024,currentMemory=512
  --vcpus VCPUS         Number of vcpus to configure for your guest. Ex:
                        --vcpus 5
                        --vcpus 5,maxvcpus=10,cpuset=1-4,6,8
                        --vcpus sockets=2,cores=4,threads=2
  --cpu CPU             CPU model and features. Ex:
                        --cpu coreduo,+x2apic
                        --cpu host-passthrough
                        --cpu host
  --metadata METADATA   Configure guest metadata. Ex:
                        --metadata name=foo,title="My pretty title",uuid=...
                        --metadata description="My nice long description"

Installation Method Options:
  --cdrom CDROM         CD-ROM installation media
  -l LOCATION, --location LOCATION
                        Distro install URL, eg. https://host/path. See man
                        page for specific distro examples.
  --pxe                 Boot from the network using the PXE protocol
  --import              Build guest around an existing disk image
  -x EXTRA_ARGS, --extra-args EXTRA_ARGS
                        Additional arguments to pass to the install kernel
                        booted from --location
  --initrd-inject INITRD_INJECT
                        Add given file to root of initrd from --location
  --unattended [UNATTENDED]
                        Perform an unattended installation
  --install INSTALL     Specify fine grained install options
  --boot BOOT           Configure guest boot settings. Ex:
                        --boot hd,cdrom,menu=on
                        --boot init=/sbin/init (for containers)
  --idmap IDMAP         Enable user namespace for LXC container. Ex:
                        --idmap uid.start=0,uid.target=1000,uid.count=10

OS options:
  --os-variant OS_VARIANT
                        The OS being installed in the guest.
                        This is used for deciding optimal defaults like virtio.
                        Example values: fedora29, rhel7.0, win10, ...
                        See 'osinfo-query os' for a full list.

Device Options:
  --disk DISK           Specify storage with various options. Ex.
                        --disk size=10 (new 10GiB image in default location)
                        --disk /my/existing/disk,cache=none
                        --disk device=cdrom,bus=scsi
                        --disk=?
  -w NETWORK, --network NETWORK
                        Configure a guest network interface. Ex:
                        --network bridge=mybr0
                        --network network=my_libvirt_virtual_net
                        --network network=mynet,model=virtio,mac=00:11...
                        --network none
                        --network help
  --graphics GRAPHICS   Configure guest display settings. Ex:
                        --graphics spice
                        --graphics vnc,port=5901,listen=0.0.0.0
                        --graphics none
  --controller CONTROLLER
                        Configure a guest controller device. Ex:
                        --controller type=usb,model=qemu-xhci
                        --controller virtio-scsi
  --input INPUT         Configure a guest input device. Ex:
                        --input tablet
                        --input keyboard,bus=usb
  --serial SERIAL       Configure a guest serial device
  --parallel PARALLEL   Configure a guest parallel device
  --channel CHANNEL     Configure a guest communication channel
  --console CONSOLE     Configure a text console connection between the guest
                        and host
  --hostdev HOSTDEV     Configure physical USB/PCI/etc host devices to be
                        shared with the guest
  --filesystem FILESYSTEM
                        Pass host directory to the guest. Ex: 
                        --filesystem /my/source/dir,/dir/in/guest
                        --filesystem template_name,/,type=template
  --sound [SOUND]       Configure guest sound device emulation
  --watchdog WATCHDOG   Configure a guest watchdog device
  --video VIDEO         Configure guest video hardware.
  --smartcard SMARTCARD
                        Configure a guest smartcard device. Ex:
                        --smartcard mode=passthrough
  --redirdev REDIRDEV   Configure a guest redirection device. Ex:
                        --redirdev usb,type=tcp,server=192.168.1.1:4000
  --memballoon MEMBALLOON
                        Configure a guest memballoon device. Ex:
                        --memballoon model=virtio
  --tpm TPM             Configure a guest TPM device. Ex:
                        --tpm /dev/tpm
  --rng RNG             Configure a guest RNG device. Ex:
                        --rng /dev/urandom
  --panic PANIC         Configure a guest panic device. Ex:
                        --panic default
  --memdev MEMDEV       Configure a guest memory device. Ex:
                        --memdev dimm,target.size=1024
  --vsock VSOCK         Configure guest vsock sockets. Ex:
                        --vsock cid.auto=yes
                        --vsock cid.address=7

Guest Configuration Options:
  --iothreads IOTHREADS
                        Set domain <iothreads> and <iothreadids>
                        configuration.
  --seclabel SECLABEL, --security SECLABEL
                        Set domain seclabel configuration.
  --cputune CPUTUNE     Tune CPU parameters for the domain process.
  --numatune NUMATUNE   Tune NUMA policy for the domain process.
  --memtune MEMTUNE     Tune memory policy for the domain process.
  --blkiotune BLKIOTUNE
                        Tune blkio policy for the domain process.
  --memorybacking MEMORYBACKING
                        Set memory backing policy for the domain process. Ex:
                        --memorybacking hugepages=on
  --features FEATURES   Set domain <features> XML. Ex:
                        --features acpi=off
                        --features apic=on,apic.eoi=on
  --clock CLOCK         Set domain <clock> XML. Ex:
                        --clock offset=localtime,rtc_tickpolicy=catchup
  --pm PM               Configure VM power management features
  --events EVENTS       Configure VM lifecycle management policy
  --resource RESOURCE   Configure VM resource partitioning (cgroups)
  --sysinfo SYSINFO     Configure SMBIOS System Information. Ex:
                        --sysinfo host
                        --sysinfo bios.vendor=MyVendor,bios.version=1.2.3,...
  --qemu-commandline QEMU_COMMANDLINE
                        Pass arguments directly to the qemu emulator. Ex:
                        --qemu-commandline='-display gtk,gl=on'
                        --qemu-commandline env=DISPLAY=:0.1
  --launchSecurity LAUNCHSECURITY, --launchsecurity LAUNCHSECURITY
                        Configure VM launch security (e.g. SEV memory encryption). Ex:
                        --launchSecurity type=sev,cbitpos=47,reducedPhysBits=1,policy=0x0001,dhCert=BASE64CERT
                        --launchSecurity sev

Virtualization Platform Options:
  -v, --hvm             This guest should be a fully virtualized guest
  -p, --paravirt        This guest should be a paravirtualized guest
  --container           This guest should be a container guest
  --virt-type VIRT_TYPE
                        Hypervisor name to use (kvm, qemu, xen, ...)
  --arch ARCH           The CPU architecture to simulate
  --machine MACHINE     The machine type to emulate

Miscellaneous Options:
  --autostart           Have domain autostart on host boot up.
  --transient           Create a transient domain.
  --destroy-on-exit     Force power off the domain when the console viewer is
                        closed.
  --wait [WAIT]         Minutes to wait for install to complete.
  --noautoconsole       Don't automatically try to connect to the guest
                        console
  --noreboot            Don't boot guest after completing install.
  --print-xml [XMLONLY]
                        Print the generated domain XML rather than create the
                        guest.
  --dry-run             Run through install process, but do not create devices
                        or define the guest.
  --check CHECK         Enable or disable validation checks. Example:
                        --check path_in_use=off
                        --check all=off
  -q, --quiet           Suppress non-error output
  -d, --debug           Print debugging information

Use '--option=?' or '--option help' to see available suboptions
See man page for examples and full option syntax.
```

#### 2.2.3、创建NAT网络虚拟机：

##### 2.2.3.1、上传镜像并安装虚拟机：

```
[root@c81 src]# ll -h /usr/local/src/CentOS-8-x86_64-1905-boot.iso #上传好的镜像
-rw-r--r--. 1 root root 534M Mar 11 17:16 /usr/local/src/CentOS-8-x86_64-1905-boot.iso

[root@c81 src]# qemu-img create -f qcow2 /var/lib/libvirt/images/centos.qcow2 10G

[root@c81 src]# virt-install --virt-type kvm --name centos8 --memory 1024 --vcpus 2 --cdrom=/usr/local/src/CentOS-8.1.1911-x86_64-dvd1.iso --disk path=/var/lib/libvirt/images/centos.qcow2 --network network=default --graphics vnc,listen=0.0.0.0 --noautoconsole

[root@c81 src]# cat /etc/libvirt/qemu/centos8.xml
```

##### 2.2.3.2、通过VNC客户端连并安装虚拟机：

连接宿主机IP：5900、vnc默认从5900端口开始，其他虚拟机依次往后推

![kvm_07](http://images.zsjshao.net/kvm/kvm_07.png)

![kvm_08](http://images.zsjshao.net/kvm/kvm_08.png)

##### 2.2.3.3、安装完成后需手动重启

```
[root@c81 src]# virsh list --all
 Id    Name                           State
----------------------------------------------------
 -     centos8.1                      shut off

[root@c81 src]# virsh start centos8.1
Domain centos8.1 started

[root@c81 src]# virsh list --all
 Id    Name                           State
----------------------------------------------------
 3     centos8.1                      running
```

##### 2.2.3.4、登录到虚拟机

![kvm_09](http://images.zsjshao.net/kvm/kvm_09.png)

#### 2.2.4、创建bridge网络虚拟交换机：

桥接网络可以让运行在宿主机上的虚拟机使用和宿主机同网段IP，并且可以从外部直接访问到虚拟机，目前企业中大部分场景都使用桥接网络。

##### 2.2.4.1、创建team0网卡：

```
[root@localhost ~]# nmcli con add type team con-name team0 ifname team0 config '{"runner":{"name":"loadbalance"}}'
[root@localhost ~]# nmcli con add con-name team0-eth0 type team-slave ifname eth0 master team0
[root@localhost ~]# nmcli con add con-name team0-eth1 type team-slave ifname eth1 master team0
```

##### 2.2.4.2、创建br0桥接网卡：

```
[root@localhost network-scripts]# nmcli connection add type bridge con-name br0 ifname br0 ipv4.addresses 192.168.3.28/24 ipv4.gateway 192.168.3.1 ipv4.dns 192.168.3.1 ipv4.method manual
[root@localhost network-scripts]# nmcli connection add type bridge-slave ifname team0 master br0
[root@localhost network-scripts]# cat ifcfg-team0 >> ifcfg-bridge-slave-team0
[root@localhost network-scripts]# cat ifcfg-bridge-slave-team0
TYPE=Ethernet
NAME=bridge-slave-team0
DEVICE=team0
ONBOOT=yesnmcli
BRIDGE=br0

TEAM_CONFIG="{\"runner\":{\"name\":\"loadbalance\"}}"
PROXY_METHOD=none
BROWSER_ONLY=no
BOOTPROTO=none
DEFROUTE=yes
IPV4_FAILURE_FATAL=no
IPV6INIT=yes
IPV6_AUTOCONF=yes
IPV6_DEFROUTE=yes
IPV6_FAILURE_FATAL=no
IPV6_ADDR_GEN_MODE=stable-privacy
#NAME=team0
#DEVICE=team0
#ONBOOT=yes
DEVICETYPE=Team

[root@localhost network-scripts]# nmcli con reload && nmcli con up br0 && nmcli con down team0 && nmcli con down eth0 && nmcli con up team0-eth0 && nmcli con up bridge-slave-team0
```

注：注意当前激活的网卡，需要启动的网卡有br0、bridge-slave-team0、team0-eth0、team0-eth1，需要关闭的网卡有team0、eth0、eth1。

##### 2.2.4.3、上传镜像并安装虚拟机

```
[root@localhost ~]# qemu-img create -f qcow2 /var/lib/libvirt/images/centos8-bridge.qcow2 10G
[root@localhost ~]# virt-install --virt-type kvm --name centos8 --memory 1024 --vcpus 2 --cdrom=/var/lib/libvirt/images/CentOS-8.1.1911-x86_64-dvd1.iso --disk path=/var/lib/libvirt/images/centos8-bridge.qcow2 --network bridge=br0 --graphics vnc,listen=0.0.0.0 --noautoconsole
```

##### 2.2.4.4、使用vnc工具安装系统，重启后查看IP地址

![kvm_10](http://images.zsjshao.net/kvm/kvm_10.png)

##### 2.2.4.5、使用xshell远程工具连接

![kvm_11](http://images.zsjshao.net/kvm/kvm_11.png)

#### 2.2.5、虚拟机管理命令

```
virsh list #列出当前开机的
virsh edit CentOS-7-x86_64 #查看虚拟机配置文件
virsh list --all 列出所有
virsh shutdown CentOS-7-x86_64 #正常关机
virsh start CentOS-7-x86_64 #正常关机
virsh destroy centos7 #强制停止/关机
virsh undefine Win_2008_r2-x86_64 #强制删除
virsh autostart centos7 #设置开机自启动

vim /etc/default/grub
GRUB_CMDLINE_LINUX="... console=ttyS0"
grub2-mkconfig -o /boot/grub2/grub.cfg

virsh console centos7

默认ttyS设备
ls /dev/ttyS
ttyS0  ttyS1  ttyS2  ttyS3 
```

