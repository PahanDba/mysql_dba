create database if not exists assistant_dba;
drop function if exists assistant_dba.`regexp_replace`;
DELIMITER $$
CREATE FUNCTION  assistant_dba.`regexp_replace`(ori_str varchar(64),pattern VARCHAR(64),repl_str VARCHAR(64)) RETURNS longtext CHARSET utf8mb4
    DETERMINISTIC
BEGIN  
#Thank you for this function the website https://www.cnblogs.com/rainbow--/p/17026987.html
#This is an analog of function regexp_replace from MySQL 8.0 to MySQL 5.7
	DECLARE tmp_str LONGTEXT;  
	DECLARE target_str LONGTEXT;  
	DECLARE str0 LONGTEXT;  
	DECLARE i1 INT;
	DECLARE i2 INT;
	SET tmp_str = ori_str; 
	loop0: LOOP
		IF NOT tmp_str REGEXP pattern THEN  
			LEAVE loop0;  
		END IF;
		SET i1 = 1;
		SET i2 = CHAR_LENGTH(tmp_str);
		loop1: LOOP
			SET str0 = SUBSTR(tmp_str, i1, i2-i1+1);
			IF NOT str0 REGEXP pattern THEN
				SET i1 = i1-1; 
				LEAVE loop1;
			ELSE
				SET i1 = i1+1;
			END IF;
		END LOOP;
		loop2: LOOP
			SET str0 = SUBSTR(tmp_str, i1, i2-i1+1);
			IF NOT str0 REGEXP pattern THEN
				SET i2 = i2+1; 
				LEAVE loop2;
			ELSE
				SET i2 = i2-1;  
			END IF;
		END LOOP;
		SET target_str = SUBSTR(tmp_str, i1, i2-i1+1);
		SET tmp_str = REPLACE(tmp_str, target_str, repl_str);
	END LOOP;  
	RETURN tmp_str;
END$$
DELIMITER ;


DROP PROCEDURE if exists assistant_dba.`count_dml_stmt`;
DELIMITER $$
CREATE PROCEDURE assistant_dba.`count_dml_stmt`()
begin
declare speciality condition for sqlstate '45000';
SET sql_log_bin = 0;
set @error_mysql_version:= concat ('Warning! This procedure doesn''t work with MySQL less than 5.7.') ;
set @error_check_function:= concat ('Warning! The function ''assistant_dba.regexp_replace'' doesn''t exist on this database server.') ;
#call `assistant_dba`.`count_dml_stmt` ();
set @var_server_id := (select @@server_id);
set @var_server_name :=(select @@hostname);
set @var_server_version := (select @@version);
set @var_first_number_server_version := (select substring(@@version,1,3));
#I check the version MySQL. If MySQL has a version less than 5.7, then this procedure has finished with an error.
    if @var_first_number_server_version<5.7 then
       signal speciality set message_text = @error_mysql_version;
	end if;

if @var_first_number_server_version<8 then 
	set @check_version=5;
    #I'll create the table which called t_server_idsevernamecount_dml_stmt. For example, the global variables has values server_id=3043 and hostname=mysql3043.
    #The table will be named t_3043_mysql3043_count_dml_stmt.
    #I remove from the hostname the characters that do not satisfy the condition [a-z] or [A-Z] or [0-9] or _.
    set @tblname_count_dml_stmt=concat('t_',@var_server_id,'_',(select assistant_dba.`regexp_replace`(@var_server_name ,'[^a-zA-Z0-9_]','')),'_count_dml_stmt');
    
end if;    

if @var_first_number_server_version>=8 then 
	set @check_version=8;
    #I'll create the table which called t_server_idsevernamecount_dml_stmt. For example, the global variables has values server_id=3043 and hostname=mysql3043.
    #The table will be named t_3043_mysql3043_count_dml_stmt.
    #I remove from the hostname the characters that do not satisfy the condition [a-z] or [A-Z] or [0-9] or _.
    set @tblname_count_dml_stmt=concat('t_',@var_server_id,'_',(select regexp_replace(@var_server_name ,'[^a-zA-Z0-9_]','')),'_count_dml_stmt');
