## FTP

### FTP User isolate

FTP 用户隔离是 Internet 服务提供商 (ISP) 的一种解决方案，他们希望为客户提供用于上传内容的个人 FTP 目录。FTP 用户隔离通过将用户限制在他们自己的目录中来防止用户查看或覆盖其他用户的内容。用户无法在目录树中向上导航，因为他们的顶级目录显示为 FTP 服务的根目录。在他们的特定站点中，用户可以创建、修改或删除文件和文件夹。



不要隔离用户

- 启动用户在：FTP根目录

- 启动用户在：用户名目录

隔离用户

- 限制用户进入以下目录： 用户名目录（禁用全局虚拟目录）

- 限制用户进入以下目录： 用户名物理目录（启用全局虚拟目录）

  - 用户账户类型：匿名用户

    主目录语法： % FtpRoot %\LocalUser\Public

  - 用户帐户类型：本地 Windows 用户帐户（需要基本身份验证）

    主目录语法： % FtpRoot %\LocalUser\%用户名%

  - 用户帐户类型： Windows 域帐户（需要基本身份验证）

    主目录语法： % FtpRoot %\%UserDomain%\%用户名%

  - 用户帐户类型： IIS 管理器或 ASP.NET 自定义身份验证用户帐户

    主目录语法： % FtpRoot %\LocalUser\%用户名%

- 将用户限制到以下目录：在 Active Directory 中配置的 FTP 主目录

  - AD域中用户**FTPRoot**和*FTPDir*属性以提供用户主目录的完整路径。
    - Server Manage -> Tools -> ADSI Edit -> Connec to

























