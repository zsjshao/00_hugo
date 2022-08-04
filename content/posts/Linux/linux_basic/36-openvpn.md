+++
author = "zsjshao"
title = "36_openvpn"
date = "2020-05-01"
tags = ["linux_basic"]
categories = ["linux_basic"]

+++


## 1、openvpn简介及部署：

VPN：VPN 英文全称(Virtual Private Network)，中文译为：虚拟私人网络，又称为虚拟专用网络，用于在不安全的线路上安全的传输数据。

OpenVPN：一个实现VPN的开源软件，OpenVPN 是一个健壮的、高度灵活的 VPN 守护进程。它支持 SSL/TLS 安全、Ethernet bridging、经由代理的 TCP 或 UDP 隧道和 NAT。另外，它也支持动态 IP 地址以及DHCP，可伸缩性足以支持数百或数千用户的使用场景，同时可移植至大多数主流操作系统平台上。

官网：https://openvpn.net

GitHub地址：https://github.com/OpenVPN/openvpn

openvpn示意图

![openvpn_01](http://images.zsjshao.net/openvpn/openvpn_01.png)

### 1.1、openvpn基础环境：

环境信息：

```
openvpn server：192.168.3.71 172.16.3.71
web-server1：172.16.3.72
操作系统版本： centos 7.7 x86_64
主机名：
```

###  1.2、安装openvpn：

```
#!/bin/bash
NODE_IP=192.168.3.71


# 安装软件包
yum install epel-release -y
rpm -q openvpn || yum install openvpn easy-rsa -y

rpm -q openvpn &>/dev/null || exit 1

OPENVPN_VERSION=`rpm -qi openvpn | grep Version | awk '{print $3}'`
EASY_VERSION=`rpm -qi easy-rsa | grep Version | awk '{print $3}'`
EASY_VERSION_M=`echo $EASY_VERSION | awk -F. '{print $1}'`

# copy配置文件
\cp -f /usr/share/doc/openvpn-$OPENVPN_VERSION/sample/sample-config-files/server.conf /etc/openvpn/
\cp -rf /usr/share/easy-rsa/ /etc/openvpn/
\cp -f /usr/share/doc/easy-rsa-$EASY_VERSION/vars.example /etc/openvpn/easy-rsa/$EASY_VERSION_M/vars

# 初始化pki
cd /etc/openvpn/easy-rsa/$EASY_VERSION
[ -d /etc/openvpn/easy-rsa/$EASY_VERSION/pki ] || ./easyrsa init-pki

# 修改证书有效期
sed -i 's/^#set_var EASYRSA_CERT_EXPIRE.*/set_var EASYRSA_CERT_EXPIRE 36500/' /etc/openvpn/easy-rsa/$EASY_VERSION/vars
sed -i 's/^set_var EASYRSA_CERT_EXPIRE.*/set_var EASYRSA_CERT_EXPIRE 36500/' /etc/openvpn/easy-rsa/$EASY_VERSION/vars

# 创建CA机构
[ -f /etc/openvpn/easy-rsa/$EASY_VERSION/pki/private/ca.key ] || ./easyrsa build-ca nopass <<EOF

EOF

# 创建服务端证书(私钥)
[ -f /etc/openvpn/easy-rsa/$EASY_VERSION/pki/private/server.key ] || ./easyrsa gen-req server nopass <<EOF

EOF

# 签发服务端证书
[ -f /etc/openvpn/easy-rsa/$EASY_VERSION/pki/issued/server.crt ] || ./easyrsa sign server server <<EOF
yes
EOF

# 创建 Diffie-Hellman
[ -f /etc/openvpn/easy-rsa/$EASY_VERSION/pki/dh.pem ] || ./easyrsa gen-dh

# 复制证书到server目录
mkdir -p /etc/openvpn/certs
cp -f /etc/openvpn/easy-rsa/$EASY_VERSION/pki/dh.pem /etc/openvpn/certs/
cp -f /etc/openvpn/easy-rsa/$EASY_VERSION/pki/ca.crt /etc/openvpn/certs/
cp -f /etc/openvpn/easy-rsa/$EASY_VERSION/pki/issued/server.crt /etc/openvpn/certs/
cp -f /etc/openvpn/easy-rsa/$EASY_VERSION/pki/private/server.key /etc/openvpn/certs/

# server配置文件
cat > /etc/openvpn/server.conf <<EOF
local $NODE_IP
port 1194
proto tcp # tcp/udp协议，指定OpenVPN创建的通信隧道类型
#dev tap # 创建一个以太网隧道，以太网使用tap
dev tun  # 创建一个路由IP隧道，互联网使用tun
ca /etc/openvpn/certs/ca.crt
cert /etc/openvpn/certs/server.crt
key /etc/openvpn/certs/server.key
dh /etc/openvpn/certs/dh.pem
server 10.8.0.0 255.255.255.0  # 客户端连接后分配IP的地址池，服务器默认会占用第一个IP 10.8.0.1
push "route 172.16.3.0 255.255.255.0"  # 给客户端生成的静态路由表
push "route 172.16.4.0 255.255.255.0"
client-to-client
keepalive 10 120
cipher AES-256-CBC  # 加密算法
max-clients 100
user nobody
group nobody
persist-key  # 重启VPN服务，你重新读取keys文件，保留使用第一次的keys文件
persist-tun  # 重启vpn服务，一直保持tun或者tap设备是up的，否则会先down然后再up
status openvpn-status.log
log-append /var/log/openvpn/openvpn.log
verb 3
mute 20
crl-verify /etc/openvpn/easy-rsa/$EASY_VERSION/pki/crl.pem
EOF

cd /etc/openvpn/easy-rsa/$EASY_VERSION/
./easyrsa gen-crl

systemctl stop firewalld
systemctl disable firewalld
yum install iptables-services iptables -y
systemctl enable iptables.service
systemctl restart iptables.service
iptables -F
iptables -X
iptables -Z
iptables -t nat -F
iptables -t nat -X
iptables -t nat -Z
grep ^net.ipv4.ip_forward /etc/sysctl.conf || echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf
sysctl -p
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j MASQUERADE
iptables -A INPUT -p TCP --dport 1194 -j ACCEPT
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
service iptables save
mkdir -p /var/log/openvpn
chown nobody.nobody /var/log/openvpn
sed -i 's/^set_var EASYRSA_CERT_EXPIRE.*/set_var EASYRSA_CERT_EXPIRE 60/' /etc/openvpn/easy-rsa/$EASY_VERSION/vars
systemctl enable openvpn@server
systemctl restart openvpn@server
```

###  1.3、创建客户端证书

```
#!/bin/bash
USERNAME=$1
NODE_IP=192.168.3.71

[ -z $USERNAME ] && echo "please input your username \$1" && exit 1

OPENVPN_VERSION=`rpm -qi openvpn | grep Version | awk '{print $3}'`
EASY_VERSION=`rpm -qi easy-rsa | grep Version | awk '{print $3}'`
EASY_VERSION_M=`echo $EASY_VERSION | awk -F. '{print $1}'`

# 复制客户端配置文件
[ -d /etc/openvpn/client/easy-rsa ] || \cp -rf /usr/share/easy-rsa/ /etc/openvpn/client/
[ -f /etc/openvpn/client/easy-rsa/$EASY_VERSION_M/vars ] || \cp -f /usr/share/doc/easy-rsa-$EASY_VERSION/vars.example /etc/openvpn/client/easy-rsa/$EASY_VERSION_M/vars

# 初始化pki
cd /etc/openvpn/client/easy-rsa/$EASY_VERSION
[ -d /etc/openvpn/client/easy-rsa/$EASY_VERSION/pki ] || ./easyrsa init-pki

# 生成客户端证书
\rm -f /etc/openvpn/client/easy-rsa/$EASY_VERSION/pki/private/$USERNAME.key
\rm -f /etc/openvpn/client/easy-rsa/$EASY_VERSION/pki/reqs/$USERNAME.req
./easyrsa gen-req $USERNAME

# 签发客户端证书
\rm -f /etc/openvpn/easy-rsa/$EASY_VERSION/pki/reqs/$USERNAME.req
\rm -f /etc/openvpn/easy-rsa/$EASY_VERSION/pki/issued/$USERNAME.crt
cd /etc/openvpn/easy-rsa/$EASY_VERSION/
./easyrsa import-req /etc/openvpn/client/easy-rsa/$EASY_VERSION/pki/reqs/$USERNAME.req $USERNAME

./easyrsa sign client $USERNAME <<EOF
yes
EOF


mkdir -p /etc/openvpn/client/$USERNAME
cp -f /etc/openvpn/easy-rsa/$EASY_VERSION/pki/ca.crt /etc/openvpn/client/$USERNAME
cp -f /etc/openvpn/easy-rsa/$EASY_VERSION/pki/issued/$USERNAME.crt /etc/openvpn/client/$USERNAME
cp -f /etc/openvpn/client/easy-rsa/$EASY_VERSION/pki/private/$USERNAME.key /etc/openvpn/client/$USERNAME

cat > /etc/openvpn/client/$USERNAME/client.ovpn <<EOF
client
dev tun
proto tcp
remote $NODE_IP 1194
resolv-retry infinite
nobind
persist-key
persist-tun
ca ca.crt
cert $USERNAME.crt
key $USERNAME.key
remote-cert-tls server
#tls-auth ta.key 1
cipher AES-256-CBC
verb 3
EOF
cd /etc/openvpn/client/$USERNAME
mkdir -p /tmp/openvpn/
tar Jcvf /tmp/openvpn/$USERNAME.tar.xz .
```

### 1.4、windows 安装openvpn客户端：

官方客户端下载地址： https://openvpn.net/community-downloads/

非官方地址：https://sourceforge.net/projects/securepoint/files/

openvpn客户端安装过程：略

### 1.5、windows客户端测试连接：

```
[root@c71 3.0.6]# cd /etc/openvpn/client/zsjshao/
[root@c71 zsjshao]# tar -Jcvf zsjshao.tar.xz ./*
./ca.crt
./client.ovpn
./zsjshao.crt
./zsjshao.key
[root@c71 zsjshao]# sz zsjshao.tar.xz
```

![openvpn_02](http://images.zsjshao.net/openvpn/openvpn_02.png)

![openvpn_03](http://images.zsjshao.net/openvpn/openvpn_03.png)

![openvpn_04](http://images.zsjshao.net/openvpn/openvpn_04.png)

![openvpn_05](http://images.zsjshao.net/openvpn/openvpn_05.png)

## 2、高级功能

### 2.1、账号证书管理

主要是证书的创建和吊销，对应的员工的入职和离职

#### 2.2.1、证书自动过期:

过期时间以服务器时间为准，开始检查证书的有效期是否在服务器时间为准的有效期内。

```
[root@c71 3.0.6]# pwd
/etc/openvpn/easy-rsa/3.0.3
[root@c71 3.0.6]# vim vars
117 #set_var EASYRSA_CERT_EXPIRE 3650 #默认3650天
117 set_var EASYRSA_CERT_EXPIRE 60#安装需求更改有效期
```

#### 2.2.2、证书手动注销

```
[root@c71 3.0.6]# cat /etc/openvpn/easy-rsa/3/pki/index.txt #查看证书状态为R吊销状态
[root@c71 3.0.6]# cat /etc/openvpn/easy-rsa/3.0.6/pki/crl.pem
[root@c71 3.0.6]# cd /etc/openvpn/easy-rsa/3.0.6/
[root@c71 3.0.6]# ./easyrsa revoke zhangsan
[root@c71 3.0.6]# ./easyrsa gen-crl
```

#### 2.2.3、修改证书密码

```
[root@c71 3.0.6]# cd /etc/openvpn/client/easy-rsa/3.0.6/
[root@c71 3.0.6]# ./easyrsa set-rsa-pass zhangsan
```