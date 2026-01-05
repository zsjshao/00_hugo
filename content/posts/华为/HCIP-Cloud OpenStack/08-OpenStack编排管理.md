+++
author = "zsjshao"
title = "08-OpenStack编排管理"
date = "2020-12-05"
tags = ["openstack"]
categories = ["HCIP_Cloud OpenStack"]

+++

## 本章导读

Heat为OpenStack提供资源编排服务，完成OpenStack中资源及应用的自动部署，因此掌握Heat知识对自动化运维OpenStack至关重要。本章节分为理论和实验两个部分，理论部分主要讲解Heat作用、架构和使用场景；实验部分重点锻炼学员Heat日常运维操作，帮助学员理论联系实际，真正掌握Heat 。

本章内容主要包括：

1. OpenStack编排服务Heat简介

2. Heat架构

3. Heat概念

4. Heat典型编排场景

5. OpenStack动手实验： Heat操作

## 1、OpenStack编排访问Heat简介

### 1.1、提问：OpenStack能更加智能化吗？

使用OpenStack运行业务时，遇到以下情况，能更加智能化吗？

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/01.png)

OpenStack架构复杂，服务众多，智能化的应用运维解决方法是必要的。

### 1.2、Heat编排服务，使OpenStack智能化

HEAT编排服务首次出现在OpenStack的“Havana”版本中。

Heat为云应用程序编排OpenStack基础架构资源。

Heat提供OpenStack原生Rest API和CloudFormation兼容的查询API。

依赖的OpenStack服务

- Keystone

### 1.3、Heat在OpenStack中的位置和作用

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/02.png)

Heat向开发人员和系统管理员提供了一种简便地创建和管理一批相关资源的方法，并通过有序且可预测的方式对其进行资源配置和更新。可以使用Heat的标准示例模板或自己创建模板来介绍heat资源以及应用程序运行时所需的任何相关依赖项或运行时参数。可以不需要了解服务需要配置的顺序，也不必弄清楚让这些依赖项正常运行的细枝末节。

对于Heat的功能和实现，简单来说就是用户可以预先定义一个规定格式的任务模版，任务模版中定义了一连串的相关任务（例如用什么配置开几台虚拟机，然后在其中一台中安装一个mysql服务，设定相关数据库属性，然后再配置几台虚拟机安装web服务群集等等），然后将模版交由Heat执行，就会按一定的顺序执行heat模版中定义的一连串任务。

### 1.4、Heat与其他OpenStack服务的关系

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/03.png)

Heat是位于Nova、Neutron等服务之上的一个组件，它充当了OpenStack对外接口的角色，用户不需要直接接触OpenStack其他服务，只需把对各种资源的需求写在Heat模版里，Heat就会自动调用相关服务的接口来配置资源，从而满足用户的需求。

## 2、Heat架构

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/04.png)

用户在Horizon 中或者命令行中提交包含模板和参数输入的请求，Horizon 或者命令行工具会把请求转化为REST 格式的API 调用，然后调用Heat-api 或者是Heat-api-cfn。Heat-api 和Heat-api-cfn 会验证模板的正确性，然后通过消息队列传递给Heat Engine来处理请求。

Heat中的模板是OpenStack资源的集合（虚拟机、网络、存储、告警、浮动IP、安全组、伸缩组、嵌套stack等），通过定义模板，可以将需要创建的资源在模板中描述，用此模板可以多次创建需要的资源。

### 2.1、Heat组件

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/05.png)

### 2.2、Heat Engine架构

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/06.png)

Heat Engine 在这里的作用分为三层：

- 第一层处理Heat 层面的请求，就是根据模板和输入参数来创建Stack（包含各种资源的集合）。
- 第二层解析Stack 里各种资源的依赖关系，Stack 和嵌套Stack 的关系。
- 第三层就是根据解析出来的关系，依次调用各种服务客户端来创建各种资源。

## 3、Heat概念

### 3.1、Heat模板

Template：模板是OpenStack资源的集合（虚拟机、网络、存储、告警、浮动IP、安全组、伸缩组、嵌套stack等），通过定义模板，在模板中描述需要创建的资源，使用模板可以多次创建需要的资源。

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/07.png)

Heat的CFN模板，主要是为了兼容AWS。

CFN和HOT模板结构类似，只是具体的编写参数等有细微区别。

### 3.2、Heat模板默认编写语言 - YAML

YAML Ain't Markup Language

- 使用缩进（一个或多个空格）排版
- 序列项用短划线表示
- MAP中的key-value对用冒号表示

