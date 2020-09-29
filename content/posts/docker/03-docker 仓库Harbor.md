+++
author = "zsjshao"
title = "03_docker 仓库harbor"
date = "2020-04-26"
tags = ["docker","harbor"]
categories = ["容器"]

+++


# docker仓库 Harbor

harbor是一个用于存储和分发Docker镜像的企业级Registry服务器，由vmware开源，其通过添加一些企业必需的功能特性，例如安全、标识和管理等，扩展了开源Docker Distribution。作为一个企业级私有Registry服务器，harbor提供了更好的性能和安全。提升用户使用Registry构建和运行环境传输的效率。harbor支持安装在多个Registry节点的镜像资源复制，镜像全部保存在私有Registry中，确保数据和知识产权在公司内部网络中管控，另外，harbor也提供了高级的安全特性，诸如用户管理，访问控制和活动审计等。

官网地址：https://vmware.github.io/harbor/cn/

官方github地址：https://github.com/goharbor/harbor

## 1、下载离线Harbor安装包

```
wget https://github.com/goharbor/harbor/releases/download/v1.10.1/harbor-offline-installer-v1.10.1.tgz
```

手动安装docker-compose

```
https://github.com/docker/compose/releases
```

## 2、配置Harbor

证书异常，文档需更新

### 2.1、安装harbor1

```
#!/bin/bash

DOMAIN=zsjshao.net
HARBOR1=harbor1.zsjshao.net
HARBOR2=harbor2.zsjshao.net
HARBOR1_NODE_IP=192.168.3.71          #当前节点
HARBOR2_NODE_IP=192.168.3.72
PASS=shaoji

rpm -q yum-utils || yum install -y yum-utils
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
rpm -q docker-ce || yum -y install docker-ce docker-compose

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
	  "registry-mirrors": ["https://jr0tl680.mirror.aliyuncs.com"]
  }
EOF
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

mkdir /etc/certs -p
rm -rf /etc/certs/*
cd /etc/certs/
openssl genrsa -out harbor_ca.key 4096
openssl req -x509 -new -nodes -sha512 -days 3650 -subj "/C=CN/ST=GD/L=GZ/O=${DOMAIN}/OU=devops/CN=${DOMAIN}" -key harbor_ca.key -out harbor_ca.crt
openssl genrsa -out ${HARBOR1}.key 4096
openssl genrsa -out ${HARBOR2}.key 4096
openssl req -sha512 -new -subj "/C=CN/ST=GD/L=GZ/O=${DOMAIN}/OU=devops/CN=${HARBOR1}" -key ${HARBOR1}.key -out ${HARBOR1}.csr
openssl req -sha512 -new -subj "/C=CN/ST=GD/L=GZ/O=${DOMAIN}/OU=devops/CN=${HARBOR2}" -key ${HARBOR2}.key -out ${HARBOR2}.csr
cat > v3.ext <<-EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
extendedKeyUsage = serverAuth
subjectAltName = @alt_names

[alt_names]
DNS.1=${HARBOR1}
DNS.2=${HARBOR2}
DNS.3=${DOMAIN}
IP.1=${HARBOR1_NODE_IP}
IP.2=${HARBOR2_NODE_IP}
EOF
openssl x509 -req -sha512 -days 3650 -extfile v3.ext -CA harbor_ca.crt -CAkey harbor_ca.key -CAcreateserial -in ${HARBOR1}.csr -out ${HARBOR1}.crt
openssl x509 -req -sha512 -days 3650 -extfile v3.ext -CA harbor_ca.crt -CAkey harbor_ca.key -CAcreateserial -in ${HARBOR2}.csr -out ${HARBOR2}.crt
openssl x509 -inform PEM -in ${HARBOR1}.crt -out ${HARBOR1}.cert
openssl x509 -inform PEM -in ${HARBOR2}.crt -out ${HARBOR2}.cert

mkdir /etc/docker/certs.d/${HARBOR1}/ -p
rm -rf /etc/docker/certs.d/${HARBOR1}/*
\cp -f ${HARBOR1}* /etc/docker/certs.d/${HARBOR1}/
\cp -f harbor_ca.crt /etc/docker/certs.d/${HARBOR1}/
\cp -f harbor_ca.crt /etc/ssl/certs/

systemctl restart docker

# 安装Harbor
cd /usr/local/src/
if [ ! -f harbor-offline-installer-v1.10.1.tgz ] ; then
  echo "file not exist"
  exit 1
fi
rm -rf harbor
rm -rf /data/*
tar xf harbor-offline-installer-v1.10.1.tgz
cd harbor
sed -i "s@^hostname.*@hostname: ${HARBOR1}@" harbor.yml
sed -i "s@^  certificate.*@  certificate: /etc/certs/${HARBOR1}.crt@" harbor.yml
sed -i "s@^  private_key.*@  private_key: /etc/certs/${HARBOR1}.key@" harbor.yml
sed -i "s@^harbor_admin_password.*@harbor_admin_password: $PASS@" harbor.yml
./prepare 
./install.sh --with-clair
```

