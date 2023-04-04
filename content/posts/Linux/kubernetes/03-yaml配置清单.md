+++
author = "zsjshao"
title = "03_yaml"
date = "2020-05-01"
tags = ["kubernetes"]
categories = ["kubernetes"]

+++


# yaml配置清单：

基本语法：

- 缩进时不允许使用Tab键，只允许使用空格
- 缩进的空格数目可以不同，但相同层级的元素缩进一致即可
- #表示注释

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
  imagePullSecrets:
    name: myregistrykey
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

command: ["/bin/sh","-c","sleep 3600"]
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

#### 变量

env <[]Object>

```
env:
- name: 
  value:
  valueFrom:
```





### Pod的生命周期

状态：Pending，Running，Failed，Succeeded，Unknown

Pod生命周期中的重要行为：

- 初始化容器：
- 容器探测：
  - liveness
  - readiness

restartPolicy：

- Always，OnFailure，Never.  Default to Always.

探针类型有三种：

- ExecAction、TCPSocketAction、HTTPGetAction

#### 存活性探测：

```
restartPolicy: Always
livenessProbe：
  exec:
    command: ["test","-e","/tmp/testfile"]
  httpGet:
    host: 
    httpHeaders:
    path: /index.html
    port:
    scheme:
  tcpSocket:
    host: 
    port: 
  failureThreshold: 1
  initialDelaySeconds: 1
  periodSeconds: 3
  successThreshold: 1
  timeoutSeconds: 1
```

#### 就绪性探测

```
readinessProbe:
  httpGet:
    host: 
    httpHeaders:
    path: /index.html
    port:
    scheme:
```

#### lifecycle

lifecycle \<Object>

```
lifecycle:
  postStart:
    exec:
      command: []
    httpGet:
    tcpSocket:
  preStop:
    exec:
    httpGet:
    tcpSocket:
```



## Pod控制器：

ReplicationController：

ReplicaSet：

Deployment：

DaemonSet:

Job:

Cronjob:

StatefulSet:



TPR：Third Party Resources，1.2+，1.7

CDR：Custom Definded Resources，1.8+



Operator：



Helm：



### ReplicaSet

```
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: myapp
  namespace: default
spec:
  minReadySeconds: 
  replicas: 2
  selector:
    matchLabels:
      app: myapp
      release: canary
  template: 
    metadata:
      name: myapp-pod
      labels:
        app: myapp
        release: canary
    spec:
      containers:
      - name: myapp-container
        image: 
        ports:
        - name: http
          containerPort: 80
```

### Deployment

```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp-deploy
  namespace: default
spec:
  replicas: 2
  revisionHistoryLimit: 10
  strategy:
    type: RollingUpdate
    rollingUpdate: 
      maxSurge: 10%
      maxUnavailable: 0 
  paused: 
  selector:
    matchLabels:
      app: myapp
      release: canary
  template:
    metadata:
      labels:
        app: myapp
        release: canary
    spec:
      containers:
      - name: myapp
        image:
        ports:
        - name: http
          containerPort: 80
```

kubectl rollout help

```
kubectl rollout status deployment myapp-deploy
kubectl rollout pause deployment myapp-deploy
kubectl rollout resume deployment myapp-deploy
kubectl rollout history deployment myapp-deploy
kubectl rollout undo deployment myapp-deploy --to-revision=1
```

patch

```
kubectl patch help
kubectl patch deployment myapp-deploy -p '{"spec":{"replicas":5}}'
kubectl patch deployment myapp-deploy -p '{"spec":{"strategy":{"rollingUpdate":{"maxSurge":1,"maxUnavailable":0}}}}'
```

set image

```
kubectl set image deployment myapp-deploy myapp=ikubernetes/myapp:v3 && kubectl rollout pause deployment myapp-deploy
```

### DaemonSet

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: myapp-ds
  namespace: default