https://yaml.org/start.html

### 3.3、Heat模板 - “Hello World”

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/08.png)

“Hello World”模板简单演示如何使用Heat编排创建一台虚拟机，使用指定密钥对、

### 3.4、HOT模板 - 结构

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/09.png)

Heat template version：支持如下版本字段，建议根据实际的OpenStack版本选择匹配的Heat模板版本号：

- 2013-05-23
- 2014-10-16
- 2015-04-30
- 2015-10-15
- 2016-04-08
- 2016-10-14或newton
- 2017-02-24或ocata
- 2017-09-01或pike
- 2018-03-02或queens
- 2018-08-31或rocky

Parameters：输入参数支持的参数类型主要有string，number，comma_delimited_list，json，boolean。

### 3.5、HOT模板 - Resource

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/10.png)

resource ID

- 资源ID，在模板的resources部分中必须是唯一的。

type

- 资源类型，例如OS::Nova::Server或OS::Neutron::Port，必选属性。

properties

- 特定于资源的属性列表。可以在适当的位置或通过函数提供属性值，可选属性。

metadata

- 特定于资源的元数据。此部分是可选的。

depends_on

- 资源依赖模板中的一个或多个资源上，可选属性。

update_policy

- 以嵌套字典的形式更新资源的策略，可选属性。

deletion_policy

- 删除资源的策略。允许的删除策略是Delete，Retain和Snapshot。该属性是可选的，默认策略是从Stack中删除资源时删除物理资源。

external_id

- 允许为现有外部（到堆栈）资源指定resource_id，可选属性。

Condition

- 资源的条件，决定是否创建资源，可选属性。
- Newton版本开始支持。

### 3.6、HOT模板 - 查询Resource Type

Heat中支持的资源非常多，当进行资源定义时，可以使用命令查询资源所需的参数及类型。

查找需要创建的资源

```
osbash@controller:~$ openstack orchestration resource type list | grep Server
| OS::Heat::DeployedServer                 |
| OS::Nova::Server                         |
| OS::Nova::ServerGroup                    |
```

列出资源详情

```
osbash@controller:~$ openstack orchestration resource type show OS::Nova::Server
resource_type: OS::Nova::Server
properties:
  admin_pass:
    description: The administrator password for the server.
    immutable: false
    required: false
...
```

### 3.7、Heat Stack

Stack：资源的集合，管理一组资源的基本单位，用户操作的最小单位。

通过对Stack的生命周期管理，进而完成应用的部署和对资源的管理。

Stack示例：

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/11.png)

### 3.8、Heat Stack常用命令

```
stack list
stack create
stack show
stack delete
stack output list
stack resource list
stack event show
```

## 4、Heat典型编排场景

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/12.png)

Heat 从多方位支持对资源进行设计和编排：

- 基础架构资源编排：对计算、存储和网络等基础资源进行编排，支持用户自定义脚本配置虚拟机。
- 应用资源编排：实现对虚拟机的复杂配置，例如安装软件、配置软件。
- 高级功能编排：例如应用的负载均衡和自动伸缩。
- 第三方工具集成编排：例如复用用户环境中现有的AnsiblePlaybook配置，节省配置时间。

### 4.1、Heat对基础架构资源的编排

对于不同的OpenStack资源，Heat提供了不同的资源类型。

- 例如虚拟机，Heat提供了OS::Nova::Server，并提供一些参数（key、image、flavor等），参数可以在模板中直接指定，也可以在创建Stack时提供。

使用模板创建资源

```
openstack stack create --template server_console.yaml --parameter "image=ubuntu" STACK_NAME
```

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/13.png)

更多Heat模板示例，请参考如下链接：

- https://github.com/openstack/heat-templates/blob/master/hot/server_console.yaml

### 4.2、Heat对软件配置和部署的编排

Heat提供了多种资源类型来支持对于软件配置和部署的编排，其中最常用的是OS::Heat::SoftwareConfig和OS::Heat::SoftwareDeployment。

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/14.png)

Heat 提供了多种资源类型来支持对于软件配置和部署的编排，例如：

- OS::Heat::CloudConfig：VM 引导程序启动时的配置，由OS::Nova::Server 引用
- OS::Heat::SoftwareConfig：描述软件配置
- OS::Heat::SoftwareDeployment：执行软件部署
- OS::Heat::SoftwareDeploymentGroup：对一组VM 执行软件部署
- OS::Heat::SoftwareComponent：针对软件的不同生命周期部分，对应描述软件配置
- OS::Heat::StructuredConfig：和OS::Heat::SoftwareConfig 类似，但是用Map 来表述配置
- OS::Heat::StructuredDeployment：执行OS::Heat::StructuredConfig 对应的配置
- OS::Heat::StructuredDeploymentsGroup：对一组VM 执行OS::Heat::StructuredConfig 对应的配置

