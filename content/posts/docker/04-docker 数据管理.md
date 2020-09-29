+++
author = "zsjshao"
title = "04_docker 数据管理"
date = "2020-04-26"
tags = ["docker"]
categories = ["容器"]

+++

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
