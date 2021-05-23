+++
author = "zsjshao"
title = "goland变量"
date = "2020-05-01"
tags = ["go"]
categories = ["go"]
+++
## Goland变量

### 为什么需要变量

#### 一个程序就是一个世界

![goland_01](http://images.zsjshao.net/goland/goland_01.png)

#### 变量是程序的基本组成单位

不论是使用哪种高级程序语言编写程序，变量都是程序的基本组成单位

### 变量的介绍

#### 变量的概念

变量相当于内存中一个数据存储空间的表示，你可以把变量看做是一个房间的门牌号，通过门牌号我们可以找到房间，同样的道理，通过变量名可以访问到变量（值）。

#### 变量的使用步骤

声明变量（也叫：定义变量）

非变量赋值

使用变量

示例：

```
[root@ali project]# cat var.go 
package main
import "fmt"

func main() {
    // 定义变量/声明变量
    var i int
    // 给i 赋值
    i = 10
    // 使用变量
    fmt.Println("i = ", i)
}
[root@ali project]# go run var.go
i =  10
```

#### 变量声明

基本语法：`var 变量名 数据类型`

##### 单一变量声明

Golang变量使用的三种方式

第一种：指定变量类型，声明后若不赋值，使用默认值

第二种：根据值自行判定变量类型（类型推导）

第三种：省略var，注意 := 左侧的变量不应该是已经声明过的，否则会导致编译错误

```
[root@ali project]# cat var.go
package main
import "fmt"

func main() {
    // 第一种类型
    var i float64
    i = 10.11
    fmt.Println("i=", i)

    // 第二种类型
    var j = 10.11
    fmt.Println("j=", j)

    // 第三种类型
    k := 10.11
    fmt.Println("k=", k)
}
[root@ali project]# go run var.go
i= 10.11
j= 10.11
k= 10.11
```

##### 多变量声明

在编程中，有时我们需要一次性声明多个变量，Golang也提供这样的语法

```
[root@ali project]# cat var.go
package main
import "fmt"

func main() {
    // 第一种类型
    var i, j, k float64
    i = 10.11
    j = 11.11
    k = 12.11
    fmt.Println("i=", i, "j=", j, "k=", k)

    // 第二种类型
    var o, p, q = 10.11, 11.11, 12.11
    fmt.Println("o=", o, "p=", p, "q=", q)

    // 第三种类型
    x, y, z := 10.11, 11.11, 12.11
    fmt.Println("x=", x, "y=", y, "z=", z)
}
[root@ali project]# go run var.go
i= 10.11 j= 11.11 k= 12.11
o= 10.11 p= 11.11 q= 12.11
x= 10.11 y= 11.11 z= 12.11
```

声明全局变量(在Go中函数外部定义的变量就是全局变量)

```
[root@ali project]# cat var.go
package main
import "fmt"

var x, y  int
//x=10.11 函数外不允许赋值操作
//z := 12.11 等同于 var z float64  z = 12.11

var i = 10.11
var j = 12.11
var name = "tom"

var (
    o = 10.11
    p = 11.11
    name2 = "jerry"
)

func main() {
    fmt.Println("i=", i, "j=", j, "name=", name)
    fmt.Println("o=", o, "p=", p, "name2=", name2)
    fmt.Println("x=", x, "y=", y )
}

[root@ali project]# go var.go
i= 10.11 j= 12.11 name= tom
o= 10.11 p= 11.11 name2= jerry
x= 0 y= 0
```

全局变量不支持第一种方式的赋值操作，和第三种声明方式

#### 变量使用注意事项

变量表示内存中的一个存储区域

该区域有自己的名称（变量名）和类型（数据类型）

变量的数据值可以在同一类型范围内不断变化

变量在同一个作用域（一个函数或者代码块）内不能重名

变量=变量名+值+数据类型，这是变量的三要素

Golang的变量如果没有赋初值，编译器会使用默认值，比如int默认值为0，string默认值为空串，小数默认为0

#### 变量的数据类型

##### 基本数据类型

数值型

- 整数类型，用于存放整数值，分为有符号和无符号两种

  - int(默认类型),int8,int16,int32(rune(unicode)),int64,

  - uint,uint8(byte),uint16,uint32,uint64

    其中int和uint的大小和系统有关，64位系统int等同于int64，uint同理

  在使用整形变量时，遵守保小不保大的原则，即尽量使用占用空间小的数据类型
  
  ```
  [root@ali project]# cat var.go
  package main
  import "fmt"
  
  func main() {
      var n1 = 100
      fmt.Printf("n1 的值 %v\nn1 的类型 %T \n", n1, n1)
  }
  [root@ali project]# go run var.go
  n1 的值 100
  n1 的类型 int
  ```



- 小数类型/浮点类型（单精度:float32,双精度:float64）
  - 浮点数=符号位+指数位+尾数位 





```

  
浮点类型（单精度:float32,双精度:float64）
    浮点数=符号位+指数位+尾数位
    尾数部分可能丢失，造成精度损失，尽量使用float64(默认类型)。-123.0000901
    浮点数常量有十进制和科学计数法两种表示形式
      512.34
      5.1234e2
 
 默认值为0
```

字符型

```
字符型(没有专门的字符型，使用byte来保存单个字母(ASCII)字符，汉字使用rune类型或int)
  Go默认使用UTF-8编码
  英文字母占用一个字节，汉字占用3个字节
  在go中，字符的本质是一个整数，直接输出时，是该字符对应的UTF-8编码的码值
  字符类型是可以进行运算的，相当于一个整数，因为它都对应有Unicode码
  263663246122522
```

布尔型

```
布尔型(bool)，bool类型数据只允许取值true和false，不能使用0或1代替
  bool类型占一个字节

默认值为false
```

字符串

```
字符串(string)由字符组成
  字符串赋值后不可修改
  字符串的两种表示形式
    双引号，会识别转义字符
    反引号，以字符串的原生形式输出，包括换行和特殊字符，可以实现防止攻击、输出源代码等效果

默认值为空“”
```







##### 派生/复杂数据类型









### 程序中 + 号的使用

当左右两边为数值时，做加法运算

当左右两边为字符串时，做字符串拼接，可换行，+号留在上一行