### 4.3、Heat对资源自动伸缩的编排

Heat提供自动伸缩组和伸缩策略，结合Ceilometer可以实现根据各种条件，比如负载，进行资源自动伸缩的功能。

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/15.png)

### 4.4、Heat负载均衡的编排

Heat提供自动负载均衡编排，由一组不同的资源类型来实现。

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/16.png)

负载均衡是一个高级应用，它也是由一组不同的资源类型来实现的。资源类型包括：

- OS::Neutron::Pool：定义资源池，一般可以由VM 组成
- OS::Neutron::PoolMember：定义资源池的成员
- OS::Neutron::HealthMonitor：定义健康监视器，根据自定的协议，比如TCP 来监控资源的状态，并提供给
- OS::Neutron::Pool 来调整请求分发
- OS::Neutron::LoadBalancer：关联资源池以定义整个负载均衡。

### 4.5、Heat和配置管理工具集成

Heat在基于OS::Heat::SoftwareConfig和OS::Heat::SoftwareDeployment的协同使用上，提供了对Chef、Puppet和Ansible等流行配置管理工具的支持。

![Heat](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/08/17.png)

随着DevOps的流行，大量配置管理的工具应运而生，比如Chef、Puppet和Ansible。各种工具除了提供一个平台框架外，更是针对大量的中间件和软件部署提供了可以灵活配置和引用的脚本。

## 5、OpenStack动手实验：Heat操作

### 5.1、heatclient

```
osbash@controller:~$ sudo apt install python-heatclient
```

### 5.2、demo.yaml

```
osbash@controller:~$ cat demo.yaml
heat_template_version: 2015-10-15

parameters:
 NetID:
  type: string
  description: Network ID to use for the instance

resources:
 server:
  type: OS::Nova::Server
  properties:
   image: cirros
   flavor: cirrors
   networks:
   - network: {get_param: NetID}

outputs:
 instance_name:
  description: Name of the instance.
  value: {get_attr: [server,name]}
 instance_ip:
  description: IP address of the instance.
  value: {get_attr: [server,first_address]}

osbash@controller:~$ openstack network list
+--------------------------------------+-------------+--------------------------------------+
| ID                                   | Name        | Subnets                              |
+--------------------------------------+-------------+--------------------------------------+
| 53a8a22e-089d-451c-8843-8e1e190e103e | network_cli | bf87d804-953f-43f6-a057-7c173677e05a |
| 7026b16b-dc98-4283-aeda-027cb66e3c39 | selfservice | 469317e6-f2dd-496f-b2ba-d33169cf4d4f |
| b8452e19-b6b5-4c96-831a-5ddc05e73c94 | provider    | 5b085117-9dc3-4326-9561-984501e1278e |
+--------------------------------------+-------------+--------------------------------------+

osbash@controller:~$ openstack stack create -t demo.yaml --parameter "NetID=b8452e19-b6b5-4c96-831a-5ddc05e73c94" stack_demo
+---------------------+--------------------------------------+
| Field               | Value                                |
+---------------------+--------------------------------------+
| id                  | c796cb3e-5f68-4f40-b99f-aa79c71d5979 |
| stack_name          | stack_demo                           |
| description         | No description                       |
| creation_time       | 2020-12-06T14:56:52Z                 |
| updated_time        | None                                 |
| stack_status        | CREATE_IN_PROGRESS                   |
| stack_status_reason | Stack CREATE started                 |
+---------------------+--------------------------------------+

osbash@controller:~$ openstack stack event list stack_demo
2020-12-06 14:56:53Z [stack_demo]: CREATE_IN_PROGRESS  Stack CREATE started
2020-12-06 14:56:53Z [stack_demo.server]: CREATE_IN_PROGRESS  state changed
2020-12-06 14:57:06Z [stack_demo.server]: CREATE_COMPLETE  state changed
2020-12-06 14:57:06Z [stack_demo]: CREATE_COMPLETE  Stack CREATE completed successfully
osbash@controller:~$ openstack stack list
+--------------------------------------+------------+----------------------------------+-----------------+----------------------+--------------+
| ID                                   | Stack Name | Project                          | Stack Status    | Creation Time        | Updated Time |
+--------------------------------------+------------+----------------------------------+-----------------+----------------------+--------------+
| c796cb3e-5f68-4f40-b99f-aa79c71d5979 | stack_demo | bc78fc6cc32f4e779eb750d212253523 | CREATE_COMPLETE | 2020-12-06T14:56:52Z | None         |
+--------------------------------------+------------+----------------------------------+-----------------+----------------------+--------------+
osbash@controller:~$ openstack stack output show --all stack_demo
+---------------+----------------------------------------------------+
| Field         | Value                                              |
+---------------+----------------------------------------------------+
| instance_name | {                                                  |
|               |   "output_key": "instance_name",                   |
|               |   "description": "Name of the instance.",          |
|               |   "output_value": "stack_demo-server-vks7xyv22hnb" |
|               | }                                                  |
| instance_ip   | {                                                  |
|               |   "output_key": "instance_ip",                     |
|               |   "description": "IP address of the instance.",    |
|               |   "output_value": "203.0.113.175"                  |
|               | }                                                  |
+---------------+----------------------------------------------------+

osbash@controller:~$ openstack server list
+--------------------------------------+--------------------------------+---------+------------------------+--------+----------------+
| ID                                   | Name                           | Status  | Networks               | Image  | Flavor         |
+--------------------------------------+--------------------------------+---------+------------------------+--------+----------------+
| 22c12711-0d3b-4ffc-8996-5af527a189eb | stack_demo-server-vks7xyv22hnb | ACTIVE  | provider=203.0.113.175 | cirros | cirrors        |
| 6900a70b-c777-4c4f-8d75-7b8408199f46 | cirrors                        | SHUTOFF | provider=203.0.113.193 |        | flavor_cli_new |
+--------------------------------------+--------------------------------+---------+------------------------+--------+----------------+
```

