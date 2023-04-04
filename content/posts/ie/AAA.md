Authentication（认证）

- username/password
- 证书
- 指纹/虹膜（生物信息）



Authorization（授权）



Accounting（审计）







RADIUS

- Authentication/Authorization：1645 and 1812
- Accounting：1646 and 1813
- UDP
- Encrypts only passwords up to 16 bytes
- AAA combined as one service





示例：

AAA本地认证

```
enable
config terminal
username admin password admin

aaa new-model
aaa authentication login default local
line vty 0 4
login authentication default
exit
line console 0
login authentication default
end
write
```

AAA RADIUS认证

```
enable
config terminal
username admin password admin

aaa new-model
aaa authentication login FOR_VTY group radius local none
radius-server host 192.168.100.1 key ruijie

line vty 0 4
login authentication FOR_VTY
exit
line console 0
login authentication FOR_VTY
end
write
```

AAA console免认证

```
enable
config terminal

aaa new-model
aaa authentication login FOR_CON none

line console 0
login authentication FOR_CON
end
write
```
