# SAS tidyverse

## 这是个啥
SAS tidyverse提供类似于`R tidyverse`包及R使用习惯的宏程序, 也是 ***a grammar of data manipulation***.

## 为什么做
   * 好的设计让人爱不释手，它很美---***pipe philosophy***
 
   * 让R重度使用者写SAS时更亲切，同时减少代码编辑时间
   
   * 我们产生不了源代码，只是代码的搬运工

## 目前已包含哪些宏
### 类似dplyr的
 * %filter()
 * %select()
 * %mutate()
 * %group_by()
 * %summarise()  **还只能和group_by()搭配用**
 * %count()
 * %summarise_all()  **同R的 group_by() %>% %mutate()**
 * %left_join()
 * %left_join_()
 * %rename()
 
### 类似R base的
 * %nrow()
 * %ncol()
 * %names()
 * %head()
 * %extract()
 * %view()
### 其他
 * %with()
 * %as()
 * %remove()
 * %sort()
 * %sort_nodup()
 * %contents()
 * %format()
 * %freq()

## 特点：
* 类似于dplyR函数，可以输入不限定个数的参数
* 通过数据操作指针，实现pipe语法功能
* names,ncol,nrow,rename,format等函数采用了高效的处理方式，直接读取和直接改变属性
* extract操作像python 
* left_join会输出匹配率
* 公司SAS一天不断，就会持续更新完善

## 来个示例（更多参见example.sas）
