+++
author = "zsjshao"
title = "openstack-脚本"
date = "2020-04-19"
tags = ["openstack"]
categories = ["openstack"]
+++

## openstack

### 环境配置

环境要求：已部署Mariadb、memcached、rabbitmq，使用haproxy进行调度各服务，包括MariaDB、Memcached、rabbitmq

<!-- more -->

Mariadb、memcached、rabbitmq简易环境部署示例

```
#!/bin/bash
VERSION=train
MYSQL_PASS=r00tme
NODE_IP=192.168.3.110
MYSQL_HOST=192.168.3.110
RABBIT_USER=openstack
RABBIT_PASS=openstack

# 添加openstack源
yum install centos-release-openstack-$VERSION -y
yum install python-openstackclient python-memcached openstack-selinux -y
yum update -y

yum install mariadb mariadb-server python2-PyMySQL -y
cat > /etc/my.cnf.d/openstack.cnf << EOF
[mysqld]
bind-address = $MYSQL_HOST
default-storage-engine = innodb
innodb_file_per_table = on
skip_name_resolve=on
max_connections = 4096
collation-server = utf8_general_ci
character-set-server = utf8
EOF
systemctl enable mariadb.service
systemctl start mariadb.service
mysql -e "GRANT ALL PRIVILEGES ON *.* TO "root"@\"%\" IDENTIFIED BY \"$MYSQL_PASS\" with grant option;"

yum install rabbitmq-server -y

systemctl enable rabbitmq-server.service
systemctl start rabbitmq-server.service

rabbitmqctl add_user $RABBIT_USER $RABBIT_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"

yum install memcached python-memcached -y
sed -i "s/OPTIONS=.*/OPTIONS=\"-l 127.0.0.1,::1,$NODE_IP\"/" /etc/sysconfig/memcached

systemctl enable memcached.service
systemctl start memcached.service
```

haproxy部署示例

```
#!/bin/bash
yum install haproxy -y
cat > /etc/haproxy/haproxy.cfg <<EOF
global
    maxconn 100000
#   chroot /usr/local/haproxy
    #stats socket /var/lib/haproxy/haproxy.sock mode 600 level admin
    uid 995
    gid 992
    daemon
    nbproc 4
    cpu-map 1 0
    cpu-map 2 1
    cpu-map 3 2
    cpu-map 4 3
    pidfile /var/run/haproxy.pid
    log 127.0.0.1 local3 info

defaults
    option http-keep-alive
    option  forwardfor
    maxconn 100000
    mode http
    timeout connect 300000ms
    timeout client  300000ms
    timeout server  300000ms

listen stats
    bind :9999
    stats enable
    stats hide-version
    stats uri /haproxy-status
    stats realm HAPorxy\Stats\Page
    stats auth haadmin:123456
    stats refresh 30s
    stats admin if TRUE

listen  dashboard_ex_80
    bind 192.168.3.120:80
    mode tcp
    server web1  192.168.3.101:80  check inter 3000 fall 2 rise 5
    server web2  192.168.3.103:80  check inter 3000 fall 2 rise 5

listen  dashboard_in_80
    bind 192.168.3.120:80
    mode tcp
    server web1  192.168.3.101:80  check inter 3000 fall 2 rise 5
    server web2  192.168.3.103:80  check inter 3000 fall 2 rise 5

listen  mariadb_3306
    bind 192.168.3.120:3306
    mode tcp
    server mariadb1  192.168.3.110:3306  check inter 3000 fall 2 rise 5

listen  rabbitmq_5672
    bind 192.168.3.120:5672
    mode tcp
    balance source
    server rabbitmq1  192.168.3.110:5672  check inter 3000 fall 2 rise 5

listen  rabbitmq_web_15672
    bind 192.168.3.120:15672
    mode tcp
    balance source
    server rabbitmq1  192.168.3.110:15672  check inter 3000 fall 2 rise 5

listen  memcached_11211
    bind 192.168.3.120:11211
    mode tcp
    balance source
    server memcached1  192.168.3.110:11211  check inter 3000 fall 2 rise 5

listen keystone_5000
    bind 192.168.3.120:5000
    mode tcp
    server controller1 192.168.3.101:5000 check inter 3000 fall 2 rise 5
    server controller2 192.168.3.103:5000 check inter 3000 fall 2 rise 5

listen keystone_35357
    bind 192.168.3.120:35357
    mode tcp
    server controller1 192.168.3.101:35357 check inter 3000 fall 2 rise 5
    server controller2 192.168.3.103:35357 check inter 3000 fall 2 rise 5

listen glance_9292
    bind 192.168.3.120:9292
    mode tcp
    server controller1 192.168.3.101:9292 check inter 3000 fall 2 rise 5
    server controller2 192.168.3.103:9292 check inter 3000 fall 2 rise 5

listen nova_8774
    bind 192.168.3.120:8774
    mode tcp
    server nova1 192.168.3.101:8774 check inter 3000 fall 2 rise 5
    server nova2 192.168.3.103:8774 check inter 3000 fall 2 rise 5

listen metadata_8775
    bind 192.168.3.120:8775
    mode tcp
    server metadata1 192.168.3.101:8775 check inter 3000 fall 2 rise 5
    server metadata2 192.168.3.103:8775 check inter 3000 fall 2 rise 5

listen cinder_8776
    bind 192.168.3.120:8776
    mode tcp
    server cinder1 192.168.3.101:8776 check inter 3000 fall 2 rise 5
    server cinder2 192.168.3.103:8776 check inter 3000 fall 2 rise 5

listen placement_8778
    bind 192.168.3.120:8778
    mode tcp
    server placement1 192.168.3.101:8778 check inter 3000 fall 2 rise 5
    server placement2 192.168.3.103:8778 check inter 3000 fall 2 rise 5

listen nova_vnc_6080
    bind 192.168.3.120:6080
    mode tcp
    server nova_vnc1 192.168.3.101:6080 check inter 3000 fall 2 rise 5
    server nova_vnc2 192.168.3.103:6080 check inter 3000 fall 2 rise 5

listen neutron_9696
    bind 192.168.3.120:9696
    mode tcp
    server neutron1 192.168.3.101:9696 check inter 3000 fall 2 rise 5
    server neutron2 192.168.3.103:9696 check inter 3000 fall 2 rise 5
EOF

systemctl enable haproxy
systemctl start haproxy
```



### 控制节点

