+++
author = "zsjshao"
title = "06_docker 容器资源限制"
date = "2020-04-26"
tags = ["docker"]
categories = ["容器"]
+++


# 容器资源限制

## 1、内存限制

对于Linux 主机，如果没有足够的内容来执行重要的系统任务，将会抛出 OOM 或者 Out of Memory Exception(内存溢出、内存泄漏、内存异常), 随后系统会开始杀死进程以释放内存。每个进程都有可能被 kill，包括Dockerd和其它的应用程序。如果重要的系统进程被Kill,会导致整个系统宕机。

产生 OOM 异常时，Docker尝试通过调整Docker守护程序上的OOM优先级来减轻这些风险，以便它比系统上的其他进程更不可能被杀死。 容器上的OOM优先级未调整，这使得单个容器被杀死的可能性比Docker守护程序或其他系统进程被杀死的可能性更大，不推荐通过在守护程序或容器上手动设置--oom-score-adj为极端负数，或通过在容器上设置--oom-kill-disable来绕过这些安全措施。

### 1.1、限制容器对内存的访问

Docker 可以强制执行硬性内存限制，即只允许容器使用给定的内存大小。 

Docker 也可以执行非硬性内存限制，即容器可以使用尽可能多的内存，除非内核检测到主机上的内存不够用了。

内存限制参数：

- -m or --memory=   :容器可以使用的最大内存量，如果您设置此选项，则允许的最小值为4m （4兆字节）。
- --memory-swap *   :容器可以使用的交换分区大小，要在设置物理内存限制的前提才能设置交换分区的限制
- --memory-swappiness :设置容器使用交换分区的倾向性，值越高表示越倾向于使用swap分区，范围为0-100，0为能不用就不用，100为能用就用
- --memory-reservation :允许您指定小于--memory的软限制，当Docker检测到主机上的争用或内存不足时会激活该限制，如果使用--memory-reservation，则必须将其设置为低于--memory才能使其优先。 因为它是软限制，所以不能保证容器不超过限制。
- --kernel-memory ：容器可以使用的最大内核内存量，最小为4m，由于内核内存与用户空间内存隔离，因此无法与用户空间内存直接交换，因此内核内存不足的容器可能会阻塞宿主主机资源，这会对主机和其他容器产生副作用。
- --oom-kill-disable：默认情况下，发生OOM时，kernel会杀死容器内进程，但是可以使用--oom-kill-disable参数，可以禁止oom发生在指定的容器上，即仅在已设置-m / --memory选项的容器上禁用OOM，如果-m 参数未配置，产生OOM时，主机为了释放内存还会杀死容器进程

swap限制：

- swap限制参数--memory-swap 只有在设置了 --memory 后才会有意义。使用Swap,可以让容器将超出限制部分的内存置换到磁盘上。
- WARNING：经常将内存交换到磁盘的应用程序会降低性能

不同的设置会产生不同的效果：

- --memory-swap：值为正数， 那么--memory和--memory-swap都必须要设置，--memory-swap表示你能使用的内存和swap分区大小的总和，例如： --memory=300m, --memory-swap=1g, 那么该容器能够使用 300m 内存和 700m swap，即--memory是实际物理内存大小值不变，而实际的计算方式为(--memory-swap)-(--memory)=容器可用swap
- --memory-swap：如果设置为0，则忽略该设置，并将该值视为未设置，即未设置交换分区。
- --memory-swap：如果等于--memory的值，并且--memory设置为正整数，容器无权访问swap即也没有设置交换分区
- --memory-swap：如果设置为unset，如果宿主机开启了swap，则实际容器的swap值为2x( --memory)，即两倍于物理内存大小，但是并不准确。
- --memory-swap：如果设置为-1，如果宿主机开启了swap，则容器可以使用主机上swap的最大空间。

## 2、CPU限制

优先级

- 实时优先级：0-99
- 非实时优先级(nice)：-20-19，对应100-139的进程优先级

Linux kernel进程的调度基于CFS(Completely Fair Scheduler)，完全公平调度

CPU密集型的场景：

- 优先级越低越好，计算密集型任务的特点是要进行大量的计算，消耗CPU资源，比如计算圆周率、对视频进行高清解码等等，全靠CPU的运算能力

IO密集型的场景：

- 优先级值高点，涉及到网络、磁盘IO的任务都是IO密集型任务，这类任务的特点是CPU消耗很少，任务的大部分时间都在等待IO操作完成（因为IO的速度远远低于CPU和内存的速度），比如Web应用，高并发，数据量大的动态网站来说，数据库应该为IO密集型。

磁盘调度算法

```
[root@c72 harbor]# cat /sys/block/sda/queue/scheduler 
noop [deadline] cfq
```

默认情况下，每个容器对主机CPU周期的访问权限是不受限制的，但是我们可以设置各种约束来限制给定容器访问主机的CPU周期，大多数用户使用的是默认的CFS调度方式，在Docker 1.13及更高版本中，还可以配置实时优先级。

cpu限制参数

- --cpus= 指定容器可以使用多少可用CPU资源。例如，如果主机有两个CPU，并且您设置了--cpus =“1.5”，那么该容器将保证最多可以访问一个半的CPU。这相当于设置--cpu-period =“100000”和--cpu-quota =“150000”。在Docker 1.13和更高版本中可用。
- --cpuset-cpus  主要用于指定容器运行的CPU编号，也就是我们所谓的绑核。
- --cpuset-mem  设置使用哪个cpu的内存，仅对 非统一内存访问(NUMA)架构有效
- --cpu-shares   主要用于cfs中调度的相对权重，,cpushare值越高的，将会分得更多的时间片，默认的时间片1024，最大262144

## 3、示例

```
运行容器进行压力测试：
root@u1:~# docker pull lorel/docker-stress-ng

获取帮助： docker run -it --rm lorel/docker-stress-ng --help

测试内存资源，限制容器最大可用内存为256m，默认一个vm占用256m内存
docker run -it --rm -m 256m lorel/docker-stress-ng --vm 4

测试CPU资源，限制最多使用两核心，默认一个cpu会占满
docker run -it --rm --cpus 2 lorel/docker-stress-ng --cpu 4

测试CPU资源，限制只能使用指定的核心
docker run -it --rm --cpuset-cpus 0,2 lorel/docker-stress-ng --cpu 4

测试CPU资源，限制cpu为2:3
docker run -it --rm --cpu-shares 200 lorel/docker-stress-ng --cpu 2
docker run -it --rm --cpu-shares 300 lorel/docker-stress-ng --cpu 2

动态观察容器的资源占用状态
docker stats
```

实际上这些限制都体现在宿主机的CGroup上

```
-m 256m 等于 memory.limit_in_bytes 268435456
--cpus 3 等于 cpu.cfs_quota_us 300000
--cpuset-cpus 0,2 等于 cpuset.cpus 0,2
--cpu-shares 200 等于 cpu.shares 200

cpu.cfs_period_us，默认值为100000，表示将一颗cpu时间片分成100000份
cpu.cfs_quota_us，默认值为-1，表示不受限制。

查看当前CGroup管理的进程
cat /sys/fs/cgroup/cpu/docker/容器ID/tasks

可使用echo命令直接修改，一般只能改大不能改小
例如 echo 300 > /sys/fs/cgroup/cpu/docker/容器ID/cpu.shares
```
