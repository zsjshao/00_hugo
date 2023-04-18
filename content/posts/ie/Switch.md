+++
author = "zsjshao"
title = "Switch"
date = "2023-04-04"
tags = ["Switch"]
categories = ["IE"]

+++

### 交换机基础功能

学习MAC地址（CAM）

转发/过滤流量

防环









### VTP

功能：同步vlan

角色：Server、Client、Transparent



 Server（default mode）

- 创建，修改和删除vlans
- 发送和转发通告信息
- 同步vlan配置信息
- vlan信息保存在NVRAM/FLASH

Client

- 不能创建，修改和删除vlans
- 转发通告信息
- 同步vlan信息
- 不保存vlan信息

Transparent

- 创建，修改和删除本地vlans
- 转发通过信息
- 不同步vlan信息
- vlan信息保存在NVRAM/FLASH



#### 更新机制

组播（MAC）更新

周期更新5分钟、触发更新

通过最新的版本号确定同步信息



#### 配置

```
conf t
vtp domain ZSJSHAO
vtp mode server
vtp password cisco
vtp pruning

show vtp status
```



### 防环

单点失效



冗余网络问题：

- 多帧复制
- mac地址抖动
- 广播风暴



#### 生成树

Bridge Protocol Data Unit：BPDU协商报文，2S

- 配置BPDU

- TCN拓扑变更BPDU



#### 选举规则

选根桥：拥有最小bridge-id的交换机成为根桥

选非根桥的根端口：

- 最小Root ID（未选举根前）
- 最小到达根桥的路径开销（BPDU报文携带路径开销）
- 最小发送Bridge ID
- 最小发送Port ID

选指定端口

- 最小Root ID（未选举根前）
- 最小到达根桥的路径开销（BPDU报文携带路径开销）
- 最小Bridge ID
- 最小Port ID

非指定端口被阻塞



#### 选举参数

BID：bridge-ID 桥ID，优先级（32768）+MAC

path cost：路径开销，10G（2），1G（4），100M（19），10M（100）

port ID：接口ID，优先级（128）+端口号



查看状态

```
Ruijie#show spanning-tree summary 
Spanning tree enabled protocol stp
  Root ID    Priority    32768
             Address     5000.0001.0001
             this bridge is root
             Hello Time   2 sec  Forward Delay 15 sec  Max Age 20 sec

  Bridge ID  Priority    32768
             Address     5000.0001.0001
             Hello Time   2 sec  Forward Delay 15 sec  Max Age 20 sec

Interface        Role Sts Cost       Prio     OperEdge Type
---------------- ---- --- ---------- -------- -------- ----------------
Gi0/0            Desg FWD 20000      128      False    P2p                             
Gi0/1            Desg FWD 20000      128      False    P2p                             
Gi0/2            Desg FWD 20000      128      False    P2p                             
Gi0/3            Desg FWD 20000      128      False    P2p                             
Gi0/4            Desg FWD 20000      128      False    P2p                             
Gi0/5            Desg FWD 20000      128      False    P2p                             
Gi0/6            Desg FWD 20000      128      False    P2p                             
Gi0/7            Desg FWD 20000      128      False    P2p                             
Gi0/8            Desg FWD 20000      128      False    P2p  
```



#### 修改优先级

```

```























