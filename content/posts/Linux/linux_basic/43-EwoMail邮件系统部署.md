+++
author = "zsjshao"
title = "43_EwoMail"
date = "2020-05-01"
tags = ["linux_basic"]
categories = ["linux_basic"]

+++

## EwoMail邮件系统部署

官网：http://www.ewomail.com/

环境需求：全新系统，没有安装apache、mysql、nginx等服务

1、部署

```
wget -c http://download.ewomail.com:8282/ewomail-1.05.sh && sh ewomail-1.05.sh classroom.com
```

2、修改冲突端口

```
cd /ewomail/nginx/conf/vhost/

# 修改用户登录端口
vim rainloop.conf
修改前：
listen 8000;
修改后：
listen 30010;

vim rainloop.conf.ssl
修改前：
listen 8000 ssl;
修改后：
listen 30010 ssl;


# 修改管理员界面登录端口
vim ewomail-admin.conf
修改前：
listen 8010;
修改后：
listen 30011;

# 修改phpmyadmin界面端口
vim phpmyadmin.conf
修改前：
listen 8020;
修改后：
listen 30012;

# 重新启动nginx
/ewomail/nginx/sbin/nginx -t
/ewomail/nginx/sbin/nginx -s reload

# 若nginx未启动，直接运行即可
/ewomail/nginx/sbin/nginx
```

3、修改php配置，否则用户登录会提示”域不允许“

    vim  /ewomail/www/ewomail-admin/core/config.php
    
    修改后：
    'url' => 'http://192.168.158.70:30011',
    'webmail_url' => 'http://192.168.158.70:30010',
4、在物理机添加hosts解析记录

```
vim /etc/hosts
127.0.0.1 classroom.com mail.classroom.com smtp.classroom.com imap.classroom.com
```

5、登录管理员界面，默认账号admin；密码：ewomail123

登录URL：http://192.168.158.70:30011

![ewomail_01](http://images.zsjshao.net/ewomail/ewomail_01.png)

修改主机名称、imap、smtp为主机IP地址192.168.158.70

添加两个测试用户test01和test02测试邮件是否正常发送接收

![ewomail_02](http://images.zsjshao.net/ewomail/ewomail_02.png)

![ewomail_03](http://images.zsjshao.net/ewomail/ewomail_03.png)

6、分别登录test01和test02账号进行测试

登录URL：http://192.168.158.70:30010

![ewomail_04](http://images.zsjshao.net/ewomail/ewomail_04.png)

![ewomail_05](http://images.zsjshao.net/ewomail/ewomail_05.png)

登录test02查看能否收到测试邮件

![ewomail_06](http://images.zsjshao.net/ewomail/ewomail_06.png)