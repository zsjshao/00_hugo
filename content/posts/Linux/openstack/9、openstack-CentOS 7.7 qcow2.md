+++
author = "zsjshao"
title = "openstack-镜像制作"
date = "2020-04-18"
tags = ["openstack"]
categories = ["openstack"]

+++

## CentOS 7.7qcow2镜像制作

<!-- more -->

1、安装基础环境

```
[root@c77 ~]# yum install -y qemu-kvm qemu-kvm-tools libvirt virt-manager virt-install -y
```

2、创建qcow2文件

```
[root@c77 tmp]# qemu-img create -f qcow2 centos7.7.qcow2 50G
```

3、上传镜像并创建虚拟机

```
[root@c77 tmp]# virt-install  --virt-type kvm --name  CentOS7.7   --ram 1024 \
--cdrom=/tmp/CentOS-7-x86_64-Minimal-1908.iso --disk path=/tmp/centos7.7.qcow2 \
--network bridge=br0 --graphics vnc,listen=0.0.0.0 --noautoconsole
```

4、使用vnc连接5900端口或使用virt-manager连接虚拟机，系统安装过程略

5、安装相关软件包并优化配置

```
yum install acpid cloud-init cloud-utils-growpart -y
yum install vim iotop bc gcc gcc-c++ glibc glibc-devel pcre pcre-devel openssl  \
openssl-devel zip unzip zlib-devel  net-tools lrzsz tree ntpdate telnet lsof \
tcpdump wget libevent libevent-devel bc  systemd-devel bash-completion traceroute rsync -y
systemctl enable acpid
echo "NOZEROCONF=yes" >> /etc/sysconfig/network
systemctl stop firewalld
systemctl disable firewalld
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
sed -i 's/#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config
echo 'alias cdnet="cd /etc/sysconfig/network-scripts/"' >> /etc/bashrc
ssh-keygen -f /root/.ssh/id_rsa -P ''
cat /root/.ssh/id_rsa.pub >> /root/.ssh/authorized_keys

vim /etc/default/grub 
GRUB_CMDLINE_LINUX="...  console=tty0 console=ttyS0,115200n8"
grub2-mkconfig -o /boot/grub2/grub.cfg
```

6、清除虚拟机mac地址信息

```
[root@c77 tmp]# virt-sysprep -d CentOS7.7
CentOS7.7为创建虚拟机时指定的名称
```

7、重新转换格式并压缩

```
[root@c77 tmp]# qemu-img convert -c -O qcow2 centos7.7.qcow centos7.7-x86_64.qcow2
```

