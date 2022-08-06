+++
author = "zsjshao"
title = "09_IPAM"
date = "2022-08-04"
tags = ["windows"]
categories = ["windows"]

+++

# IPAM

## 1、IPAM简介

IP 地址管理 (IPAM) 是一套集成工具，支持端到端规划、部署、管理和监视你的 IP 地址基础结构，同时提供丰富的用户体验。 IPAM 自动发现网络上的 IP 地址基础结构服务器和域名系统 (DNS) 服务器，使用户能够从中心界面管理它们。

## 2、IPAM安装

| 服务器名称          | IP地址       | 网关       |
| ------------------- | ------------ | ---------- |
| dc01.zsjshao.cn     | 10.0.0.1/8   | 10.0.0.254 |
| app01.zsjshao.cn    | 10.0.0.11/8  | 10.0.0.254 |
| app02.zsjshao.cn    | 10.0.0.12/8  | 10.0.0.254 |
| manage.zsjshao.cn   | 10.0.0.200/8 | 10.0.0.254 |
| client01.zsjshao.cn | DHCP自动获取 |            |

> 按照表中名称和地址网关配置服务器，DNS服务器均为dc01，即10.0.0.1

### 2.1、域环境部署

1、安装域控

```
PS C:\Users\Administrator> Add-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

Success Restart Needed Exit Code      Feature Result
------- -------------- ---------      --------------
True    No             Success        {Active Directory 域服务, 组策略管理, 远程...

```

2、安装新林

```
$DSRMPW = ConvertTo-SecureString "1234.com" -AsPlainText -Force
Install-ADDSForest -DomainName "zsjshao.cn" -SafeModeAdministratorPassword $DSRMPW -Force:$true
```

3、成员服务器加域

```
Add-Computer zsjshao.cn
```

> 输入域成员的凭据

### 2.2、dhcp环境部署

1、安装dhcp服务

```
Invoke-Command -ComputerName app01,app02 -ScriptBlock { Install-WindowsFeature -Name DHCP -IncludeManagementTools }
```

2、dhcp授权

```
# 在app01上执行命令
netsh dhcp add securitygroups
Add-DhcpServerInDC -DnsName app01.zsjshao.cn

# 在app02上执行命令
netsh dhcp add securitygroups
Add-DhcpServerInDC -DnsName app02.zsjshao.cn
```

> 需要安装dhcp管理工具

3、创建作用域

```
Invoke-Command -ComputerName app01 -ScriptBlock { Add-DhcpServerv4Scope -Name app01-10.x/8 -StartRange 10.0.0.100 -EndRange 10.0.0.149 -SubnetMask 255.0.0.0 -State Active }

Invoke-Command -ComputerName app02 -ScriptBlock { Add-DhcpServerv4Scope -Name app02-10.x/8 -StartRange 10.0.0.150 -EndRange 10.0.0.199 -SubnetMask 255.0.0.0 -State Active }
```

4、配置作用域选项

```
Invoke-Command -ComputerName app01,app02 -ScriptBlock { Set-DhcpServerv4OptionValue -ScopeId 10.0.0.0 -Route 10.0.0.254 -DnsServer 10.0.0.1 -DnsDomain zsjshao.cn }
```

### 2.3、IPAM安装

1、添加角色和功能

![ipam01](http://images.zsjshao.cn/images/windows/ipam01.png)

2、连接IPAM服务器

![ipam02](http://images.zsjshao.cn/images/windows/ipam02.png)

3、设置IPAM服务器，设置GPO名称前缀

![ipam03](http://images.zsjshao.cn/images/windows/ipam03.png)

4、配置服务器发现

![ipam04](http://images.zsjshao.cn/images/windows/ipam04.png)

![ipam05](http://images.zsjshao.cn/images/windows/ipam05.png)

5、启动服务器发现

![ipam06](http://images.zsjshao.cn/images/windows/ipam06.png)

6、执行命令

```c
Invoke-IpamGpoProvisioning -Domain zsjshao.cn -GpoPrefixName ipam -IpamServerFqdn manage.zsjshao.cn -DelegatedGpoUser zsjshao\administrator -Force
```

> 注意：命令需要确认3次

7、在dc上查看策略

![ipam07](http://images.zsjshao.cn/images/windows/ipam07.png)

8、修改ipam_dhcp组策略的安全筛选

![ipam08](http://images.zsjshao.cn/images/windows/ipam08.png)

9、更新策略重启

```
Invoke-GPUpdate -Computer app01
Restart-Computer -ComputerName app01 -Force

Invoke-GPUpdate -Computer app02
Restart-Computer -ComputerName app02 -Force

Invoke-GPUpdate -Computer manage
Restart-Computer -ComputerName manage -Force
```

> 为了成功计划使用此cmdlet的计算机的组策略刷新，必须在每个客户端计算机上设置以下防火墙规则，以允许以下连接：
>
> 远程计划任务管理（RPC）
>
> 远程计划任务管理（RPC-ERMAP）
>
> Windows管理检测（WMI-IN）

10、添加服务器

![ipam09](http://images.zsjshao.cn/images/windows/ipam09.png)

> 注意：app02需要做同样的操作

11、检索所有服务器数据

![ipam10](http://images.zsjshao.cn/images/windows/ipam10.png)

12、查看状态

![ipam11](http://images.zsjshao.cn/images/windows/ipam11.png)

13、查看IP地址块

![ipam12](http://images.zsjshao.cn/images/windows/ipam12.png)

## 3、IPAM添加作用域

1、在app01上新建作用域

![ipam13](http://images.zsjshao.cn/images/windows/ipam13.png)

2、设置作用域常规属性

![ipam14](http://images.zsjshao.cn/images/windows/ipam14.png)

3、设置DHCP作用域选项

![ipam15](http://images.zsjshao.cn/images/windows/ipam15.png)

4、在app01上查看

![ipam16](http://images.zsjshao.cn/images/windows/ipam16.png)

5、客户端地址获取测试

![ipam17](http://images.zsjshao.cn/images/windows/ipam17.png)

> 注意：跨网段获取IP地址需要配置DHCP中继或超级作用域

## 4、官方文档参考

IP 地址管理 (IPAM)：

https://docs.microsoft.com/zh-cn/windows-server/networking/technologies/ipam/ipam-top

IPAM 服务器上的 Windows powershell 命令行：

https://docs.microsoft.com/zh-cn/powershell/module/ipamserver/?view=win10-ps