```
#!/bin/bash
# 设置openstack版本，支持queens、rocky、stein、train
VERSION=train

# 声明环境配置
HAPROXY_VIP=openstack-vip.zsjshao.net
HAPROXY_NODE_IP=192.168.3.120
NODE_IP=192.168.3.101
BRIDGE_NAME=eth0
RABBIT_USER=openstack
RABBIT_PASS=openstack
ADMIN_PASS=admin
MYSQL_PASS=r00tme
HOSTNAME=`hostname`
# 启用cinder后配置nfs服务器地址和共享目录
STORE_NODE_IP=192.168.3.110
SHARE_DIR=/openstack-nfs-data

# 添加openstack源
yum -q install centos-release-openstack-$VERSION -y &>/dev/null 
yum install python-openstackclient openstack-utils python-memcached openstack-selinux -y &>/dev/null 
yum update -y &>/dev/null 

[ -f limits.conf ] && cp -f limits.conf /etc/security/limits.conf

# 添加hosts解析记录
grep openstack-vip.zsjshao.net /etc/hosts &>/dev/null || echo "$HAPROXY_NODE_IP $HAPROXY_VIP" >> /etc/hosts

# 生成服务账号密码
if [ ! -f /root/pass.txt ]; then
GLANCE_PASS=`openssl rand -hex 6`
NOVA_PASS=`openssl rand -hex 6`
PLACEMENT_PASS=`openssl rand -hex 6`
NEUTRON_PASS=`openssl rand -hex 6`
CINDER_PASS=`openssl rand -hex 6`
echo "export GLANCE_PASS=$GLANCE_PASS" >> /root/pass.txt
echo "export NOVA_PASS=$NOVA_PASS" >> /root/pass.txt
echo "export PLACEMENT_PASS=$PLACEMENT_PASS" >> /root/pass.txt
echo "export NEUTRON_PASS=$NEUTRON_PASS" >> /root/pass.txt
echo "export CINDER_PASS=$CINDER_PASS" >> /root/pass.txt
echo "export RABBIT_USER=$RABBIT_USER" >> /root/pass.txt
echo "export RABBIT_PASS=$RABBIT_PASS" >> /root/pass.txt
echo "export HAPROXY_VIP=$HAPROXY_VIP" >> /root/pass.txt
echo "export HAPROXY_NODE_IP=$HAPROXY_NODE_IP" >> /root/pass.txt
fi

source /root/pass.txt

# 生成数据库密码
MYSQL_HOST=$HAPROXY_NODE_IP
if [ ! -f /root/sqlpass.txt ]; then
KEYSTONE_SQL_PASS=`openssl rand -hex 10`
GLANCE_SQL_PASS=`openssl rand -hex 10`
NOVA_SQL_PASS=`openssl rand -hex 10`
PLACEMENT_SQL_PASS=`openssl rand -hex 10`
NEUTRON_SQL_PASS=`openssl rand -hex 10`
CINDER_SQL_PASS=`openssl rand -hex 10`
echo "export KEYSTONE_SQL_PASS=$KEYSTONE_SQL_PASS" >> /root/sqlpass.txt
echo "export GLANCE_SQL_PASS=$GLANCE_SQL_PASS" >> /root/sqlpass.txt
echo "export NOVA_SQL_PASS=$NOVA_SQL_PASS" >> /root/sqlpass.txt
echo "export PLACEMENT_SQL_PASS=$PLACEMENT_SQL_PASS" >> /root/sqlpass.txt
echo "export NEUTRON_SQL_PASS=$NEUTRON_SQL_PASS" >> /root/sqlpass.txt
echo "export CINDER_SQL_PASS=$CINDER_SQL_PASS" >> /root/sqlpass.txt
fi

source /root/sqlpass.txt

# 更改yum源
[ -f /etc/yum.repos.d/CentOS-OpenStack-$VERSION.repo ] && openstack-config --set /etc/yum.repos.d/CentOS-OpenStack-$VERSION.repo centos-openstack-$VERSION baseurl https://mirrors.aliyun.com/centos/7/cloud/x86_64/openstack-$VERSION/

# 安装控制节点的openstack软件包
rpm -q openstack-neutron-linuxbridge &>/dev/null || yum -q info openstack-placement-api &>/dev/null && yum install openstack-placement-api -y &>/dev/null 
rpm -q openstack-neutron-linuxbridge &>/dev/null || yum -q info openstack-placement-api &>/dev/null || yum install openstack-nova-placement-api -y &>/dev/null 
rpm -q openstack-neutron-linuxbridge &>/dev/null || yum install openstack-keystone httpd mod_wsgi python2-PyMySQL openstack-glance openstack-nova-api openstack-nova-conductor openstack-nova-novncproxy openstack-nova-scheduler openstack-nova-console openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables libibverbs openstack-dashboard mariadb openstack-cinder nfs-utils -y 

# 创建数据库和用户账号并授权
if ! mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e 'use keystone' &>/dev/null ;then
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "CREATE DATABASE keystone;"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "CREATE DATABASE glance;"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "CREATE DATABASE nova_api;"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "CREATE DATABASE nova;"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "CREATE DATABASE nova_cell0;"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "CREATE DATABASE placement;"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "CREATE DATABASE neutron;"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "CREATE DATABASE cinder;"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON keystone.* TO "keystone"@\"%\" IDENTIFIED BY \"$KEYSTONE_SQL_PASS\";"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON glance.* TO "glance"@\"%\" IDENTIFIED BY \"$GLANCE_SQL_PASS\";"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON nova.* TO "nova"@\"%\" IDENTIFIED BY \"$NOVA_SQL_PASS\";"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON nova_api.* TO "nova"@\"%\" IDENTIFIED BY \"$NOVA_SQL_PASS\";"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO "nova"@\"%\" IDENTIFIED BY \"$NOVA_SQL_PASS\";"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON placement.* TO "placement"@\"%\" IDENTIFIED BY \"$PLACEMENT_SQL_PASS\";"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON neutron.* TO "neutron"@\"%\" IDENTIFIED BY \"$NEUTRON_SQL_PASS\";"
mysql -uroot -p$MYSQL_PASS -h$MYSQL_HOST -e "GRANT ALL PRIVILEGES ON cinder.* TO "cinder"@\"%\" IDENTIFIED BY \"$CINDER_SQL_PASS\";"
fi

# 连接数据库配置
openstack-config --set /etc/keystone/keystone.conf database connection mysql+pymysql://keystone:$KEYSTONE_SQL_PASS@$HAPROXY_VIP/keystone
openstack-config --set /etc/glance/glance-api.conf database connection mysql+pymysql://glance:$GLANCE_SQL_PASS@$HAPROXY_VIP/glance
openstack-config --set /etc/glance/glance-registry.conf database connection mysql+pymysql://glance:$GLANCE_SQL_PASS@$HAPROXY_VIP/glance
openstack-config --set /etc/nova/nova.conf api_database connection mysql+pymysql://nova:$NOVA_SQL_PASS@$HAPROXY_VIP/nova_api
openstack-config --set /etc/nova/nova.conf database connection mysql+pymysql://nova:$NOVA_SQL_PASS@$HAPROXY_VIP/nova
rpm -q openstack-placement-api || openstack-config --set /etc/nova/nova.conf placement_database connection mysql+pymysql://placement:$PLACEMENT_SQL_PASS@$HAPROXY_VIP/placement
rpm -q openstack-placement-api && openstack-config --set /etc/placement/placement.conf placement_database connection mysql+pymysql://placement:$PLACEMENT_SQL_PASS@$HAPROXY_VIP/placement
openstack-config --set /etc/neutron/neutron.conf database connection mysql+pymysql://neutron:$NEUTRON_SQL_PASS@$HAPROXY_VIP/neutron
openstack-config --set /etc/cinder/cinder.conf database connection mysql+pymysql://cinder:$CINDER_SQL_PASS@$HAPROXY_VIP/cinder

# 配置keystone组件
openstack-config --set /etc/keystone/keystone.conf token provider fernet
su -s /bin/sh -c "keystone-manage db_sync" keystone
keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
keystone-manage bootstrap --bootstrap-password $ADMIN_PASS --bootstrap-admin-url http://$HAPROXY_VIP:5000/v3/ --bootstrap-internal-url http://$HAPROXY_VIP:5000/v3/ --bootstrap-public-url http://$HAPROXY_VIP:5000/v3/ --bootstrap-region-id RegionOne
sed -i "s/^ServerName .*/ServerName $HOSTNAME/" /etc/httpd/conf/httpd.conf
ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
systemctl enable httpd.service
systemctl restart httpd.service
echo "restarting httpd"
sleep 20

export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$HAPROXY_VIP:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2

sleep 3

# 生成用户凭据
cat > /root/admin-openrc << EOF
export OS_PROJECT_DOMAIN_NAME=Default
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_NAME=admin
export OS_USERNAME=admin
export OS_PASSWORD=$ADMIN_PASS
export OS_AUTH_URL=http://$HAPROXY_VIP:5000/v3
export OS_IDENTITY_API_VERSION=3
export OS_IMAGE_API_VERSION=2
EOF
source /root/admin-openrc

sleep 3

# 创建service项目和user角色
if ! openstack user list ; then
  echo "keystone error"
  exit 1
fi
openstack project create --domain default --description "Service Project" service --or-show
openstack role create user --or-show

# 创建各服务组件的用户
openstack user create --domain default --password $GLANCE_PASS glance --or-show
openstack user create --domain default --password $NOVA_PASS nova --or-show
openstack user create --domain default --password $PLACEMENT_PASS placement --or-show
openstack user create --domain default --password $NEUTRON_PASS neutron --or-show
openstack user create --domain default --password $CINDER_PASS cinder --or-show


# 给各组件的用户加入service项目并授予admin角色
openstack role add --project service --user glance admin 
openstack role add --project service --user nova admin
openstack role add --project service --user neutron admin
openstack role add --project service --user placement admin
openstack role add --project service --user cinder admin

# 创建服务
openstack service list | grep glance || openstack service create --name glance --description "OpenStack Image" image
openstack service list | grep nova || openstack service create --name nova --description "OpenStack Compute" compute
openstack service list | grep placement || openstack service create --name placement --description "Placement API" placement
openstack service list | grep neutron || openstack service create --name neutron --description "OpenStack Networking" network
openstack service list | grep cinderv2 || openstack service create --name cinderv2 --description "OpenStack Block Storage" volumev2
openstack service list | grep cinderv3 || openstack service create --name cinderv3 --description "OpenStack Block Storage" volumev3

#创建各服务API列表
if ! openstack endpoint list | grep image &>/dev/null ; then
openstack endpoint create --region RegionOne image public http://$HAPROXY_VIP:9292
openstack endpoint create --region RegionOne image internal http://$HAPROXY_VIP:9292
openstack endpoint create --region RegionOne image admin http://$HAPROXY_VIP:9292
openstack endpoint create --region RegionOne compute public http://$HAPROXY_VIP:8774/v2.1
openstack endpoint create --region RegionOne compute internal http://$HAPROXY_VIP:8774/v2.1
openstack endpoint create --region RegionOne compute admin http://$HAPROXY_VIP:8774/v2.1
openstack endpoint create --region RegionOne placement public http://$HAPROXY_VIP:8778
openstack endpoint create --region RegionOne placement internal http://$HAPROXY_VIP:8778
openstack endpoint create --region RegionOne placement admin http://$HAPROXY_VIP:8778
openstack endpoint create --region RegionOne network public http://$HAPROXY_VIP:9696
openstack endpoint create --region RegionOne network internal http://$HAPROXY_VIP:9696
openstack endpoint create --region RegionOne network admin http://$HAPROXY_VIP:9696
openstack endpoint create --region RegionOne volumev2 public http://$HAPROXY_VIP:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne volumev2 internal http://$HAPROXY_VIP:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne volumev2 admin http://$HAPROXY_VIP:8776/v2/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 public http://$HAPROXY_VIP:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 internal http://$HAPROXY_VIP:8776/v3/%\(project_id\)s
openstack endpoint create --region RegionOne volumev3 admin http://$HAPROXY_VIP:8776/v3/%\(project_id\)s
fi

#编辑glance-api.conf配置文件
#openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_uri http://$HAPROXY_VIP:5000
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken www_authenticate_uri http://$HAPROXY_VIP:5000
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_url http://$HAPROXY_VIP:5000
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken memcached_servers $HAPROXY_VIP:11211
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_type password
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken project_domain_name Default
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken user_domain_name Default
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken project_name service
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken username glance
openstack-config --set /etc/glance/glance-api.conf keystone_authtoken password $GLANCE_PASS
openstack-config --set /etc/glance/glance-api.conf paste_deploy flavor keystone
openstack-config --set /etc/glance/glance-api.conf glance_store stores file,http
openstack-config --set /etc/glance/glance-api.conf glance_store default_store file
openstack-config --set /etc/glance/glance-api.conf glance_store filesystem_store_datadir /var/lib/glance/images/

#编辑glance-registry.conf配置文件，Stein及之前的版本需要配置
if [ -f /etc/glance/glance-registry.conf ] ; then
#openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_uri http://$HAPROXY_VIP:5000
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken www_authenticate_uri http://$HAPROXY_VIP:5000
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_url http://$HAPROXY_VIP:5000
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken memcached_servers $HAPROXY_VIP:11211
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_type password
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken project_domain_name Default
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken user_domain_name Default
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken project_name service
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken username glance
openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken password $GLANCE_PASS
openstack-config --set /etc/glance/glance-registry.conf paste_deploy flavor keystone
fi

#编辑nova.conf配置文件
openstack-config --set /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata
openstack-config --set /etc/nova/nova.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HAPROXY_VIP
openstack-config --set /etc/nova/nova.conf DEFAULT my_ip $NODE_IP
openstack-config --set /etc/nova/nova.conf DEFAULT use_neutron True
openstack-config --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
openstack-config --set /etc/nova/nova.conf api auth_strategy keystone
openstack-config --set /etc/nova/nova.conf keystone_authtoken \#www_authenticate_uri http://$HAPROXY_VIP:5000/v3
openstack-config --set /etc/nova/nova.conf keystone_authtoken www_authenticate_uri http://$HAPROXY_VIP:5000
openstack-config --set /etc/nova/nova.conf keystone_authtoken \#auth_url http://$HAPROXY_VIP:5000/v3
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_url http://$HAPROXY_VIP:5000/v3
openstack-config --set /etc/nova/nova.conf keystone_authtoken memcached_servers $HAPROXY_VIP:11211
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_type password
openstack-config --set /etc/nova/nova.conf keystone_authtoken project_domain_name default
openstack-config --set /etc/nova/nova.conf keystone_authtoken user_domain_name default
openstack-config --set /etc/nova/nova.conf keystone_authtoken project_name service
openstack-config --set /etc/nova/nova.conf keystone_authtoken username nova
openstack-config --set /etc/nova/nova.conf keystone_authtoken password $NOVA_PASS
openstack-config --set /etc/nova/nova.conf vnc enabled true
openstack-config --set /etc/nova/nova.conf vnc server_listen ' $my_ip'
openstack-config --set /etc/nova/nova.conf vnc server_proxyclient_address ' $my_ip'
openstack-config --set /etc/nova/nova.conf glance api_servers http://$HAPROXY_VIP:9292
openstack-config --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
openstack-config --set /etc/nova/nova.conf placement os_region_name RegionOne
openstack-config --set /etc/nova/nova.conf placement project_domain_name Default
openstack-config --set /etc/nova/nova.conf placement project_name service
openstack-config --set /etc/nova/nova.conf placement auth_type password
openstack-config --set /etc/nova/nova.conf placement user_domain_name Default
openstack-config --set /etc/nova/nova.conf placement auth_url http://$HAPROXY_VIP:5000/v3
openstack-config --set /etc/nova/nova.conf placement username placement
openstack-config --set /etc/nova/nova.conf placement password $PLACEMENT_PASS

# 编辑neutron.conf配置文件
openstack-config --set /etc/neutron/neutron.conf DEFAULT core_plugin ml2
openstack-config --set /etc/neutron/neutron.conf DEFAULT service_plugins
openstack-config --set /etc/neutron/neutron.conf DEFAULT allow_overlapping_ips true
openstack-config --set /etc/neutron/neutron.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HAPROXY_VIP
openstack-config --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
openstack-config --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_status_changes true
openstack-config --set /etc/neutron/neutron.conf DEFAULT notify_nova_on_port_data_changes true
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken \#auth_uri http://$HAPROXY_VIP:5000
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri http://$HAPROXY_VIP:5000
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://$HAPROXY_VIP:5000
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers $HAPROXY_VIP:11211
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_type password
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name default
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name default
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_name service
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken username neutron
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken password $NEUTRON_PASS
openstack-config --set /etc/neutron/neutron.conf nova auth_url http://$HAPROXY_VIP:5000
openstack-config --set /etc/neutron/neutron.conf nova auth_type password
openstack-config --set /etc/neutron/neutron.conf nova project_domain_name default
openstack-config --set /etc/neutron/neutron.conf nova user_domain_name default
openstack-config --set /etc/neutron/neutron.conf nova region_name RegionOne
openstack-config --set /etc/neutron/neutron.conf nova project_name service
openstack-config --set /etc/neutron/neutron.conf nova username nova
openstack-config --set /etc/neutron/neutron.conf nova password $NOVA_PASS
openstack-config --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp

# 编辑ml2_conf.ini配置文件
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 type_drivers flat,vlan
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 tenant_network_types 
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 mechanism_drivers linuxbridge
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2 extension_drivers port_security
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini ml2_type_flat flat_networks internal,external
openstack-config --set /etc/neutron/plugins/ml2/ml2_conf.ini securitygroup enable_ipset true

# 编辑linuxbridge_agent.ini配置文件
openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings  external:$BRIDGE_NAME
openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan false
openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group false
openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

# 编辑dhcp_agent.ini配置文件
openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT interface_driver linuxbridge
openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT dhcp_driver neutron.agent.linux.dhcp.Dnsmasq
openstack-config --set /etc/neutron/dhcp_agent.ini DEFAULT enable_isolated_metadata true

# 编辑metadata_agent.ini配置文件
openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT nova_metadata_host $HAPROXY_VIP
openstack-config --set /etc/neutron/metadata_agent.ini DEFAULT metadata_proxy_shared_secret 20200317

# 编辑nova.conf配置文件
openstack-config --set /etc/nova/nova.conf neutron auth_url http://$HAPROXY_VIP:5000
openstack-config --set /etc/nova/nova.conf neutron auth_type password
openstack-config --set /etc/nova/nova.conf neutron project_domain_name default
openstack-config --set /etc/nova/nova.conf neutron user_domain_name default
openstack-config --set /etc/nova/nova.conf neutron region_name RegionOne
openstack-config --set /etc/nova/nova.conf neutron project_name service
openstack-config --set /etc/nova/nova.conf neutron username neutron
openstack-config --set /etc/nova/nova.conf neutron password $NEUTRON_PASS
openstack-config --set /etc/nova/nova.conf neutron service_metadata_proxy true
openstack-config --set /etc/nova/nova.conf neutron metadata_proxy_shared_secret 20200317

# 创建符号链接
ln -s /etc/neutron/plugins/ml2/ml2_conf.ini /etc/neutron/plugin.ini

# 配置placement
if [ -f /etc/httpd/conf.d/00-placement-api.conf ] ; then
openstack-config --set /etc/placement/placement.conf placement_database connection mysql+pymysql://placement:$PLACEMENT_SQL_PASS@$HAPROXY_VIP/placement
openstack-config --set /etc/placement/placement.conf api auth_strategy keystone
openstack-config --set /etc/placement/placement.conf keystone_authtoken auth_url http://$HAPROXY_VIP:5000/v3
openstack-config --set /etc/placement/placement.conf keystone_authtoken memcached_servers $HAPROXY_VIP:11211
openstack-config --set /etc/placement/placement.conf keystone_authtoken auth_type password
openstack-config --set /etc/placement/placement.conf keystone_authtoken project_domain_name Default
openstack-config --set /etc/placement/placement.conf keystone_authtoken user_domain_name Default
openstack-config --set /etc/placement/placement.conf keystone_authtoken project_name service
openstack-config --set /etc/placement/placement.conf keystone_authtoken username placement
openstack-config --set /etc/placement/placement.conf keystone_authtoken password $PLACEMENT_PASS
fi

if [ -f /etc/httpd/conf.d/00-placement-api.conf ] ; then
grep 'Require all granted' /etc/httpd/conf.d/00-placement-api.conf || cat >> /etc/httpd/conf.d/00-placement-api.conf << EOF
<Directory /usr/bin>
  <IfVersion >= 2.4>
    Require all granted
  </IfVersion>
  <IfVersion < 2.4>
    Order allow,deny
    Allow from all
  </IfVersion>
</Directory>
EOF
fi
if [ -f /etc/httpd/conf.d/00-nova-placement-api.conf ] ; then
grep 'Require all granted' /etc/httpd/conf.d/00-nova-placement-api.conf || cat >> /etc/httpd/conf.d/00-nova-placement-api.conf << EOF


<Directory /usr/bin>
  <IfVersion >= 2.4>
    Require all granted
  </IfVersion>
  <IfVersion < 2.4>
    Order allow,deny
    Allow from all
  </IfVersion>
</Directory>
EOF
fi

# 编辑cinder.conf配置文件
if rpm -q openstack-cinder ; then
openstack-config --set /etc/cinder/cinder.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HAPROXY_VIP
openstack-config --set /etc/cinder/cinder.conf DEFAULT auth_strategy keystone
openstack-config --set /etc/cinder/cinder.conf DEFAULT my_ip $NODE_IP
openstack-config --set /etc/cinder/cinder.conf DEFAULT enabled_backends nfs
openstack-config --set /etc/cinder/cinder.conf DEFAULT state_path /var/lib/cinder
openstack-config --set /etc/cinder/cinder.conf DEFAULT default_volume_type  nfs
openstack-config --set /etc/cinder/cinder.conf keystone_authtoken www_authenticate_uri http://$HAPROXY_VIP:5000
openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_url http://$HAPROXY_VIP:5000
openstack-config --set /etc/cinder/cinder.conf keystone_authtoken memcached_servers $HAPROXY_VIP:11211
openstack-config --set /etc/cinder/cinder.conf keystone_authtoken auth_type password
openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_domain_name default
openstack-config --set /etc/cinder/cinder.conf keystone_authtoken user_domain_name default
openstack-config --set /etc/cinder/cinder.conf keystone_authtoken project_name service
openstack-config --set /etc/cinder/cinder.conf keystone_authtoken username cinder
openstack-config --set /etc/cinder/cinder.conf keystone_authtoken password $CINDER_PASS
openstack-config --set /etc/cinder/cinder.conf oslo_concurrency lock_path /var/lib/cinder/tmp
openstack-config --set /etc/cinder/cinder.conf nfs volume_backend_name openstack-NFS
openstack-config --set /etc/cinder/cinder.conf nfs volume_driver cinder.volume.drivers.nfs.NfsDriver
openstack-config --set /etc/cinder/cinder.conf nfs nfs_shares_config /etc/cinder/nfs_openstack_cfg
openstack-config --set /etc/cinder/cinder.conf nfs nfs_mount_point_base  \$state_path/mnt

echo "$STORE_NODE_IP:$SHARE_DIR" > /etc/cinder/nfs_openstack_cfg
chown root.cinder /etc/cinder/nfs_openstack_cfg
fi

# 初始化数据库
su -s /bin/sh -c "glance-manage db_sync" glance

su -s /bin/sh -c "nova-manage api_db sync" nova
su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell1 --verbose" nova
su -s /bin/sh -c "nova-manage db sync" nova
su -s /bin/sh -c "placement-manage db sync" placement
su -s /bin/sh -c "cinder-manage db sync" cinder
su -s /bin/sh -c "neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head" neutron


# 安装dashboard
if [ -f /etc/openstack-dashboard/local_settings ] ; then
sed -i "s/^OPENSTACK_HOST .*/OPENSTACK_HOST = \"$NODE_IP\"/" /etc/openstack-dashboard/local_settings
sed -i "s/^ALLOWED_HOSTS .*/ALLOWED_HOSTS = \[\'*'\]/" /etc/openstack-dashboard/local_settings

LANE=`wc -l /etc/openstack-dashboard/local_settings | awk '{print $1}'`

grep ^SESSION_ENGINE /etc/openstack-dashboard/local_settings || sed -i "${LANE:-50}a SESSION_ENGINE = 'django.contrib.sessions.backends.cache'" /etc/openstack-dashboard/local_settings

grep ^OPENSTACK_KEYSTONE_DEFAULT_ROLE /etc/openstack-dashboard/local_settings || sed -i "${LANE:-50}a OPENSTACK_KEYSTONE_DEFAULT_ROLE = \"user\"" /etc/openstack-dashboard/local_settings
grep ^OPENSTACK_KEYSTONE_DEFAULT_ROLE /etc/openstack-dashboard/local_settings && sed -i "s/^OPENSTACK_KEYSTONE_DEFAULT_ROLE.*/OPENSTACK_KEYSTONE_DEFAULT_ROLE = \"user\"/" /etc/openstack-dashboard/local_settings 

grep ^WEBROOT /etc/openstack-dashboard/local_settings || sed -i "${LANE:-50}a WEBROOT = '/dashboard/'" /etc/openstack-dashboard/local_settings
grep ^WEBROOT /etc/openstack-dashboard/local_settings && sed -i "s@^WEBROOT.*@WEBROOT = '/dashboard/'@" /etc/openstack-dashboard/local_settings

sed -i 's@^TIME_ZONE .*@TIME_ZONE = "Asia/Shanghai"@' /etc/openstack-dashboard/local_settings
grep ^WSGIApplicationGroup /etc/httpd/conf.d/openstack-dashboard.conf || sed -i "3a WSGIApplicationGroup %{GLOBAL}" /etc/httpd/conf.d/openstack-dashboard.conf

grep ^CACHES /etc/openstack-dashboard/local_settings || cat >> /etc/openstack-dashboard/local_settings << EOF
CACHES = {
	'default': {
		 'BACKEND': 'django.core.cache.backends.memcached.MemcachedCache',
		 'LOCATION': '$HAPROXY_VIP:11211',
	}
}

OPENSTACK_API_VERSIONS = {
	"identity": 3,
	"image": 2,
	"volume": 2,
}
EOF
fi

# 设置为开机自启
systemctl enable httpd openstack-glance-api.service openstack-nova-api.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service NetworkManager
openstack-config --set /usr/lib/systemd/system/openstack-nova-conductor.service Service Restart always
openstack-config --set /usr/lib/systemd/system/openstack-nova-conductor.service Service RestartSec 6
openstack-config --set /usr/lib/systemd/system/openstack-nova-scheduler.service Service Restart always
openstack-config --set /usr/lib/systemd/system/openstack-nova-scheduler.service Service RestartSec 6
systemctl daemon-reload

# 重启服务
echo -e '#!/bin/bash\nsystemctl restart openstack-glance-api.service' > /root/rsglance.sh
echo -e '#!/bin/bash\nsystemctl restart openstack-nova-api.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service ' > /root/rsnova.sh
echo -e '#!/bin/bash\nsystemctl restart neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service ' > /root/rsneutron.sh
echo -e '#!/bin/bash\nsystemctl restart openstack-cinder-api.service openstack-cinder-scheduler.service openstack-cinder-volume.service ' > /root/rscinder.sh

if [[ $VERSION == queens || $VERSION == rocky || $VERSION == stein ]] ; then
  systemctl enable openstack-glance-registry.service openstack-nova-consoleauth.service
  echo -e '#!/bin/bash\nsystemctl restart openstack-glance-registry.service' >> /root/rsglance.sh
   echo -e '#!/bin/bash\nsystemctl restart openstack-nova-consoleauth.service' >> rsnova.sh
fi

su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

# 禁用块存储
openstack service set --disable cinderv2
openstack service set --disable cinderv3

# 启用块存储
#openstack service set --enable cinderv2
#openstack service set --enable cinderv3
#echo "$STORE_NODE_IP:$SHARE_DIR" > /etc/cinder/nfs_openstack_cfg
#cinder type-create nfs 
#cinder type-key nfs set volume_backend_name=openstack-NFS
#systemctl enable openstack-cinder-api.service openstack-cinder-scheduler.service openstack-cinder-volume.service
#systemctl start openstack-cinder-api.service openstack-cinder-scheduler.service openstack-cinder-volume.service
```

