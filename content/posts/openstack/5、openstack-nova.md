+++
author = "zsjshao"
title = "openstack-nova"
date = "2020-04-22"
tags = ["openstack"]
categories = ["openstack"]
+++

## nova

### 1、什么是nova

Nova是OpenStack 最核心的服务，负责维护和管理云环境的计算资源。OpenStack 作为 IaaS 的云操作系统，虚拟机生命周期管理也就是通过Nova来实现的。

<!-- more -->

### 2、nova架构

Nova 的架构比较复杂，包含很多组件。 这些组件以子服务（后台 deamon 进程）的形式运行。

![nova_01](http://images.zsjshao.net/openstack/nova/nova_01.png)

#### nova-api

nova-api 是整个 Nova 组件的门户，所有对 Nova 的请求都首先由 nova-api 处理。nova-api 向外界暴露若干 HTTP REST API 接口 在 keystone 中我们可以查询 nova-api 的 endponits。

```
[root@controller1 ~]# openstack endpoint list --service compute
+----------------------------------+-----------+--------------+--------------+---------+-----------+--------------------------------------------+
| ID                               | Region    | Service Name | Service Type | Enabled | Interface | URL                                        |
+----------------------------------+-----------+--------------+--------------+---------+-----------+--------------------------------------------+
| 25800f2c52e94cc697d7abbeaf804f2b | RegionOne | nova         | compute      | True    | public    | http://openstack-vip.zsjshao.net:8774/v2.1 |
| 32685087877f4b328d127d5ec2cfc28d | RegionOne | nova         | compute      | True    | admin     | http://openstack-vip.zsjshao.net:8774/v2.1 |
| 6e6617fcb3234a44b73d0c4503b38470 | RegionOne | nova         | compute      | True    | internal  | http://openstack-vip.zsjshao.net:8774/v2.1 |
+----------------------------------+-----------+--------------+--------------+---------+-----------+--------------------------------------------+
```

客户端就可以将请求发送到 endponits 指定的地址，向 nova-api 请求操作。 当然，作为最终用户的我们不会直接发送 Rest AP I请求。 OpenStack CLI，Dashboard 和其他需要跟 Nova 交换的组件会使用这些 API。
Nova-api 对接收到的 HTTP API 请求会做如下处理：

```
1)检查客户端传入的参数是否合法有效
2)调用Nova其他子服务的处理客户端HTTP请求
3)格式化Nova其他子服务返回的结果并返回给客户端
```

#### nova-scheduler

虚机调度服务，负责决定在哪个计算节点上运行虚机

参考链接：https://docs.openstack.org/nova/latest/user/filter-scheduler.html

#### nova-conductor

nova-compute需要获取和更新数据库中instance的信息。但nova-compute并不会直接访问数据库，而是通过nova-conductor实现数据的访问。

![nova_02](http://images.zsjshao.net/openstack/nova/nova_02.png)

```
这样做有两个显著好处：
  更高的安全性
  在 OpenStack 的早期版本中，nova-compute 可以直接访问数据库，但这样存在非常大的安全隐患。 因为 nova-compute 这个服务是部署在计算节点上的，为了能够访问控制节点上的数据库，就必须在计算节点的 /etc/nova/nova.conf 中配置访问数据库的连接信息，比如
    [database]
    connection = mysql+pymysql://glance:glance@openstack-vip.zsjshao.net/glance
  试想任意一个计算节点被黑客入侵，都会导致部署在控制节点上的数据库面临极大风险。为了解决这个问题，从G版本开始，Nova引入了一个新服务nova-conductor，将nova-compute访问数据库的全部操作都放到nova-conductor中，而且nova-conductor是部署在控制节点上的。这样就避免了nova-compute直接访问数据库，增加了系统的安全性。

  更好的伸缩性
  nova-conductor将nova-compute与数据库解耦之后还带来另一个好处：提高了 nova 的伸缩性。nova-compute与conductor是通过消息中间件交互的。
这种松散的架构允许配置多个nova-conductor实例。 在一个大规模的OpenStack部署环境里，管理员可以通过增加nova-conductor的数量来应对日益增长的计算节点对数据库的访问。
```

#### nova-compute

管理虚机的核心服务，通过调用 Hypervisor API 实现虚机生命周期管理
nova-compute在计算节点上运行，负责管理节点上的instance。OpenStack 对 instance 的操作，最后都是交给 nova-compute 来完成的。nova-compute与Hypervisor一起实现 OpenStack 对 instance 生命周期的管理。

nova-compute 的功能可以分为两类：

```
1)定时向 OpenStack 报告计算节点的状态
2)实现 instance 生命周期的管理
```

#### Hypervisor

计算节点上跑的虚拟化管理程序，虚机管理最底层的程序。不同虚拟化技术提供自己的 Hypervisor。常用的 Hypervisor 有KVM，Xen, VMWare等

#### nova-console

用户可以通过多种方式访问虚机的控制台：

```
nova-novncproxy，基于Web浏览器的VNC访问
nova-spicehtml5proxy，基于HTML5浏览器的SPICE访问
nova-xvpnvncproxy，基于Java客户端的VNC访问
```

#### nova-consoleauth

负责对访问虚机控制台请求提供 Token 认证

#### nova-cert

提供 x509 证书支持

#### Database

Nova会有一些数据需要存放到数据库中，一般使用MySQL。数据库安装在控制节点上。 Nova使用命名为 “nova”的数据库。

#### Message Queue

在前面我们了解到Nova包含众多的子服务，这些子服务之间需要相互协调和通信。为解耦各个子服务，Nova通过Message Queue作为子服务的信息中转站。所以在架构图上我们看到了子服务之间没有直接的连线，是通过Message Queue，里面·联系的。

### 3、安装nova

#### 3.1：controller1的配置

创建nova数据库并授权

```
[root@mariadb1 ~]# mysql -e "CREATE DATABASE nova_api;"
[root@mariadb1 ~]# mysql -e "CREATE DATABASE nova;"
[root@mariadb1 ~]# mysql -e "CREATE DATABASE nova_cell0;"
[root@mariadb1 ~]# mysql -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'localhost' IDENTIFIED BY 'nova';"
[root@mariadb1 ~]# mysql -e "GRANT ALL PRIVILEGES ON nova_api.* TO 'nova'@'%' IDENTIFIED BY 'nova';"
[root@mariadb1 ~]# mysql -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'nova';"
[root@mariadb1 ~]# mysql -e "GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'nova';"
[root@mariadb1 ~]# mysql -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'localhost' IDENTIFIED BY 'nova';"
[root@mariadb1 ~]# mysql -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO 'nova'@'%' IDENTIFIED BY 'nova';"
```

创建nova用户

```
[root@controller1 ~]# openstack user create --domain default --password nova nova
```

将nova用户添加到service项目并授予admin角色

```
[root@controller1 ~]# openstack role add --project service --user nova admin
```

创建nova服务，服务类型为compute

```
[root@controller1 ~]# openstack service create --name nova --description "OpenStack Compute" compute
```

创建endpoint

```
[root@controller1 ~]# openstack endpoint create --region RegionOne compute public http://openstack-vip.zsjshao.net:8774/v2.1
[root@controller1 ~]# openstack endpoint create --region RegionOne compute internal http://openstack-vip.zsjshao.net:8774/v2.1
[root@controller1 ~]# openstack endpoint create --region RegionOne compute admin http://openstack-vip.zsjshao.net:8774/v2.1
```

创建placement用户

```
[root@controller1 ~]# openstack user create --domain default --password placement placement
```

将placement用户添加到service项目并授予admin角色

```
[root@controller1 ~]# openstack role add --project service --user placement admin
```

创建placement服务，服务类型为placement

```
[root@controller1 ~]# openstack service create --name placement --description "Placement API" placement
```

创建endpoint

```
[root@controller1 ~]# openstack endpoint create --region RegionOne placement public http://openstack-vip.zsjshao.net:8778
[root@controller1 ~]# openstack endpoint create --region RegionOne placement internal http://openstack-vip.zsjshao.net:8778
[root@controller1 ~]# openstack endpoint create --region RegionOne placement admin http://openstack-vip.zsjshao.net:8778
```

安装nova软件包

```
[root@controller1 ~]# yum install openstack-nova-api openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler openstack-nova-placement-api -y
```

编辑/etc/nova/nova.conf配置文件，修改如下内容

```
[root@controller1 ~]# vim /etc/nova/nova.conf
[DEFAULT]
enabled_apis = osapi_compute,metadata
transport_url = rabbit://openstack:openstack@openstack-vip.zsjshao.net
my_ip = 192.168.101.71
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver

[api]
auth_strategy = keystone

[api_database]
connection = mysql+pymysql://nova:nova@openstack-vip.zsjshao.net/nova_api

[database]
connection = mysql+pymysql://nova:nova@openstack-vip.zsjshao.net/nova

[glance]
api_servers = http://openstack-vip.zsjshao.net:9292

[keystone_authtoken]
auth_url = http://openstack-vip.zsjshao.net:5000/v3
memcached_servers = openstack-vip.zsjshao.net:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = nova
password = nova

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[placement]
os_region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://openstack-vip.zsjshao.net:5000/v3
username = placement
password = placement

[scheduler]
discover_hosts_in_cells_interval = 300

[vnc]
enabled = true
server_listen = $my_ip
server_proxyclient_address = $my_ip
```

编辑/etc/httpd/conf.d/00-nova-placement-api.conf配置文件，添加如下内容

```
[root@controller1 ~]# vim /etc/httpd/conf.d/00-nova-placement-api.conf
...
<Directory /usr/bin>
  <IfVersion >= 2.4>
    Require all granted
  </IfVersion>
  <IfVersion < 2.4>
    Order allow,deny
    Allow from all
  </IfVersion>
</Directory>
```

重启httpd服务

```
[root@controller1 ~]# systemctl restart httpd
```

填充数据库

```
[root@controller1 ~]# su -s /bin/sh -c "nova-manage api_db sync" nova
[root@controller1 ~]# su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
[root@controller1 ~]# su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
[root@controller1 ~]# su -s /bin/sh -c "nova-manage db sync" nova
[root@controller1 ~]# nova-manage cell_v2 list_cells
```

启动服务并设为开机自动启动

```
[root@controller1 ~]# systemctl enable openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service openstack-nova-metadata-api
[root@controller1 ~]# systemctl start openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service openstack-nova-metadata-api
```

#### 3.2：controller2的配置

```
安装nova软件包
[root@controller2 ~]# yum install openstack-nova-api openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler openstack-nova-placement-api -y

拷贝配置文件
[root@controller2 ~]# rsync -avlogp 192.168.3.71:/etc/nova/nova.conf /etc/nova/
[root@controller2 ~]# rsync -avlogp 192.168.3.71:/etc/httpd/conf.d/00-nova-placement-api.conf /etc/httpd/conf.d/

修改配置文件vnc监听地址
[root@controller2 ~]# vim /etc/nova/nova.conf
my_ip = 192.168.101.72

重启httpd服务
[root@controller2 ~]# systemctl restart httpd
[root@controller2 ~]# systemctl enable openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service openstack-nova-metadata-api
[root@controller2 ~]# systemctl start openstack-nova-api.service openstack-nova-consoleauth.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service openstack-nova-metadata-api
```

#### 3.3：compute1的配置

安装软件包

```
[root@compute1 ~]# yum install openstack-nova-compute -y
```

编辑/etc/nova/nova.conf配置文件，修改如下内容

```
[root@compute1 ~]# vim /etc/nova/nova.conf
[DEFAULT]
enabled_apis = osapi_compute,metadata
transport_url = rabbit://openstack:openstack@openstack-vip.zsjshao.net
my_ip = 10.0.0.177
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver

[api]
auth_strategy = keystone

[keystone_authtoken]
auth_url = http://openstack-vip.zsjshao.net:5000/v3
memcached_servers = openstack-vip.zsjshao.net:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = nova
password = nova

[vnc]
enabled = True
server_listen = 0.0.0.0
server_proxyclient_address = $my_ip
novncproxy_base_url = http://openstack-vip.zsjshao.net:6080/vnc_auto.html

[glance]
api_servers = http://openstack-vip.zsjshao.net:9292

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[placement]
os_region_name = RegionOne
project_domain_name = Default
project_name = service
auth_type = password
user_domain_name = Default
auth_url = http://openstack-vip.zsjshao.net:5000/v3
username = placement
password = placement

[libvirt]
virt_type = qemu
```

启动服务并设为开机自动启动

```
[root@compute1 ~]# systemctl enable libvirtd.service openstack-nova-compute.service
[root@compute1 ~]# systemctl start libvirtd.service openstack-nova-compute.service
```

#### 3.4：compute2的配置

```
安装软件包
[root@compute2 ~]# yum install openstack-nova-compute -y

拷贝配置文件
[root@compute2 ~]# rsync -avlogp 192.168.3.73:/etc/nova/nova.conf /etc/nova/

修改配置文件vnc监听地址
[root@compute2 ~]# vim /etc/nova/nova.conf 
my_ip = 192.168.101.74

启动服务并设为开机自动启动
[root@compute2 ~]# systemctl enable libvirtd.service openstack-nova-compute.service
[root@compute2 ~]# systemctl start libvirtd.service openstack-nova-compute.service
```

#### 3.5：controller的配置

```
扫描计算节点
[root@controller1 ~]# su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

查看compute服务
[root@controller1 ~]# openstack compute service list
+----+------------------+-------------------------+----------+---------+-------+----------------------------+
| ID | Binary           | Host                    | Zone     | Status  | State | Updated At                 |
+----+------------------+-------------------------+----------+---------+-------+----------------------------+
|  1 | nova-scheduler   | controller1.zsjshao.net | internal | enabled | up    | 2020-03-13T18:58:11.000000 |
|  2 | nova-consoleauth | controller1.zsjshao.net | internal | enabled | up    | 2020-03-13T18:58:10.000000 |
|  3 | nova-conductor   | controller1.zsjshao.net | internal | enabled | up    | 2020-03-13T18:58:11.000000 |
|  6 | nova-conductor   | controller2.zsjshao.net | internal | enabled | up    | 2020-03-13T18:58:15.000000 |
|  7 | nova-scheduler   | controller2.zsjshao.net | internal | enabled | up    | 2020-03-13T18:58:15.000000 |
|  8 | nova-consoleauth | controller2.zsjshao.net | internal | enabled | up    | 2020-03-13T18:58:15.000000 |
|  9 | nova-compute     | compute1.zsjshao.net    | nova     | enabled | up    | 2020-03-13T18:58:11.000000 |
| 10 | nova-compute     | compute2.zsjshao.net    | nova     | enabled | up    | 2020-03-13T18:58:11.000000 |
+----+------------------+-------------------------+----------+---------+-------+----------------------------+

检查单元格和API接口
[root@controller1 ~]# nova-status upgrade check
Option "os_region_name" from group "placement" is deprecated. Use option "region-name" from group "placement".
+--------------------------------+
| Upgrade Check Results          |
+--------------------------------+
| Check: Cells v2                |
| Result: Success                |
| Details: None                  |
+--------------------------------+
| Check: Placement API           |
| Result: Success                |
| Details: None                  |
+--------------------------------+
| Check: Resource Providers      |
| Result: Success                |
| Details: None                  |
+--------------------------------+
| Check: Ironic Flavor Migration |
| Result: Success                |
| Details: None                  |
+--------------------------------+
| Check: API Service Version     |
| Result: Success                |
| Details: None                  |
+--------------------------------+
```
