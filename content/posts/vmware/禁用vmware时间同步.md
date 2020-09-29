+++
author = "zsjshao"
title = "vmware禁用时间同步"
date = "2020-04-29"
tags = ["vmware"]
categories = ["vmware"]

+++

### vmware禁用时间同步

1、关闭虚拟机，在虚拟机安装目录中找到vmx虚拟机配置文件

![vmware_01](http://images.zsjshao.net/vmware/vmware_01.png)

2、使用文本编辑工具打开vmx配置文件，修改如下项

```
修改前
tools.syncTime = "TRUE"

修改后
tools.syncTime = "FALSE"
time.synchronize.continue = "FALSE"
time.synchronize.restore = "FALSE"
time.synchronize.resume.disk = "FALSE"
time.synchronize.shrink = "FALSE"
time.synchronize.tools.startup = "FALSE"
```

3、保存退出，启动虚拟机

