+++
author = "zsjshao"
title = "openssh"
date = "2020-06-07"
tags = ["openssh"]
categories = ["windows"]
+++

## openssh安装

1、下载openssh安装包

https://github.com/PowerShell/Win32-OpenSSH/releases

2、解压展开至指定目录，重命名成openssh

3、配置环境变量，添加openssh目录路径

4、安装openssh

- 执行安装脚本install-sshd.ps1

![01_ssh](http://images.zsjshao.net/openssh/01_ssh.png)

5、生成密钥

ssh-keygen -t rsa

6、设置为开机自启动

Set-Service -Name sshd -StartupType 'Automatic'

7、启动服务

Start-Service sshd

8、开启防火墙

New-NetFirewallRule -Protocol TCP -LocalPort 22 -Direction Inbound -Action Allow -DisplayName SSH

注意：命令由powershell内置

