+++
author = "zsjshao"
title = "99_Nano Server"
date = "2022-09-09"
tags = ["windows"]
categories = ["windows"]

+++

# Nano Server

## 1、Nano Server

Nano Server是一个安装选项

- 位于Windows Server安装介质上

- 必须定制以确定其功能

零占用模型

- 服务器角色和功能，需要预先添加到Nano Server

- 从本地/云存储库安装，类似应用程序的独立软件包

提供基础架构级别的主要角色和功能

- Hyper-V、存储（SoFC）、网络（DNS）、群集

- 核心CLR、ASP.NET 5和PaaS

完整的Windows Server驱动程序支持

反恶意软件作为可选功能

## 2、Nano Server 快速入门

Nano Server文件夹中包含的脚本，以便轻松构建自定义的Nano Server映像

- NanoServerImageGenerator.psm1

- Convert-WindowsImage.ps1

使用脚本生成Nano Server映像

- PHYSICAL MACHINE

- VIRTUAL MACHINE

```
New-NanoSerrverImage -MediaPath F:\ -BasePath .\Base -TargetPath .\NanoVM\SRV-Nano.vhd -ComputerName SRV-Name -GuestDrivers -Storage -Clustering

-Storage：文件服务
-Clustering：集群服务
```

## 3、Nano Server角色和功能

表中显示了此版本的Nano Server中可用的角色和功能，以及将为其安装软件包的Windows PowerShell选项

| Role or Feature                                              | Option                                                       |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| Hyper-V role                                                 | -Compute                                                     |
| Failover clustering                                          | -Clustering                                                  |
| File server role and other storage components                | -Storage                                                     |
| Windows Defender antimalware, including a default signature file | -Defender                                                    |
| OEM drivers —— select drivers that ship in-box with Server Core | -OEMDrivers                                                  |
| Reverse forwarders for application compatibility, for example common application frameworks such as Ruby, Node.js, etc | -ReverseForwarders                                           |
| Hyper-V guest drivers for hosting Nano Server as a VM        | -GuestDrivers                                                |
| Host Support for Windows Container                           | -Containers                                                  |
| DNS Server Role                                              | -Packages Microsoft-NanoServer-DNS-Package                   |
| Desired State Configuration                                  | -Packages Microsoft-NanoServer-DSC-Package                   |
| IIS Web Server                                               | -Packages Microsoft-NanoServer-IIS-Package                   |
| System Center VMM Agent                                      | -Packages Microsoft-Windows-Server--SCVMM-Package<br />-Packages Microsoft-Windows-Server--SCVMM-Compute-Package |
| Network Perf Diagnostics Service(NPDS)                       | -Packages Microsoft-NanoServer-NPDS-Package                  |
| Data Center Bridging                                         | -Packages Microsoft-NanoServer-DCB-Package                   |

## 4、远程管理Nano Server

Remote graphical&Web tools

PowerShell remoting

VM&容器 management

Deployment & monitoring

Partners & Frameworks

![nanoserver01](http://images.zsjshao.cn/images/windows/nanoserver01.png)



## 5、镜像构建

```
mkdir C:\nano

copy F:\NanoServer\NanoServerImageGenerator\*.ps* C:\nano

Import-Module C:\Nano\NanoServerImageGenerator.psm1

New-NanoServerImage
  -DeploymentType Guest
  -Edition Datacenter
  -MediaPath F:\
  -BasePath C:\nano
  -TargetPath C:\nano.vhdx
  -Package Microsoft-NanoServer-IIS-Package,Microsoft-NanoServer-Storage-Package
  -ComputerName Nano
  -InterfaceNameOrIndex Ethernet
  -Ipv4Address 172.16.0.111
  -Ipv4SubnetMask 255.255.255.0
  -Ipv4Gateway 172.16.0.254
  -Ipv4Dns 172.16.0.254
  -Verbose

-DeploymentType Guest|Host
```

## 6、防火墙

Inbound Firewall Rules -> File and Printer Sharing(SMB-In) -> F4(Enable)

Inbound Firewall Rules -> File and Printer Sharing（Echo Request - ICMPv4 - In) -> F4(Enable)

WinRM -> ENTER

## 7、加域

```
$Name = "nano"
$IP = "172.16.0.111"
$UserName = "$IP\administrator"
$Password = ConvertTo-SecureString "1234.com" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($UserName,$Password)
$DomainName = "zsjshao.cn"

djoin.exe /provision /domain zsjshao.cn /machine $Name /savefile C:\$Name.txt
Copy-Item C:\$Name.txt -Destination \\$IP\C$
Set-Item WSman:\localhost\Client\TrustedHosts $IP
Enter-PSSession -ComputerName $IP -Credential $Credential

djoin.exe /reuestodj /loadfile C:\nano.txt /windowspath C:\windows /localos
Restart-Computer
```