### 5.3、custom.yaml

```
osbash@controller:~$ cat custom.yaml
heat_template_version: 2015-10-15

description: custom HOT template that just defines a single server,contains just base features to verify base HOT support.

parameters:
 image:
  type: string
  description: Image to use for the instance.
  constraints:
  - custom_constraint: glance.image

 flavor:
  type: string
  description: Flavor to use for the instance.
  constraints:
  - custom_constraint: nova.flavor

 network:
  type: string
  description: Network to use for the instance.

resources:
 server:
  type: OS::Nova::Server
  properties:
   image: {get_param: image}
   flavor: {get_param: flavor}
   networks:
   - network: {get_param: network}

outputs:
 instance_name:
  description: Name of the instance.
  value: {get_attr: [server,name]}
 instance_ip:
  description: IP address of the instance.
  value: {get_attr: [server,first_address]}

osbash@controller:~$ openstack stack create -t custom.yaml --parameter image=cirros --parameter flavor=cirrors --parameter network=provider stack_custom
+---------------------+---------------------------------------------------------------------------------------------------------------+
| Field               | Value                                                                                                         |
+---------------------+---------------------------------------------------------------------------------------------------------------+
| id                  | bdb977e6-4b3b-4020-98e9-77ac0885dcdc                                                                          |
| stack_name          | stack_custom                                                                                                  |
| description         | custom HOT template that just defines a single server,contains just base features to verify base HOT support. |
| creation_time       | 2020-12-06T15:07:43Z                                                                                          |
| updated_time        | None                                                                                                          |
| stack_status        | CREATE_IN_PROGRESS                                                                                            |
| stack_status_reason | Stack CREATE started                                                                                          |
+---------------------+---------------------------------------------------------------------------------------------------------------+

osbash@controller:~$ openstack stack list
+--------------------------------------+--------------+----------------------------------+-----------------+----------------------+--------------+
| ID                                   | Stack Name   | Project                          | Stack Status    | Creation Time        | Updated Time |
+--------------------------------------+--------------+----------------------------------+-----------------+----------------------+--------------+
| bdb977e6-4b3b-4020-98e9-77ac0885dcdc | stack_custom | bc78fc6cc32f4e779eb750d212253523 | CREATE_COMPLETE | 2020-12-06T15:07:43Z | None         |
| c796cb3e-5f68-4f40-b99f-aa79c71d5979 | stack_demo   | bc78fc6cc32f4e779eb750d212253523 | CREATE_COMPLETE | 2020-12-06T14:56:52Z | None         |
+--------------------------------------+--------------+----------------------------------+-----------------+----------------------+--------------+

osbash@controller:~$ openstack server list
+--------------------------------------+----------------------------------+---------+------------------------+--------+----------------+
| ID                                   | Name                             | Status  | Networks               | Image  | Flavor         |
+--------------------------------------+----------------------------------+---------+------------------------+--------+----------------+
| a68bc423-43d5-4a0d-a3ca-2fa729d36a6c | stack_custom-server-gmjbc35wvlos | ACTIVE  | provider=203.0.113.130 | cirros | cirrors        |
| 22c12711-0d3b-4ffc-8996-5af527a189eb | stack_demo-server-vks7xyv22hnb   | ACTIVE  | provider=203.0.113.175 | cirros | cirrors        |
| 6900a70b-c777-4c4f-8d75-7b8408199f46 | cirrors                          | SHUTOFF | provider=203.0.113.193 |        | flavor_cli_new |
+--------------------------------------+----------------------------------+---------+------------------------+--------+----------------+
```

