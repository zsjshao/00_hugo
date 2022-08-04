+++
author = "zsjshao"
title = "openstack-neutron"
date = "2020-04-21"
tags = ["openstack"]
categories = ["openstack"]
+++

## neutron

### 1、什么是neutron

OpenStack Networking（neutron）允许您创建由其他OpenStack服务管理的接口设备并将其连接到网络。可以实现插件以适应不同的网络设备和软件，为OpenStack架构和部署提供灵活性。

Neutron 为整个 OpenStack 环境提供网络支持，包括二层交换，三层路由，负载均衡，防火墙和 VPN 等。Neutron 提供了一个灵活的框架，通过配置，无论是开源还是商业软件都可以被用来实现这些功能。

<!-- more -->

**二层交换 Switching**

Nova 的 Instance 是通过虚拟交换机连接到虚拟二层网络的。Neutron 支持多种虚拟交换机，包括 Linux 原生的 Linux Bridge 和 Open vSwitch。 Open vSwitch（OVS）是一个开源的虚拟交换机，它支持标准的管理接口和协议。

利用 Linux Bridge 和 OVS，Neutron 除了可以创建传统的 VLAN 网络，还可以创建基于隧道技术的 Overlay 网络，比如 VxLAN 和 GRE（Linux Bridge 目前只支持 VxLAN）。在后面章节我们会学习如何使用和配置 Linux Bridge 和 Open vSwitch。

**三层路由 Routing**

Instance 可以配置不同网段的 IP，Neutron 的 router（虚拟路由器）实现 instance 跨网段通信。router 通过 IP forwarding，iptables 等技术来实现路由和 NAT。我们将在后面章节讨论如何在 Neutron 中配置 router 来实现 instance 之间，以及与外部网络的通信。

**负载均衡 Load Balancing**

Openstack 在 Grizzly 版本第一次引入了 Load-Balancing-as-a-Service（LBaaS），提供了将负载分发到多个 instance 的能力。LBaaS 支持多种负载均衡产品和方案，不同的实现以 Plugin 的形式集成到 Neutron，目前默认的 Plugin 是 HAProxy。我们会在后面章节学习 LBaaS 的使用和配置。

**防火墙 Firewalling**

Neutron 通过下面两种方式来保障 instance 和网络的安全性。

**Security Group**

通过 iptables 限制进出 instance 的网络包。

**Firewall-as-a-Service**

FWaaS，限制进出虚拟路由器的网络包，也是通过 iptables 实现。

### 2、什么是network

network是一个隔离的二层广播域。Neutron 支持多种类型的network，包括 local, flat, VLAN, VxLAN和GRE。

**local**

local网络与其他网络和节点隔离。local网络中的instance只能与位于同一节点上同一网络的instance通信，local网络主要用于单机测试。

**flat**

flat网络是无vlan tagging的网络。flat网络中的instance能与位于同一网络的instance 通信，并且可以跨多个节点。

**vlan**

vlan网络是具有802.1q tagging的网络。vlan是一个二层的广播域，同一vlan中的 instance可以通信，不同vlan只能通过router通信。vlan网络可跨节点，是应用最广泛的网络类型。

**vxlan**

vxlan是基于隧道技术的overlay网络。vxlan网络通过唯一的segmentation ID（也叫 VNI）与其他 vxlan 网络区分。vxlan中数据包会通过VNI封装成UDP包进行传输。因为二层的包通过封装在三层传输，能够克服vlan和物理网络基础设施的限制。

**gre**

gre是与vxlan类似的一种overlay网络。主要区别在于使用IP包而非UDP进行封装。



 不同network之间在二层上是隔离的。

以 vlan 网络为例，network A和network B会分配不同的VLAN ID，这样就保证了 network A中的广播包不会跑到network B中。当然，这里的隔离是指二层上的隔离，借助路由器不同network是可能在三层上通信的。

network必须属于某个Project（ Tenant 租户），Project中可以创建多个network。Project 与network之间是 1对多关系。

### 3、什么是subnet

subnet是一个IPv4或者IPv6地址段。instance的 IP 从subnet中分配。每个subnet 需要定义IP地址的范围和掩码。

network与subnet是 1对多 关系。一个subnet只能属于某个network；一个network 可以有多个subnet，这些subnet可以是不同的IP段，但不能重叠。

不同的network可以创建相同的subnet，那么就可能存在具有相同IP的两个instance，这样会不会冲突？ 简单的回答是：不会！

具体原因：因为Neutron的router是通过 Linux network namespace 实现的。network namespace是一种网络的隔离机制。通过它，每个router有自己独立的路由表。上面的配置有两种结果：

