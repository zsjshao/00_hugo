+++
author = "zsjshao"
title = "01_AD域"
date = "2022-08-04"
tags = ["windows"]
categories = ["windows"]
+++

## AD域

https://docs.microsoft.com/zh-cn/windows-server/identity/ad-ds/ad-ds-getting-started

1．额外域控制器
域控制器在活动目录中的作用是非常重要的，出于数据备份和负载分担的目的，在一个域中应该至少安装两台DC，这样可以避免由于DC的单点故障所引发的一系列问题。
安装额外域控制器的过程实质上是域信息的复制过程，安装额外域控制器的过程会将活动目录的所有信息进行复制，并最终同第一台域控制器数据完全一致。此时，如果主域控制器宕机，活动目录不会失效，域的工作可以交由额外域控制器进行，因此额外域控制器在活动目录中起到数据备份、负载分担的作用。
2．全局编录
一个域的活动目录只能存储该域的信息，相当于这个域的目录。而当一个目录林中有多个域时，由于每个域都有一个活动目录，因此如果一个域的用户要在整个目录林范围内查找一个对象时就需要搜索目录林中的所有域，这时，全局编录（Global Catalog，GC）就起到作用了。
全局编录相当于一个总目录，就像一套丛书中有一个总目录一样，在全局编录中存储了已有活动目录对象的子集，默认情况下，存储在全局编录的对象属性是那些经常用到的内容，而非全部属性。整个目录林会共享相同的全局编录信息。此时，如果一个域中的用户进行查找，就可以依托这个总目录快速找到所要查找的对象了。
全局编录存放在全局编录服务器上，全局编录服务器必须是一台域控制器，在Windows Server 2012中，默认情况下域中的所有域控制器都是全局编录服务器。GC中的对象包含访问权限，用户只能看见有访问权限的对象，如果一个用户对某个对象没有权限，在查找时将看不到这个对象。 

## 用户和组

工作组

net user

net localgroup



域

net user

net group

dsadd

dsmod

dsget

dsrm



导出：csvde -d "OU=Sales,DC=zsjshao,DC=net" -f Sales_user.csv

l：市/县

c：国家

st：省份

company：公司

title：职称

displayname：显示名称

dn：cn=用户,ou=Sales,dc=zsjshao,dc=net

samaccountname：显示名称

objectclass：类型

description：描述

pager：寻呼机

mail：电子邮箱

wWWhomepage：网页

useraccountcontrol：用户账户属性

department：部门

userprincipalname：UPN名称

mobile：移动电话

info：注释

导入：csvde -i -f Sales_user.csv



域计算机的用户账号和组账号

域控制器负责管理域用户账号和域组账号，域控制器没有本地账号和本地组账号；成员计算机有本地账号和本地组账号，为了管理方便，域管理通常回收了成员计算机的本地用户账号，仅允许员工以域用户账号身份登录。

（1）域用户账号

在域控制器中，内置了少量用户，如图9-1所示的Administrator、Guest账号。其中，经常使用的就是Administrator管理员账号了，它拥有AD的最高权限。在AD创建后，就是通过它来为企业员工创建个人账号的。Guest账号默认为禁用状态。