#### 快速添加控制节点

```
#!/bin/bash
# 设置openstack版本，支持queens、rocky、stein、train
VERSION=train

# 声明环境配置
CONTROLLER_IP=192.168.3.101
NODE_IP=192.168.3.103
HOSTNAME=`hostname`
BRIDGE_NAME=eth0

# 添加openstack源
yum -q install centos-release-openstack-$VERSION -y &>/dev/null 
yum install python-openstackclient openstack-utils python-memcached openstack-selinux -y &>/dev/null 
yum update -y &>/dev/null 

[ -f limits.conf ] && cp -f limits.conf /etc/security/limits.conf

# 更改yum源
[ -f /etc/yum.repos.d/CentOS-OpenStack-$VERSION.repo ] && openstack-config --set /etc/yum.repos.d/CentOS-OpenStack-$VERSION.repo centos-openstack-$VERSION baseurl https://mirrors.aliyun.com/centos/7/cloud/x86_64/openstack-$VERSION/

# 安装控制节点的openstack软件包
rpm -q openstack-neutron-linuxbridge &>/dev/null || yum -q info openstack-placement-api &>/dev/null && yum install openstack-placement-api -y &>/dev/null 
rpm -q openstack-neutron-linuxbridge &>/dev/null || yum -q info openstack-placement-api &>/dev/null || yum install openstack-nova-placement-api -y &>/dev/null 
rpm -q openstack-neutron-linuxbridge &>/dev/null || yum install openstack-keystone httpd mod_wsgi python2-PyMySQL openstack-glance openstack-nova-api openstack-nova-conductor openstack-nova-novncproxy openstack-nova-scheduler openstack-nova-console openstack-neutron openstack-neutron-ml2 openstack-neutron-linuxbridge ebtables libibverbs openstack-dashboard mariadb openstack-cinder nfs-utils -y 

# 解压配置文件至各目录
if ping -c1 -w 1 192.168.3.101 &>/dev/null ; then
echo 'StrictHostKeyChecking no' > /root/.ssh/config
rsync -avlogp $CONTROLLER_IP:/root/* /root/
rsync -avlogp $CONTROLLER_IP:/etc/glance/* /etc/glance/
rsync -avlogp $CONTROLLER_IP:/etc/httpd/* /etc/httpd/
rsync -avlogp $CONTROLLER_IP:/etc/keystone/* /etc/keystone/
rsync -avlogp $CONTROLLER_IP:/etc/neutron/* /etc/neutron/
rsync -avlogp $CONTROLLER_IP:/etc/nova/* /etc/nova/
rpm -q openstack-placement-api &>/dev/null && rsync -avlogp $CONTROLLER_IP:/etc/placement/* /etc/placement/
rsync -avlogp $CONTROLLER_IP:/etc/cinder/* /etc/cinder/
rsync -avlogp $CONTROLLER_IP:/etc/openstack-dashboard/* /etc/openstack-dashboard/
rsync -avlogp $CONTROLLER_IP:/etc/hosts /etc/

rm -f /root/.ssh/config
else
[ -f glance.tar.xz ] || exit 1 && echo "glance.tar.xf not existing"
tar xf root.tar.xz -C /root/
tar xf glance.tar.xz -C /etc/glance/
tar xf httpd.tar.xz -C /etc/httpd/
tar xf keystone.tar.xz -C /etc/keystone/
tar xf neutron.tar.xz -C /etc/neutron/
tar xf nova.tar.xz -C /etc/nova/
rpm -q openstack-placement-api &>/dev/null && tar xf placement.tar.xz -C /etc/placement/
tar xf cinder.tar.xz -C /etc/cinder/
tar xf openstack-dashboard.tar.xz -C /etc/openstack-dashboard/
cp -f hosts /etc/
fi


# 修改配置文件
sed -i "s/^ServerName .*/ServerName $HOSTNAME/" /etc/httpd/conf/httpd.conf
sed -i "s/^my_ip = .*/my_ip = $NODE_IP/" /etc/nova/nova.conf
sed -i "s/^OPENSTACK_HOST .*/OPENSTACK_HOST = \"$NODE_IP\"/" /etc/openstack-dashboard/local_settings
sed -i "s/^physical_interface_mappings =.*/physical_interface_mappings = external:$BRIDGE_NAME/" /etc/neutron/plugins/ml2/linuxbridge_agent.ini

# 设置为开机自启
systemctl enable httpd openstack-glance-api.service openstack-nova-api.service openstack-nova-scheduler.service openstack-nova-conductor.service openstack-nova-novncproxy.service neutron-server.service neutron-linuxbridge-agent.service neutron-dhcp-agent.service neutron-metadata-agent.service NetworkManager
openstack-config --set /usr/lib/systemd/system/openstack-nova-conductor.service Service Restart always
openstack-config --set /usr/lib/systemd/system/openstack-nova-conductor.service Service RestartSec 6
openstack-config --set /usr/lib/systemd/system/openstack-nova-scheduler.service Service Restart always
openstack-config --set /usr/lib/systemd/system/openstack-nova-scheduler.service Service RestartSec 6
systemctl daemon-reload
```