spec:
  minReadySeconds:
  revisionHistoryLimit: 10
  updateStrategy: 
    rollingUpdate:
      maxUnavailable: 10%
    type: RollingUpdate | OnDelete
  selector:
    matchLabels:
      app: filebeat
      release: stable
  template:
    metadata:
      labels:
        app: filebeat
        release: stable
    spec:
      containers:
      - name: filebeat
        image:
        env:
        - name: REDIS_HOST
          value: redis.default.svc.cluster.local
        - name: REDIS_LOG_LEVEL
          value: info
```

### StatefulSet

```

```





## Service

```
apiVersion: v1
kind: Service
metadata:
  name: myapp
  namespace: default
spec:
  selector:
    app: myapp
    release: canary
  clusterIP: IPADDR | None |
  sessionAffinity: None | ClientIP
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    nodePort: 30080
    protocol: TCP
```

工作模式： userspace，iptables，ipvs

- userspace： 1.1-
- iptables：1.10-
- ipvs：1.11+

类型(type)：

- ExternalName，ClusterIP，NodePort，and LoadBalancer

资源记录：

- SVC_NAME.NS_NAME.DOMAIN.LTD.
- svc.cluster.local.
- redis.default.svc.cluster.local.



## ingress

http

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-tomcat
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: tomcat.magedu.com
    http:
      paths:
      - path:
        backend:
          serviceName: tomcat
          servicePort: 8080
```

https

```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-tomcat-tls
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  tls:
  - hosts:
    - tomcat.magedu.com
    secreName: tomcat-ingress-secret
  rules:
  - host: tomcat.magedu.com
    http:
      paths:
      - path:
        backend:
          serviceName: tomcat
          servicePort: 8080
```

## volume

emptyDir

```
spec:
  containers:
    volumeMounts:
    - name: html
      mountPath: /data/web/html/
      readOnly: false

volumes:
- name: html
  emptyDir: {}
```

hostPath

```
volumes:
- name: html
  hostPath:
    path: /data/pod/volume1
    type: DirectoryOrCreate
```

NFS

```
volumes:
- name: html
  nfs: /data/volumes/pod1
  server: store01.zsjshao.net
  readOnly: false
```

## PersistentVolume

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv003
  labels: 
    name: pv003
spec:
  nfs:
    path: /data/volumes/v3
    server: stor01.zsjshao.net
  accessModes: ["ReadWriteMany","ReadWriteOnce","ReadOnlyMany"]
  capacity:
    storage: 2Gi
```

## PersistentVolumeClaim

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
  namespace: default
spec:
  accessModes: ["ReadWriteMany"]
  resources:
    requests:
      storage: 2Gi
---

spec:
  containers:
    volumeMounts:
    - name: html
      mountPath: /data/web/html/
      readOnly: false
  volumes:
  - name: html
    persistentVolumeClaim:
      claimName: mypvc
```

## ConfigMap

from-literal

```
kubectl create configmap nginx-port --from-literal=port=80
```



```
apiVersion: v1
data:
  port: "80"
kind: ConfigMap
metadata:
  name: nginx-port
  namespace: default

---
spec:
  containers:
    env:
    - name: NGINX_SERVER_PORT
      valueFrom:
        configMapKeyRef:
          name: nginx-port
          key: port          
          optional: true

---
spec:
  containers:
    volumeMounts:
    - name: nginxport
      mountPath: /etc/nginx/nginxport/
      readOnly: false
  volumes:
  - name: nginxport
    configMap
      name: nginx-port
```

from-file

```

```





## Secret

```
kubectl create secret generic mysql-root-password --from-literal=password=MyP@ss123
```



```
apiVersion: v1
data:
  password: TXlQQHNzMTIz
kind: Secret
metadata:
  name: mysql-root-password
  namespace: default
type: Opaque

---
spec:
  containers:
    env:
    - name: MYSQL_ROOT_PASSWORD
      valueFrom:
        SecretKeyRef:
          name: mysql-root-password
          key: password          
          optional: true
```

echo TXlQQHNzMTIz | base64 -d





















