## 1、虚拟化产商、技术

- 服务器虚拟化
  - VMware ESX
  - XenServer
  - Hyper-v

- 应用程序虚拟化
  - VMware ThinAPP
  - APP-v/RD APP
- 虚拟桌面架构
  - VMware View
  - XenDesktop
  - RDS VDI

## 2、Hyper-v

### 2.1、Hyper-v发展历程

2003年2月19日 微软收购Connectix Virtual PC，并在2004年发表第一个虚拟化产品Microsoft Virtual PC 2004

2005年微软发布了服务器的虚拟化产品Virtual Server 2005用来弥补Microsoft Virtual PC 2004功能上的不足

2008年2月27日，Windows Server 2008发布，Windows Server 2008 X64版本中携带全新的虚拟化产品Hyper-v 1.0

2009年8月11日，发布Windows 2008 R2，自带Hyper-v 2.0，2012年9月4日，发布了Windows Server 2012，自带Hyper-v 3.0

### 2.2、Hyper3.0 新功能

| 功能名称      | 描述                                                         |
| ------------- | ------------------------------------------------------------ |
| 客户端Hyper-v | 集成到客户端操作系统（Windows 8）                            |
| PowerShell    | 使用Windows PowerShell可创建和管理Hyper-v环境                |
| Hyper-v复制   | 更加廉价的Hyper-v高可用解决方案                              |
| 存储迁移      | 可以在不停机的情况下迁移存储到新位置                         |
| 虚拟光纤通道  | 从来宾操作系统内连接到光纤通道存储                           |
| 虚拟磁盘格式  | 创建高达64TB的稳定、高性能的虚拟磁盘                         |
| 虚拟交换机    | 如网络虚拟化这样的新功能将支持多用户管理，以及Microsoft伙伴可提供的扩展，从而添加监视、转发和筛选数据包的功能 |

### 2.3、Hyper-v 3.0部署需求

服务器CPU支持虚拟化，并且在BIOS中启用虚拟化支持

在BIOS中企业DEP（数据执行保护）

安装Windows Server2012，Windows8 X64系统

安装Hyper-v组件

### 2.4、Hyper-v 3.0磁盘

两种磁盘存储类型：VDH和VDHX

- VDH是传统的磁盘类型，最多支持2TB空间；VHDX是Windows 2012特有的磁盘类型，最多支持64TB空间，存储效率更高

两种磁盘接口：IDE和SCSI

- IDE：最多支持4块硬盘，OS必须安装在IDE中，需要重启才能添加
- SCSI：最多支持256块磁盘，OS不能安装在SCSI中，添加无需关机

创建磁盘三种类型：动态扩展，固定大小，差异

有两种类型：网络适配器和旧版的网络适配器

- 网络适配器：支持10Gbps，需要安装驱动才能使用

- 旧版网络适配器：100Mb网卡，PXE网卡

三种网络类型：外部网络、内部网络和专用网络

### 2.5、Hyper-v 备份

System Center Date Protection Manager

同一的管理平台，更加方便的虚拟机和存储的迁移

对所有的宿主机和虚拟机性能全面的监控

智能的对虚拟机进行迁移

P2V，V2V

Portal功能，更加方面的为公司提供虚拟化服务

Symantec Backup EXEC





## 群集滚动升级



```
Update-ClusterFunctionalLevel -Cluster clu2016.zsjshao.com
```





停止群集服务

```
icm node3 {Stop-Process -Name clussvc -Force}
```





