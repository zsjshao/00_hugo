### ATT:骨干区域连接标记

@ Level-1-2路由器将自己的level-1 LSP的ATT位置1,用来表明自己与骨干区域相连，然后将该Level-1 LSP发送给自己的所有的level-1邻居路由器

特殊场景:L12的路由器R3,R4 如果在骨干区域形成邻居关系，，但没有其他L2的邻居时，ATTbit位不置1,此ATT置1没有指导报文访问骨干区域的意义。

@ L1/2的路由器在L2的LSDB中必须存在至少一条其他区域的L2LSP，ATT才置1.当L1,L1/2,L2的路由器都在一个区域时，L1/2路由不会产生ATT置1的LSP

@ 当level-1-2路由失去level-2的所有邻居后,ATT不置1.
@ level-1路由器收到一个ATT1位置的LSP时，则产生一个level-1的默认路由，指向距离自己最近的一个level-1-2路由器。
@ level-1区域类似于OSPF中的totally stub，不包含其他区域中明细路由，只包含默认路由!
@有条件的产生ATT置1的L1-LSP,使用命令set-attached-bit route-map xixi 当满足route-map xixi的路由存在时，将自身的产生的L1-LSP的ATT位置1，如果满足的路由不存在时，则自身产生的L1-LSP的ATT位不置1



优点:

1、节省leve1-1区域中设备系统资源，如CPU,内存(减小了路由表大小)等

2、节省该区域中路由更新所占用的网络资源

3、其他区明细路由的翻滚，不会对自己区域的稳定性造成影响缺点:

容易造成次优路径。

解决方案:ISIS路由泄露(route leaking)实质:将level-2的路由引入到eve1-1区域中去，因为在level-2区域中保存的本区域中的域内路由以及其他所有非骨干区域中的域间路由

实施路由器:leve1-1-2路由器

实施命令:

```
router isis
redistribute isis ip level-2 into level-1 distribute-list 100
redistribute isis ip level-2 into level-1 route-map test
access-list 100 permit ip any any
```

如果ACL不存在，代表所有路由都可以泄露到L1区域，如果route-map不存在，代表所有路由都不可以泄露到L1区域。



### 防环

@路由选择:L1>L2>L1 ia(DU=1)泄漏到L1区域的路由U/D置1,而泄漏到L2区域的路由U/D置0.

@如果同一个物理区域有多台L12的路由器，非骨干的leve1-1LSP 在L12路由器上将被自动泄露在骨干区域，默认不会再泄露到本区域，如果做了L2向L1的泄露也不会传回本区域，但是如果此物理区域由于链路的故障导致不连续后，如果做L2向L1的泄露，还是会传回"本"区域(某场景)

@骨干区域泄露到非骨干区域的LSP，不会再次泄露回骨干区域。

@当一台L12路由器失去所有L2的邻居后，将会使用其他同一区域L12路由的ATT置1的LSP 计算默认路由，在华为设备(模拟器上测试)不会有此特性，如果要实现默认路由的生成，则需要将此路由器设置成L1的路由器

@L12的路由器存在L2的邻居时,优先使用L2的LSP计算骨干区域路由,如果无法计算,则使用泄漏的LSP计算路由,但不会再泄漏回骨干区域,(对比:在OSPF ABR区域0有邻居时不会使用非骨干区域的3类LSA计算区域间路由.)

@当同一个非骨干区域有多个L1-2路由器,彼此不会使用对方的ATT置1的LSP计算默认路由，华为设备。

### 过载

超载位。L:overload.

华为设备: set-overload 命令使用在L12路由器上时，此路由器不会在自己产生的L1和L2的LSP中描述那些区域间的路由，只描述自身的直连路由。L12路由器向非骨干区域泄漏L2的路由时，如果设置OL，那么默认将不会泄漏这些路由，可以使用set-overload allow interlevel命令继续泄漏这些路由，L1的路由也会被泄漏到L2的区域。

set-overload on-startup start-from-nbr 0000.0000.0002 60 300

启动后如果和邻居在300s之前能建立邻居关系，则在邻居关系建立之后的60s之内，继续保持产生OL置1的LSP，60s之后OL位不在置1

启动后如果和邻居在300s之内都无法建立邻居关系，则在这300s内产生OL置1的LSP300s之后不管邻居是否建立，OL不再置1.

set-overload on-startup wait-for-bgp 100

BGP邻居建立之后的100s内，产生的LSP的OL位置1，100s之后不在置1，如果100s内BGP邻居无法建立，则在100s后也不再OL置1.

华为设备
set-overload [allow {interlevel |external }* ]
@L12为ASBR时
set-overload allow interlevelL12正常描述直连路由以及泄漏的所有路由，但不描述自身引入的外部路由set-overload allow externalL12只描述直连路由以及自身引入的外部路由不描述泄漏的路由
@ L1/L2为ASBR时
set-overload allow interlevel L1/L2描述直连路由 ，自身引入的外部路由不进行描述
set-overload allow externalL1/L2描述直连路由也描述自身引入的外部
set-overload
@L12路由器设置OL=1后，默认不把L1路由在L2的LSP进行描述，也不会把L2的泄漏的路由在L1的LSP中进行描述，同时ATT=0，也不会描述自身引入的外部路由。
@ L1,L2 路由器设置OL=1后，不描述自身引入的外部路由















