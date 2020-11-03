+++
author = "zsjshao"
title = "03_yaml"
date = "2020-05-01"
tags = ["kubernetes"]
categories = ["kubernetes"]

+++


# yaml配置清单：

## 资源的清单格式：

### 一级字段：

- apiVersion（group/version)，kind，metadata（name，namespace，labels，annotations，...），spec，status（只读）

## Pod

```
apiVersion: v1
kind: Pod
metadata:
 name: centos
 namespace: default
 labels:
   app: myapp
   tier: frontend
spec:
  containers:
  - name: centos
    image: registry.cn-shenzhen.aliyuncs.com/zsjshao/centos7.7-base
    imagePullPolicy: IfNotPresent
    ports:
    - name: http
      containerPort: 80
    - name: https
      containerPort: 443
  nodeSelector:
    disktype: ssd
```

### spec.containers <[]object>

#### 镜像

```
- name <string>
  image <string>
  imagePullPolicy <string>
    Always, Never, IfNotPresent
```

#### 端口

```
  ports:
  - name: http
    containerPort: 80
    hostIP:
    hostPort:
    protocol:
  - name: https
    containerPort: 443
```

#### 修改镜像中的默认应用：

command <[]string>

```
command：
- "/bin/sh"
- "-c"
- "sleep 3600"
```

args <[]string>

```
args:

```

\$\(VAR_NAME)：变量引用

\$\$\(VAR_NAME)：命令替换

https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell



#### 标签：

labels \<string>

  ```
labels:
  app: myapp
  tier: frontend
  ```



kubectl label help



key=value

- key：字母、数字、_、-、

- value：可以为空，只能字母或数字开头及结尾，中间可使用字母、数字、_、-、               

- 63个字符



```
kubectl get pods -l app,release
```



标签选择器：

- 等值关系：=，==，!=

- 集合关系：
  - KEY in (VALUE1, VALUE2, ...)
  - KEY notin (VALUE1, VALUE2, ...)
  - KEY
  - !KEY

```
kubectl get pods -l app=nginx,release=stable
kubectl get pods -l app!=nginx
kubectl get pods -l "release in (canary,beta,alpha)"
kubectl get pods -l "release notin (canary,beta,alpha)"
```



许多资源支持内嵌字段定义其使用的标签选择器：

- matchLabels：直接给定键值
- matchExpressions：基于给定的表达式来定义使用标签选择器，{key: "KEY", operator: "OPERATOR", values: [VAL1, VAL2, ...]}
  - 操作符：
    - In，NotIn：values字段的值必须为空列表；
    - Exists，NotExists：values字段的值必须为空列表；

#### 节点标签选择器

nodeSelector <map[string]string>

```
nodeSelector:
  disktype: ssd
```

设置节点标签

```
kubectl label nodes node01.zsjshao.net disktype=ssd
```

#### 指定节点

nodeName \<string>



#### 资源注解

annotations：

```
annotations:
  zsjshao.net/create-by: "cluster admin"
```

与label不同的地方在于，它不能用于挑选资源对象，仅用于为对象提供“元数据”。



### Pod的生命周期

状态：Pending，Running，Failed，Succeeded，Unknown















