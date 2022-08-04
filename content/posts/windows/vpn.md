## VPN

vpn是远程访问的一种技术，可以帮助用户实现跨越Internet的资源访问。

用户拨通VPN之后，在客户端和服务器间建立一个隧道，所有和内网交互的数据通过隧道进行传输。

**技术特点**

- 用户访问内网时候使用非固定端口

- 用户远程访问的时候对安全要求比较高

**应用场景**

- 用户在Internet上访问公司文件服务器

- 用户在Internet上登录域

**加密情况**

- 所有vpn协议都是安全加密的



**VPN服务两种应用场景**

- Client-to-Site VPN

- Site-to-Site VPN



### PPTP (Point-to-Point Tunneling Protocol)

比较基础和简单的VPN协议，支持TCP/IP网络

使用1723端口

加密是使用ppp内置MPPE加密协议（128位加密）

适用于Client-to-Site和Site-to-Site的类型





### L2TP（Layer Two Tunneling Protocal）

是PPTP升级的一个协议，除了支持TCP/IP网络，还支持Frame-Relay，X.25等网络

使用1701端口

使用IPSEC协议进行加密和身份验证，更加安全。

适用于Site-to-Site的类型



### SSTP（Secure Socket Tunneling Protocal）

是Windows Server 2008/2008R2中新支持的功能

使用443端口

加密使用SSL协议

适用于Client-to-Site的类型









