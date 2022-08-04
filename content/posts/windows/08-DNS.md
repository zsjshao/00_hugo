## 1、DNS作用

企业有必要有自己DNS服务器？

如果是域环境，必须需要DNS服务器，因为域服务的正常运行必须需要DNS服务器支持

如果是工作组环境，DNS也可以提供额外的功能，比如域名的屏蔽、DNS缓存等等

DNS是什么？

DNS是公网上提供的一种域名解析的服务，主要负责把用户的域名转换成IP地址。

DNS服务器是本身就是一个包含了诸多主机名和IP地址对应关系的数据库

InterNIC负责公网上DNS服务器的管理和维护

## 2、公网DNS架构

![01_dns](http://images.zsjshao.cn/images/linux_basic/22-dns/01_dns.png)

DNS命名规范

A-Z（不区分字符大小写）  0-9 Hyphen（-）

## 3、DNS解析过程

DNS区域

DNS区域类型有两种：

正向查找区域：负责将域名转化成IP地址

反向查找区域：负责将IP地址转化成域名

默认情况下，DNS数据存储在系统分区中；如果是活动目录集成区域，DNS数据存储在活动目录数据库中



工作组模式存储路径：C:\Windows\System32\dns\

域环境存储路径：C:\Windows\NTDS\ntds.dit



DNS记录类型

A记录/AAAA记录

CName别名记录

MX记录

SRV记录



查看DNS缓存：ipconfig /displaydns

清除DNS缓存：ipconfig /flushdns

## 4、DNS常规演示

### DNS区域委派





什么情况下才能使用到备用DNS服务器IP地址

首选没有该区域解析时会使用到备用，即首选有com区域，备用有net区域，发起zsjshao.net查询时会使用备用。

### GlobalNames区域

1、启用GlobalNames区域

```
PS C:\> Set-DnsServerGlobalNameZone -Enable
或
C:\> dnscmd dc1.zsjshao.cn /config /enableglobalnamessupport 1
```





## 5、DNS容错

服务器端：保证多套DNS服务器并且能相互同步

- 在AD集成区域模式下，同域中多DNS服务器自动同步数据

- 在非AD集成区域模式下，通过主要区域和辅助区域来实现DNS数据库同步

客户端：DNS地址指向多个DNS服务器



DNS企业常见应用

负载均衡



启用 GlobalNames 区域的 CMD 命令：

https://docs.microsoft.com/zh-cn/windows-server/administration/windows-commands/dnscmd

启用 GlobalNames 区域的 powershell 命令：

https://docs.microsoft.com/en-us/powershell/module/dnsserver/set-dnsserverglobalnamezone?view=win10-ps