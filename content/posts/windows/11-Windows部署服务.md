预安装阶段---Boot.win---PE

系统安装---Install.win



WDS部署前提

- Server 操作系统
- 文件系统：NTFS
- 必须需要AD架构
- 网络中需要微软DHCP Server
- 安装和配置WDS



SCCM





## DISM

https://docs.microsoft.com/zh-cn/windows-hardware/manufacture/desktop/dism-image-management-command-line-options-s14

```
# 显示有关指定的WIM或VHD文件中包含的映像的信息
dism /Get-ImageInfo /imagefile:d:\install.wim

# 将WIM文件挂载到指定的目录，以便该文件可用于提供服务
mkdir d:\win-mount
dism /mount-wim /wimfile:d:\install.wim /index:4 /mountdir:d:\wim-mount

# 查看映像文件的功能状态
dism /image:d:\win-mount /get-features > d:\wim.txt
notepad d:\win.txt

# 查看映像文件中，IIS-WebServerRole功能状态。默认为：已禁用
dism /image:d:\win-mount /get-featureinfo /featurename:iis-webserverrole

# 启用映像文件中IIS-WebServerRole功能
dism /image:d:\win-mount /enable-feature /featurename:iis-webserverrole /all

# 卸载WIM文件并提交挂载映像时所做的更改
dism /unmount-wim /mountdir:d:\win-mount /commit
```

## SIM

https://docs.microsoft.com/zh-cn/windows-hardware/get-started/kits-and-tools-overview

https://docs.microsoft.com/zh-cn/windows-hardware/customize/desktop/wsim/windows-system-image-manager-scenarios-overview

https://docs.microsoft.com/zh-cn/windows-hardware/manufacture/desktop/windows-setup-configuration-passes



## MDT

https://docs.microsoft.com/zh-cn/mem/configmgr/mdt/?redirectedfrom=MSDN