重新配置haproxy完成调度

重启系统验证

### 计算节点

```
#!/bin/bash
# 设置openstack版本，支持queens、rocky、stein、train
VERSION=train

# 声明环境配置
CONTROLLER_IP=192.168.3.101
NODE_IP=192.168.3.102
HOSTNAME=`hostname`
BRIDGE_NAME=eth0

# 添加openstack源
rpm -q openstack-neutron-linuxbridge &>/dev/null || yum -q install centos-release-openstack-$VERSION -y &>/dev/null 
rpm -q openstack-neutron-linuxbridge &>/dev/null || yum -q install python-openstackclient python-memcached openstack-selinux -y &>/dev/null 
rpm -q openstack-neutron-linuxbridge &>/dev/null || yum -q update -y &>/dev/null 

# 更改yum源
openstack-config --set /etc/yum.repos.d/CentOS-OpenStack-$VERSION.repo centos-openstack-$VERSION baseurl https://mirrors.aliyun.com/centos/7/cloud/x86_64/openstack-$VERSION/

[ -f limits.conf ] && cp -f limits.conf /etc/security/limits.conf

# 拷贝密码配置文件
echo 'StrictHostKeyChecking no' > /root/.ssh/config
rsync $CONTROLLER_IP:/root/pass.txt /root/
sleep 3
source /root/pass.txt
if [ ! -f /root/pass.txt ] ; then
    echo 'pass.txt not existing'
    exit 1
fi

rm -f /root/.ssh/config

if [[ $VERSION == queens || $VERSION == rocky ]] ; then
  VNC_IP=$CONTROLLER_IP
else
  VNC_IP=$HAPROXY_VIP
fi

# 添加hosts解析记录
grep openstack-vip.zsjshao.net /etc/hosts &>/dev/null || echo "$HAPROXY_NODE_IP $HAPROXY_VIP" >> /etc/hosts

# 安装软件包
echo "install openstack pkg"
rpm -q openstack-neutron-linuxbridge &>/dev/null || yum install openstack-nova-compute openstack-neutron-linuxbridge ebtables ipset libibverbs openstack-utils openstack-neutron-linuxbridge ebtables ipset rsync -y 

# 编辑nova.conf配置文件
echo "edit config"
openstack-config --set /etc/nova/nova.conf DEFAULT enabled_apis osapi_compute,metadata
openstack-config --set /etc/nova/nova.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HAPROXY_VIP
openstack-config --set /etc/nova/nova.conf DEFAULT my_ip $NODE_IP
openstack-config --set /etc/nova/nova.conf DEFAULT use_neutron True
openstack-config --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.firewall.NoopFirewallDriver
openstack-config --set /etc/nova/nova.conf api auth_strategy keystone
openstack-config --set /etc/nova/nova.conf keystone_authtoken \#auth_url http://$HAPROXY_VIP:5000/v3
openstack-config --set /etc/nova/nova.conf keystone_authtoken www_authenticate_uri http://$HAPROXY_VIP:5000
openstack-config --set /etc/nova/nova.conf keystone_authtoken memcached_servers $HAPROXY_VIP:11211
openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_type password
openstack-config --set /etc/nova/nova.conf keystone_authtoken project_domain_name default
openstack-config --set /etc/nova/nova.conf keystone_authtoken user_domain_name default
openstack-config --set /etc/nova/nova.conf keystone_authtoken project_name service
openstack-config --set /etc/nova/nova.conf keystone_authtoken username nova
openstack-config --set /etc/nova/nova.conf keystone_authtoken password $NOVA_PASS
openstack-config --set /etc/nova/nova.conf vnc enabled True
openstack-config --set /etc/nova/nova.conf vnc server_listen 0.0.0.0
openstack-config --set /etc/nova/nova.conf vnc server_proxyclient_address ' $my_ip'
openstack-config --set /etc/nova/nova.conf vnc novncproxy_base_url http://$VNC_IP:6080/vnc_auto.html
openstack-config --set /etc/nova/nova.conf glance api_servers http://$HAPROXY_VIP:9292
openstack-config --set /etc/nova/nova.conf oslo_concurrency lock_path /var/lib/nova/tmp
openstack-config --set /etc/nova/nova.conf placement os_region_name RegionOne
openstack-config --set /etc/nova/nova.conf placement project_domain_name Default
openstack-config --set /etc/nova/nova.conf placement project_name service
openstack-config --set /etc/nova/nova.conf placement auth_type password
openstack-config --set /etc/nova/nova.conf placement user_domain_name Default
openstack-config --set /etc/nova/nova.conf placement auth_url http://$HAPROXY_VIP:5000/v3
openstack-config --set /etc/nova/nova.conf placement username placement
openstack-config --set /etc/nova/nova.conf placement password $PLACEMENT_PASS
openstack-config --set /etc/nova/nova.conf libvirt virt_type kvm
openstack-config --set /etc/nova/nova.conf cinder os_region_name RegionOne

# 编辑neutron.conf配置文件
openstack-config --set /etc/neutron/neutron.conf DEFAULT transport_url rabbit://$RABBIT_USER:$RABBIT_PASS@$HAPROXY_VIP
openstack-config --set /etc/neutron/neutron.conf DEFAULT auth_strategy keystone
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken www_authenticate_uri http://$HAPROXY_VIP:5000
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_url http://$HAPROXY_VIP:5000
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken memcached_servers $HAPROXY_VIP:11211
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken auth_type password
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_domain_name default
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken user_domain_name default
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken project_name service
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken username neutron
openstack-config --set /etc/neutron/neutron.conf keystone_authtoken password $NEUTRON_PASS
openstack-config --set /etc/neutron/neutron.conf oslo_concurrency lock_path /var/lib/neutron/tmp

# 编辑linuxbridge_agent.ini配置文件
openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini linux_bridge physical_interface_mappings external:$BRIDGE_NAME
openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini vxlan enable_vxlan false
openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup enable_security_group false
openstack-config --set /etc/neutron/plugins/ml2/linuxbridge_agent.ini securitygroup firewall_driver neutron.agent.linux.iptables_firewall.IptablesFirewallDriver

# 编辑nova.conf配置文件
openstack-config --set /etc/nova/nova.conf neutron auth_url http://$HAPROXY_VIP:5000
openstack-config --set /etc/nova/nova.conf neutron auth_type password
openstack-config --set /etc/nova/nova.conf neutron project_domain_name default
openstack-config --set /etc/nova/nova.conf neutron user_domain_name default
openstack-config --set /etc/nova/nova.conf neutron region_name RegionOne
openstack-config --set /etc/nova/nova.conf neutron project_name service
openstack-config --set /etc/nova/nova.conf neutron username neutron
openstack-config --set /etc/nova/nova.conf neutron password $NEUTRON_PASS

# 设置为开机自启
systemctl enable libvirtd.service openstack-nova-compute.service neutron-linuxbridge-agent.service NetworkManager &>/dev/null

# CentOS 7.2及以上版本修改此值，不然kvm模式无法启动云主机
openstack-config --set /etc/nova/nova.conf libvirt hw_machine_type x86_64=pc-i440fx-rhel7.2.0

# nova实现迁移
mkdir -p /var/lib/nova/.ssh
chsh -s /bin/bash nova &>/dev/null
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDE8xLYv5xFsDIpqHg6DzMCEmXpDrGjqJKWdR/C4kg9qTMi4Xccv5yolVCMnDgR1md4EMzufKNB8JokEYC7VgyOcOnIohgET3eZZo+uYIibsf8KvnlQW/A2nXJP4UvB752vrZ6viwZXWeybif2LurRA69JfU/gmFgCvI0ccAKH0EZWbsD5q9blWZopMdVebcH4ULKGWBlx8Hp/Ufu6zn4sY/Ay8vAE9llFsUU+w0MVLz4+paUN5jH++hOXufq8O11tg6P7BGe3HV+3yTgACCyni92jXN/h7/tJzbUXFlpKdOg7QuTHjCkMNatPqTKLHtYe9fT98gzrw3cvxj+Vx3Msb nova@compute.zsjshao.net' > /var/lib/nova/.ssh/id_rsa.pub
echo -e '-----BEGIN RSA PRIVATE KEY-----\nMIIEowIBAAKCAQEAxPMS2L+cRbAyKah4Og8zAhJl6Q6xo6iSlnUfwuJIPakzIuF3\nHL+cqJVQjJw4EdZneBDM7nyjQfCaJBGAu1YMjnDpyKIYBE93mWaPrmCIm7H/Cr55\nUFvwNp1yT+FLwe+dr62er4sGV1nsm4n9i7q0QOvSX1P4JhYAryNHHACh9BGVm7A+\navW5VmaKTHVXm3B+FCyhlgZcfB6f1H7us5+LGPwMvLwBPZZRbFFPsNDFS8+PqWlD\neYx/voTl7n6vDtdbYOj+wRntx1ft8k4AAgsp4vdo1zf4e/7Sc21FxZaSnToO0Lkx\n4wpDDWrT6kyix7WHvX0/fIM68N3L8Y/lcdzLGwIDAQABAoIBAEmr73nauxcqYKlK\nlqaJNvhob2ytjW99yE+1wkrBIGrIVxOOKWM8ndpF+FqQuTya6ht0lWQEhYFOAirJ\nzVDGUG4b+KePUtKR81gTkF2XSKKNA60+MN0JdyLG5JLS4ObLvj2QAZMCuz2DqslH\n5esVzQWX8Rqtq157zoe0942XAv3ryKHx2sBsHQpVWo/jbMgjiyRWa6CzSPUXXW9b\nC/Bt4UvMKfOjih4iGDk4MNM3LtkNjVHA9xkV10iW8W7kVMQKckN+EsGZjuahnrvn\njC/sxWYT3WbZOazFNaZhL5Et53Gds9HMbQQdPPGFM5yT3kT+ezDJ4v9Mcsd+9aqh\n6Bwov7kCgYEA/x6wLZbPeauZR9zgIdd8yWppDKZTtWIKEJEdaZAlAmZ11BxOVjrZ\nQzN25NENSSyqU7p2JpUkfSkYuYE0kZABQcpJK5XBQbYoO+pYw2r8Ha7n/kl+hWdY\nj5h9t68OloBrd7zUCW9oXMOElHe2//5FDAg4hddUOUvO0flbiIryklcCgYEAxaEC\n+33acO4/EFxzwWMqrCyv8IxBB9EyuQapp4Vj5bZ82Kv7sz4s7Fp+sHg8WMAKZzmk\ne1LxE1xEleC8GYCkA54pDF3lSWn+vJ1ItAxfCNT8+DiBoOHDkbDKjAxC3oigCwGO\nLwOyGG0Riprt/gEZ2YAlblTVbdn2n2USrYShet0CgYBNNYJoKa4cynwXLZd/ZnHT\nmyqzs1q+GC+nl+No4UDyGwQp728d1a2PEvI2ibYVoTjjIhlDz/s9DcT3z0yTiRt4\nR7ohQK8+Ldy7VU8LxUML0LVRVfi+cupwetwBTS+DCNZ9ZF5fhKH3AQ0MybZOfyty\nWsKQbvyEYpbzIR48kqCa/QKBgEVMBAOzSZk3sR1Hjb9NynS85qRuSY84J5UBZRO8\njh7KMlS3WXasYowt3yZ5wo9MJ1myuJ4Vozqqq9HyD4LRvLEYEESp1/A6Hnx8mjWn\n8Nrj9CAFkE6dWzoGx777vabSOWwii3yoyxYNiI0VbkYWlL3TVUyuqnfuaa/SfQ4i\n54xxAoGBAJPgto9JTFYETnu2snjX5+4Tmjrqqcs9yiU5uCXyV7Raog7DBpwuMUAk\nPFLA5QD9JyxfrXiF9pF84xHO013hN6mDrmhADvhUVo5+0Gpv8Me4ab1veHMcKWLd\ni83MC5LIE4yHGuQtj2XYcBsckAIsH3uGHGozP9r8Ho1gP46N0fc/\n-----END RSA PRIVATE KEY-----' > /var/lib/nova/.ssh/id_rsa
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDE8xLYv5xFsDIpqHg6DzMCEmXpDrGjqJKWdR/C4kg9qTMi4Xccv5yolVCMnDgR1md4EMzufKNB8JokEYC7VgyOcOnIohgET3eZZo+uYIibsf8KvnlQW/A2nXJP4UvB752vrZ6viwZXWeybif2LurRA69JfU/gmFgCvI0ccAKH0EZWbsD5q9blWZopMdVebcH4ULKGWBlx8Hp/Ufu6zn4sY/Ay8vAE9llFsUU+w0MVLz4+paUN5jH++hOXufq8O11tg6P7BGe3HV+3yTgACCyni92jXN/h7/tJzbUXFlpKdOg7QuTHjCkMNatPqTKLHtYe9fT98gzrw3cvxj+Vx3Msb nova@compute.zsjshao.net' > /var/lib/nova/.ssh/authorized_keys
chown nova.nova /var/lib/nova/.ssh -R

# 优化项
openstack-config --set /etc/nova/nova.conf DEFAULT resume_guests_state_on_host_boot true
openstack-config --set /etc/nova/nova.conf DEFAULT cpu_allocation_ratio 8
openstack-config --set /etc/nova/nova.conf DEFAULT ram_allocation_ratio 1.0
openstack-config --set /etc/nova/nova.conf DEFAULT disk_allocation_ratio 1.0
#openstack-config --set /etc/nova/nova.conf DEFAULT reserved_host_disk_mb 20480
#openstack-config --set /etc/nova/nova.conf DEFAULT reserved_host_memory_mb 4096
openstack-config --set /etc/nova/nova.conf DEFAULT allow_resize_to_same_host true
#openstack-config --set /etc/nova/nova.conf DEFAULT vcpu_pin_set ^0
echo 'net.bridge.bridge-nf-call-iptables = 1' >> /etc/sysctl.conf
echo 'net.bridge.bridge-nf-call-ip6tables = 1' >> /etc/sysctl.conf

echo "finish"
```

### 创建云主机

```
source /root/admin-openrc
su -s /bin/sh -c "nova-manage cell_v2 list_cells" nova
su -s /bin/sh -c "nova-manage cell_v2 discover_hosts --verbose" nova

openstack network create  --share --external --provider-physical-network external --provider-network-type flat external_eth0
openstack subnet create --network external_eth0 --allocation-pool start=192.168.3.200,end=192.168.3.220 --dns-nameserver 192.168.3.1 --gateway 192.168.3.1 --subnet-range 192.168.3.0/24 external_eth0_subnet

openstack flavor create --id 0 --vcpus 1 --ram 64 --disk 1 m1.nano

```

