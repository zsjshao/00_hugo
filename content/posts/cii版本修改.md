+++
author = "zsjshao"
title = "cii 1.4.0升级到1.5.1"
date = "2020-09-10"
tags = ["cii"]
categories = ["DB"]

+++

## cii 1.4.0升级到1.5.1

1、上传文件到服务器，查看文件

```
[root@cii-501 ~]# ls
1.5.1.zip  anaconda-ks.cfg
```

2、安装unzip软件包

```
[root@cii-501 ~]# yum install -y unzip
```

3、连接pgsql数据库，更新表数据，此步骤仅当版本为1.4.0需执行，1.5.0无需执行此步骤

```
[root@cii-501 ~]# psql -Upostgres
用户 postgres 的口令：
psql (9.5.22)
输入 "help" 来获取帮助信息.

postgres=# \c cii_pri;
您现在已经连接到数据库 "cii_pri",用户 "postgres".
cii_pri=# alter table t_authorization_details add COLUMN ntc_num INT2;
comment on ALTER TABLE
cii_pri=# comment on column t_authorization_details.ntc_num is 'NTC组件数量';

UPCOMMENT
cii_pri=# 
cii_pri=# UPDATE "public"."t_common_config" SET "commonKey"='version.system', "value"='1.5.1', "description"='系统当前版本(1.5.1)' 
cii_pri-# WHERE ("commonKey"='version.system');
UPDATE 1
cii_pri=# update t_common_config set "value" = '1.5.0' where "commonKey" = 'version.rack';
UPDATE 1
cii_pri=# \q
```

附上述步骤所使用的SQL指令，复制粘贴执行即可

```
alter table t_authorization_details add COLUMN ntc_num INT2;
comment on column t_authorization_details.ntc_num is 'NTC组件数量';

UPDATE "public"."t_common_config" SET "commonKey"='version.system', "value"='1.5.1', "description"='系统当前版本(1.5.1)' 
WHERE ("commonKey"='version.system');
update t_common_config set "value" = '1.5.0' where "commonKey" = 'version.rack';
```

4、更新webapps文件

```
[root@cii-501 ~]# unzip -o 1.5.1.zip -d /home/tomcat_8080/webapps/
```

5、重启服务

```
[root@cii-501 ~]# systemctl restart tomcat.service
```

6、使用浏览器访问

![cii_01](http://images.zsjshao.net/cii/cii_01.png)

查看当前平台相关版本信息

```
[root@localhost ~]# su - postgres -c psql
Password: 
psql (9.5.21)
Type "help" for help.

postgres=# \c cii_pri
You are now connected to database "cii_pri" as user "postgres".
cii_pri=# select * from t_common_config where "commonKey" like '%version%';
        commonKey        | value |                description                
-------------------------+-------+-------------------------------------------
 version.cpy             | 1.0.0 | 测评云当前版本
 version.system.isupdate | 0     | 系统版本是否升级0未升级、1已升级、2升级中
 version.cpy.isupdate    | 0     | 测评云资源版本是否升级0未升级、1已升级
 version.rack            | 1.5.9 | 机架当前版本
 version.project         | 1.3.3 | 项目当前版本
 version.course          | 2.2.7 | 课程当前版本
 version.system          | 1.5.0 | 系统当前版本(1.5.0)
(7 rows)

cii_pri=# update t_common_config set "value" = '1.5.0' where "commonKey" = 'version.rack';
UPDATE 1
cii_pri=# \q
select * from knowledge_info;
```
