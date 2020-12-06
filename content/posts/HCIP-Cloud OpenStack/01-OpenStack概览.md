+++
author = "zsjshao"
title = "01-OpenStack概览"
date = "2020-12-05"
tags = ["openstack"]
categories = ["HCIP_Cloud OpenStack"]

+++

## 本章导读

本章节OpenStack概览作为课程的第一章，将帮助大家快速了解什么是OpenStack，为后续的深入学习打下坚实的基础。

本章我们将从如下几个方面着手进行课程内容的介绍

1. OpenStack简介

2. OpenStack架构

3. OpenStack核心服务简介

4. OpenStack服务间交互示例

5. OpenStack动手实验：体验OpenStack

## 1、Openstack简介

### 1.1、OpenStack是什么？

![OpenStack概述](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/01/1.png)

OpenStack是开源云操作系统，可控制整个数据中心的大型计算、存储和网络资源池。

用户能够通过Web界面、命令行或API接口配置资源。

OpenStack社区网站：www.openstack.org

### 1.2、OpenStack和虚拟化、云计算什么关系？

![OpenStack概述](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/01/2.png)

#### 1.2.1、OpenStack不是虚拟化

OpenStack的架构定位与技术范畴：

- OpenStack只是系统的控制面

- OpenStack不包括系统的数据面组件，如Hypervisor、存储和网络设备等。

OpenStack和虚拟化有着关键的区别：

![OpenStack概述](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/01/3.png)

虚拟化是OpenStack底层的技术实现手段之一，但并非核心关注点。

#### 1.2.2、OpenStack不是云计算

OpenStack只是构建云计算的关键组件：

- 内核、骨干、框架、总线

为了构建云计算，我们还需要很多东西：

![OpenStack概述](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/01/4.png)

### 1.3、OpenStack的设计思想

开放

- 开源，并尽可能重用已有开源项目

- 不要“重复发明轮子”

灵活

- 不使用任何不可替代的私有/商业组件

- 大量使用插件方式进行架构设计与实现

可扩展

- 由多个相互独立的项目组成

- 每个项目包含多个独立服务组件

- 无中心架构

- 无状态架构

Apache2.0 License

约70%的代码（核心逻辑）使用Python开发

### 1.4、OpenStack历史版本

OpenStack每年两个大版本，一般在4月和10月中旬发布，版本命名从字母A-Z。

![OpenStack概述](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/01/5.png)

## 2、OpenStack架构

### 2.1、OpenStack架构图

![OpenStack概述](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/01/6.png)

OpenStack的服务分为如下几大类：

- 计算
- 存储
- 网络
- 共用服务
- 硬件生命周期
- 编排
- 工作流
- 应用程序生命周期
- API代理
- 操作界面

OpenStack服务组件通过消息队列（Message Queue）相互通信。

OpenStack组件众多，建议重点关注计算、存储和网络服务组件，其他服务可以在实际工作需要时再进行学习。

### 2.2、OpenStack生成环境部署架构示例

![OpenStack概述](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/01/7.png)

生产环境中，一般会有专门的OpenStack部署服务节点、控制节点、计算节点、网络节点和存储服务节点等。

生产环境的控制节点建议三台以上，其他节点按需求部署。

如果只是测试，OpenStack服务可以部署在单节点上。

## 3、OpenStack核心服务简介

### 3.1、认证服务Keystone

首次出现在OpenStack的“Essex”版本中。

Keystone提供身份验证，服务发现和分布式多租户授权。

Keystone支持LDAP，OAuth，OpenID Connect，SAML和SQL。

依赖的OpenStack服务

- 不依赖其他OpenStack服务，为其他OpenStack服务提供认证支持。

LDAP：Lightweight Directory Access Protocol，轻量目录访问协议

OAuth：Open Authorization，为用户资源的授权提供了一个安全的、开放而又简易的标准。

OpenID Connect是OpenID和Oauth2的合集。

SAML：Security Assertion Markup Language，安全断言标记语言，是一个基于XML的开源标准数据格式，它在当事方之间交换身份验证和授权数据，尤其是在身份提供者和服务提供者之间交换。

### 3.2、操作界面Horizon

Horizon操作界面首次出现咋OpenStack的“Essex”版本中

Horizon提供基于Web的控制界面，使云管理员和用户能够管理各种OpenStack资源和服务。

依赖的OpenStack服务

- 依赖Keystone组件

### 3.3、镜像服务Glance

