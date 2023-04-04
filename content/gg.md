## gg函数

### 信息提示

gg.toast()

瞬时的消息提示。

此提示在屏幕下方，居中的位置。信息不起眼，不是置顶层，不可触摸。约显示2秒会消失。

```
gg.toast(arg1,arg2)

参数1是字符串，提示的内容
参数2是布尔值。默认值是false，大约2秒，填true大约1秒
```

gg.alert()

gg.alert()的返回值：0，1，2，3

取决于按下了哪个按钮。右1，中2，左三，对话框被取消是0.

可以使用“手机自身的返回按钮”或者“点击对话框外的区域”来取消对话框

 参数1是提示信息的字符串文本内容

参数2按钮，可填字符串或nil值。在右侧，默认值是nil，显示“确定”2字

参数3按钮，可填字符串或nil值。在中间偏右侧。默认值是nil，即不显示。

参数4按钮，可填字符串或nil值。在左侧。默认值是nil，即不显示。

### 内存区域

gg.setRanges

```
--设置为Ca内存
  gg.setRanges(4)
  gg.SetRanges(gg.REGION_C_ALLOC)  

-- 设置为Ca和A内存
  gg.setRanges(4|32)
  gg.setRanges(36)
  gg.setRanges(gg.REGION_C_ALLOC|gg.REGION_ANONYMOUS)

-- 设置gg默认前7中内存和
  gg.setRanges(262207)
```



| 英文标识            | 数字标识 | gg标识 | 值         |
| ------------------- | -------- | ------ | ---------- |
| gg.REGION_JAVA_HEAP | 2        | Jh     | Jh=2       |
| gg.REGION_C_HEAP    | 1        | Ch     | Ch=1       |
| gg.REGION_C_ALLOC   | 4        | Ca     | Ca=4       |
| gg.REGION_C_DATA    | 8        | Cd     | Cd=8       |
| gg.REGION_C_BSS     | 16       | Cb     | Cb=16      |
| gg.REGION_PPSSPP    | 262144   | PS     | PS=262144  |
| gg.REGION_ANONYMOUS | 32       | A      | A=32       |
| gg.REGION_JAVA      | 65536    | J      | J=65536    |
| gg.REGION_STACK     | 64       | S      | S=64       |
| gg.REGION_ASHMEM    | 524288   | As     | As=524288  |
| gg.REGION_VIDEO     | -2080896 | V      | V=-2080896 |
| gg.REGION_OTHER     | -1032320 | O      | O=-1032320 |
| gg.REGION_BAD       | 131072   | B      | B=131072   |
| gg.REGION_CODE_APP  | 16384    | Xa     | Xa=16384   |
| gg.REGION_CODE_SYS  | 32768    | Xs     | Xs=32768   |



gg.getRanges

```
-- 获取内存区域，返回值是数字。

gg.getRanges()
```



### 搜索

search 搜索 number 数字 sign 标记 type 类型

gg.searchNumber()

搜索指定的数据。

如果结果列表是空的，则执行新搜索；

若列表不是空的，则是改善搜索。



返回值：true 或 字符串错误



gg.searchNumber(arg1, arg2, arg3, arg4, arg5, arg6, arg7)

参数1.字符串。是要搜索的数值。写数字、数组，也可以是一个范围。

参数2.八种数值类型，可用数字形式来表示。 英文是形如 gg.TYPE_

参数3.布尔值。默认是false，表示“此值不加密”，写true表示“此值加密”

参数4.标志。形如gg.SIGN_，默认是gg.SIGN_EQUAL，意思是“标记相同”

参数5.开始搜索的内存地址，默认是0，为不限制开始。

参数6.结束搜索的内存地址，默认是-1，为不限制结束。

参数7.数字。是指定搜出多少个结果后停止搜索。默认是0，表示搜索所有结果