### 2.2、安装Harbor2

```
#!/bin/bash

DOMAIN=zsjshao.net
HARBOR1=harbor1.zsjshao.net
HARBOR2=harbor2.zsjshao.net
HARBOR1_NODE_IP=192.168.3.71          #当前节点
HARBOR2_NODE_IP=192.168.3.72
PASS=shaoji

rpm -q yum-utils || yum install -y yum-utils
yum-config-manager --add-repo https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
wget -O /etc/yum.repos.d/epel.repo http://mirrors.aliyun.com/repo/epel-7.repo
rpm -q docker-ce || yum -y install docker-ce docker-compose

mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
	  "registry-mirrors": ["https://jr0tl680.mirror.aliyuncs.com"]
  }
EOF
systemctl daemon-reload
systemctl restart docker
systemctl enable docker

mkdir /etc/certs -p
cd /etc/certs/
rm -rf /etc/certs/*
rsync -avlogp ${HARBOR1_NODE_IP}:/etc/certs/* /etc/certs/
\cp -f harbor_ca.crt /etc/ssl/certs/

mkdir /etc/docker/certs.d/${HARBOR2}/ -p
rm -rf /etc/docker/certs.d/${HARBOR2}/*
\cp -fv ${HARBOR2}* /etc/docker/certs.d/${HARBOR2}/
\cp -fv harbor_ca.crt /etc/docker/certs.d/${HARBOR2}/

systemctl restart docker
systemctl enable docker

# 安装Harbor
cd /usr/local/src/
if [ ! -f harbor-offline-installer-v1.10.1.tgz ] ; then
  echo "file not exist"
  exit 1
fi
rm -rf harbor
rm -rf /data/*
tar xf harbor-offline-installer-v1.10.1.tgz
cd harbor
sed -i "s@^hostname.*@hostname: ${HARBOR2}@" harbor.yml
sed -i "s@^  certificate.*@  certificate: /etc/certs/${HARBOR2}.crt@" harbor.yml
sed -i "s@^  private_key.*@  private_key: /etc/certs/${HARBOR2}.key@" harbor.yml
sed -i "s@^harbor_admin_password.*@harbor_admin_password: $PASS@" harbor.yml
./prepare 
./install.sh --with-clair
```

### 2.3、web界面访问

https://FQDN

![harbor_01](http://images.zsjshao.net/docker/harbor/harbor_01.png)

创建项目

![harbor_02](http://images.zsjshao.net/docker/harbor/harbor_02.png)

客户端登录harbor

```
root@u1:~# docker login harbor.zsjshao.net -u admin
Password: 

Login Succeeded
```

证书配置

Error response from daemon: Get https://harbor.zsjshao.net/v2/: x509: certificate signed by unknown authority

若提示证书不被信任，需将ca证书导入受信任的根证书颁发机构

```
scp harbor.zsjshao.net:/data/cert/ca.crt /etc/ssl/certs/
```

上传镜像

```
root@u1:~# docker tag 448f83a26c2d harbor1.zsjshao.net/osbase/centos8.1-base:latest
root@u1:~# docker push harbor1.zsjshao.net/osbase/centos8.1-base:latest
The push refers to repository [harbor1.zsjshao.net/osbase/centos8.1-base]
c905c3521389: Pushed 
e67b282d2de5: Pushed 
0683de282177: Pushed 
latest: digest: sha256:ffeb1fa839bd7741ab39354eb4fcf50b95d96211720cdd98f102461302c56917 size: 949
```

创建复制目标

![harbor_03](http://images.zsjshao.net/docker/harbor/harbor_03.png)

注意：使用域名需要配置DNS提供解析功能，并修改宿主机的DNS配置文件，不能使用/etc/hosts文件进行解析。

创建复制规则

![harbor_04](http://images.zsjshao.net/docker/harbor/harbor_04.png)

查看复制任务

![harbor_05](http://images.zsjshao.net/docker/harbor/harbor_05.png)

在harbor2配置复制harbor1的复制规则，实现镜像同步。

## 3、Harbor管理

```
# 重新安装
docker-compose down -v
docker rmi `docker images | awk '{print $3}'`
./prepare 
./install.sh --with-clair

# 重新启动
docker-compose down -v
docker-compose up -d
```
