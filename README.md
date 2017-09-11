# SAS_tidyverse

SAS_tidyverse提供类似于dplyr包及R函数使用习惯的宏程序, 也是A  grammar of data manipulation。
包括如下内容


类似于dplyR的：
%filter(),  %select(),  %mutate(),  %group_by(),  %summarise(),  %count(), %summarise_all(),  %left_join(),%left_join_(),%rename().
类似于 R 的：
%nrow(),  %ncol(),  %names(),  %head(),  %extract(),  %view()
其他
%with(),  %as(),  %remove(), %sort(),  %sort_nodup(),  %contents(), %format(),%freq()

特点：
类似于dplyR函数，可以输入不限定个数的参数
通过数据操作指针，实现类似R 的pipe语法功能
Names,ncol,nrow,Rename,format等函数采用了高效的处理方式，直接读取和直接改变属性
%left_jon,支持输出匹配率，及时发现匹配问题。
总的来说，主要是自己写了括号内容的小解释器，我们产生不了源代码，只是代码的搬运工，减少程序编辑时间，增强程序可读性（某些时候损失一点点运算效率）！
