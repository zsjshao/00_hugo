+++
author = "zsjshao"
title = "openstack-简介"
date = "2020-04-25"
tags = ["openstack"]
categories = ["openstack"]
+++

## openstack简介

<!-- more -->

### 1、云计算与openstack

IT系统架构的发展过程图

![openstack_01](http://images.zsjshao.net/openstack/openstack_01.png)

IT系统架构的发展到目前为止大致可以分为3个阶段：

物理机架构 这一阶段，应用部署和运行在物理机上。 比如企业要上一个ERP系统，如果规模不大，可以找3台物理机，分别部署Web服务器、应用服务器和数据库服务器。 如果规模大一点，各种服务器可以采用集群架构，但每个集群成员也还是直接部署在物理机上。这种架构，一套应用一套服务器，通常系统的资源使用率都很低，达到20%的都是好的。

虚拟化架构 摩尔定律决定了物理服务器的计算能力越来越强，虚拟化技术的发展大大提高了物理服务器的资源使用率。 这个阶段，物理机上运行若干虚拟机，应用系统直接部署到虚拟机上。 虚拟化的好处还体现在减少了需要管理的物理机数量，同时节省了维护成本。

云计算架构 虚拟化提高了单台物理机的资源使用率，随着虚拟化技术的应用，IT环境中有越来越多的虚拟机，这时新的需求产生了： 如何对IT环境中的虚拟机进行统一和高效的管理。 有需求就有供给，云计算登上了历史舞台。

计算（CPU/内存）、存储和网络是 IT 系统的三类资源。 通过云计算平台，这三类资源变成了三个池子 当需要虚机的时候，只需要向平台提供虚机的规格。 平台会快速从三个资源池分配相应的资源，部署出这样一个满足规格的虚机。 虚机的使用者不再需要关心虚机运行在哪里，存储空间从哪里来，IP是如何分配，这些云平台都搞定了。

云平台是一个面向服务的架构，按照提供服务的不同分为 IaaS、PaaS 和 SaaS。

![openstack_02](http://images.zsjshao.net/openstack/openstack_02.png)

IaaS（Infrastructure as a Service）提供的服务是虚拟机。 IaaS 负责管理虚机的生命周期，包括创建、修改、备份、启停、销毁等。 使用者从云平台得到的是一个已经安装好镜像（操作系统+其他预装软件）的虚拟机。 使用者需要关心虚机的类型（OS）和配置（CPU、内存、磁盘），并且自己负责部署上层的中间件和应用。 IaaS 的使用者通常是数据中心的系统管理员。 典型的 IaaS 例子有 AWS、阿里云等。

PaaS（Platform as a Service）提供的服务是应用的运行环境和一系列中间件服务（比如数据库、消息队列等）。 使用者只需专注应用的开发，并将自己的应用和数据部署到PaaS环境中。 PaaS负责保证这些服务的可用性和性能。 PaaS的使用者通常是应用的开发人员。 典型的 PaaS 有 Heroku、Google App Engine、IBM BlueMix 等。

SaaS（Software as a Service）提供的是应用服务。 使用者只需要登录并使用应用，无需关心应用使用什么技术实现，也不需要关系应用部署在哪里。 SaaS的使用者通常是应用的最终用户。 典型的 SaaS 有 Google Gmail、Salesforce 等。

### 2、什么是OpensStack？

What is OpenStack? OpenStack is a cloud operating system that controls large pools of compute, storage, and networking resources throughout a datacenter, all managed through a dashboard that gives administrators control while empowering their users to provision resources through a web interface.

以上是官网对 OpenStack 的定义，OpenStack 对数据中心的计算、存储和网络资源进行统一管理。 由此可见，OpenStack 针对的是 IT 基础设施，是 IaaS 这个层次的云操作系统。

以下是openstack架构图

![openstack_03](http://images.zsjshao.net/openstack/openstack_03.png)

OpenStack覆盖了网络、虚拟化、操作系统、服务器等各个方面，主要由以下11个核心项目组成。
```
Keystone：身份服务（Identity Service）。为OpenStack其他服务提供身份认证、服务规则、服务令牌的功能和管理用户、帐号和角色信息服务，并为对象存储提供授权服务。可以作为OpenStack的统一认证的组件。

Nova：计算（Compute）。一套控制器，用于为单个用户或使用群组管理虚拟机实例的整个生命周期，根据用户需求来提供虚拟服务。负责虚拟机的创建、开机、挂起、暂停、重启、关机、调整、迁移、销毁等操作，配置CPU、内存、硬盘等信息规格。

Glance：镜像服务（Image Service）。一套虚拟机镜像查找及检索系统，支持多种虚拟机镜像格式（AKI、AMI、ARI、ISO、QCOW2、Raw、VDI、VHD、VMDK），有创建上传镜像、删除镜像、编辑镜像基本信息的功能。

Neutron：网络管理（Network）。提供云计算的网络虚拟化技术，为OpenStack其他服务提供网络连接服务。为用户提供接口，可以定义Network、Subnet、Router，配置DHCP、DNS、负载均衡、L3服务，网络支持GRE、VLAN。插件架构支持许多主流的网络厂家和技术，如OpenvSwitch。

Cinder：块存储 (Block Storage)。为运行实例提供数据块存储服务，它的插件驱动架构有利于块设备的创建和管理，如创建卷、删除卷，在实例上挂载和卸载卷。多个卷可以被挂载到单一虚拟机实例，同时卷可以在虚拟机实例间移动，单个卷在同一时刻只能被挂载到一个虚拟机实例。Cinder主要核心是对卷的管理，允许对卷、卷的类型、卷的快照进行处理。它并没有实现对块设备的管理和实际服务，而是为后端不同的存储结构提供了统一的接口，不同的块设备服务厂商在 Cinder 中实现其驱动支持以与 OpenStack 进行整合。

Swift：对象存储（Object Storage）。提供对象存储的功能，对象存储的核心是将数据通路（数据读或写）和控制通路（元数据）分离，并且基于对象存储设备（Object-based Storage Device，OSD）构建存储系统，每个对象存储设备具有一定的智能，能够自动管理其上的数据分布。可为Glance提供镜像存储，为Cinder提供卷备份服务。

Horizon：UI界面 (Dashboard)。在整个Openstack应用体系框架中，Horizon就是整个应用的入口。它提供了一个模块化的，基于web的图形化界面服务门户。用户可以通过浏览器使用这个Web图形化界面来访问、控制他们的计算、存储和网络资源，如启动实例、分配IP地址、设置访问控制等。

Ceilometer：测量 (Metering)。像一个漏斗一样，能把OpenStack内部发生的几乎所有的事件都收集起来，然后为计费和监控以及其它服务提供数据支撑。

Heat：部署编排 (Orchestration)。提供了一种通过模板定义的协同部署方式，实现云基础设施软件运行环境（计算、存储和网络资源）的自动化部署。

Trove：数据库服务（Database Service）。为用户在OpenStack的环境提供可扩展和可靠的关系和非关系数据库引擎服务。

Sahara：旨在使用户能够在Openstack平台上便于创建和管理Hadoop以及其他计算框架集群，实现类似AWS的EMR（Amazon Elastic MapReduce service）服务。
```
