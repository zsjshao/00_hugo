+++
author = "zsjshao"
title = "03-OpenStack认证管理"
date = "2020-12-05"
tags = ["openstack"]
categories = ["HCIP_Cloud OpenStack"]

+++

## 本章导读

本章我们将学习另一个OpenStack中的关键组件Keystone，Keystone为OpenStack提供共用的认证与鉴权机制，第一章我们介绍过OpenStack中各个组件间的交互关系，其中我们可以看出，用户想要访问各个服务组件或者各个组件内部之间互相通信时都需要依赖Keystone组件进行鉴权。可以说Keystone在整个OpenStack中占有举足轻重的地位。

本章我们依然分理论和实验两部分进行讲解。理论部分我们主要讲解Keystone作用、架构、原理和流程。实验部分主要锻炼大家对Keystone的日常运维操作，帮助大家理论联系实际，真正地掌握和理解Keystone的作用。

本章内容主要包括：

1. OpenStack认证服务Keystone简介

2. Keystone架构

3. Keystone对象模型

4. Keystone认证工作原理和流程

5. OpenStack动手实验：Keystone操作

## 1、OpenStack认证服务Keystone简介

### 1.1、OpenStack认证服务是什么？

Keystone认证服务首次出现在OpenStack的“Essex”版本中。

Keystone提供身份验证，服务发现和分布式多租户授权。

Keystone支持LDAP，OAuth，OpenID Connect，SAML和SQL。

依赖的OpenStack服务

- Keystone为其他项目提供认证
- 外部请求调用OpenStack内部的服务时，需要先从keystone获取到相应的Token。
- 类似的，OpenStack内部不同项目间的调用也需要先从Keystone获取到认证后才能进行。

### 1.2、Keystone在OpenStack中的位置

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/1.png)

Keystone提供身份验证，服务发现和分布式多租户授权，属于共用服务。

### 1.3、Keystone在OpenStack中的作用

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/2.png)

## 2、Keystone架构

### 2.1、Keystone架构图

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/3.png)

### 2.2、Keystone各组件作用

Keystone API：接收外部请求

Keystone Middleware：缓存Token等，减轻Keystone Services压力

Keystone Services：不同的Service提供不同的认证或鉴权服务

Keystone Backends：实现Keystone服务，不同的Service由不同的Backend提供

Keystone Plugins：提供密码、Token等认证方式

## 3、Keystone对象模型

### 3.1、Keystone对象模型

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/4.png)

Keystone的管理主要是针对Identity，Resource，Assignment，Token，Catalog，Service，这些对象具体由其他更小的对象实现。

同时OpenStack各种资源和服务的访问策略由Policy定义。

### 3.2、Keystone对象模型 - Service

Keystone是在一个或多个端点（Endpoint）上公开的一组内部访问（Service）。

Keystone内部访问包括Identity、Resource、Assignment、Token、Catalog等。

Keystone许多内部服务以组合方式使用。

- 例如，身份验证时将使用认证服务（Identity）验证用户或项目凭据，并在成功时创建并返回带有令牌服务（Token）的令牌。

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/5.png)

除内部服务外，Keystone还负责与OpenStack其他服务（Service）进行交互，例如计算、存储或镜像，提供一个或多个端点，用户可以通过这些端点访问资源并执行操作。

Keystone的Service包括内部服务和外部服务。

### 3.3、Keystone对象模型 - Identity

Identity服务提供身份凭据验证以及用户（User）和用户组（Group）的数据。

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/6.png)

User是单个OpenStack服务使用者，用户本身必须属于某个特定域。所以用户名不是OpenStack全局唯一的，仅在其所属域唯一。

Groups把多个用户作为一个整体进行管理。组本身必须属于某个特定域。所以组名不是OpenStack全局唯一的，仅在其所属域唯一。

通常情况下，用户和用户组数据由Identity服务管理，允许它处理与这些数据关联的所有CRUD操作。

复杂情况下，用户和用户组数据由权威后端服务管理。

