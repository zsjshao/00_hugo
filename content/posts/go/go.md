+++
author = "zsjshao"
title = "go"
date = "2020-04-27"
tags = ["go"]
categories = ["go"]
weight = 10
+++

## Go 语言环境安装

<!-- more -->

Go 语言支持以下系统：

- Linux
- FreeBSD
- Mac OS X（也称为 Darwin）
- Window

安装包下载地址为：https://golang.org/dl/。需翻墙

### UNIX/Linux/Mac OS X, 和 FreeBSD 安装

以下介绍了在UNIX/Linux/Mac OS X, 和 FreeBSD系统下使用源码安装方法：

1、下载源码包：go1.14.2.linux-amd64.tar.gz。

2、将下载的源码包解压至 /usr/local目录。

```
[root@ali ~]# tar xf go1.14.2.linux-amd64.tar.gz -C /usr/local/
```

添加环境变量

```
export PATH=$PATH:/usr/local/go/bin
```

### Windows 系统下安装

Windows 下可以使用 .msi 后缀(在下载列表中可以找到该文件，如go1.14.2.windows-amd64.msi)的安装包来安装。

默认情况下.msi文件会安装在 c:\Go 目录下。安装后重启命令窗口。

### 安装测试

创建工作目录 F:\07-Go

文件名: hello.go，代码如下：

```
package main

import "fmt"

func main() {
   fmt.Println("Hello, World!")
}
```

使用 go 命令执行以上代码输出结果如下：

```
F:\07-Go>go run hello.go
hello, world
```



学习方法

需求、学、讲、用

说的非常好，我一句都没听懂



### dos指令

命令帮助：command/?

md(mkdir) DIR...：创建目录

rd(rmdir) [/s/q] DIR：删除目录或删除目录及文件

cd /d DIR：目录切换

dir：列出当前目录下的文件及目录

copy(cp)：拷贝文件

move(mv)：移动或重命名文件

del(rm)：删除文件

cls(clear)：清屏

exit：退出

ren(rename)：批量修过文件名

type(cat)：查看文本文件

tree：显示目录树



### Go变量

#### 变量声明

1、指定变量类型，声明后若不赋值，使用默认值

var i int

2、根据值自行判定变量类型（类型推导）

var num = 10.11

3、省略var，注意 := 左侧的变量不应该是已经声明过的，否则会导致编译错误

name := "zsjshao"

4、多变量声明

在编程中，有时我们需要一次性声明多个变量，Golang也提供这样的语法

var n1,n2,n3 int

var n1,name,n3 = 100,"zsjshao",888

n1,name,n3 := 100,"zsjshao",888

5、声明全局变量(函数外)

var n1 = 100

var n2 =  200

var name = "zsjshao"

或

var (

n1 = 100

n2 = 200

name = "zsjshao"

)

6、该区域的数据值可以在同一类型范围内不断变化

7、变量在同一个作用域内不能同名

8、变量=变量名+值+数据类型，变量的三要素

9、Goland的变量如果没有赋初值，编译器会使用默认值



#### 程序中 + 号的作用

当左右两边为数值时，做加法运算

当左右两边为字符串时，做字符串拼接，可换行，+号留在上一行



#### 变量的数据类型

##### 基本数据类型

```
数值型
  整数类型(int,int8,int16,int32(rune（unicode）),int64,uint,uint8(byte),uint16,uint32,uint64)
    在使用整形变量时，遵守保小不保大的原则，即尽量使用占用空间小的数据类型
  
  浮点类型（单精度:float32,双精度:float64）
    浮点数=符号位+指数位+尾数位
    尾数部分可能丢失，造成精度损失，尽量使用float64(默认类型)。-123.0000901
    浮点数常量有十进制和科学计数法两种表示形式
      512.34
      5.1234e2
字符型(没有专门的字符型，使用byte来保存单个字母(ASCII)字符，汉字使用rune类型或int)
  Go默认使用UTF-8编码
  英文字母占用一个字节，汉字占用3个字节
  在go中，字符的本质是一个整数，直接输出时，是该字符对应的UTF-8编码的码值
  字符类型是可以进行运算的，相当于一个整数，因为它都对应有Unicode码
  263663246122522
布尔型(bool)，bool类型数据只允许取值true和false，不能使用0或1代替
  bool类型占一个字节
字符串(string)由字符组成
  字符串赋值后不可修改
  字符串的两种表示形式
    双引号，会识别转义字符
    反引号，以字符串的原生形式输出，包括换行和特殊字符，可以实现防止攻击、输出源代码等效果
```

###### 基本数据类型的默认值

```
int 0
float32 0
bool false
string ""
```

基本数据类型的转换

- go在不同类型的变量之间赋值时需要显示转换
- T(v)，其中T为type，v为变量
- 被转换的是变量的值，而非变量自身
- 小转大正常int8->int16，大转小按溢出处理int16->int8

###### 基本数据类型和string的转换

基本数据类型转string

1、fmt.Sprintf("%参数", 表达式)

参数需要和表达式的数据类型想匹配

fmt.Sprintf().. 会返回转换后的字符串

2、使用strconv的函数

string转基本数据类型

1、使用strconv的函数

注意：转换时，要确保String类型能够转成有效的数据，若转换失败，其置为默认值



##### 派生/复杂数据类型

```
指针(Pointer)
数组()
结构体(struct)
管道(Channel)
函数
切片(slice)
接口(interface)
map
```

###### 指针

基本数据类型，变量存的就是值，也叫值类型

获取变量的地址，用&，比如：var num int，获取num的地址：&num

指针类型，指针变量存的是一个地址，这个地址指向的空间存的才是值，比如：var ptr *int = &num

获取指针类型所指向的值，使用：*，比如：var ptr *int，使用\*ptr获取获取ptr指向的值

```
[root@ali project]# cat var.go 
package main
import "fmt"

func main() {
    name := "zsjshao"
    ptr := &name
    fmt.Println("MyName =" ,*ptr,ptr,&ptr)
}
[root@ali project]# \go run var.go 
MyName = zsjshao 0xc000010200 0xc00000e030
```

如何在程序中查看变量的占用字节大小和数据类型

fmt.Printf(""%T %d",n1,unsafe.Sizeof(n1))



#### 值类型和引用类型的说明

值类型：基本数据类型int系列、float系列、bool、string、数组和结构体struct

- 变量直接存储值，内存通常在栈中分配

引用类型：指针、slice切片、map、管道chan、interface等都是引用类型

- 变量存储的是一个地址，这个地址对应的空间才真正存储数据（值），内存通常在堆上分配，当没有任何变量引用这个地址时，该地址对应的数据空间就成为一个垃圾，由GC来回收



取模

a % b = a - a / b * b



### 原码、反码、补码

对于有符号的而言

二进制的最高位是符号位：0表示正数，1表示负数

正数的原码，反码，补码都一样

负数的反码=原码符号位不变，其他位取反

负数的补码=反码+1

0的反码、补码都是0

在计算机运算的时候，都是以`补码`的方式来运算

### 位运算符

按位与& ：全为1则为1，否则为0

按位或|：一个为1则为1，否则为0

按位异或^：不同为1，相同为0

### 移位运算符

右移运算符>>：低位溢出，符号位不变，并用符号位补溢出的高位

左移运算符<<：符号位不变，低位补0

### 程序流程控制

顺序控制

分支控制

循环控制