如果两个subnet是通过同一个router路由，根据router的配置，只有指定的一个subnet 可被路由。

如果上面的两个subnet是通过不同router路由，因为router的路由表是独立的，所以两个subnet都可以被路由。

### 4、什么是port

port可以看做虚拟交换机上的一个端口。port上定义了MAC地址和IP 地址，当 instance的虚拟网卡VIF（Virtual Interface）绑定到port时，port会将MAC和IP分配给 VIF。

subnet与port是 1对多 关系。一个port必须属于某个subnet；一个subnet可以有多个port。

### 5、neutron架构

与OpenStack的其他服务的设计思路一样，Neutron也是采用分布式架构，由多个组件（子服务）共同对外提供网络服务。

![neutron_01](http://images.zsjshao.cn/images/openstack/neutron_01.png)

**Neutron Server**

对外提供OpenStack网络API，接收请求，并调用Plugin处理请求。

 **Plugin**

处理Neutron Server发来的请求，维护OpenStack逻辑网络状态，并调用Agent处理请求。

**Agent**

处理Plugin的请求，负责在network provider上真正实现各种网络功能。

**network provider**

提供网络服务的虚拟或物理网络设备，例如Linux Bridge，Open vSwitch或者其他支持 Neutron的物理交换机。

**Queue**

Neutron Server，Plugin和Agent之间通过Messaging Queue通信和调用。

**Database**

存放OpenStack的网络状态信息，包括Network, Subnet, Port, Router等。

### 6、neutron-server

![neutron_02](http://images.zsjshao.cn/images/openstack/neutron_02.png)

**Core API**

对外提供管理network, subnet和port的RESTful API。

**Extension API**

对外提供管理router, load balance, firewall等资源的RESTful API。

**Commnon Service**

认证和校验 API 请求。

**Neutron Core**

Neutron server 的核心处理程序，通过调用相应的Plugin处理请求。

**Core Plugin API**

定义了Core Plgin的抽象功能集合，Neutron Core通过该API调用相应的Core Plgin。

**Extension Plugin API**

定义了Service Plgin的抽象功能集合，Neutron Core通过该API调用相应的Service Plgin。

 

**Core Plugin**

实现了Core Plugin API，在数据库中维护network, subnet和port的状态，并负责调用相应的agent在network provider上执行相关操作，比如创建network。

**Service Plugin**

实现了Extension Plugin API，在数据库中维护router, load balance, security group等资源的状态，并负责调用相应的agent在network provider上执行相关操作，比如创建router。

 

归纳起来，Neutron Server包括两部分：

```
1)提供API服务。
2)运行Plugin。
```

**linux bridge core plugin**

```
1)与neutron server一起运行。
2)实现了core plugin API。
3)负责维护数据库信息。
4)通知linux bridge agent实现具体的网络功能。
```

**linux bridge agent**

```
1)在计算节点和网络节点（或控制节点）上运行。
2)接收来自plugin的请求。
3)通过配置本节点上的 linux bridge 实现 neutron 网络功能。
```

### 7、安装neutron

#### 7.1：controller1的配置

创建neutron数据库并授权

```
[root@mariadb1 ~]# mysql -e "CREATE DATABASE neutron;"
[root@mariadb1 ~]# mysql -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'localhost' IDENTIFIED BY 'neutron';"
[root@mariadb1 ~]# mysql -e "GRANT ALL PRIVILEGES ON neutron.* TO 'neutron'@'%' IDENTIFIED BY 'neutron';"
```

创建neutron用户

```
[root@controller1 ~]# openstack user create --domain default --password neutron neutron
```

将neutron用户添加到service项目并授予admin角色

```
[root@controller1 ~]# openstack role add --project service --user neutron admin
```

创建network服务

```
[root@controller1 ~]# openstack service create --name neutron --description "OpenStack Networking" network
```

创建endpoint

```
[root@controller1 ~]# openstack endpoint create --region RegionOne network public http://openstack-vip.zsjshao.net:9696
[root@controller1 ~]# openstack endpoint create --region RegionOne network internal http://openstack-vip.zsjshao.net:9696
[root@controller1 ~]# openstack endpoint create --region RegionOne network admin http://openstack-vip.zsjshao.net:9696
```

安装neutron软件包

```
[root@controller1 ~]# yum install openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables libibverbs -y
```

编辑/etc/neutron/neutron.conf配置文件，修改如下内容

```
[root@controller1 ~]# vim /etc/neutron/neutron.conf 
[DEFAULT]
core_plugin = ml2
service_plugins =
transport_url = rabbit://openstack:openstack@openstack-vip.zsjshao.net
auth_strategy = keystone
notify_nova_on_port_status_changes = true
notify_nova_on_port_data_changes = true

[database]
connection = mysql+pymysql://neutron:neutron@openstack-vip.zsjshao.net/neutron

[keystone_authtoken]
auth_uri = http://openstack-vip.zsjshao.net:5000
auth_url = http://openstack-vip.zsjshao.net:5000
memcached_servers = openstack-vip.zsjshao.net:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = neutron
password = neutron

[nova]
auth_url = http://openstack-vip.zsjshao.net:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = nova
password = nova

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp
```

编辑/etc/neutron/plugins/ml2/ml2_conf.ini配置文件，修改如下内容

```
[root@controller1 ~]# vim /etc/neutron/plugins/ml2/ml2_conf.ini
[ml2]
type_drivers = flat,vlan
tenant_network_types =
mechanism_drivers = linuxbridge
extension_drivers = port_security

[ml2_type_flat]
flat_networks = external,internal

[securitygroup]
enable_ipset = true
```

编辑/etc/neutron/plugins/ml2/linuxbridge_agent.ini配置文件，修改如下内容

```
[root@controller1 ~]# vim /etc/neutron/plugins/ml2/linuxbridge_agent.ini
[linux_bridge]
physical_interface_mappings = external:bond1,internal:bond2

[vxlan]
enable_vxlan = false

[securitygroup]
enable_security_group = false
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

注：此处没有启用安全组，性能不好，若想使用将enable_security_group = false改成true。
注：external:bond1其中bond1不能是bridge设备
```

编辑/etc/neutron/dhcp_agent.ini配置文件，修改如下内容

```
[root@controller1 ~]# vim /etc/neutron/dhcp_agent.ini
[DEFAULT]
interface_driver = linuxbridge
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata = true
```

编辑/etc/neutron/metadata_agent.ini配置文件，修改如下内容

```
[root@controller1 ~]# vim /etc/neutron/metadata_agent.ini
[DEFAULT]
nova_metadata_host = openstack-vip.zsjshao.net
metadata_proxy_shared_secret = 20200314
```

编辑/etc/nova/nova.conf配置文件，修改如下内容

```
[root@controller1 ~]# vim /etc/nova/nova.conf
[neutron]
url = http://openstack-vip.zsjshao.net:9696
auth_url = http://openstack-vip.zsjshao.net:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = neutron
service_metadata_proxy = true
metadata_proxy_shared_secret = 20200314
```

创建ml2的符号链接

```
[root@controller1 ~]#  ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini
```

填充数据库

```
[root@controller1 ~]# su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron
```

重启nova-api服务

```
[root@controller1 ~]# systemctl restart openstack-nova-api.service
```

启动neutron服务并设置为开机自动启动

```
[root@controller1 ~]# systemctl enable neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
[root@controller1 ~]# systemctl start neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
```

#### 7.2：controller2的配置

```
安装neutron软件包
[root@controller2 ~]# yum install openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables libibverbs -y

拷贝配置文件
[root@controller2 ~]# rsync -avlogp 192.168.3.71:/etc/neutron/* /etc/neutron/

编辑/etc/nova/nova.conf配置文件，修改如下内容
[root@controller2 ~]# vim /etc/nova/nova.conf
[neutron]
url = http://openstack-vip.zsjshao.net:9696
auth_url = http://openstack-vip.zsjshao.net:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = neutron
service_metadata_proxy = true
metadata_proxy_shared_secret = 20200314

重启nova-api服务
[root@controller2 ~]# systemctl restart openstack-nova-api.service

启动neutron服务并设置为开机自动启动
[root@controller2 ~]# systemctl enable neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
[root@controller2 ~]# systemctl start neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service
```

#### 7.3：compute1的配置

安装neutron软件包

```
[root@compute1 ~]# yum install openstack-neutron-linuxbridge ebtables ipset -y
```

编辑/etc/neutron/neutron.conf配置文件，修改如下内容

```
[root@compute1 ~]# vim /etc/neutron/neutron.conf
[DEFAULT]
transport_url = rabbit://openstack:openstack@openstack-vip.zsjshao.net
auth_strategy = keystone

[keystone_authtoken]
auth_uri = http://openstack-vip.zsjshao.net:5000
auth_url = http://openstack-vip.zsjshao.net:5000
memcached_servers = openstack-vip.zsjshao.net:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = neutron
password = neutron

[oslo_concurrency]
lock_path = /var/lib/neutron/tmp
```

编辑/etc/neutron/plugins/ml2/linuxbridge_agent.ini配置文件，修改如下内容

```
[root@compute1 ~]# vim /etc/neutron/plugins/ml2/linuxbridge_agent.ini 
[linux_bridge]
physical_interface_mappings = external:bond1,internal:bond2

[vxlan]
enable_vxlan = false

[securitygroup]
enable_security_group = false
firewall_driver = neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

注：此处没有启用安全组，性能不好，若想使用将enable_security_group = false改成true。
注：external:bond1其中bond1不能是bridge设备
```

编辑/etc/nova/nova.conf配置文件，修改如下内容

```
[root@compute1 ~]# vim /etc/nova/nova.conf
[neutron]
url = http://openstack-vip.zsjshao.net:9696
auth_url = http://openstack-vip.zsjshao.net:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = neutron
service_metadata_proxy = true
metadata_proxy_shared_secret = 20200314
```

重启nova-compute服务

```
[root@compute1 ~]# systemctl restart openstack-nova-compute.service
```

启动服务并设为开机自动启动

```
[root@compute1 ~]# systemctl enable neutron-linuxbridge-agent.service
[root@compute1 ~]# systemctl start neutron-linuxbridge-agent.service
```

#### 7.4：compute2的配置

```
安装neutron软件包
[root@compute2 ~]# yum install openstack-neutron-linuxbridge ebtables ipset -y

拷贝配置文件
[root@compute2 ~]# rsync -avlogp 192.168.3.73:/etc/neutron/* /etc/neutron/

编辑/etc/nova/nova.conf配置文件，修改如下内容
[root@compute2 ~]# vim /etc/nova/nova.conf
[neutron]
url = http://openstack-vip.zsjshao.net:9696
auth_url = http://openstack-vip.zsjshao.net:5000
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = neutron
password = neutron
service_metadata_proxy = true
metadata_proxy_shared_secret = 20200314

重启nova-compute服务
[root@compute2 ~]# systemctl restart openstack-nova-compute.service

启动服务并设为开机自动启动
[root@compute2 ~]# systemctl enable neutron-linuxbridge-agent.service
[root@compute2 ~]# systemctl start neutron-linuxbridge-agent.service
```

### 8、创建网络

#### 8.1、创建网络

```
[root@controller1 ~]# vim /etc/neutron/plugins/ml2/ml2_conf.ini
[ml2_type_flat]
flat_networks = external,internal
其中--provider-physical-network external中external的值由flat_networks选项指定

创建外部网络
[root@controller1 ~]# openstack network create  --share --external --provider-physical-network external --provider-network-type flat external_bond0

创建内部网络
[root@controller1 ~]# openstack network create  --share  --provider-physical-network internal --provider-network-type flat internal_bond1
```

#### 8.2、创建子网

```
创建外部子网
[root@controller1 ~]# openstack subnet create --network external_bond0 --allocation-pool start=192.168.3.100,end=192.168.3.200 --dns-nameserver 192.168.3.1 --gateway 192.168.3.1 --subnet-range 192.168.3.0/24 external_bond0_subnet

创建内部子网
[root@controller2 ~]# openstack subnet create --network internal_bond1 --allocation-pool start=192.168.101.100,end=192.168.101.200 --subnet-range 192.168.101.0/24 internal_bond1_subnet
```

#### 8.3、查看网络

```
[root@controller1 ~]# openstack network list
+--------------------------------------+----------------+--------------------------------------+
| ID                                   | Name           | Subnets                              |
+--------------------------------------+----------------+--------------------------------------+
| 346df603-39f9-46e9-b77d-d344831b36b9 | external_bond0 | dd8738fb-124c-4b72-9d7e-fb72fef41d19 |
| 9db04f9e-df51-4f19-a914-bfe3307b2473 | internal_bond1 | ba657dda-55e9-4eea-af08-268e2f335086 |
+--------------------------------------+----------------+--------------------------------------+

[root@controller1 ~]# openstack subnet list
+--------------------------------------+-----------------------+--------------------------------------+------------------+
| ID                                   | Name                  | Network                              | Subnet           |
+--------------------------------------+-----------------------+--------------------------------------+------------------+
| ba657dda-55e9-4eea-af08-268e2f335086 | internal_bond1_subnet | 9db04f9e-df51-4f19-a914-bfe3307b2473 | 192.168.101.0/24 |
| dd8738fb-124c-4b72-9d7e-fb72fef41d19 | external_bond0_subnet | 346df603-39f9-46e9-b77d-d344831b36b9 | 192.168.3.0/24   |
+--------------------------------------+-----------------------+--------------------------------------+------------------+
```