![img](file:///C:\Users\ADMINI~1\AppData\Local\Temp\ksohtml\wpsBC35.tmp.jpg) 

图9-1　域用户账号

（2）域控制器组账号

在Windows Server 2012网络中，组是一个非常重要的概念，用户账号是用来标识网络中的每一个用户的，而组则是用来组织用户账号的。利用组可以把具 有相同特点及属性的用户组合在一起，便于管理员进行管理和使用。当网络中的用户账号数量非常多时，给每一个用户授予资源访问权限的工作也非常繁杂，而具有相同身份的用户通常其访问权限也相同，因此，通过把具有相同身份的用户加入到一个逻辑的实体当中，并且一次赋予该实体访问资源的权限而不是单独给每个用户授权，从而节省了工作量，简化了对资源的管理，这个实体就是组。

组账号具有以下特点。

① 组是用户账号的逻辑的集合，删除组并不会把组内的用户删除。

② 当一个用户账号加入到一个组后，该用户账户就拥有该组所拥有的全部权限。

③ 一个用户账户可以是多个组的成员。

④ 在特定情况下，组是可以嵌套的，即组可以包含其他组。

在AD的域控制器中，有3类组账户：内置组、预定义组和特殊组。

① 内置组

AD创建的内置组位于【Builtin】容器中，如图9-2所示。这些组都是域本地安全组，它们提供给用户预定义的权利和权限，用户不能修改这些内置组的权限设置。当需要某个用户执行管理任务时（授权），只要把这个用户账户加入到相应的内置组中即可。下面就其中几个较为常用的组做简要介绍。

l 【Account Operators】（用户账号操作员组）。其成员可以创建、删除和修改用户账号的隶属组，但是不能修改【Administrators】组或【Account Operators】组。

l 【Administrators】（管理员组）。该组的成员对域控制器及域中的所有资源都具有完全控制权限，并且可以根据需要向其他用户指派相应的权利和访问权限。默认情况下，【Administrator】账号、【Domain Admins】和【Enterprise Admins】预定义全局组是该组的成员。由于该组可以完全控制域控制器，所以向该组中添加用户账号时要谨慎。

l 【Backup Operators】（备份操作员组）。该组的成员可以备份和还原域控制器上的文件，而不管这些被保护的文件的权限如何。这是因为执行备份任务的权限要高于所有文件权限，但该组成员不能更改文件的安全设置。

![img](file:///C:\Users\ADMINI~1\AppData\Local\Temp\ksohtml\wpsBC36.tmp.jpg) 

图9-2　AD用户和计算机【Builtin】中的组

l 【Guests】（来宾组）。该组成员只能执行授权的任务，只能访问为其分配了访问权限的资源。该组的成员拥有一个在登录时创建的临时配置文件，在注销时，该配置文件将被删除。来宾账户【Guest】是该组的默认成员。

l 【Network Configuration Operators】（网络配置操作员组）。该组的成员可以更改TCP/IP配置。

l 【Performance Log Users】（性能日志用户组）。该组成员可以从本地服务器和远程客户端管理性能计数器、日志和报警。

l 【Print Operators】（打印机操作员组）。该组的成员可以管理打印机和打印队列。

l 【Server Operators】（服务器操作员组）。其成员只可以共享磁盘资源和在域控制器上备份和恢复文件。

l 【Users】（用户组）。该组的成员可以执行一些常见任务，如运行应用程序、使用网络打印机等。用户不能共享目录或创建本地打印机等。默认情况下，【Domain Users】、【Authenticated Users】是该组的成员。因此，在域中创建的任何用户账号都将成为该组的成员。

② 预定义组

在创建好域后，在【Active Directory用户和计算机】管理控制台的【Users】中创建了预定义全局组，如图9-3所示。下面就其中几个较为常用的组做简要介绍。

l 【Domain Admins】（域管理员组）。Windows Server 2012自动将【Domain Admins】添加到【Administrators】内置域本地组中，因此域管理员可以在域内的任何一台计算机上执行管理任务。【Administrator】账号默认是该组的成员。

l 【Domain Guests】（域来宾组）。Windows Server 2012自动将【Domain Guests】组添加到【Guests】内置域本地组中，【Guest】账号默认是该组的成员。

![img](file:///C:\Users\ADMINI~1\AppData\Local\Temp\ksohtml\wpsBC37.tmp.jpg) 

图9-3　AD用户和计算机【Users】中的组

l 【Domain Users】（域用户组）。Windows Server 2012自动将【Users】添加到内置域本地组中。新建的域用户账号都默认是该组的成员。

③ 特殊组

在Windows Server 2012计算机上还有一种特殊组，称其特殊是因为这些组没有特定的成员关系，但是它们可以在不同时候代表不同的用户，这取决于用户采取何种方式访问计算机和访问什么资源。在执行组管理时特殊组不可见，但是在给资源分配权限时却要使用它们。

l 【Anonymous Logon】（匿名登录组）。指没有经过身份验证的任何用户账号。

l 【Authenticated Users】（已认证的用户组）。指具有合法用户账号的所有用户。使用【Authenticated Users】组而不是【Everyone】组，可以禁用匿名访问某个资源。【Authenticated Users】组不包括【Guest】账号。

l 【Everyone】（每人组）。包括访问该计算机的所有用户账号，如【Authenticated Users】和【Guests】，因此在给【Everyone】组分配权限时要特别注意。

l 【Creator Owner】（创建所有者组）。包括创建和取得所有权的用户账号。

l 【Interactive】（交互组）。该组包含当前登录到计算机或通过远程桌面连接登录的所有用户。

l 【Network】（网络组）。该组包含通过网络连接登录的所有用户。

l 【Terminal Server Users】（终端服务器用户组）。当终端服务器以应用程序服务器模式安装时，该组将包含当前使用终端服务器登录到该系统的任何用户。

l 【Dialup】（拨号组）。包括任何当前存在拨号连接的用户。

3．域成员计算机组账号

在域成员计算机中，虽然它们加入到域，但是它们的内置本地组仍然保留，并依托这些内置本地组为域用户提供在本机上执行管理任务的权限。域域中的内置组一样，用户也不能修改内置本地组的权限设置。当需要用户在本地计算机上执行相应的管理任务时，只需要用户账号加入到相应的内置本地组即可。

在【计算机管理】控制台【系统工具】中的【本地用户和组】可以查看内置本地组，如图9-4所示。下面就其中几个较为常用的组做简要介绍。

![img](file:///C:\Users\ADMINI~1\AppData\Local\Temp\ksohtml\wpsBC38.tmp.jpg) 

图9-4　域成员计算机的本地组

（1）【Administrators】（管理员组）。该组的成员具有对域客户机的完全控制权限，并且可以向其他用户分配权限。如图9-5所示，【Domain Admins】组默认是该组的成员，而域管理员隶属于【Domain Admins】组，因此域管理员默认拥有所有域客户机的管理权限。

（2）【Users】（用户组）。其成员只可以执行授权的任务，只能访问分配了访问权限的资源。如图9-6所示，【Domain Users】组默认是该组的成员，而域用户默认隶属于【Domain Users】组，所以域用户默认拥有使用域客户机的权限。

![img](file:///C:\Users\ADMINI~1\AppData\Local\Temp\ksohtml\wpsBC39.tmp.jpg) ![img](file:///C:\Users\ADMINI~1\AppData\Local\Temp\ksohtml\wpsBC49.tmp.jpg)

图9-5　Administrators组成员           图9-6　Users组成员

4．域计算机的用户权限

（1）域控制器的用户权限

域的内置组账户定义了与之匹配的操作域控制器的具体权限，域新创建的用户默认仅隶属于【Domain Users】组，该组的成员可以执行一些常见任务，如运行应用程序、使用网络打印机等，但不能共享目录、修改计算机配置等。

因此如果要让域用户拥有更多的权限，就可以通过将这些用户添加到拥有对应权限的组中去，例如，网络部员工tom经常需要备份域控制器的文件，那么就可以将域用户“tom”加入到【Backup Operators】组中，这样就满足了tom的工作需求。

注意：不能将“tom”加入到【Domain Admins】组，域管理员组不仅具备域控制器的备份与还原权限，还具备域用户的添加删除、域控制器安全部署配置等权限。那么tom可能会进行删除域用户、更改域的安全配置等超出其工作职权的配置，这将给域的管理带来混乱，并有可能导致公司域的正常运作和信息外泄等严重后果。因此，域用户的权限应遵从“权限最小化”原则，从权限关上避免员工的非法操作。

（2）域成员计算机的用户权限

同域控制器的权限类似，域成员计算机的权限也是由内置组预先定义了的，域用户若需要对域客户机拥有更多的操作权限需要将该域用户添加到相应的域成员计算机内置组中以提升权限。

注意：域控制器内置组的权限范围是所有的域控制器，因此域用户加入到域内置组，其继承的权限可作用于所有的域控制器，但这些权限不能作用于域成员计算机，除了【Domain Admins】组。

域成员计算机的内置组的权限的作用范围是本机，因此如果一个域用户需要拥有多台域成员计算机特定权限，需要到每一台计算机上进行组的隶属操作来授权。

## AD域安装

### 通过图形安装域控

1、配置主机名和IP地址

![adds01](http://images.zsjshao.cn/images/windows/adds01.png)

2、添加角色和功能

![adds02](http://images.zsjshao.cn/images/windows/adds02.png)

3、提升为域控制器

![adds03](http://images.zsjshao.cn/images/windows/adds03.png)

4、添加新林

![adds04](http://images.zsjshao.cn/images/windows/adds04.png)

5、设置林和域功能级别以及还原模式密码

![adds05](http://images.zsjshao.cn/images/windows/adds05.png)

> 域控和DNS安装在一起，域控DNS指向自身，若要分开安装请参考[AD与DNS分离](###AD与DNS分离)章节

6、安装

![adds06](http://images.zsjshao.cn/images/windows/adds06.png)

7、验证

![adds07](http://images.zsjshao.cn/images/windows/adds07.png)

### 通过命令安装域控

```
Add-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

$DSRMPW = ConvertTo-SecureString "1234.com" -AsPlainText -Force
Install-ADDSForest -DomianName "zsjshao.cn" -SafeModeAdministratorPassword $DSRMPW -Force:$true
```

### AD与DNS分离

#### dns服务器配置

1、配置dns服务器的IP地址和主机名

![addsdns01](http://images.zsjshao.cn/images/windows/addsdns01.png)

2、安装dns角色和功能

![addsdns02](http://images.zsjshao.cn/images/windows/addsdns02.png)

3、新建正向查找区域

![addsdns03](http://images.zsjshao.cn/images/windows/addsdns03.png)

4、允许非安全和安全动态更新

![addsdns04](http://images.zsjshao.cn/images/windows/addsdns04.png)

5、修改主机名

![addsdns05](http://images.zsjshao.cn/images/windows/addsdns05.png)

6、查看DNS解析记录

![addsdns06](http://images.zsjshao.cn/images/windows/addsdns06.png)

#### AD域控服务器配置

1、配置AD域服务器的IP地址和主机名

![addsdns07](http://images.zsjshao.cn/images/windows/addsdns07.png)

> 注意：DNS指向dns服务器而非本身

2、添加角色和功能

![](http://images.zsjshao.cn/images/windows/adds02.png)

3、提升为域控制器

![](http://images.zsjshao.cn/images/windows/adds03.png)

4、添加新林

![addsdns10](http://images.zsjshao.cn/images/windows/addsdns10.png)

5、设置林和域功能级别以及还原模式密码，不安装DNS服务

![addsdns11](http://images.zsjshao.cn/images/windows/addsdns11.png)

6、安装

![addsdns12](http://images.zsjshao.cn/images/windows/addsdns12.png)

7、验证

![addsdns13](http://images.zsjshao.cn/images/windows/addsdns13.png)

8、DNS服务器上查看DNS记录

![addsdns14](http://images.zsjshao.cn/images/windows/addsdns14.png)

> 注：无DNS记录时请执行下面两个步骤重新注册DNS记录

9、重新注册DNS记

![addsdns15](http://images.zsjshao.cn/images/windows/addsdns15.png)

10、主机重新注册DNS记录

![addsdns16](http://images.zsjshao.cn/images/windows/addsdns16.png)

### 通过图形安装辅助域控

1、配置服务器的IP地址和主机名

![adsds01](http://images.zsjshao.cn/images/windows/adsds01.png)

2、添加角色和功能

![adsds01](http://images.zsjshao.cn/images/windows/adsds02.png)

3、提升为域控制器

![adsds03](http://images.zsjshao.cn/images/windows/adsds03.png)

4、将域控制器添加到现有域

![adsds04](http://images.zsjshao.cn/images/windows/adsds04.png)

5、设置林和域功能级别以及还原模式密码

![adsds05](http://images.zsjshao.cn/images/windows/adsds05.png)

6、安装

![adsds06](http://images.zsjshao.cn/images/windows/adsds06.png)

7、验证

![adsds07](http://images.zsjshao.cn/images/windows/adsds07.png)

### 通过命令安装辅助域控

```
Add-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools

$UserName = "administrator@zsjshao.cn"
$PassWord = ConvertTo-SecureString "1234.com" -AsPlainText -Force
$DSRMPW = ConvertTo-SecureString "1234.com" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($UserName,$PassWord)

Install-ADDSDomainController -DomainName zsjshao.cn -Credential $Credential -SafeModeAdministratorPassword $DSRMPW -Force:$true
```

### 通过图形安装辅助域控（从媒体安装）

#### 域控服务器配置

1、使用ntdsutil命令导出IFM数据

```
#CMD

C:\Users\Administrator\ntdsutil
ntdsutil: Activate Instance NTDS
ntdsutil: IFM
ifm: Create Sysvol Full c:\zsjshao-ad
```

![ifm01](http://images.zsjshao.cn/images/windows/ifm01.png)

2、查看

![ifm02](http://images.zsjshao.cn/images/windows/ifm02.png)

3、拷贝到辅助域控

![ifm03](http://images.zsjshao.cn/images/windows/ifm03.png)

#### 辅助域控服务器配置

1、配置服务器的IP地址和主机名

![adsds08](http://images.zsjshao.cn/images/windows/adsds08.png)

2、添加角色和功能

![adsds09](http://images.zsjshao.cn/images/windows/adsds09.png)

3、提升为域控制器

![adsds10](http://images.zsjshao.cn/images/windows/adsds10.png)

4、将域控制器添加到现有域

![adsds11](http://images.zsjshao.cn/images/windows/adsds11.png)

5、设置林和域功能级别以及还原模式密码

![adsds12](http://images.zsjshao.cn/images/windows/adsds12.png)

6、从介质安装

![adsds13](http://images.zsjshao.cn/images/windows/adsds13.png)

7、安装

![adsds14](http://images.zsjshao.cn/images/windows/adsds14.png)

8、验证

![adsds15](http://images.zsjshao.cn/images/windows/adsds15.png)

### 通过克隆安装辅助域控（Hyper-V)

1、将域控添加到克隆组，重启域控

![adsds16](http://images.zsjshao.cn/images/windows/adsds16.png)

2、执行命令

```
Get-ADDCCloningExcludedApplicationList -Generatexml

New-ADDCCloneConfigFile `
  -Static -IPv4Address "10.0.0.5" `
  -IPv4DNSResolver "10.0.0.1" `
  -IPv4SubnetMask "255.0.0.0" `
  -IPv4DefaultGateway "10.0.0.254" `
  -SiteName "Default-First-Site-Name" `
  -CloneComputerName "dc5"
```

![adsds17](http://images.zsjshao.cn/images/windows/adsds17.png)

3、查看生成的文件，关机

![adsds18](http://images.zsjshao.cn/images/windows/adsds18.png)

4、Hyper-V管理器导出虚拟机

![adsds19](http://images.zsjshao.cn/images/windows/adsds19.png)

> 注意：使用vmware直接克隆即可

5、导入虚拟机

![adsds20](http://images.zsjshao.cn/images/windows/adsds20.png)

> 注意：必须选择复制虚拟机（创建新的唯一ID）

6、重命名虚拟机、启动虚拟机

![adsds21](http://images.zsjshao.cn/images/windows/adsds21.png)

### 通过图形安装只读域控

1、配置服务器的IP地址和主机名

![adsds22](http://images.zsjshao.cn/images/windows/adsds22.png)

2、添加角色和功能

![adsds23](http://images.zsjshao.cn/images/windows/adsds23.png)

3、提升为域控制器

![adsds24](http://images.zsjshao.cn/images/windows/adsds24.png)

4、将域控制器添加到现有域

![adsds25](http://images.zsjshao.cn/images/windows/adsds25.png)

5、设置林和域功能级别以及还原模式密码，勾选只读域控制器。

![adsds26](http://images.zsjshao.cn/images/windows/adsds26.png)

6、配置只读域控制器选项

![adsds27](http://images.zsjshao.cn/images/windows/adsds27.png)

> 注意：需要先创建委派管理员账户，可以设置要缓存密码的组和不要缓存密码的组

7、安装

![adsds28](http://images.zsjshao.cn/images/windows/adsds28.png)

8、验证

![adsds29](http://images.zsjshao.cn/images/windows/adsds29.png)

### 通过图形安装子域

1、配置服务器的IP地址和主机名

![adcds01](http://images.zsjshao.cn/images/windows/adcds01.png)

2、添加角色和功能

![adcds02](http://images.zsjshao.cn/images/windows/adcds02.png)

3、提升为域控制器

![adcds03](http://images.zsjshao.cn/images/windows/adcds03.png)

4、创建gd子域

![adcds04](http://images.zsjshao.cn/images/windows/adcds04.png)

5、设置林和域功能级别以及还原模式密码。

![adcds05](http://images.zsjshao.cn/images/windows/adcds05.png)

6、安装

![adcds06](http://images.zsjshao.cn/images/windows/adcds06.png)

7、验证

![adcds07](http://images.zsjshao.cn/images/windows/adcds07.png)



### 客户端加域

1、客户端IP地址配置

![client01](http://images.zsjshao.cn/images/windows/client01.png)

> 注意：需要跟AD域控连通，DNS指向域控的DNS服务器

2、加入域

![client02](http://images.zsjshao.cn/images/windows/client02.png)

![client03](http://images.zsjshao.cn/images/windows/client03.png)

> 注意：加域需要需要域成员账号密码，可使用普通用户或管理员

3、使用域用户登录查看

```
C:\Users\administrator>set l
LOCALAPPDATA=C:\Users\administrator\AppData\Local
LOGONSERVER=\\DC1
```

![client04](http://images.zsjshao.cn/images/windows/client04.png)

使用命令加域

```
$UserName = "administrator@zsjshao.cn"
$PassWord = ConvertTo-SecureString -String "1234.com" -AsPlainText -Force
$Credential = New-Object System.Management.Automation.PSCredential($UserName,$PassWord)

Add-Computer -DomainName zsjshao.cn -Credential $Credential -Restart
```

### 客户端退域

1、使用CMD执行sysdm.cpl命令

```
C:\Users\administrator>sysdm.cpl
```

2、退出域，加入WORKGROUP工作组

![client05](http://images.zsjshao.cn/images/windows/client05.png)

> 注意：退域需要管理员权限

3、重启登录测试

```
C:\Users\client01>set l
LOCALAPPDATA=C:\Users\client01\AppData\Local
LOGONSERVER=\\CLIENT01
```

![client06](http://images.zsjshao.cn/images/windows/client06.png)

### 客户端离线加域

1、在DC上预配置计算机账户

```
PS C:\Users\Administrator> djoin.exe /provision /domain zsjshao.cn /machine client02 /savefile c:\client02.txt

正在预配计算机...
已成功预配域 [zsjshao.cn] 中的 [client02]。
预配数据已成功保存到 [c:\client02.txt]。

计算机预配已成功完成。
操作成功完成。
PS C:\Users\Administrator>
```

> 注意：将client02.txt文件拷贝给客户端主机

2、配置客户端IP地址

![client07](http://images.zsjshao.cn/images/windows/client07.png)

3、加入域

```
PS C:\Windows\system32> djoin.exe /requestodj /loadfile c:\client02.txt /windowspath c:\windows /localos
正在从以下文件加载预配数据: [c:\client02.txt]。

预配请求已成功完成。
需要重新启动才能应用更改。
操作成功完成。
PS C:\Windows\system32>
```

> 注意：需要管理员身份执行加域命令

4、登录测试

```
C:\Users\administrator>set l
LOCALAPPDATA=C:\Users\administrator\AppData\Local
LOGONSERVER=\\DC1

C:\Users\administrator>
```

![client08](http://images.zsjshao.cn/images/windows/client08.png)

> 注意：使用域账户登录需要连通DC，身份验证在DC上进行

### 客户端加子域

参考[客户端加域](###客户端加域)

### 域控制器降级

1、在dc5上删除AD域服务

![adds08](http://images.zsjshao.cn/images/windows/adds08.png)

2、将此域控制器降级

![adds09](http://images.zsjshao.cn/images/windows/adds09.png)

3、确认凭据

![adds10](http://images.zsjshao.cn/images/windows/adds10.png)

> 降级失败后（主域控不在线），勾选强制删除此域控制器重试

4、继续删除

![adds11](http://images.zsjshao.cn/images/windows/adds11.png)

> 注意：若为最后一台域控制器，请勾选“域中的最后一个域控制器”并删除DNS区域和应用程序分区

5、设置新管理员密码

![adds12](http://images.zsjshao.cn/images/windows/adds12.png)

6、降级

![adds13](http://images.zsjshao.cn/images/windows/adds13.png)

> 注意：域控制器降级后会成为成员服务器加入域。若为最后一个域控制器，则会直接恢复成工作组状态。

7、卸载AD域服务

![adds14](http://images.zsjshao.cn/images/windows/adds14.png)

8、重启系统

![adds15](http://images.zsjshao.cn/images/windows/adds15.png)

9、退出域

![adds16](http://images.zsjshao.cn/images/windows/adds16.png)

10、验证

![adds17](http://images.zsjshao.cn/images/windows/adds17.png)

11、从域控中删除DC5计算机

![adds18](http://images.zsjshao.cn/images/windows/adds18.png)



### 域控制器升级

```
直接升级操作系统，升级过程中会提示如何升级域控
```

过程略

## 管理操作主机角色

https://docs.microsoft.com/zh-cn/windows-server/identity/ad-ds/plan/planning-operations-master-role-placement

### FSMO

FSMO是[Flex](https://so.csdn.net/so/search?q=Flex)ible single master operation的缩写，意思就是灵活单主机操作。**营运主机**（Operation Masters，又称为Flexible Single Master Operation，即FSMO）是被设置为担任提供特定角色信息的网域控制站，在每一个活动目录网域中，至少会存在三种营运主机的角色。但对于大型的网络,整个域森林中,存在5种重要的FSMO角色.而且这些角色都是唯一的。 

#### 五大角色：

　　**1、 森林级别(一个森林只存在一台DC有这个角色):**

　　(1)、Schema Master(也叫Schema Owner):架构主控

　　(2)、Domain Naming Master:域命名主控

　　**2、 域级别(一个域里面只存一台DC有这个角色):**

　　(1)、PDC Emulator :PDC仿真器

　　(2)、RID Master :RID主控

　　(3)、Infrastructure Master :结构主控

　　对于查询FSMO主机的方式有很多,本人一般在命令行下,用netdom query fsmo命令查询.要注意的是本命令需要安装windows 的Support Tools.

 

#### 五种角色主控有什么作用？

　　1、 Schema Master（架构主控）

　　作用是修改活动目录的源数据。我们知道在活动目录里存在着各种各样的对像，比如用户、计算机、打印机等，这些对像有一系列的属性，活动目录本身就是一个数据库，对象和属性之间就好像表格一样存在着对应关系，那么这些对像和属性之间的关系是由谁来定义的，就是Schema Master，如果大家部署过Exchange的话，就会知道Schema是可以被扩展的，但需要大家注意的是，扩展Schema一定是在Schema Master进行扩展的，在其它域控制器上或成员服务器上执行扩展程序，实际上是通过网络把数据传送到Schema上然后再在Schema Master上进行扩展的，要扩展Schema就必须具有Schema Admins组的权限才可以。

　　建议:在占有Schema Master的域控制器上不需要高性能，因为我们不是经常对Schema进行操作的，除非是经常会对Schema进行扩展，不过这种情况非常的少，但我们必须保证可用性，否则在安装Exchange或LCS之类的软件时会出错。

　　2、 Domain Naming Master （域命名主控）

　　这也是一个森林级别的角色，它的主要作用是管理森林中域的添加或者删除。如果你要在你现有森林中添加一个域或者删除一个域的话，那么就必须要和Domain Naming Master进行联系，如果Domain Naming Master处于Down机状态的话，你的添加和删除操作那上肯定会失败的。

　　建议:对占有Domain Naming Master的域控制器同样不需要高性能，我想没有一个网络管理员会经常在森林里添加或者删除域吧?当然高可用性是有必要的，否则就没有办法添加删除森里的域了。

　　3、 PDC Emulator （PDC仿真器）

　　在前面已经提过了，Windows 2000域开始，不再区分PDC还是BDC，但实际上有些操作则必须要由PDC来完成，那么这些操作在Windows 2000域里面怎么办呢?那就由PDC Emulator来完成，主要是以下操作:

　　⑴、处理密码验证要求;

　　在默认情况下，Windows 2000域里的所有DC会每5分钟复制一次，但有一些情况是例外的，比如密码的修改，一般情况下，一旦密码被修改，会先被复制到PDC Emulator，然后由PDC Emulator触发一个即时更新，以保证密码的实时性，当然，实际上由于网络复制也是需要时间的，所以还是会存在一定的时间差，至于这个时间差是多少，则取决于你的网络规模和线路情况。

　　⑵、统一域内的时间;

　　微软活动目录是用Kerberos协议来进行身份认证的，在默认情况下，验证方与被验证方之间的时间差不能超过5分钟，否则会被拒绝通过，微软这种设计主要是用来防止回放式攻击。所以在域内的时间必须是统一的，这个统一时间的工作就是由PDC Emulator来完成的。

　　⑶、向域内的NT4 BDC提供复制数据源;

　　对于一些新建的网络，不大会存在Windows 2000域里包含NT4的BDC的现象，但是对于一些从NT4升级而来的Windows 2000域却很可能存有这种情况，这种情况下要向NT4 BDC复制，就需要PDC Emulator。

　　⑷、统一修改组策略的模板;

　　⑸、对Windows 2000以前的操作系统，如WIN98之类的计算机提供支持;

　　对于Windows 2000之前的操作系统，它们会认为自己加入的是NT4域，所以当这些机器加入到Windows 2000域时，它们会尝试联系PDC，而实际上PDC已经不存在了，所以PDC Emulator就会成为它们的联系对象!

　　建议:从上面的介绍里大家应该看出来了，PDC Emulator是FSMO五种角色里任务最重的，所以对于占用PDC Emulator的域控制器要保证高性能和高可用性。

　　4、RID Master （RID主控）

　　在Windows 2000的安全子系统中，用户的标识不取决于用户名，虽然我们在一些权限设置时用的是用户名，但实际上取决于安全主体SID，所以当两个用户的SID一样的时候，尽管他们的用户名可能不一样，但Windows的安全子系统中会把他们认为是同一个用户，这样就会产生安全问题。而在域内的用户安全SID=Domain SID+RID，那么如何避免这种情况?这就需要用到RID Master，RID Master的作用是:分配可用RID池给域内的DC和防止安全主体的SID重复。

　　建议:对于占有RID Master的域控制器，其实也没有必要一定要求高性能，因为我们很少会经常性的利用批处理或脚本向活动目录添加大量的用户。这个请大家视实际情况而定了，当然高可用性是必不可少的，否则就没有办法添加用户了。

　　5、 Infrastructure Master （结构主控）

　　FSMO的五种角色中最无关紧要的可能就是这个角色了，它的主要作用就是用来更新组的成员列表，因为在活动目录中很有可能有一些用户从一个OU转移到另外一个OU，那么用户的DN名就发生变化，这时其它域对于这个用户引用也要发生变化。这种变化就是由Infrastructure Master来完成的。

　　建议:其实在活动目录森林里仅仅只有一个域或者森林里所有的域控制器都是GC(全局编录)的情况下，Infrastructure Master根本不起作用，所以一般情况下对于占有Infrastructure Master的域控制器往忽略性能和可能性。

 

　　**在FSMO的规划时，请大家按以下原则进行:**

　　1、占有Domain Naming Master角色的域控制器必须同时也是GC;

　　2、不能把Infrastructure Master和GC放在同一台DC上;

　　3、建议将Schema Master和Domain Naming Master放在森林根域的GC服务器上;

　　4、建议将Schema Master和Domain Naming Master放在同一台域控制器上;

　　5、建议将PDC Emulator、RID Master及Infrastructure Master放在同一台性能较好的域控制器上;

　　6、尽量不要把PDC Emulator、RID Master及Infrastructure Master放置在GC服务器上;

==以上内容参考自百度百科：
http://baike.baidu.com/view/1623435.htm

### 通过图形查看操作主机角色

1、加载dll

```
regsvr32 schmmgmt.dll
```

2、mmc添加管理单元

![fsmo01](http://images.zsjshao.cn/images/windows/fsmo01.png)

3、查看架构主机

![fsmo02](http://images.zsjshao.cn/images/windows/fsmo02.png)

![fsmo03](http://images.zsjshao.cn/images/windows/fsmo03.png)

4、查看域命名主机

![fsmo04](http://images.zsjshao.cn/images/windows/fsmo04.png)

![fsmo05](http://images.zsjshao.cn/images/windows/fsmo05.png)

5、查看RID、PDC、基础架构主机

![fsmo06](http://images.zsjshao.cn/images/windows/fsmo06.png)

![fsmo07](http://images.zsjshao.cn/images/windows/fsmo07.png)

![fsmo08](http://images.zsjshao.cn/images/windows/fsmo08.png)

![fsmo09](http://images.zsjshao.cn/images/windows/fsmo09.png)

### 通过命令查看操作主机角色

```
PS C:\Users\Administrator> netdom query fsmo
架构主机               dc1.zsjshao.cn
域命名主机              dc1.zsjshao.cn
PDC                   dc1.zsjshao.cn
RID 池管理器            dc1.zsjshao.cn
结构主机                dc1.zsjshao.cn
命令成功完成。

PS C:\Users\Administrator> Get-ADDomain zsjshao.cn | ft PDCEmulator,RIDMaster,InfrastructureMaster

PDCEmulator    RIDMaster      InfrastructureMaster
-----------    ---------      --------------------
dc1.zsjshao.cn dc1.zsjshao.cn dc1.zsjshao.cn

PS C:\Users\Administrator> Get-ADForest zsjshao.cn | ft SchemaMaster,DomainNamingMaster

SchemaMaster   DomainNamingMaster
------------   ------------------
dc1.zsjshao.cn dc1.zsjshao.cn
```

### 迁移操作主机角色

powershell命令

```
Move-ADDirectoryServerOperationMasterRole -Identity "dc2" -OperationMasterRole PDCEmulator -Confirm:$false
Move-ADDirectoryServerOperationMasterRole -Identity "dc2" -OperationMasterRole RIDMaster -Confirm:$false
Move-ADDirectoryServerOperationMasterRole -Identity "dc2" -OperationMasterRole InfrastructureMaster -Confirm:$false
```

> 图形操作见[通过图形查看操作主机角色](###通过图形查看操作主机角色)

ntdsutil命令

```
C:\Users\Administrator.ZSJSHAO>ntdsutil
ntdsutil: roles
fsmo maintenance: connection
server connections: connect to server dc2.zsjshao.cn
绑定到 dc2.zsjshao.cn ...
用本登录的用户的凭证连接 dc2.zsjshao.cn。
server connections: quit
fsmo maintenance: ?

 ?                             - 显示这个帮助信息
 Connections                   - 连接到一个特定 AD DC/LDS 实例
 Help                          - 显示这个帮助信息
 Quit                          - 返回到上一个菜单
 Seize infrastructure master   - 在已连接的服务器上覆盖结构角色
 Seize naming master           - 覆盖已连接的服务器上的命名主机角色
 Seize PDC                     - 在已连接的服务器上覆盖 PDC 角色
 Seize RID master              - 在已连接的服务器上覆盖 RID 角色
 Seize schema master           - 在已连接的服务器上覆盖架构角色
 Select operation target       - 选择的站点，服务器，域，角色和命名上下文
 Transfer infrastructure master - 将已连接的服务器定为结构主机
 Transfer naming master        - 使已连接的服务器成为命名主机
 Transfer PDC                  - 将已连接的服务器定为 PDC
 Transfer RID master           - 将已连接的服务器定为 RID 主机
 Transfer schema master        - 将已连接的服务器定为架构主机

fsmo maintenance: transfer infrastructure master
服务器 "dc2.zsjshao.cn" 知道有关 5 作用
架构 - CN=NTDS Settings,CN=DC1,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn
命名主机 - CN=NTDS Settings,CN=DC1,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn
PDC - CN=NTDS Settings,CN=DC1,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn
RID - CN=NTDS Settings,CN=DC1,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn
结构 - CN=NTDS Settings,CN=DC2,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn

fsmo maintenance: Transfer schema master
服务器 "dc2.zsjshao.cn" 知道有关 5 作用
架构 - CN=NTDS Settings,CN=DC2,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn
命名主机 - CN=NTDS Settings,CN=DC2,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn
PDC - CN=NTDS Settings,CN=DC2,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn
RID - CN=NTDS Settings,CN=DC2,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn
结构 - CN=NTDS Settings,CN=DC2,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn
```

再次查看fsmo

```
PS C:\Users\Administrator.ZSJSHAO> netdom query fsmo
架构主机            dc2.zsjshao.cn
域命名主机          dc2.zsjshao.cn
PDC               dc2.zsjshao.cn
RID 池管理器        dc2.zsjshao.cn
结构主机            dc2.zsjshao.cn
```

## 全局编录服务器

### 查看全局编录服务器

1、通过AD用户和计算机查看全局编录服务器

![gc01](http://images.zsjshao.cn/images/windows/gc01.png)

2、通过AD站点和服务查看全局编录服务器

![gc02](http://images.zsjshao.cn/images/windows/gc02.png)

> 注意：把勾去掉可以取消全局编录

3、使用命令查看全局编录服务器

```
PS C:\Users\Administrator> dsquery server -isgc
"CN=DC1,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn"
"CN=DC2,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn"
"CN=DC3,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn"
"CN=DC5,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn"
"CN=DC4,CN=Servers,CN=Default-First-Site-Name,CN=Sites,CN=Configuration,DC=zsjshao,DC=cn"
```

### 在AD域中查找资源

1、在zsjshao.cn域中创建zhangsan用户

![gc03](http://images.zsjshao.cn/images/windows/gc03.png)

2、在子域搜索zhangsan用户

![gc04](http://images.zsjshao.cn/images/windows/gc04.png)

3、在全局编录搜索zhangsan用户

![gc05](http://images.zsjshao.cn/images/windows/gc05.png)

4、在客户端查找zhangsan用户

![gc06](http://images.zsjshao.cn/images/windows/gc06.png)

5、将部门添加到全局编录

```
regsvr32 schmmgmt.dll
```

![gc07](http://images.zsjshao.cn/images/windows/gc07.png)

6、修改zhangsan用户的部门属性

![gc08](http://images.zsjshao.cn/images/windows/gc08.png)

7、在全局编录搜索IT部门

![gc09](http://images.zsjshao.cn/images/windows/gc09.png)

8、在客户端搜索IT部门

![gc10](http://images.zsjshao.cn/images/windows/gc10.png)

## AD权限管理

AD RMS 可用于通过使用信息权限管理 (IRM) 保护文档来增强组织的安全策略。

AD RMS 允许个人和管理员通过 IRM 策略指定对文档、工作簿和演示文稿的访问权限。这有助于防止未经授权的人员打印、转发或复制敏感信息。使用 IRM 限制文件的权限后，无论信息位于何处，都会强制执行访问和使用限制，因为文件的权限存储在文档文件本身中。

AD RMS 和 IRM 可帮助个人强制执行有关个人或私人信息传输的个人偏好。它们还帮助组织执行管理机密或专有信息的控制和传播的公司政策。

```
https://docs.microsoft.com/zh-cn/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/hh831364(v=ws.11)
https://docs.microsoft.com/zh-cn/previous-versions/windows/it-pro/windows-server-2012-R2-and-2012/jj735304(v=ws.11)
```

![adrms01](http://images.zsjshao.cn/images/windows/adrms01.png)

```
# 域用户账户
rms-writer@zsjshao.cn
rms-reader@zsjshao.cn
rms-superuser@zsjshao.cn
rms-service@zsjshao.cn

# 域组账户
rms-superusers@zsjshao.cn
```

> 注意：用户和组都需要设置邮箱

## 重置管理员密码

使用PE系统重置管理员密码

过程略

windows官方工具[DaRT](https://docs.microsoft.com/zh-cn/microsoft-desktop-optimization-pack/dart-v10/)

## 重置域管理员密码

内置的服务账号包括：

本地服务：在本地计算机上具有最低权限，并可对网络资源进行匿名访问

网络服务：可对本地计算机进行有限的访问，并可作为计算机账号对网络资源进行经过身份验证的访问

本地系统：在本地计算机上具有广泛的权限，其中包括域控制器上的目录访问。具有网络资源的访问权。

> 注意：以下的方法需要登录界面有讲述人按钮

1、插入光盘，从光盘启动，选择修复计算机

![resetadpasswd01](http://images.zsjshao.cn/images/windows/resetadpasswd01.png)

2、疑难解答，启动命令提示符

![resetadpasswd02](http://images.zsjshao.cn/images/windows/resetadpasswd02.png)

3、查看卷，找到系统盘

![resetadpasswd03](http://images.zsjshao.cn/images/windows/resetadpasswd03.png)

4、将cmd替换utilman文件

```
X:\Sources>c:
C:\>cd windows\system32
C:\Windows\System32>rename utilman.exe utilman.exe.bak
C:\Windows\System32>copy cmd.exe utilman.exe
已复制          1 个文件
C:\Windows\System32>
```

5、重启系统，点击讲述人按钮，重置administrator密码

![resetadpasswd04](http://images.zsjshao.cn/images/windows/resetadpasswd04.png)

> 注意：强制重置密码会使密钥改变，采用证书（公钥）加密的文件将无法打开

6、还原文件

```
C:\Users\Administrator>cd c:\windows\system32

c:\Windows\System32>copy utilman.exe.bak utilman.exe
覆盖 utilman.exe 吗? (Yes/No/All): Yes
已复制         1 个文件。

c:\Windows\System32>
```

## 重置目录服务还原模式密码

```
C:\Users\Administrator>ntdsutil
ntdsutil: set dsrm password
重置 DSRM 管理员密码: reset password on server dc1.zsjshao.cn
请键入 DS 还原模式 Administrator 帐户的密码: *******
请确认新密码: *******
密码设置成功。

重置 DSRM 管理员密码: quit
ntdsutil: quit

C:\Users\Administrator>
```

## 还原AD域

域备份/还原

1、安装windows server backup

2、备份系统状态

3、重启按F8，进入还原模式，输入还原密码



非授权还原

windows server backup直接恢复还原

授权还原

```
ntdsutil
Activate instance ntds
authoritative restore

Restore object %s
Restore subtree %s

Restore object cn=zhangsan,dc=chinaskills,dc=cn
```

msconfig：系统配置