Glance镜像服务首次出行在OpenStack的“Bexlar”版本中。

Glance提供发现、注册和检索虚拟机镜像功能。

Glance提供的虚拟机实例镜像可以存放在不同地方，例如本地文件系统、对象存储、块存储等。

依赖的OpenStack服务

- 依赖Keystone组件

### 3.4、计算服务Nova

Nova计算服务首次出现在OpenStack的“Austin"版本中。

Nova提供`大规模、可扩展、按需自助服务`的计算资源。

Nova支持管理`裸机、虚拟机和容器`。

依赖的OpenStack服务

- 依赖Keystone、Neutron、Glance组件

### 3.5、块存储服务Cinder

Cinder块存储服务首次出现在OpenStack的”Folsom“版本中

Cinder提供块存储服务，为虚拟机实例提供持久化存储。

Cinder调用不同存储接口驱动，将存储设备转化成块存储池，用户无需了解存储实际部署的位置或设备类型。

依赖的OpenStack服务

- 依赖Keystone组件

### 3.6、对象存储服务Swift

Swift对象存储服务首次出现在OpenStack的”Austin“版本中。

Swift提供高度可用、分布式、最终一致的对象存储服务。

Swift可以高效、安全且廉价的存储大量数据。

Swift非常适合存储需要弹性扩展的非结构化数据。如图片、音频、视频等。

依赖的OpenStack服务

- 为其他OpenStack服务提供对象存储服务

### 3.7、网络服务Neutron

Neutron网络服务首次出现在OpenStack的”Folsom“版本中。

Neutron负责管理虚拟网络组件，专注于为OpenStack提供网络即服务。

依赖的OpenStack服务

- 依赖Keystone组件

### 3.8、编排服务Heat

HEAT编排服务首次出现在OpenStack的”Havana“版本中

Heat为云应用程序编排OpenStack基础架构资源。

Heat提供OpenStack原生Rest API和CloudFormation兼容的查询API。

依赖的OpenStack服务

- 依赖Keystone组件

## 4、OpenStack服务间交互示例

### 4.1、创建一个VM需要些什么资源？

![OpenStack概述](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/01/8.png)

在OpenStack中创建虚拟机实例，资源需求和物理PC类似。

### 4.2、OpenStack创建VM服务间交互示例

![OpenStack概述](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/01/9.png)

OpenStack的核心工作之一是虚拟机生命周期管理。

虚拟机实例创建时，各OpenStack服务协调工作，完成任务。

## 5、OpenStack实验环境

OpenStack Training Labs

https://docs.openstack.org/training_labs/

链接：https://pan.baidu.com/s/1CoqJHLVvii3q3-_GGhKjSA

提取码：rraf

## 6、思考

### 6.1、OpenStack主要作用是什么？

OpenStack是开源云操作系统，可控制整个数据中心的大型计算，存储和网络资源池。

### 6.2、OpenStack有哪些主要服务？各服务的作用是什么？

keystone、glance、nova、neutron、cinder、swift、horizon、heat

- keystone：认证服务

- glance：镜像服务

- nova：计算服务

- neutron：网络服务

- cinder：块存储服务

- swift：对象存储服务

- horizon：UI

- heat：编排服务

## 7、测一测

### 7.1、判断

·OpenStack是一个开源云操作系统，用户只可以通过OpenStack对外提供的web界面来统一配置和管理数据中心的资源和服务。

- `true`
- false 

### 7.2、多选

以下关于OpenStack的设计思想描述正确的是？

- `开放`
- `灵活`
- 私有化
- `可扩展`

### 7.3、单选

以下关于OpenStack的描述不正确的是？

- OpenStack对外提供统一的管理接口

- 虚拟化是OpenStack底层的技术实现手段之一，但并非核心关注点

- OpenStack只是构建云计算的关键组件之一

- `OpenSatck约70%的代码（核心逻辑）使用C语言开发 正确`

用入住酒店类比OpenStack组件交互，以下描述一定不正确的是？

- 携程或酒店官网就类似于是Horizon服务

- 当客户到达酒店后，酒店前台一般会先确认客户的身份，查询是否有预定信息等，这个过程就相当于是Keystone的认证

- `酒店提供专门的存储仓库或者保险柜用来存储物品，相当于对象存储Swift 正确`

- 酒店的走廊和通道就相当于是连接各服务的网络Neutron

KeyStone服务运行依赖OpenSatck中哪个服务？

- Horizon

- `不依赖其他OpenStack服务`

- Glance

- Heat