* --------------------%with,%as --------------------------- ; 
* Usage：;
/*%with(table) *数据操作指针不指定默认为程序最近一次生成的数据集.;*/
/*%as(table) *复制数据，将数据操作指针指向的数据复制到指定数据集.;*/
 
* Examples:;
%with(sashelp.iris);
	%as(iris);
* --------------------------------------------------------- ;
 
* -----------------------%remove--------------------------- ;
* Usage：;
/*%remove(tb1,tb2,...) *删除数据集.;*/ 

* Examples:;
%with(sashelp.iris);
	%as(iris1);
	%remove;*删除操作指针指向的数据集;
 
%with(sashelp.iris);
	%as(iris1);
	%as(iris2);
 
%remove(iris1,iris2);
* --------------------------------------------------------- ;

 
 
* -------------------------%filter------------------------ ;
* Usage：;
/*%filer(filter1,filter2,...)*/
 
* Examples:;
%with(sashelp.iris)
%as(iris_filter)
	%filter(Species = "Versicolor",
      		 SepalLength>60,
      		 PetalWidth+SepalWidth>42)
 
* --------------------------------------------------------- ;
 
 
* ------------------------%select-------------------------- ;
* Usage：;
/*%select(...)*/
 
* Examples:;
%with(sashelp.iris)
	%as(iris_select1)
	%select(Species,Sepal:)
 
%with(sashelp.iris)
	%as(iris_select2)
	%select(-Species,-Sepal:)
 
%with(sashelp.iris)
	%as(iris_select3)
	%select(PetalLength,PetalWidth)
	%rename( PetalLength = Petal_Length,
    	      PetalWidth = Petal_Width)
* --------------------------------------------------------- ;

 
 
* ------------------------%mutate-------------------------- ;
 * Usage：;
/*%mutate(...)*/
 
* Examples:;
%with(sashelp.iris)
	%as(iris_mutate)
	%mutate( sepal_sum = sum(SepalWidth,SepalLength),
    		  width_sum = SepalWidth+PetalWidth,
              label = cat(Species,",",PetalLength),
              width_ratio = SepalWidth/PetalWidth,
              SepalLength_md5  = put(md5(SepalLength),$hex32.)
          )
 
 
%group_by(groupvar_1,groupvar_2,...)
%summarise(expression1,expression2,...)
 
 
 
%with(sashelp.iris)
	%as(iris_smrz) 
	%mutate(sum_width = sum(SepalWidth,PetalLength))
	%filter(sum_width>40)
 
	%group_by(Species)
	%summarise( sum_len = sum(PetalLength),n = count(*))
 
%with(sashelp.iris)
	%as(iris_smrz2)
	%group_by(PetalWidth,SepalWidth)
	%summarise(n = count(*))
 
%with(sashelp.iris)
	%as(iris_smrz3)
	%count(PetalWidth,SepalWidth)

/* Add 0831 */
%with(sashelp.iris)
	%as(iris_smrz4)
%group_by(Species)
%summarise(
         Petalwidth_lt_3 = 
         Sum(
         Case
         When Petalwidth<=3
         Then 1
         Else 0
         end
),
     sample_n = count(*),
     Ratio = (calculated petalwidth_lt_3)/(calculated sample_n)
)
    

/* summarise_all 相同 */

* --------------------------------------------------------- ;


*--------------------%left_join----------------------------- ; 
*Usage：;
/*%left_join(left_tale,right_table,key,merged_table)*/
 
* Examples:;
data a;
   vara = 3; output;
   vara = 1;output;
   vara = 2;output;
   vara = 4;output;
run;
 
 
data b;
   varb = 2; varb_s = "a";output;
   varb = 2; varb_s = "b";output;
   varb = 3; varb_s = "c";output;
   varb = 1; varb_s = "d";output;
run;
 data c;
   varc = 2; varc_s = "ac";output;
   varb = 2; varc_s = "bc";output;
varb = 2; varc_s = "bc";output;
   varb = 3; varc_s = "cc";output;
   varb = 4; varc_s = "dc";output;
run;


%left_join(a,b,vara = varb,merge_ab);*key一样时不写=直接写变量名即可,如：
%left_join(a,b,key,merge_ab);

%left_join_
*Usage：;
/*%left_join_(right_table,key),利用pipe，适用于多表情况，不断把表拼接到数据指针指向的表，注意：多对多时与sql的区别，不会产生完全笛卡尔积，可参见后例*/
 



* Examples:;
%with(a)
%left_join_(b,vara = varb)
%left_join_(c,vara = varc)


* --------------------------------------------------------- ;

* --------------------------%freq-------------------------- ;
*Usage：;
/*%freq(var1,var2,...)*不生成表，只打印结果*/

* Examples:; 
%with(sashelp.iris)	 
	%freq(Species, SepalWidth)
* --------------------------------------------------------- ;

 
* ----------------------%view------------------------------- ;
*Usage：;
/*%view(table)*打开数据表,EG里好像不行;*/

* Examples:; 
%view(sashelp.iris)
* --------------------------------------------------------- ;


 
* ----------------------%extract---------------------------- ;
*Usage：;
/*%extract(row,col)* 类似R[]操作;*/

* Examples:;  
%with(sashelp.iris);
%as(iris_extract1)
	%extract(1:100,2:4);*1-100行,2-4列;
 
	%extract(:80);*1-80行,所有列;
	%extract(2:);*2-最后一行,所有列;
	%extract( :, 1:2);*1-2列,所有行;
	%extract( 2:, 3:);
* --------------------------------------------------------- ;

 
 
* ----------------------%names,%ncol,%nrow----------------- ;
*Usage：;
/*%names,%ncol,%nrow *日志中打印相关信息;*/
 
* Examples:;  
%with(sashelp.iris)
	%names
	%ncol
	%nrow
* --------------------------------------------------------- ;
 
 

* ----------------------%rename,%format-------------------- ;
*Usage：;
/*%rename,%format*/


* Examples:; 
%with(sashelp.iris)
	%as(iris_nf)
 
	%rename( PetalLength = Petal_Length,
        	  PetalWidth = Petal_Width)
 
	%format(Petal_Length = best12.,
             Petal_Width = 5.)
* --------------------------------------------------------- ;