- 例如，Identity充当LDAP的前端，LDAP服务器是权威的信息来源，Identity准确地中继LDAP信息。

### 3.4、Keystone对象模型 - Resource

Resource服务提供有关项目（Project）和域（Domain）的数据。

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/7.png)

Project是OpenStack资源拥有者的基本单元，OpenStack中所有资源都属于特定项目。

Domain把`项目、用户和组`作为一个整体管理，每种资源都属于某个特定域。Keystone默认域名为“Default”。

项目本身必须属于某个特定域。所以项目名不是OpenStack全局唯一的，仅在其所属域唯一。

创建项目时如果如果未指定域，则将其添加到默认域。

### 3.5、Keystone对象模型 - Assignment

Assignment服务提供有关角色（Role）和角色分配（Role Assignment）的数据。

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/8.png)

Role规定最终用户可以获得的授权级别。角色可以在域或项目级别授予。可以在单个用户或组级别分配角色。角色名称在拥有该角色的域中是唯一的。

Role Assignment是一个3元组，有一个Role，一个Resource和一个Identity。

### 3.6、Keystone对象模型 - Token

Token服务提供用户访问访问的凭证，代表着用户的账户信息。

Token一般包含User信息、Scope信息（Project、Domain或者Trust）、Role信息。

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/9.png)

Token如果未包括Scope，即UnscopedToken，这种Token中既不包含服务目录，也不包含任何角色，项目范围和域范围。它的主要作用是稍后向Keystone证明身份（通常是生成范围标记），而不用重复提交原始凭据。

必须满足以下条件才能接收Unscoped Token：

- 身份验证请求中未指定授权范围（例如，在命令行中使用--os-project-name或等参数--os-domain-id）。
- 身份没有与之关联的“默认项目”，还未分配角色，因此也需要授权。

### 3.7、Keystone对象模型 - Catalog

Catalog服务提供用于查询端点（Endpoint）的端点注册表，以便外部访问OpenStack服务。

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/10.png)

Endpoint本质上是一个URL，提供服务的入口，有如下几种：

- Public：最终用户或其他服务用户使用，通常在公共网络接口上使用。

- Internal：供最终用户使用，通常在未计量的内部网络接口上。

- Admin：供管理服务的用户使用，通常是在安全的网络接口上。

### 3.8、Keystone对象模型 - Policy

每个OpenStack服务都在相关的策略文件中定义其资源的访问策略（Policy）。

访问策略类似于Linux的权限管理，不同角色的用户或用户组将会拥有不同的操作权限。

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/11.png)

访问策略规则以JSON格式指定，文件名为policy.json.

- 策略文件的路径是/etc/SERVICE_NAME/policy.json，例如/etc/keystone/policy.json。

JSON（JavaScript Object Notation）是一种轻量级的数据交换格式，结构简明，易于人阅读和编写，也易于机器解析和生成。

### 3.9、Keystone对象模型分配关系示例

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/12.png)

Region> Domain > Project > Group > User

用户提交用户名、密码后，Keystone验证后生成Token，操作OpenStack服务的请求必须携带Token，通过端点URL访问服务。



Region，Service，Endpoint

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/13.png)

Catalog中包含不同Region中的不同Service，每个Service一般有不同类型的Endpoint。



User：

- 获取Token

- 获取Service Catalog



Admin User：

- 管理Users，Projects，Roles

- 管理特定Project中Users的Roles

- 管理Services，Services的Endpoints



Service：

- 验证Token

- 定位其他Service的位置

- 调用其他Service



## 4、Keystone认证工作原理和流程

### 4.1、Keystone认证方式概览

Keystone最重要的工作是认证，Keystone支持多种认证方式。

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/14.png)

UUID：Universal Unique Identifier

PKI：Public Key Infrastructure

### 4.2、Keystone三种认证方式对比

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/15.png)

生成环境中常用的是`基于令牌`的认证方式，需要重点学习。

### 4.3、Keystone基于令牌的认证 - UUID

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/16.png)