| 数值类型          | 类   | 值        |
| ----------------- | ---- | --------- |
| gg.TYPE_AUTO=127  | A    | AUTO=127  |
| gg.TYPE_DWORD=4   | D    | DWORD=4   |
| gg.TYPE_FLOAT=16  | F    | FLOAT=16  |
| gg.TYPE_DOUBLE=64 | E    | DOUBLE=64 |
| gg.TYPE_WORD=2    | W    | WORD=2    |
| gg.TYPE_BYTE=1    | B    | BYTE=1    |
| gg.TYPE_QWORD=32  | Q    | QWORD=32  |
| gg.TYPE_XOR=8     | X    | XOR=8     |



### 列表清空

gg.clearResults()   

- 首次运行脚本先清空搜索结果

gg.getResultsCount()



### 加载/获取/重载/删除结果

gg.getResults

加载，读取搜索结果



勾选指定结果，并读取对应的‘地址’、‘数值’、‘数值类型’，存储为二维表的形式。

gg.getResults(9个参数)

参数1.数字，你想要读取多少个结果

参数2.数字，你想跳过，忽略前面的多少个结果，默认值是0

参数3.地址，addresss地址的最小值，默认值是nil，无限制

参数4.地址，address地址的最大值，默认值是nil，无限制

参数5.数字，value值的最小值，默认值是nil，无限制

参数6.数字，value值的最大值，默认值是nil，无限制

参数7.八种数值常量，形如gg.TYPE_，或是数字形式。默认值是nil，无限制。

参数8.按分数值过滤，如果第一个字符是“!"，过滤器将排除其小数部分与指定值匹配的所有值。

参数9.五种指针常量。形如POINTER_，默认值是nil。



最常用的参数是1，是数字，即你想要读取/加载多少个结果



返回值：一个二维表或字符串错误



第二维的表有3个键，address  flags   value

键address  是十六进制的地址。0x开头

键flags        是八种数值类型，返回的是数字形式

键value       是数字。改伤害，改金币等等。游戏的修改都是在改这个value值



gg.loadResults(arg1)

重新加载结果。

从已知的表中加载搜索的结果，现有搜索结果将被清除。

参数1.通过getResults得到的表。

返回值：true或字符串错误。



gg.removeResults(arg1)

删除指定加载的结果

参数1.通过getResults得到的表

返回值：true或字符串错误



string.format(arg1,arg2)

参数1，要转成十六进制，就写“%X”

参数2，写你想转换的数字

例如：string.format("%X",123456789)



### 修改加载结果的数值

gg.editAll(arg1,arg2)

编辑 加载结果的数值



这个函数所修改的是getResults得到的表对应的value键值



参数1.字符串，想改的值，可以是数字和数组

参数2.八种数值常量。gg.TYPE

参数不能省略



返回值：一个数字（表示改了多少个值）或字符串错误



案例





### 单项选择框

gg.choice()

单项选择框



参数1.是一个表，一般是写字符串文本，给用户点击

参数2.数字或nil值

​    如果数字对应表的键，则勾上对应的键值，默认是nil，都不勾上

参数3.字符串，顶部标题



返回值：根据用户点击了哪一项，返回表的键。都不选则返回nil





### 多项选择框

gg.multiChoice(arg1,arg2,arg3)

多项选择框

参数1.是一个表，一般是写字符串文本，给用户点击

参数2.是一个表。跟参数1对应

​    键值是true则勾选，键值是nil则不勾选。默认是空表，全不勾选。

参数3.字符串。这是顶部的标题。默认是nil，不显示标题。



返回值：表或nil

用户点击“确定”时，返回的是一个表。表示勾选的状态。

已选择的项，键值是true，不选的项，键值是nil

提醒，打印表时，键值是nil的，打印不出来



如果用户点击了“取消‘或’手机‘的返回键’，则返回值是nil而不是一个表。

所以，判断表的键值之前，得先判断是不是点了取消。否则会因为点取消而报错。



### 获取值，获取附件的值

固定不变的叫特征码

gg.getValues(arg1)

获取数值。

参数1.是一个二维表

必须是含有address，flags，value三个键的二维表。

参考getResults的返回值



返回值：是一个二维表，或字符串错误。

含有address，flags，value三个键的二维表。

这个value是进程的内存真实值，不是自己定义的那个值





