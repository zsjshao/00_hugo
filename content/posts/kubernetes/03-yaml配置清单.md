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
  spec:
   containers:
   - name: centos
     image: registry.cn-shenzhen.aliyuncs.com/zsjshao/centos7.7-base
```



spec.containers <[]object>

```
- name <string>
  image <string>
  imagePullPolicy <string>
    Always, Never, IfNotPresent
```

修改镜像中的默认应用：

command，args

https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell



标签：

key=value

key：字母、数字、_、-、

value：可以为空，只能字母

  



kubectl label

kubectl get pods -l app





