UUID令牌是长度固定为32 Byte 的随机字符串，但是UUID令牌不携带其它信息，OpenStack API收到该令牌后，需要找Keystone校验令牌，并获取用户相关的信息。

UUID不携带其他信息，因此Keystone必须实现令牌的存储和认证，集群规模扩大时，Keystone将成为性能瓶颈。

### 4.4、Keystone基于令牌的认证 - PKI

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/17.png)

PKI 的本质就是基于数字签名，Keystone 私钥对令牌进行数字签名，各个OpenStack服务的API server用公钥在本地验证该令牌。

和UUID 相比，PKI令牌携带更多用户信息的同时还附上了数字签名，以支持本地认证，从而避免多次找Keystone认证。但因为携带更多信息，当OpenStack规模较大时，PKI令牌大小容易超出HTTP Header大小，导致请求失败。

### 4.5、Keystone基于令牌的认证 - PKIZ

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/18.png)

PKIZ 在PKI 的基础上做了压缩处理，但是压缩的效果极其有限。

一般情况下，压缩后的大小为PKI token 的90%左右，所以PKIZ 不能友好的解决token size 太大问题。

### 4.6、Keystone基于令牌的认证 - Fernet

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/19.png)

UUID，PKI，PKIZ令牌都会持久存放在数据库中，累积的令牌容易导致数据库性能下降，用户需定期清理数据库中的令牌。

为避免该问题，OpenStack目前版本都默认使用Fernet令牌，携带少量的用户信息，采用对称加密，无需存于数据库中，但需定期更换秘钥。

### 4.7、如何选择Keystone基于令牌的认证方式？

| Token类型    | UUID    | PKI            | PKIZ           | Fernet          |
| ------------ | ------- | -------------- | -------------- | --------------- |
| 大小         | 32 Byte | KB级别         | KB级别         | 约255 Byte      |
| 支持本地认证 | 不支持  | 支持           | 支持           | 不支持          |
| Keystone负载 | 大      | 小             | 小             | 大              |
| 存储于数据库 | 是      | 是             | 是             | 否              |
| 携带信息     | 无      | user,Catalog等 | user,catalog等 | user等          |
| 涉及加密方式 | 无      | 非对称加密     | 非对称加密     | 对称加密（AES） |
| 是否压缩     | 否      | 否             | 是             | 否              |

目前OpenStack新发布版本默认采用`Fernet令牌`。

令牌类型的选择涉及多个因素，包括Keystone server的负载、region数量、安全因素、维护成本以及令牌本身的成熟度。

- Region的数量影响PKI/PKIZ令牌的大小
- 从安全的角度上看，UUID无需维护密钥，PKI需要妥善保管Keystone server上的私钥，Fernet需要周期性的更换密钥。
- 因此从安全、维护成本和成熟度上看，UUID > PKI/PKIZ > Fernet

如果：

- Keystone server 负载低，region少于3个，采用UUID令牌。
- Keystone server 负载高，region少于3个，采用PKI/PKIZ令牌。
- Keystone server 负载低，region大于或等于3个，采用UUID令牌。
- Keystone server 负载高，region大于或等于3个，目前OpenStack新版本默认采用Fernet令牌。

### 4.8、OpenStack认证流程 - 以创建VM为例

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/20.png)

不同服务间的调用需要携带Token，Keystone负责验证Token有效性。

Keystone只校验Token是否有效，那每个服务的操作权限控制是怎么实现的？

- 例如用户是否有创建VM权限，是否有更改VM规格权限？

### 4.9、RBAC：基于角色的访问控制 - 流程

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/21.png)

Policy.json文件是实现RBAC（基于角色的访问控制）的关键机制。

### 4.10、RBAC：基于角色的访问控制 - 原理

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/22.png)

示例的policy.json说明：

- 定义了all_admins包含哪些角色。
- 定义了list project针对all_admins的具体规则，create project时需要admin角色。