### 5.4、main.yaml

```
osbash@controller:~$ cat sub.yaml 
heat_template_version: 2015-10-15

parameters:
 network:
  type: string
  description: Network ID to use for the instance

resources:
 server:
  type: OS::Nova::Server
  properties:
   image: cirros
   flavor: cirrors
   networks:
   - network: {get_param: network}

osbash@controller:~$ cat main.yaml
heat_template_version: 2015-10-15

resources:
 server:
  type: sub.yaml
  properties:
   network: provider

osbash@controller:~$ openstack stack create -t main.yaml stack_nest
+---------------------+--------------------------------------+
| Field               | Value                                |
+---------------------+--------------------------------------+
| id                  | 472bb192-1ccf-43d4-94f3-6b1280412bf6 |
| stack_name          | stack_nest                           |
| description         | No description                       |
| creation_time       | 2020-12-06T15:16:12Z                 |
| updated_time        | None                                 |
| stack_status        | CREATE_IN_PROGRESS                   |
| stack_status_reason | Stack CREATE started                 |
+---------------------+--------------------------------------+
osbash@controller:~$ openstack stack list
+--------------------------------------+------------+----------------------------------+-----------------+----------------------+--------------+
| ID                                   | Stack Name | Project                          | Stack Status    | Creation Time        | Updated Time |
+--------------------------------------+------------+----------------------------------+-----------------+----------------------+--------------+
| 472bb192-1ccf-43d4-94f3-6b1280412bf6 | stack_nest | bc78fc6cc32f4e779eb750d212253523 | CREATE_COMPLETE | 2020-12-06T15:16:12Z | None         |
+--------------------------------------+------------+----------------------------------+-----------------+----------------------+--------------+
osbash@controller:~$ openstack server list
+--------------------------------------+----------------------------------------------------+---------+------------------------+--------+----------------+
| ID                                   | Name                                               | Status  | Networks               | Image  | Flavor         |
+--------------------------------------+----------------------------------------------------+---------+------------------------+--------+----------------+
| e8967d6c-b761-4f92-8322-552904deeea9 | stack_nest-server-edey6nlaunva-server-yi3ohws5cwg6 | ACTIVE  | provider=203.0.113.103 | cirros | cirrors        |
| 6900a70b-c777-4c4f-8d75-7b8408199f46 | cirrors                                            | SHUTOFF | provider=203.0.113.193 |        | flavor_cli_new |
+--------------------------------------+----------------------------------------------------+---------+------------------------+--------+----------------+
```

### 5.5、删除stack

```
osbash@controller:~$ openstack stack delete stack_demo
Are you sure you want to delete this stack(s) [y/N]? y
osbash@controller:~$ openstack stack delete --yes stack_custom
```

## 6、思考题

Heat能解决什么问题？

Heat中有哪些常用概念？

Heat能应用到哪些场景？

## 7、测一测

### 7.2、判断

Heat目前支持HOT模板格式，但不支持亚马逊的CloudFormation模板格式。

- true
- `false 正确`

resources用于模板中资源的声明，在HOT模板中，应该至少有一个资源的定义，否则在实例化模板时将不会做任何事情。

- `true 正确`
- false

Heat目前只支持对计算、存储、网络等基础资源进行编排，虚拟机内安装软件等复杂配置不支持编排。

- true
- `false 正确`

### 7.3、多选

一个Satck可以拥有以下哪些资源？

- `CPU`
- `Memory`
- `Disk`
- `Network`

Heat提供了不同的资源类型，针对不同类型也提供了一些参数，我们可以通过以下哪些方式获取参数？

- `在模板中直接指定`

- `在创建Satck时提供`

- `根据上下文其他参数获取`

- 在安装Heat时指定