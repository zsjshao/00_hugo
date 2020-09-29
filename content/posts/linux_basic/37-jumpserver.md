+++
author = "zsjshao"
title = "37_jumpserver"
date = "2020-05-01"
tags = ["linux_basic"]
categories = ["linux_basic"]

+++

## 1、jumpserver安装

官网：https://jumpserver.org/

### 1.1、安装docker

```
#!/bin/bash
wget https://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo
yum install docker-ce -y
mkdir -p /etc/docker
tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://jr0tl680.mirror.aliyuncs.com"]
}
EOF
systemctl daemon-reload
systemctl enable docker
systemctl restart docker
docker info
:<<EOF
...
 Insecure Registries:
  127.0.0.0/8
 Registry Mirrors:
  https://jr0tl680.mirror.aliyuncs.com/
 Live Restore Enabled: false
EOF
```

### 1.2、docker版安装
https://jumpserver.readthedocs.io/zh/master/dockerinstall.html

#### 1.2.1、拉取镜像

```
[root@c71 ~]# docker pull jumpserver/jms_all:latest
```

#### 1.2.2、mariadb安装

安装mariadb10.4，版本需大于等于5.5.6

```
#!/bin/bash
DB_PASS=jumpserver

echo -e '[MariaDB]\nbaseurl=https://mirrors.aliyun.com/mariadb/yum/10.4/centos7-amd64/\ngpgcheck=0\n' > /etc/yum.repos.d/mariadb.repo
yum install MariaDB-server -y
cat > /etc/my.cnf.d/jumpserver.cnf <<EOF
[mysqld]
default-storage-engine = innodb
innodb_file_per_table = on
skip_name_resolve = on
max_connections = 4096
character-set-server = utf8
EOF
systemctl start mariadb
systemctl enable mariadb
sleep 3
if ! mysql -e 'use jumpserver' &>/dev/null ;then
mysql -e "CREATE DATABASE jumpserver default charset 'utf8';"
mysql -e "GRANT ALL PRIVILEGES ON jumpserver.* TO "jumpserver"@\"%\" IDENTIFIED BY \"$DB_PASS\";"
fi
```

#### 1.2.3、redis安装

```
#!/bin/bash
REDIS_PASS=jumpserver

yum install epel-release -y
yum install redis -y
sed -i 's/^bind.*/bind 0.0.0.0/' /etc/redis.conf
grep ^requirepass /etc/redis.conf || sed -i "/requirepass/a requirepass $REDIS_PASS" /etc/redis.conf
sed -i "s/^requirepass.*/requirepass $REDIS_PASS/" /etc/redis.conf
systemctl start redis
systemctl enable redis
```

#### 1.2.4、启动容器

**密钥生成命令**

```
$ if [ "$SECRET_KEY" = "" ]; then SECRET_KEY=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 50`; echo "SECRET_KEY=$SECRET_KEY" >> ~/.bashrc; echo $SECRET_KEY; else echo $SECRET_KEY; fi
$ if [ "$BOOTSTRAP_TOKEN" = "" ]; then BOOTSTRAP_TOKEN=`cat /dev/urandom | tr -dc A-Za-z0-9 | head -c 16`; echo "BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN" >> ~/.bashrc; echo $BOOTSTRAP_TOKEN; else echo $BOOTSTRAP_TOKEN; fi
```

```
#!/bin/bash
SECRET_KEY=csbmqTvb93m1h2JYrR2JJrSoq3dRKSclabBjaQYvzDEbFTyW7h
BOOTSTRAP_TOKEN=xX55ic6k02tDiAd3
DB_HOST=192.168.3.71
DB_USER=jumpserver
DB_PASSWORD=jumpserver
REDIS_HOST=192.168.3.71
REDIS_PASSWORD=jumpserver

mkdir /opt/jumpserver -p
if ! docker ps | grep jms_all ; then
docker run --name jms_all -d \
    -v /opt/jumpserver:/opt/jumpserver/data/media \
    -p 80:80 \
    -p 2222:2222 \
    -e SECRET_KEY=$SECRET_KEY \
    -e BOOTSTRAP_TOKEN=$BOOTSTRAP_TOKEN \
    -e DB_HOST=$DB_HOST \
    -e DB_PORT=3306 \
    -e DB_USER=$DB_USER \
    -e DB_PASSWORD=$DB_PASSWORD \
    -e DB_NAME=jumpserver \
    -e REDIS_HOST=$REDIS_HOST \
    -e REDIS_PORT=6379 \
    -e REDIS_PASSWORD=$REDIS_PASSWORD \
    jumpserver/jms_all:latest
fi
```

#### 1.2.5、web访问

使用手册：https://jumpserver.readthedocs.io/zh/master/introduce.html

http://IP

![jumpserver_01](http://images.zsjshao.net/jumpserver/jumpserver_01.png)