end if;  
	set @sql_create_tbl :=concat(' CREATE TABLE if not exists \`assistant_dba\`.',@tblname_count_dml_stmt,' 
									(\`id\` INT UNSIGNED NOT NULL AUTO_INCREMENT, \`object_type\` VARCHAR(64) NOT NULL, 
                                    \`object_schema\`  VARCHAR(64) NOT NULL, \`object_name\`  VARCHAR(64) NOT NULL, 
                                    \`count_star\` bigint not null, \`count_read\` bigint not null, \`count_write\` bigint not null, 
                                    \`count_fetch\` bigint not null, \`count_insert\` bigint not null, \`count_update\` bigint not null, 
                                    \`count_delete\` bigint not null, \`date_collect\` datetime not null,  
                                    \`date_start\` datetime not null,
									PRIMARY KEY (\`id\`), 
                                    key \`IX_object_schema_object_name_date_collect\` 
                                    (\`object_schema\` asc, \`object_name\` asc, \`date_collect\`) ); '); 
		prepare dynamic_create_tbl from @sql_create_tbl;
		execute dynamic_create_tbl;
        deallocate prepare dynamic_create_tbl;

	set @sql_insert :=concat(' insert into \`assistant_dba\`.',@tblname_count_dml_stmt,' 
								(\`object_type\` , \`object_schema\`, \`object_name\` , \`count_star\`, \`count_read\` , 
                                \`count_write\`, \`count_fetch\` , \`count_insert\`, \`count_update\`, \`count_delete\`, 
                                \`date_collect\`,\`date_start\`)  
								SELECT object_type, object_schema, object_name, count_star, count_read, count_write, 
                                count_fetch, count_insert, count_update, count_delete, now() as date_collect,
								(select DATE_ADD (now(), interval -g.VARIABLE_VALUE second) d 
                                from performance_schema.global_status as g WHERE g.variable_name=''Uptime'') as date_start
								FROM performance_schema.table_io_waits_summary_by_table; '); 
		prepare dynamic_insert from @sql_insert;
		execute dynamic_insert;
        deallocate prepare dynamic_insert;
end$$
DELIMITER ;

DROP EVENT if exists assistant_dba.`count_dml_stmt`;
DELIMITER $$
CREATE EVENT assistant_dba.`count_dml_stmt` ON SCHEDULE EVERY 30 SECOND STARTS '2024-12-14 00:00:00' ON COMPLETION NOT PRESERVE ENABLE COMMENT 'Collecting information how many DML operations were in each tbl.' 
DO BEGIN
   call assistant_dba.count_dml_stmt(); 
 END$$
 DELIMITER ;

DELIMITER ;
DROP PROCEDURE if exists assistant_dba.`count_dml_stmt_analyze`;
DELIMITER $$
CREATE PROCEDURE assistant_dba.`count_dml_stmt_analyze`(in in_table_name_store varchar(64), in_schema_name_my varchar(64), in_table_name_my varchar(64), date_collect_start_input datetime, date_collect_finish_input datetime )
begin
/*
in_table_name_store - The table, which stores the values DML (COUNT_STAR, COUNT_READ, COUNT_WRITE, COUNT_FETCH, COUNT_INSERT, COUNT_UPDATE, COUNT_DELETE) 
of statements from the table performance_schema.table_io_waits_summary_by_table. This table is always there in the database called 'assistant_dba'.
in_schema_name_my - The schema, where there is the table and the data about it we want to analyze.. 
in_table_name_my - The table, which we want to analyze.
date_collect_start_input - The starting time of the interval in the format 'YYYY-MM-DD HH:MM:SS’, which we need to analyze.
date_collect_finish_input - The finishing time of the interval in the format 'YYYY-MM-DD HH:MM:SS’, which we need to analyze.

*/   
declare speciality condition for sqlstate '45000';
SET sql_log_bin = 0;
SET SESSION group_concat_max_len = 1000000;
#the starting time equals the finishing time
#call assistant_dba.count_dml_stmt_analyze('t_3043_mysql3043_count_dml_stmt', 'assistant_dba','t_3043_mysql3043_count_dml_stmt' ,'2025-06-29 13:47:10','2025-06-29 21:50:10');
#The finishing date and time of the interval is less than the starting date and time of the interval
#call assistant_dba.count_dml_stmt_analyze('t_3043_mysql3043_count_dml_stmt', 'assistant_dba','t_3043_mysql3043_count_dml_stmt' ,'2025-06-29 23:47:10','2025-06-29 21:50:10');
#The starting date and time of the interval and the finishing date and time of the interval are at different dates at the launch of the MySQL server
#call assistant_dba.count_dml_stmt_analyze('t_3043_mysql3043_count_dml_stmt', 'assistant_dba','t_3043_mysql3043_count_dml_stmt' ,'2025-05-12 10:47:10','2025-07-05 21:50:10');
#The starting date and time of the interval and the finishing date and time of the interval fall on the same MySQL server start date
#call assistant_dba.count_dml_stmt_analyze('t_3043_mysql3043_count_dml_stmt', 'assistant_dba','t_3043_mysql3043_count_dml_stmt' ,'2025-05-26 18:30:23','2025-05-26 18:52:46');
#The starting date and time of the interval and the finishing date and time of the interval are at one date at the launch of the MySQL server, and the finishing date 
#and time have not yet arrived, i.e., are in the future
#call assistant_dba.count_dml_stmt_analyze('t_3043_mysql3043_count_dml_stmt', 'assistant_dba','t_3043_mysql3043_count_dml_stmt' ,'2025-05-26 18:30:23','2025-07-10 18:52:46');    

set @table_name_store:=in_table_name_store;
set @schema_name_my:=in_schema_name_my;
set @table_name_my:=in_table_name_my;
set @date_collect_start_input:=date_collect_start_input;
set @date_collect_finish_input:=date_collect_finish_input;
set @table_name_store_time_start_srv_tmp:=concat(@table_name_store,'_time_start_srv_tmp');
set @table_name_store_tmp:=concat(@table_name_store,'_tmp');
set @error_table_name_store:= concat('Error! The store table ',@table_name_store,' doesn''t exist in the database ''assistant_dba'' on this database server.') ;
set @error_schema_name_my:= concat('Error! The schema ',@schema_name_my,' didn''t find in the ''assistant_dba''.''',@table_name_store,''' on this database server.') ;
set @error_table_name_my:= concat('Error! The table ',@table_name_my,' didn''t find in the ''assistant_dba''.''',@table_name_store,''' on this database server.') ;
set @error_datetime_interval:= concat('Error!') ;
#I am checking your input parameters.
If time_to_sec(timediff(@date_collect_finish_input,@date_collect_start_input))<0 then
	select 'The finishing date and time of the interval can''t be less than the starting date and time of the interval.' as msg_error;
    signal speciality set message_text = @error_datetime_interval;
end if;
set @check_table_name_store='';
set @check_table_name_store_stmt = concat('select TABLE_NAME into @check_table_name_store from information_schema.TABLES where TABLE_SCHEMA=''assistant_dba'' and TABLE_NAME=''',@table_name_store,''';');
	PREPARE st0 FROM @check_table_name_store_stmt;
    EXECUTE st0;
    DEALLOCATE PREPARE st0;
if @table_name_store<>@check_table_name_store then
 signal speciality set message_text = @error_table_name_store;
end if;
set @check_schema_name_my='';
set @check_schema_name_my_stmt = concat('select distinct object_schema into @check_schema_name_my from assistant_dba.',@table_name_store,' where object_schema=''',@schema_name_my,''';');
	PREPARE st1 FROM @check_schema_name_my_stmt;
    EXECUTE st1;
    DEALLOCATE PREPARE st1;
if @schema_name_my<>@check_schema_name_my then
 signal speciality set message_text = @error_schema_name_my;
end if;
set @check_table_name_my='';
set @check_table_name_my_stmt = concat('select distinct object_name into @check_table_name_my from assistant_dba.',@table_name_store,' where object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,''';');
	PREPARE st2 FROM @check_table_name_my_stmt;
    EXECUTE st2;
    DEALLOCATE PREPARE st2;
if @table_name_my<>@check_table_name_my then
 signal speciality set message_text = @error_table_name_my;
end if;
set @check_date_collect_start_input='';
set @check_date_collect_start_input_stmt = concat('select distinct date_collect into @check_date_collect_start_input from assistant_dba.',@table_name_store,' where object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,''' and date_collect=''',@date_collect_start_input,''';');
	PREPARE st3 FROM @check_date_collect_start_input_stmt;
    EXECUTE st3;
    DEALLOCATE PREPARE st3;
if @check_date_collect_start_input is null or @check_date_collect_start_input='' or @check_date_collect_start_input=' '
	then 
    set @msg:=concat(cast(@date_collect_start_input as char),' doesn''t exist');
    set @date_collect_start_input_less='';
    set @date_collect_start_input_less_stmt:=concat('SELECT max(date_collect) into @date_collect_start_input_less FROM assistant_dba.',@table_name_store,' where object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,''' and date_collect	<= ''',@date_collect_start_input,''';');
    PREPARE st4 FROM @date_collect_start_input_less_stmt;
    EXECUTE st4;
    DEALLOCATE PREPARE st4;
    set @date_collect_start_input_more='';
    set @date_collect_start_input_more_stmt:=concat('SELECT min(date_collect) into @date_collect_start_input_more FROM assistant_dba.',@table_name_store,' where object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,''' and date_collect>= ''',@date_collect_start_input,''';');
    PREPARE st5 FROM @date_collect_start_input_more_stmt;
    EXECUTE st5;
    DEALLOCATE PREPARE st5;
    set @date_collect_start_input_less_delta:=(select time_to_sec(timediff(@date_collect_start_input,@date_collect_start_input_less)));
    set @date_collect_start_input_more_delta:=(select time_to_sec(timediff(@date_collect_start_input_more,@date_collect_start_input)));
    if @date_collect_start_input_less_delta<=@date_collect_start_input_more_delta then
		set @date_collect_start_input_new=@date_collect_start_input_less;
    else 
		set @date_collect_start_input_new=@date_collect_start_input_more;
    end if;
end if; 
if @check_date_collect_start_input=@date_collect_start_input
	then set @msg:=concat(cast(@date_collect_start_input as char),' exist');
    set @date_collect_start_input_new=@date_collect_start_input;
end if; 
set @date_start_beg_srv='';
set @date_start_beg_srv_stmt:=concat('SELECT distinct date_start into @date_start_beg_srv FROM assistant_dba.',@table_name_store,' where object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,''' and date_collect= ''',@date_collect_start_input_new,''';');
    PREPARE st5_1 FROM @date_start_beg_srv_stmt;
    EXECUTE st5_1;
    DEALLOCATE PREPARE st5_1;
/*This information is for debugging.
select 'datetime start';
select @msg as 'message', @date_collect_start_input_less, 
	@date_collect_start_input_less_delta, 
    @date_collect_start_input, 
    @date_collect_start_input_more,  
    @date_collect_start_input_more_delta,
    @date_collect_start_input_new,
    @date_start_beg_srv;
*/    
set @check_date_collect_finish_input='';
set @check_date_collect_finish_input_stmt = concat('select distinct date_collect into @check_date_collect_finish_input from assistant_dba.',@table_name_store,' where object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,''' and date_collect=''',@date_collect_finish_input,''';');
	PREPARE st6 FROM @check_date_collect_finish_input_stmt;
    EXECUTE st6;
    DEALLOCATE PREPARE st6;
if @check_date_collect_finish_input is null or @check_date_collect_finish_input='' or @check_date_collect_finish_input=' '
	then 
    set @msg:=concat(cast(@date_collect_finish_input as char),' doesn''t exist');
    set @date_collect_finish_input_less='';
    set @date_collect_finish_input_less_stmt:=concat('SELECT max(date_collect) into @date_collect_finish_input_less FROM assistant_dba.',@table_name_store,' where object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,''' and date_collect	<= ''',@date_collect_finish_input,''';');
    PREPARE st7 FROM @date_collect_finish_input_less_stmt;
    EXECUTE st7;
    DEALLOCATE PREPARE st7;
    set @date_collect_finish_input_more='';
    set @date_collect_finish_input_more_stmt:=concat('SELECT min(date_collect) into @date_collect_finish_input_more FROM assistant_dba.',@table_name_store,' where object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,''' and date_collect>= ''',@date_collect_finish_input,''';');
    PREPARE st8 FROM @date_collect_finish_input_more_stmt;
    EXECUTE st8;
    DEALLOCATE PREPARE st8;
    #I check that finish date and time exists in the teble.
    if @date_collect_finish_input_more is null or @date_collect_finish_input_more='' or @date_collect_finish_input_more=' 'then
		set @date_collect_finish_input_more = @date_collect_finish_input_less;
    end if;    
    set @date_collect_finish_input_less_delta:=(select time_to_sec(timediff(@date_collect_finish_input,@date_collect_finish_input_less)));
    set @date_collect_finish_input_more_delta:=(select time_to_sec(timediff(@date_collect_finish_input_more,@date_collect_finish_input)));
    if @date_collect_finish_input_less_delta<=@date_collect_finish_input_more_delta then
		set @date_collect_finish_input_new=@date_collect_finish_input_less;
    else 
		set @date_collect_finish_input_new=@date_collect_finish_input_more;
    end if;
    if @date_collect_finish_input_less_delta=@date_collect_finish_input_more_delta then
		set @date_collect_finish_input_new=@date_collect_finish_input_less;
    end if;    
end if; 
if @check_date_collect_finish_input=@date_collect_finish_input
	then set @msg:=concat(cast(@date_collect_finish_input as char),' exist');
    set @date_collect_finish_input_new=@date_collect_finish_input;
end if; 

set @date_start_fin_srv='';
set @date_start_fin_srv_stmt:=concat('SELECT distinct date_start into @date_start_fin_srv FROM assistant_dba.',@table_name_store,' where object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,''' and date_collect= ''',@date_collect_finish_input_new,''';');
    PREPARE st8_1 FROM @date_start_fin_srv_stmt;
    EXECUTE st8_1;
    DEALLOCATE PREPARE st8_1;

/*This information is for debugging..
select 'datetime finish';
select @msg as 'message', @date_collect_finish_input_less, 
	@date_collect_finish_input_less_delta, 
    @date_collect_finish_input, 
    @date_collect_finish_input_more,  
    @date_collect_finish_input_more_delta,
    @date_collect_finish_input_new,
    @date_start_fin_srv;
*/    

If time_to_sec(timediff(@date_collect_start_input_new,@date_collect_finish_input_new))=0 then
	select concat('You need to change your boundary values ''',@date_collect_start_input,''' and ''',@date_collect_finish_input,''' because after the process of searching for the boundary values,') as msg_error
    union all
    select concat('the procedure found that the values of the date and time of the start and the date and time of the finish were equal.') as msg_error
    union all
    select 'This may indicate that your database server was not running during the specified interval, or the store table doesn''t have values in this interval.' as msg_error
    union all
    select concat('The procedure found the following boundary values instead of  ''',@date_collect_start_input,''' : ''',@date_collect_start_input_new,''', ')  as msg_error
    union all
    select concat('and instead of  ''',@date_collect_finish_input,''' : ''',@date_collect_finish_input_new,'''.') as msg_error;
    signal speciality set message_text = @error_datetime_interval;
end if;

#If, in your settings, the date and time of start and the date and time of end are in the same time interval as the database server was started.
if time_to_sec(timediff(@date_start_beg_srv,@date_start_fin_srv))=0 then
	set @drop_temptbl_good:=concat('drop  table if exists assistant_dba.',@table_name_store_tmp,'; ');
    PREPARE st8_2 FROM @drop_temptbl_good;
    EXECUTE st8_2;
    DEALLOCATE PREPARE st8_2;
	set @create_temptbl_good:=concat('create  table assistant_dba.',@table_name_store_tmp,' (id int(10) NOT NULL AUTO_INCREMENT, object_type varchar(64) NOT NULL, object_schema varchar(64) NOT NULL, object_name varchar(64) NOT NULL, count_star bigint(20) NOT NULL, count_read bigint(20) NOT NULL,  count_write bigint(20) NOT NULL, count_fetch bigint(20) NOT NULL, count_insert bigint(20) NOT NULL, count_update bigint(20) NOT NULL, count_delete bigint(20) NOT NULL, date_collect datetime NOT NULL, date_start datetime NOT NULL, comment_my varchar(500) NULL, PRIMARY KEY (id)); ');
    PREPARE st8_3 FROM @create_temptbl_good;
    EXECUTE st8_3;
    DEALLOCATE PREPARE st8_3;
    set @date_1_stmt:=concat('insert into assistant_dba.',@table_name_store_tmp,' (object_type, object_schema, object_name, count_star, count_read,
		count_write, count_fetch, count_insert, count_update, count_delete, date_collect, date_start, comment_my)
		select object_type, object_schema, object_name, count_star, count_read, count_write, count_fetch, count_insert,
		count_update, count_delete, date_collect, date_start, ''These are the values of the DML operations on the starting date and time of the interval and the finishing date and time of the interval.''  FROM assistant_dba.',@table_name_store,' where (date_collect=''',@date_collect_start_input_new,''' or date_collect=''',@date_collect_finish_input_new,''') and 
		object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,''';');
    PREPARE st9 FROM @date_1_stmt;
    EXECUTE st9;
    DEALLOCATE PREPARE st9;
    set @date_2_stmt:=concat('select ''These are the values of the DML operations on the starting date and time of the interval and the finishing date and time of the interval.''  as description,
							count_star, count_read, count_write, count_fetch, count_insert, count_update, count_delete, '' '' as ''delta_sec'',
                            date_collect, date_start
							from assistant_dba.',@table_name_store_tmp,'
                            union all
							select ''This is the delta of the values of the DML operations on the starting date and time of the interval and the finishing date and time of the interval, with the number of seconds in the interval.'', 
                            t2.count_star-t1.count_star, t2.count_read-t1.count_read, t2.count_write-t1.count_write, 
                            t2.count_fetch-t1.count_fetch, t2.count_insert-t1.count_insert, t2.count_update-t1.count_update, 
                            t2.count_delete-t1.count_delete, time_to_sec(timediff (t2.date_collect,t1.date_collect)) ,
							''9998-12-12 23:59:59'',t1.date_start
							FROM assistant_dba.',@table_name_store,' t1 
							join assistant_dba.',@table_name_store,' t2
							on  t2.object_schema = t1.object_schema and t2.object_name = t1.object_name 
							and t1.object_schema=''',@schema_name_my, ''' and t1.object_name=''',@table_name_my,'''
							and t1.date_collect=''',@date_collect_start_input_new,''' and t2.date_collect=''',@date_collect_finish_input_new,'''
                            union all
							select ''This is the average value of the DML operations per second between the starting date and time of the interval and the finishing date and time of the interval.'' as description, 
                            (t2.count_star-t1.count_star)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_star,
							(t2.count_read-t1.count_read)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_read, 
                            (t2.count_write-t1.count_write)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_write, 
                            (t2.count_fetch-t1.count_fetch)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_fetch, 
                            (t2.count_insert-t1.count_insert)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_insert,
							(t2.count_update-t1.count_update)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_update, 
                            (t2.count_delete-t1.count_delete)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_delete, 
                            '''' ,
							''9999-12-12 23:59:59'', t1.date_start 
                            FROM assistant_dba.',@table_name_store_tmp,' t1 
							join assistant_dba.',@table_name_store_tmp,' t2
							on t2.date_start=t1.date_start and t2.date_collect>t1.date_collect
                            order by 11, 10	;');
    PREPARE st10 FROM @date_2_stmt;
    EXECUTE st10;
    DEALLOCATE PREPARE st10;
end if;    

#If, in your settings, the date and time of start and the date and time of end are in a different time interval than when the database server was started.
if time_to_sec(timediff(@date_start_beg_srv,@date_start_fin_srv))<>0 then
	set @drop_temptbl_good:=concat('drop  table if exists assistant_dba.',@table_name_store_tmp,'; ');
    PREPARE st12 FROM @drop_temptbl_good;
    EXECUTE st12;
    DEALLOCATE PREPARE st12;
	set @create_temptbl_good:=concat('create  table assistant_dba.',@table_name_store_tmp,' (id int(10) NOT NULL AUTO_INCREMENT, 
									object_type varchar(64) NOT NULL, object_schema varchar(64) NOT NULL, object_name varchar(64) NOT NULL, 
                                    count_star bigint(20) NOT NULL, count_read bigint(20) NOT NULL,  count_write bigint(20) NOT NULL, 
                                    count_fetch bigint(20) NOT NULL, count_insert bigint(20) NOT NULL, count_update bigint(20) NOT NULL, 
                                    count_delete bigint(20) NOT NULL, date_collect datetime NOT NULL, date_start datetime NOT NULL, 
                                    comment_my varchar(500) NULL, PRIMARY KEY (id)); ');
    PREPARE st13 FROM @create_temptbl_good;
    EXECUTE st13;
    DEALLOCATE PREPARE st13;
	set @drop_temptbl_good:=concat('drop  table if exists assistant_dba.',@table_name_store_time_start_srv_tmp,'; ');
    PREPARE st17 FROM @drop_temptbl_good;
    EXECUTE st17;
    DEALLOCATE PREPARE st17;
	set @create_temptbl_good:=concat('create  table assistant_dba.',@table_name_store_time_start_srv_tmp,' (id int(10) NOT NULL AUTO_INCREMENT, date_start datetime NOT NULL, min_date_collect datetime NOT NULL, max_date_collect datetime NOT NULL, PRIMARY KEY (id)); ');
    PREPARE st18 FROM @create_temptbl_good;
    EXECUTE st18;
    DEALLOCATE PREPARE st18;
    set @date_19_stmt:=concat('insert into assistant_dba.',@table_name_store_time_start_srv_tmp,' (date_start, min_date_collect, max_date_collect)
		select date_start, min(date_collect) as min_date_collect, max(date_collect) as max_date_collect 
		FROM assistant_dba.',@table_name_store,'
		where date_start in (
			select distinct date_start 
			FROM assistant_dba.',@table_name_store,'
			where (date_collect>=''',@date_collect_start_input_new,''' and date_collect<=''',@date_collect_finish_input_new,''') and 
					object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,''')
			and 
			object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,'''
			group by date_start
            having min(date_collect) != max(date_collect);');
    PREPARE st19 FROM @date_19_stmt;
    EXECUTE st19;
    DEALLOCATE PREPARE st19;
    set @date_20_stmt:=concat('insert into assistant_dba.',@table_name_store_tmp,' (object_type, object_schema, object_name, count_star,
								count_read, count_write, count_fetch, count_insert, count_update, count_delete, date_collect, date_start)
								select t1.object_type, t1.object_schema, t1.object_name, t1.count_star, t1.count_read,
								t1.count_write, t1.count_fetch, t1.count_insert, t1.count_update, t1.count_delete, t1.date_collect, t1.date_start
								from assistant_dba.',@table_name_store,' t1
								join (select date_start, min(date_collect) as min_date_collect, max(date_collect) as max_date_collect 
									  FROM assistant_dba.',@table_name_store,'
									  where date_start in (
										select distinct date_start 
										FROM assistant_dba.',@table_name_store,'
										where (date_collect>=''',@date_collect_start_input_new,''' and date_collect<=''',@date_collect_finish_input_new,''') and 
										object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,''') and
										object_schema=''',@schema_name_my,''' and object_name=''',@table_name_my,'''
										group by date_start
										having min(date_collect) != max(date_collect)) t2
								on t2.date_start=t1.date_start and (t2.min_date_collect=t1.date_collect or t2.max_date_collect=t1.date_collect)
								where t1.object_schema=''',@schema_name_my,''' and t1.object_name=''',@table_name_my,''';');
	PREPARE st20 FROM @date_20_stmt;
    EXECUTE st20;
    DEALLOCATE PREPARE st20;
    set @date_21_stmt:=concat('select ''These are the values of the DML operations on the starting date and time of the interval and the finishing date and time of the interval.''  as description,
							count_star, count_read,
                            count_write, count_fetch, count_insert, count_update, count_delete, '' '' as ''delta_sec'',
                            date_collect, date_start
							from assistant_dba.',@table_name_store_tmp,'
                            union all
							select ''This is the delta of the values of the DML operations on the starting date and time of the interval and the finishing date and time of the interval, with the number of seconds in the interval.'' as description, 
                            t2.count_star-t1.count_star as delta_count_star,
							t2.count_read-t1.count_read as delta_count_read, t2.count_write-t1.count_write as delta_count_write, 
                            t2.count_fetch-t1.count_fetch as delta_count_fetch, t2.count_insert-t1.count_insert as delta_count_insert,
							t2.count_update-t1.count_update as delta_count_update, t2.count_delete-t1.count_delete as delta_count_delete, 
                            time_to_sec(timediff (t2.date_collect,t1.date_collect)) as ''delta_sec'' ,
							''9998-12-12 23:59:59'', t1.date_start  
                            FROM assistant_dba.',@table_name_store_tmp,' t1 
							join assistant_dba.',@table_name_store_tmp,' t2
							on t2.date_start=t1.date_start and t2.date_collect>t1.date_collect
                            union all
							select ''This is the average value of the DML operations per second between the starting date and time of the interval and the finishing date and time of the interval.'' as description, 
                            (t2.count_star-t1.count_star)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_star,
							(t2.count_read-t1.count_read)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_read, 
                            (t2.count_write-t1.count_write)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_write, 
                            (t2.count_fetch-t1.count_fetch)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_fetch, 
                            (t2.count_insert-t1.count_insert)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_insert,
							(t2.count_update-t1.count_update)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_update, 
                            (t2.count_delete-t1.count_delete)/time_to_sec(timediff (t2.date_collect,t1.date_collect)) as delta_count_delete, 
                            '''' ,
							''9999-12-12 23:59:59'', t1.date_start 
                            FROM assistant_dba.',@table_name_store_tmp,' t1 
							join assistant_dba.',@table_name_store_tmp,' t2
							on t2.date_start=t1.date_start and t2.date_collect>t1.date_collect
                            order by 11, 10;');
	PREPARE st21 FROM @date_21_stmt;
    EXECUTE st21;
    DEALLOCATE PREPARE st21;  

end if; 

set @drop_temptbl_srv_tmp:=concat('drop  table if exists assistant_dba.',@table_name_store_time_start_srv_tmp,'; ');
PREPARE st200 FROM @drop_temptbl_srv_tmp;
EXECUTE st200;
DEALLOCATE PREPARE st200;

set @drop_temptbl_tmp:=concat('drop  table if exists assistant_dba.',@table_name_store_tmp,'; ');
PREPARE st201 FROM @drop_temptbl_tmp;
EXECUTE st201;
DEALLOCATE PREPARE st201;
 
end$$
DELIMITER ;