### 4.11、提问：Keystone如何实现认证和权限控制？

1、用户在OpenStack操作界面/CLI 上创建一个VM，Keystone如何认证该用户，如何验证该用户具有创建VM的权限？

2、两种方式对Keystone有区别吗？

无论是操作界面或是CLI，Keystone的认证和权限控制原理都是一样的，发放Token，验证Token，通过Policy.json实现权限控制。

### 4.12、总结：Keystone如何实现认证和权限控制？

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/23.png)

流程图简单演示用户创建虚拟机的过程中，Keystone是如何发放Token，验证Token及权限控制过程。

## 5、OpenStack动手实验：Keystone操作

### 5.1、web界面方式

#### 5.1.1、创建role

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/24.png)

#### 5.1.2、创建用户

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/25.png)

#### 5.1.3、创建组

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/26.png)

#### 5.1.4、添加用户到组

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/27.png)

#### 5.1.5、创建项目

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/28.png)

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/29.png)

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/30.png)

#### 5.1.6、项目配额

![keystone](http://images.zsjshao.net/huawei/HCIP-Cloud-OpenStack/03/31.png)

### 5.2、CLI方式

#### 5.2.1、help

```
osbash@controller:~$ openstack role --help
Command "role" matches:
  role add
  role assignment list
  role create
  role delete
  role list
  role remove
  role set
  role show
osbash@controller:~$ 
```

#### 5.2.2、创建role

```
osbash@controller:~$ openstack role create role_cli
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | None                             |
| domain_id   | None                             |
| id          | 7251e05f683e4b45bfbc2cdc0376247b |
| name        | role_cli                         |
| options     | {}                               |
+-------------+----------------------------------+
```

#### 5.2.3、创建用户

```
osbash@controller:~$ openstack user create --domain default --project admin --password-prompt user_cli_01
User Password:
Repeat User Password:
+---------------------+----------------------------------+
| Field               | Value                            |
+---------------------+----------------------------------+
| default_project_id  | bc78fc6cc32f4e779eb750d212253523 |
| domain_id           | default                          |
| enabled             | True                             |
| id                  | 1ebce1369dbd4fe482e5d6712d4675cf |
| name                | user_cli_01                      |
| options             | {}                               |
| password_expires_at | None                             |
+---------------------+----------------------------------+
```

#### 5.2.4、为用户添加角色

```
osbash@controller:~$ openstack role add --project admin --user user_cli_01 role_cli
osbash@controller:~$ openstack role assignment list --name | grep user_cli_01
| role_cli         | user_cli_01@Default    |       | admin@Default       |        |        | False     |
```

#### 5.2.5、创建组

```
osbash@controller:~$ openstack group create --domain default group_cli
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description |                                  |
| domain_id   | default                          |
| id          | 815a68672e504ea9b6b69796fdefe192 |
| name        | group_cli                        |
+-------------+----------------------------------+
```

#### 5.2.6、添加用户到组

```
osbash@controller:~$ openstack group add user group_cli user_cli_01
osbash@controller:~$ openstack group contains user group_cli user_cli_01
user_cli_01 in group group_cli
```

#### 5.2.7、创建项目

```
osbash@controller:~$ openstack project create --domain default project_cli
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description |                                  |
| domain_id   | default                          |
| enabled     | True                             |
| id          | 1e90a4a378254974a6dd1700048f702e |
| is_domain   | False                            |
| name        | project_cli                      |
| options     | {}                               |
| parent_id   | default                          |
| tags        | []                               |
+-------------+----------------------------------+
```

#### 5.2.8、添加用户到项目

```
osbash@controller:~$ openstack role add --project project_cli --user user_cli_01 admin
osbash@controller:~$ openstack role assignment list --name | grep user_cli_01
| admin            | user_cli_01@Default    |       | project_cli@Default |        |        | False     |
| role_cli         | user_cli_01@Default    |       | admin@Default       |        |        | False     |
```

#### 5.2.9、项目配额

```
osbash@controller:~$ openstack quota --help
Command "quota" matches:
  quota list
  quota set
  quota show
```

#### 5.2.10、创建Service

```
osbash@controller:~$ openstack service create --name swift --description "Openstack Object Storage" object-store
+-------------+----------------------------------+
| Field       | Value                            |
+-------------+----------------------------------+
| description | Openstack Object Storage         |
| enabled     | True                             |
| id          | 29fe14abc59d4ba7b80553ae12551833 |
| name        | swift                            |
| type        | object-store                     |
+-------------+----------------------------------+
```

#### 5.2.11、创建endpoint

```
osbash@controller:~$ openstack endpoint create --region RegionOne swift admin http://controller:8080/v1
+--------------+----------------------------------+
| Field        | Value                            |
+--------------+----------------------------------+
| enabled      | True                             |
| id           | 1e61e61b7aea4592ae1b02783960105c |
| interface    | admin                            |
| region       | RegionOne                        |
| region_id    | RegionOne                        |
| service_id   | 29fe14abc59d4ba7b80553ae12551833 |
| service_name | swift                            |
| service_type | object-store                     |
| url          | http://controller:8080/v1        |
+--------------+----------------------------------+
osbash@controller:~$ openstack endpoint create --region RegionOne swift public http://controller:8080/v1/AUTH_%\(project_id\)s
+--------------+-----------------------------------------------+
| Field        | Value                                         |
+--------------+-----------------------------------------------+
| enabled      | True                                          |
| id           | eab088ebaaeb4a88ab7546075b694bcd              |
| interface    | public                                        |
| region       | RegionOne                                     |
| region_id    | RegionOne                                     |
| service_id   | 29fe14abc59d4ba7b80553ae12551833              |
| service_name | swift                                         |
| service_type | object-store                                  |
| url          | http://controller:8080/v1/AUTH_%(project_id)s |
+--------------+-----------------------------------------------+
osbash@controller:~$ openstack endpoint create --region RegionOne swift internal http://controller:8080/v1/AUTH_%\(project_id\)s
+--------------+-----------------------------------------------+
| Field        | Value                                         |
+--------------+-----------------------------------------------+
| enabled      | True                                          |
| id           | 62bf70ba38b54c558ea67626e18a06b8              |
| interface    | internal                                      |
| region       | RegionOne                                     |
| region_id    | RegionOne                                     |
| service_id   | 29fe14abc59d4ba7b80553ae12551833              |
| service_name | swift                                         |
| service_type | object-store                                  |
| url          | http://controller:8080/v1/AUTH_%(project_id)s |
+--------------+-----------------------------------------------+
```

## 6、思考题

1、Keystone对象模型有哪些？

Identity、Resource、Assignment、Token、Catalog、Policy

2、请举例说明Keystone认证流程。

## 7、测一测

### 7.1、多选

OpenStack中Keystone最重要的工作是认证，其认证方式包括（ ）？

- `基于本地的认证`

- `基于外部的认证`

- `基于令牌的认证`

- 基于策略的认证

以下关于Keystone中各组件的描述正确的是？

- `Keystone API，接收外部请求`

- `Keystone Services提供不同的认证或鉴权服务`

- `Keystone Middleware缓存Token等，减轻Keystone Services压力`

- `Keystone Plugins提供密码、Token等认证方式`

以下哪些是Keystone在OpenStack中的作用？

- `身份认证`

- `端点注册`

- `服务管理`

- `令牌管理`

以下关于Keystone对象模型的描述正确的是？

- `Identity服务提供身份凭据验证以及用户（User）和用户组（Group）的数据`

- `Resource服务提供有关项目（Project）和域（Domain）的数据`

- `Assignment服务提供有关角色（Role）和角色分配（ Role Assignment）的数据`

- `Token服务提供用户访问服务的凭证，代表着用户的账户信息`

### 7.2、单选

以下哪个不是Keystone中基于令牌的认证方式？

- UUID

- Fernet

- `Https 正确`

- PKIZ

