+++
author = "zsjshao"
title = "02_docker 镜像与制作"
date = "2020-04-26"
tags = ["docker"]
categories = ["容器"]

+++

# docker镜像与制作

## 1、镜像的生成途径

基于容器制作（commit）,基本不用

- docker commit [OPTIONS] CONTAINER [REPOSITORY[:TAG]]

Dockerfile

![docker_07](http://images.zsjshao.cn/images/docker/docker_07.png)

## 2、Dockerfile

https://docs.docker.com/engine/reference/builder/

### FROM

```
ɝ FROM指令是最重的一个且必须为Dockerfile文件开篇的第一个非注释行，用于为映像文件构建过程指定基准镜像，后续的指令运行于此基准镜像所提供的运行环境
ɝ 实践中，基准镜像可以是任何可用镜像文件，默认情况下，docker build会在docker主机上查找指定的镜像文件，在其不存在时，则会从Docker Hub Registry上拉取所需的镜像文件ɰ 如果找不到指定的镜像文件，docker build会返回一个错误信息
ɝ Syntax
  ɰ FROM <image>[:<tag>] 或
  ɰ FROM <image>@<digest>
    l <image>：指定作为base image的名称；
    l <tag>：base image的标签，为可选项，省略时默认为latest；
```

### MAINTAINER(depreacted)

```
ɝ 用于让镜像制作者提供本人的详细信息
ɝ Dockerfile并不限制MAINTAINER指令可在出现的位置，但推荐将其放置于FROM指令之后,不能放置于FROM之前。
ɝ Syntax
  ɰ MAINTAINER <authtor's detail>
    l <author's detail>可是任何文本信息，但约定俗成地使用作者名称及邮件地址
    l MAINTAINER "zsjshao <zsjshao@163.com>"
ɝ 建议使用LABEL
  ɰ LABEL maintainer="zsjshao@163.com"
```

### LABEL

```
The LABEL instruction adds metadata to an image
  l Syntax: LABEL <key>=<value> <key>=<value> <key>=<value> ...
  l The LABEL instruction adds metadata to an image.
  l A LABEL is a key-value pair.
  l To include spaces within a LABEL value, use quotes and backslashes as you would in command-line parsing.
  l An image can have more than one label.
  l You can specify multiple labels on a single line.
```

### COPY

```
ɝ 用于从Docker主机复制文件至创建的新映像文件
ɝ Syntax
  ɰ COPY <src> ... <dest> 或
  ɰ COPY ["<src>",... "<dest>"]
    l <src>：要复制的源文件或目录，支持使用通配符
    l <dest>：目标路径，即正在创建的image的文件系统路径；建议为<dest>使用绝对路径，否则，COPY指定则以WORKDIR为其起始路径；
  ɰ 注意：在路径中有空白字符时，通常使用第二种格式
ɝ 文件复制准则
  ɰ <src>必须是build上下文中的路径，不能是其父目录中的文件
  ɰ 如果<src>是目录，则其内部文件或子目录会被递归复制，但<src>目录自身不会被复制
  ɰ 如果指定了多个<src>，或在<src>中使用了通配符，则<dest>必须是一个目录，且必须以/结尾
  ɰ 如果<dest>事先不存在，它将会被自动创建，这包括其父目录路径
```
复制时采用通配符方式可创建.dockerignore文件忽略不想复制的文件。

### ADD

```
ɝ ADD指令类似于COPY指令，ADD支持使用TAR文件和URL路径
ɝ Syntax
  ɰ ADD <src> ... <dest> 或
  ɰ ADD ["<src>",... "<dest>"]
ɝ 操作准则
  ɰ 同COPY指令
  ɰ 如果<src>为URL且<dest>不以/结尾，则<src>指定的文件将被下载并直接被创建为<dest>；如果<dest>以/结尾，则文件名URL指定的文件将被直接下载并保存为<dest>/<filename>
  ɰ 如果<src>是一个本地系统上的压缩格式的tar文件，它将被展开为一个目录，其行为类似于“tar -x”命令；然而，通过URL获取到的tar文件将不会自动展开；
  ɰ 如果<src>有多个，或其间接或直接使用了通配符，则<dest>必须是一个以/结尾的目录路径；如果<dest>不以/结尾，则其被视作一个普通文件，<src>的内容将被直接写入到<dest>；
```

### WORKDIR

```
ɝ 用于为Dockerfile中所有的RUN、CMD、ENTRYPOINT、COPY和ADD指定设定工作目录
ɝ Syntax
  ɰ WORKDIR <dirpath>
    l 在Dockerfile文件中，WORKDIR指令可出现多次，其路径也可以为相对路径，不过，其是相对此前一个WORKDIR指令指定的路径
    l 另外，WORKDIR也可调用由ENV指定定义的变量
  ɰ 例如
    l WORKDIR /var/log
    l WORKDIR $STATEPATH
```

### VOLUME

```
ɝ 用于在image中创建一个挂载点目录，以挂载Docker host上的卷或其它容器上的卷
ɝ Syntax
  ɰ VOLUME <mountpoint> 或
  ɰ VOLUME ["<mountpoint>"]
ɝ 如果挂载点目录路径下此前在文件存在，docker run命令会在卷挂载完成后将此前的所有文件复制到新挂载的卷中
```

### EXPOSE

```
ɝ 用于为容器打开指定要监听的端口以实现与外部通信
ɝ Syntax
  ɰ EXPOSE <port>[/<protocol>] [<port>[/<protocol>] ...]
    l <protocol>用于指定传输层协议，可为tcp或udp二者之一，默认为TCP协议
ɝ EXPOSE指令可一次指定多个端口，例如
  ɰ EXPOSE 11211/udp 11211/tcp
```

### ENV

```
ɝ 用于为镜像定义所需的环境变量，并可被Dockerfile文件中位于其后的其它指令（如ENV、ADD、COPY、CMD等）所调用
ɝ 调用格式为$variable_name或${variable_name}
ɝ Syntax
  ɰ ENV <key> <value> 或
  ɰ ENV <key>=<value> ...
ɝ 第一种格式中，<key>之后的所有内容均会被视作其<value>的组成部分，因此，一次只能设置一个变量；
ɝ 第二种格式可用一次设置多个变量，每个变量为一个"<key>=<value>"的键值对，如果<value>中包含空格，可以以反斜线(\)进行转义，也可通过对<value>加引号进行标识；另外，反斜线也可用于续行；
ɝ 定义多个变量时，建议使用第二种方式，以便在同一层中完成所有功能
ɝ ENV变量可被-e/--env list 声明的变量进行替换
```

### ARG
```
l The ARG instruction defines a variable that users can pass at build-time to the builder with the docker build command using the --build-arg <varname>=<value> flag.
l If a user specifies a build argument that was not defined in the Dockerfile, the build outputs a warning.
l Syntax: ARG <name>[=<default value>]
l A Dockerfile may include one or more ARG instructions.
l An ARG instruction can optionally include a default value:
  ü ARG version=1.14
  ü ARG user=zsjshao
```

### RUN

```
ɝ 用于指定docker build过程中运行的程序，其可以是任何命令
ɝ Syntax
  ɰ RUN <command> 或
  ɰ RUN ["<executable>", "<param1>", "<param2>"]
ɝ 第一种格式中，<command>通常是一个shell命令，且以“/bin/sh -c”来运行它，这意味着此进程在容器中的PID不为1，不能接收Unix信号，因此，当使用docker stop <container>命令停止容器时，此进程接收不到SIGTERM信号；
ɝ 第二种语法格式中的参数是一个JSON格式的数组，其中<executable>为要运行的命令，后面的<paramN>为传递给命令的选项或参数；然而，此种格式指定的命令不会以“/bin/sh -c”来发起，因此常见的shell操作如变量替换以及通配符(?,*等)替换将不会进行；不过，如果要运行的命令依赖于此shell特性的话，可以将其替换为类似下面的格式。
  ɰ RUN ["/bin/bash", "-c", "<executable>", "<param1>"]
ɝ 注意：json数组中，要使用双引号
```

### CMD

```
ɝ 类似于RUN指令，CMD指令也可用于运行任何命令或应用程序，不过，二者的运行时间点不同
  ɰ RUN指令运行于映像文件构建过程中，而CMD指令运行于基于Dockerfile构建出的新映像文件启动一个容器时
  ɰ CMD指令的首要目的在于为启动的容器指定默认要运行的程序，且其运行结束后，容器也将终止；不过，CMD指定的命令其可以被docker run的命令行选项所覆盖
  ɰ 在Dockerfile中可以存在多个CMD指令，但仅最后一个会生效
ɝ Syntax
  ɰ CMD <command> 或
  ɰ CMD [“<executable>”, “<param1>”, “<param2>”] 或
  ɰ CMD ["<param1>","<param2>"]
ɝ 前两种语法格式的意义同RUN
ɝ 第三种则用于为ENTRYPOINT指令提供默认参数
```

### ENTRYPOINT

```
ɝ 类似CMD指令的功能，用于为容器指定默认运行程序，从而使得容器像是一个单独的可执行程序
ɝ 与CMD不同的是，由ENTRYPOINT启动的程序不会被docker run命令行指定的参数所覆盖，而且，这些命令行参数会被当作参数传递给ENTRYPOINT指定指定的程序
  ɰ 不过，docker run命令的--entrypoint选项的参数可覆盖ENTRYPOINT指令指定的程序
ɝ Syntax
  ɰ ENTRYPOINT <command>
  ɰ ENTRYPOINT ["<executable>", "<param1>", "<param2>"]
ɝ docker run命令传入的命令参数会覆盖CMD指令的内容并且附加到ENTRYPOINT命令最后做为其参数使用
ɝ Dockerfile文件中也可以存在多个ENTRYPOINT指令，但仅有最后一个会生效
```

### USER

```
ɝ 用于指定运行image时的或运行Dockerfile中任何RUN、CMD或ENTRYPOINT指令指定的程序时的用户名或UID
ɝ 默认情况下，container的运行身份为root用户
ɝ Syntax
  ɰ USER <UID>|<UserName>
  ɰ 需要注意的是，<UID>可以为任意数字，但实践中其必须为/etc/passwd中某用户的有效UID，否则，docker run命令将运行失败
```

### HEALTHCHECK

```
l The HEALTHCHECK instruction tells Docker how to test a container to check that it is still working.
l This can detect cases such as a web server that is stuck in an infinite loop and unable to handle new connections, even though the server process is still running.
l The HEALTHCHECK instruction has two forms:
  ü HEALTHCHECK [OPTIONS] CMD command (check container health by running a command inside the container)
  ü HEALTHCHECK NONE (disable any healthcheck inherited from the base image)
l The options that can appear before CMD are:
  ü --interval=DURATION (default: 30s)
  ü --timeout=DURATION (default: 30s)
  ü --start-period=DURATION (default: 0s)
  ü --retries=N (default: 3)
l The command’s exit status indicates the health status of the container. The possible values are:
  ü 0: success - the container is healthy and ready for use
  ü 1: unhealthy - the container is not working correctly
  ü 2: reserved - do not use this exit code
l For example
  ü HEALTHCHECK --interval=5m --timeout=3s CMD curl -f http://localhost/ || exit 1
```

### SHELL

```
l The SHELL instruction allows the default shell used for the shell form of commands to be overridden.
l The default shell on Linux is ["/bin/sh", "-c"], and on Windows is ["cmd", "/S", "/C"].
l The SHELL instruction must be written in JSON form in a Dockerfile.
  ü Syntax: SHELL ["executable", "parameters"]
l The SHELL instruction can appear multiple times.
l Each SHELL instruction overrides all previous SHELL instructions, and affects all subsequent instructions.
```
### STOPSIGNAL

```
l The STOPSIGNAL instruction sets the system call signal that will be sent to the container to exit.
l This signal can be a valid unsigned number that matches a position in the kernel’s syscall table, for instance 9, or a signal name in the format SIGNAME, for instance SIGKILL.
l Syntax: STOPSIGNAL signal
```

### ONBUILD

```
ɝ 用于在Dockerfile中定义一个触发器
ɝ Dockerfile用于build映像文件，此映像文件亦可作为base image被另一个Dockerfile用作FROM指令的参数，并以之构建新的映像文件
ɝ 在后面的这个Dockerfile中的FROM指令在build过程中被执行时，将会“触发”创建其base image的Dockerfile文件中的ONBUILD指令定义的触发器
ɝ Syntax
  ɰ ONBUILD <INSTRUCTION>
ɝ 尽管任何指令都可注册成为触发器指令，但ONBUILD不能自我嵌套，且不会触发FROM和MAINTAINER指令
ɝ 使用包含ONBUILD指令的Dockerfile构建的镜像应该使用特殊的标签，例如ruby:2.0-onbuild
ɝ 在ONBUILD指令中使用ADD或COPY指令应该格外小心，因为新构建过程的上下文在缺少指定的源文件时会失败
```

**尽量采用分层的方式构建镜像**

## 3、示例：

### 3.1、centos7.7 base镜像制作

```
# 提供Dockerfile文件
vim Dockerfile
FROM centos:7.7.1908
MAINTAINER zsjshao
RUN yum install -y epel-release && \
    yum install -y openssh-server vim iproute passwd iotop bc gcc gcc-c++ glibc glibc-devel pcre pcre-devel openssl openssl-devel zip unzip zlib-devel lrzsz tree ntpdate telnet lsof tcpdump wget libevent libevent-devel bc systemd-devel bash-completion traceroute rsync -y && \        
    yum clean all && \
    rm -rf /var/cache/yum/ && \
    /usr/bin/ssh-keygen -f /root/.ssh/id_rsa -P '' && \
    /usr/bin/ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' && \
    /usr/bin/ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    /usr/bin/ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key -N ''  && \
    sed -i 's/^#UseDNS yes/UseDNS no/' /etc/ssh/sshd_config && \
    sed -i 's/^UseDNS.*/UseDNS no/' /etc/ssh/sshd_config && \
    echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA2gTNkkedvVQyIhzcu1m33wlgoMQRT0BJ5IZDI0Bb7y3yZQ7ntOaYLWXMXRwRdc8paHUpE6XmxqYs3rKAWuRPi8BV9Kh4krsPjpDzl7qHOWxvTy167hGQkoccHkE6UHgNBcWDL8BrQfN6/RARxhw3PvQdvEgam97oeMiMpmjp2bd29mUELjByy3RIDM04GOklBgE4SQjm4n9LOK4Ojp7nUGGv1hPK1fP0YW/Qi21wyK41fXhsRB8d61IYrD76RAVqwoJtuoflNCZJf+EaXn8I7t0sus10Z3znsKSOREsWkMvNZ+dIpVa5O/FeJ0GJ0xMuMlFfk930ENuWiwdVyUNu6w==' >> /root/.ssh/authorized_keys && \
    rm -f /etc/localtime && ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

ADD docker-entrypoint.sh /bin/
EXPOSE 22/tcp
CMD [ "/usr/sbin/sshd","-D" ]
ENTRYPOINT [ "/bin/docker-entrypoint.sh" ]
```

```
# 提供entrypoint脚本文件
vim docker-entrypoint.sh
#!/bin/bash

exec "$@"

chmod +x docker-entrypoint.sh
```

```
# 制作镜像
root@u1:/data/dockerfile/centos/7.7.1908# docker build -t centos7.7-base:latest .
```

### 3.2、基于centos7.7 base制作nginx镜像

```
文件准备
wget http://nginx.org/download/nginx-1.16.1.tar.gz
编辑nginx.conf，添加daemon off;配置参数，让nginx工作在前台
echo "nginx test page" > index.html

# 所需文件列表
root@u1:/data/dockerfile/nginx# ls -lA
total 1024
-rw-r--r-- 1 root root     516 Mar 26 22:11 Dockerfile
-rw-r--r-- 1 root root      16 Mar 26 22:07 index.html
-rw-r--r-- 1 root root 1032630 Aug 14  2019 nginx-1.16.1.tar.gz
-rw-r--r-- 1 root root    2671 Mar 26 22:05 nginx.conf
```

```
# 提供Dockerfile文件
FROM centos7.7-base
MAINTAINER zsjshao
ADD nginx-1.16.1.tar.gz /usr/local/src/
RUN cd /usr/local/src/nginx-1.16.1/ && \
    ./configure --prefix=/apps/nginx --with-http_ssl_module --with-http_v2_module --with-http_realip_module --with-http_stub_status_module --with-http_gzip_static_module --with-pcre && \
    useradd -r -s /sbin/nologin nginx && \
    make && make install && \
    chown nginx.nginx -R /apps/nginx/
COPY index.html /apps/nginx/html/
COPY nginx.conf /apps/nginx/conf/
EXPOSE 80/tcp
CMD [ "/apps/nginx/sbin/nginx" ]
```

```
root@u1:/data/dockerfile/nginx# docker built -t centos7.7-nginx:v1 .
```

测试

```
root@u1:/data/dockerfile/nginx# docker run -d --rm -p 80:80 centos7.7-nginx:v1
d5b231f8e80a6beadaf5b6183ea1b127ddadd6512e3382f12a16e8dac3fdebd5
root@u1:/data/dockerfile/nginx# docker ps -a
CONTAINER ID        IMAGE                COMMAND                  CREATED             STATUS              PORTS                        NAMES
d5b231f8e80a        centos7.7-nginx:v1   "/bin/docker-entrypo…"   49 seconds ago      Up 48 seconds       22/tcp, 0.0.0.0:80->80/tcp   jolly_euclid
root@u1:/data/dockerfile/nginx# curl localhost
nginx test page
```