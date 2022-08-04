+++
author = "zsjshao"
title = "05_docker 网络管理"
date = "2020-04-26"
tags = ["docker"]
categories = ["容器"]

+++

# docker 网络管理

## 1、docker网络类型

docker的网络有四种类型：分别是

- Bridge(Bridged containers)
- none(Closed containers)
- container(Joined containers)
- host(Open containers)

![network_01](http://images.zsjshao.cn/images/docker/network_01.png)

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