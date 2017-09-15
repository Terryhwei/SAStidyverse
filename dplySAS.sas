
 
%macro interpreter(param_string,sep_sign) ;
   %global param_execute;
   * param inputs;
   %let param_orig = &param_string;
   *remove the head and tail brackets;
   %let param_len = %eval(%length(&param_orig)-2);
   %let param_cnt = %sysfunc(substr(&param_orig,2,&param_len));
   *scan parameter separated by ',';
    %let i = 1;
   %let next_temp = first_round;
 
    %let param_execute = ;
    %let unmatched_part = ;
 
     * While current parm is not blank;
    %do %while (%str(&next_temp) ne %str( ));
  
        %let param_&i = %bquote(%scan( %bquote(&param_cnt),&i,%str(,)));
        %let next_temp = %bquote(%scan( %bquote(&param_cnt),%eval(&i +1),%str(,)));
      
     *paired match testing;
       %if( %sysfunc(COUNT(&&param_&i,%str(%())) eq
            %sysfunc(COUNT(&&param_&i,%str(%)))) and
           %sysfunc(mod( %sysfunc(COUNT(&&param_&i,%str(%'))),2)) eq 0 and
           %sysfunc(mod(%sysfunc(COUNT(&&param_&i,%str(%"))),2)) eq 0 and
           &unmatched_part = )
       %then %do;      
           %let param_execute = &param_execute &&param_&i %str(&sep_sign) %str( );
       %end;
 
       %else %do;
           %let unmatched_part = &unmatched_part &&param_&i;
           %if(
              %sysfunc(COUNT(&unmatched_part,%str(%())) eq
                %sysfunc(COUNT(&unmatched_part,%str(%)))) and
              %sysfunc(mod( %sysfunc(COUNT(&unmatched_part,%str(%'))),2)) eq 0 and
              %sysfunc(mod(%sysfunc(COUNT(&unmatched_part,%str(%"))),2)) eq 0
             )        
           %then %do;
            %let param_execute = &param_execute &&param_&i %str(&sep_sign) %str( );
           %let unmatched_part = ;    
            %end;
 
           %else %do;
           %let param_execute = &param_execute&&param_&i%str(,);
          %end;
      %end;
      %let i = %eval(&i+1);   
    %end;
 
%mend;
 
%macro pipe_prep;
%if &table eq %str() %then %do;
    data _null_;
       call symput('table','&syslast');
    run;
%end;
%mend;
 
 
%macro with(table);
%let syslast = &table;
%mend;

 
 
%macro as(table);
%pipe_prep;
%remove(&table);
proc append base = &table data=&syslast;
run;
%mend;
 

 
%macro remove/parmbuff;
%interpreter(&syspbuff,%str( ));
 
%if &param_execute eq %str() %then %do;
%let rm_table = &syslast;
%end;
%else %do;
%let rm_table = &param_execute;
%end;
 
%put Remove:&rm_table;
/*%put &param_execute;*/
proc delete
    data = &rm_table;
run;
%mend;
 
 
%macro filter/parmbuff;
    %interpreter(&syspbuff,and);
   data &syslast;
       set &syslast;
       %nrstr(
       where  %trim(%left(&param_execute)) 1);
    run;
%mend;
 
 
%macro select/parmbuff;
    %let param_input_orig = &syspbuff;
    *remove the head and tail brackets;
   %let param_len = %eval(%length(&param_input_orig)-2);
   %let param_cnt = %sysfunc(substr(&param_input_orig,2,&param_len));
 
   *scan parameter separated by ',';
    %let i = 1;
   %let next_temp = first_round;
 
    %let keep_list = ;
    %let drop_list = ;
 
     * While current parm is not blank;
    %do %while (%str(&next_temp) ne %str( ));
  
        %let param_&i = %bquote(%scan( %bquote(&param_cnt),&i,%str(,)));
       %let next_temp = %bquote(%scan( %bquote(&param_cnt),%eval(&i +1),%str(,)));
       
        %if   %bquote(%substr(%trim(%left(&&param_&i)),1,1)) eq %str(-) %then %do;

       %let temp_len = %length(%trim(%left(&&param_&i)));
       %let temp_drop = %substr(%trim(%left(&&param_&i)),2,%eval(&temp_len-1));
 
 
 
        %let drop_list = &drop_list &temp_drop;
        %let temp_drop = ;
        %end;
 
       %else %do;
        %let keep_list = &keep_list  &&param_&i;
       %end;
       %let i = %eval(&i+1);   
    %end;
  
    data &syslast;
       set &syslast;
        %if %bquote(%trim(%left(&keep_list))) ne %str() %then %do;
       keep %trim(%left(&keep_list));
       %end;
 
       %if %bquote(%trim(%left(&drop_list))) ne %str() %then %do;
       drop %trim(%left(&drop_list));
       %end;
    run;
%mend;
 
 
%macro mutate/parmbuff;
    %interpreter(&syspbuff,; );
    %put &param_execute;
    data &syslast;
       set &syslast;
        %str( ;)
       %trim(&param_execute)
     ;
    run;
%mend;
 
 
%macro group_by/parmbuff;
%global group_var;
  %let param_len = %eval(%length(&syspbuff)-2);
  %let group_var = %sysfunc(substr(&syspbuff,2,&param_len)); 
%mend;
 
%macro summarise/parmbuff;
%interpreter(&syspbuff,%str(#));

%let i = 1;
%let next_temp = first_round;
%let sql_expr = ;
 
%do %while (%str(&next_temp) ne %str( ));
  
        %let param_&i = %bquote(%scan( %bquote(&param_execute),&i,%str(#)));
       %let next_temp = %bquote(%scan( %bquote(&param_execute),%eval(&i +1),%str(#)));
 
       %let left_part =  %bquote(%scan( %bquote(&&param_&i),1,%str(=)));
       %let left_len = %eval(%length(&left_part)+2);
       %let str_len = %eval(%length(&&param_&i)-&left_len+1);
       %let right_part =  %sysfunc(substr(&&param_&i,&left_len,&str_len));
 
        
       %if &i eq 1 %then %do;
       %let sql_expr_temp =  &right_part as &left_part ;
       %end;
       %else %do;
        %let sql_expr_temp = %str(,) &right_part as &left_part ;
       %end;
 
        %let sql_expr = &sql_expr   &sql_expr_temp;
   
 
       %let i = %eval(&i+1);   
    %end;
 
/*  %put &sql_expr;*/
 
proc sql;
    create table &syslast  as
    select &group_var ,&sql_expr
    from &syslast
    group by  &group_var;
quit;
 
%mend;
 
 
%macro summarise_all/parmbuff store secure des="dplySAS";
%interpreter(&syspbuff,%str(#));
 
%let i = 1;
%let next_temp = first_round;
%let sql_expr = ;
 
%do %while (%str(&next_temp) ne %str( ));
  
        %let param_&i = %bquote(%scan( %bquote(&param_execute),&i,%str(#)));
       %let next_temp = %bquote(%scan( %bquote(&param_execute),%eval(&i +1),%str(#)));
 
       %let left_part =  %bquote(%scan( %bquote(&&param_&i),1,%str(=)));
       %let left_len = %eval(%length(&left_part)+2);
       %let str_len = %eval(%length(&&param_&i)-&left_len+1);
       %let right_part =  %sysfunc(substr(&&param_&i,&left_len,&str_len));
 
        
       %if &i eq 1 %then %do;
       %let sql_expr_temp =  &right_part as &left_part ;
       %end;
       %else %do;
        %let sql_expr_temp = %str(,) &right_part as &left_part ;
       %end;
 
        %let sql_expr = &sql_expr   &sql_expr_temp;
   
 
       %let i = %eval(&i+1);   
    %end;
 
/*  %put &sql_expr;*/
 
proc sql;
    create table &syslast  as
    select * ,&sql_expr
    from &syslast
    group by  &group_var;
quit;
 
%mend;
 
 
 
 
%macro sort/parmbuff;
%interpreter(&syspbuff,%str( ));
proc sort data = &syslast;
    by  &param_execute;
run;
%mend;
 
 
%macro sort_nodup/parmbuff store secure des="dplySAS";
%interpreter(&syspbuff,%str( ));
proc sort data = &syslast nodupkey;
    by  &param_execute;
run;
%mend;

 
%macro contents(table);
    %pipe_prep;
    proc contents data = &table;run;
    run;
%mend;
 
 
%macro extract(nrow,ncol);
 
    %let nrow_colon = %sysfunc(count(&nrow,%str(:)));
    %let ncol_colon = %sysfunc(count(&ncol,%str(:)));
 
    %if &nrow_colon >1 or &ncol_colon>1 %then %do;
       %put ERROR: Multiple colon!!;
        %return;
    %end;
 
 
    %let dsid=%sysfunc(open(&syslast));   
    %let nvars = %sysfunc(attrn(&dsid,nvar));
    %let nobs = %sysfunc(attrn(&dsid,nobs));
    %let dsid=%sysfunc(close(&dsid));
 
 
   
    %if &nrow_colon eq 0 %then %do;
       %let firstobs = &nrow;
       %let obs = &nrow;
    %end;
    %else %do;
       %if %sysfunc(index(&nrow,%str(:))) = 1 %then %do;
           %let row_left = ;
           %let row_right = %scan(&nrow,1,%str(:));
       %end;
        %else %do;
           %let row_left = %scan(&nrow,1,%str(:));
           %let row_right = %scan(&nrow,2,%str(:));
       %end;
 
 
       %if     &row_left eq %str() %then %do;
           %let firstobs = 1;
       %end;
       %else %do;
           %let firstobs = %sysfunc(min( &row_left,&nobs));
       %end;
 
       %if  &row_right  eq %str() %then %do;
           %let obs = &nobs;
       %end;
       %else %do;
           %let obs = %sysfunc(min(&row_right,&nobs));
       %end;
    %end;
  
 
    %if &ncol eq %str() %then %do;
       %let firstvarn = 1;
       %let lastvarn = &nvars;
    %end;
    %else %if &ncol_colon eq 0 %then %do;
       %let firstvarn = &ncol;
       %let lastvarn = &ncol;
    %end;
 
    %else %do;
        %if %sysfunc(index(&ncol,%str(:))) = 1 %then %do;
           %let col_left = ;
           %let col_right = %scan(&ncol,1,%str(:));
       %end;
        %else %do;
           %let col_left = %scan(&ncol,1,%str(:));
           %let col_right = %scan(&ncol,2,%str(:));
        %end;
  
       %if  &col_left eq %str() %then %do;
           %let firstvarn = 1;
       %end;
       %else %do;
           %let firstvarn =  %sysfunc(min(&col_left,&nvars));
       %end;
 
       %if &col_right eq %str() %then %do;
           %let lastvarn = &nvars;
       %end;
       %else %do;
           %let lastvarn =  %sysfunc(min(&col_right,&nvars));
       %end;
    %end;
 
 
 
    %if &firstobs > &obs %then %do;
       %put ERROR: firstobs number > obs number!!;
        %return;
    %end;
 
    %if &firstvarn > &lastvarn %then %do;
       %put ERROR: firstvar number > lastvar number!!;
        %return;
    %end;
 
  
    %let dsid=%sysfunc(open(&syslast)); 
    %let keep_var = ;
    %do k = &firstvarn %to &lastvarn;
       %let varname = %sysfunc(varname(&dsid,&k));
       %let keep_var = &keep_var &varname;
    %end;
    %let dsid=%sysfunc(close(&dsid));
 
    %put keepvar : &keep_var!!;
 
    data &syslast;
       set &syslast
       (firstobs = &firstobs
         obs = &obs);
       keep
       &keep_var;
    run;
   ;
%mend;
 
 
 
%macro nrow(table);
%pipe_prep;
%let dsid=%sysfunc(open(&table)); 
 %let nobs = %sysfunc(attrn(&dsid,nobs));
%let dsid=%sysfunc(close(&dsid));
 
%put Rows: &nobs ;
 
%mend;
 
 
%macro ncol(table);
%pipe_prep;
%let dsid=%sysfunc(open(&table)); 
 %let nvars = %sysfunc(attrn(&dsid,nvar));
%let dsid=%sysfunc(close(&dsid));
%put Columns: &nvars ;
 
%mend;
 
%macro names(table);
%pipe_prep;
%let dsid=%sysfunc(open(&table)); 
  %let nvars = %sysfunc(attrn(&dsid,nvar));
  %let var = ;
    %do k = 1 %to &nvars;
       %let varname = %sysfunc(varname(&dsid,&k));
       %let var = &var  &varname;
    %end;
%let dsid=%sysfunc(close(&dsid));
%put Names: &var ;
%mend;
 
%macro print(table);
%pipe_prep;
    proc print data = &table;run;
%mend;
 
 
%macro count/parmbuff store secure des="dplySAS";
  %let param_len = %eval(%length(&syspbuff)-2);
  %let count_param = %sysfunc(substr(&syspbuff,2,&param_len));
  %group_by(&count_param);
  %as(_temp_count_);
  %summarise(n = count(*));
  %print;
%mend;

%macro head(table);
  %pipe_prep;
  %with(&table);
  %as(_temp_head_);
  %extract(1:30,1:15);
  %print;
  %remove;
%mend;


%macro rename/parmbuff ;
  %interpreter(&syspbuff,%str(  ) );  
  %let lib_part = %bquote(%scan( %bquote(&syslast),1,%str(.)));
  %let data_part = %bquote(%scan( %bquote(&syslast),2,%str(.)));
 
  proc datasets nolist library = &lib_part;
    modify   &data_part;
    rename &param_execute ;
  run;
  quit;
%mend;

 
%macro format/parmbuff store secure des="dplySAS";
    %interpreter(&syspbuff,%str(  ) );  
    %let lib_part = %bquote(%scan( %bquote(&syslast),1,%str(.)));
    %let data_part = %bquote(%scan( %bquote(&syslast),2,%str(.)));
 
    %let param_execute_trans = %sysfunc(translate(&param_execute,%str( ),%str(=)));
 
    proc datasets nolist library = &lib_part;
        modify   &data_part;
        format &param_execute_trans ;
        run;
    quit;
%mend;
 
 
%macro left_join/parmbuff ;
    %let param_orig = &syspbuff;
    %let param_len = %eval(%length(&param_orig)-2);
    %let param_cnt = %sysfunc(substr(&param_orig,2,&param_len));
 
    %let table_left = %bquote(%scan( %bquote(&param_cnt),1,%str(,)));
    %let table_right = %bquote(%scan( %bquote(&param_cnt),2,%str(,)));
    %let match_key = %bquote(%scan( %bquote(&param_cnt),3,%str(,)));
    %let result_table = %bquote(%scan( %bquote(&param_cnt),4,%str(,)));
 
 
    %if &match_key eq %str()  %then %do;
        %put ERROR:  match key missing!!;
        %return;
    %end;
 
 
    %if %sysfunc(COUNT(&match_key,%str(=))) eq 0 %then %do;
        %let key_left = &match_key;
        %let key_right = &match_key;
    %end;
    %else %do;
        %let key_left = %bquote(%scan( %bquote(&match_key),1,%str(=)));
        %let key_right = %bquote(%scan( %bquote(&match_key),2,%str(=)));
    %end;
 
    /*%put &table_left &table_right &match_key  &key_left &key_right ;*/
 
    %with(&table_left);
    %sort(&key_left);
 
 
    %with(&table_right);
    %sort(&key_right);
 
    %remove(&result_table);
    data &result_table;
       merge
       &table_left(in=a )
       &table_right(in=b
       rename=(&key_right = &key_left)
       );
       by &key_left;
       match=cat(a,b);
       if a;
    run;
 
 
    %count(match);
    %with(&result_table);
 
     
%mend;
 

%macro left_join_/parmbuff ;
    %let param_orig = &syspbuff;
    %let param_len = %eval(%length(&param_orig)-2);
    %let param_cnt = %sysfunc(substr(&param_orig,2,&param_len));
    
    %let table_left = &syslast;
    
    %let table_right = %bquote(%scan( %bquote(&param_cnt),1,%str(,)));
    %let match_key = %bquote(%scan( %bquote(&param_cnt),2,%str(,)));
    %let result_table = &syslast;
 
 
    %if &match_key eq %str()  %then %do;
        %put ERROR:  match key missing!!;
        %return;
    %end;
 
 
    %if %sysfunc(COUNT(&match_key,%str(=))) eq 0 %then %do;
        %let key_left = &match_key;
        %let key_right = &match_key;
    %end;
    %else %do;
        %let key_left = %bquote(%scan( %bquote(&match_key),1,%str(=)));
        %let key_right = %bquote(%scan( %bquote(&match_key),2,%str(=)));
    %end;
 
    /*%put &table_left &table_right &match_key  &key_left &key_right ;*/
 
    %with(&table_left);
    %sort(&key_left);
 
 
    %with(&table_right);
    %sort(&key_right);
 
    %remove(&result_table);
    data &result_table;
       merge
       &table_left(in=a )
       &table_right(in=b
       rename=(&key_right = &key_left)
       );
       by &key_left;
       match=cat(a,b);
       if a;
    run;
 
 
    %count(match);
    %with(&result_table);
 
     
%mend; 
 
 
 
 
 
 
  
%macro view(table);
    %pipe_prep;
    dm "vt &table" continue;
%mend;
 
 
%macro close_view;
    dm "next VIEWTABLE: ;end;";
%mend;
 
 
%macro as_date(var);
  mdy(
    substr(&var,6,2),
    substr(&var,9,2),
    substr(&var,1,4));
   
%mend;
 
%macro as_datetime(var);
    (input(substr(&var,1,10),yymmdd10.)*24*60*60
       +input(substr(&var,12,8),time8.));
%mend;
 
 
%macro freq/parmbuff store secure des="dplySAS";
    %interpreter(&syspbuff,%str( * ) ); 
    %let param_execute_c = %sysfunc(compress(&param_execute));
    %let param_len = %eval(%length(&param_execute_c)-1);
    %let param_cnt = %sysfunc(substr(&param_execute_c,1,&param_len));
    proc freq data = &syslast;
      table %trim(&param_cnt)/
      missing   norow nocol nocum nopercent ;
    run;
%mend;
 
