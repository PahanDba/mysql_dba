create database if not exists assistant_dba;
drop procedure if exists  assistant_dba.`monitoring_of_pressure_check_pct_per_core_mysql`;
DELIMITER $$
CREATE PROCEDURE if not exists  assistant_dba.`monitoring_of_pressure_check_pct_per_core_mysql`(in sch_name varchar (64), tbl_name varchar (64))
begin
declare var_sch_name_top varchar(64);
declare var_tbl_name_top varchar(64);
# call assistant_dba.monitoring_of_pressure_check_pct_per_core_mysql ('assistant_dba_temp','top_20260405_203042');
set @sql_cpuid_gt_100=concat('
with cpuid_gt_100 
as(
SELECT sum(cpu_pct) as sum_cpu_pct,  cpuid 
FROM ',sch_name,'.',tbl_name,'
group by cpuid)
update ',sch_name,'.',tbl_name,'
set collision = ''YES''
where cpuid in (
select cpuid  
from cpuid_gt_100
where sum_cpu_pct>100)');

prepare dynamic_sql_cpuid_gt_100 from @sql_cpuid_gt_100;
execute dynamic_sql_cpuid_gt_100;
deallocate prepare dynamic_sql_cpuid_gt_100;  
end$$
DELIMITER ;


drop procedure if exists  assistant_dba.`monitoring_of_pressure_insert_mysql`;
DELIMITER $$
CREATE PROCEDURE if not exists  assistant_dba.`monitoring_of_pressure_insert_mysql`()
begin
declare var_sch_name_mysql varchar(64);
declare var_tbl_name_mysql varchar(64);
declare var_sch_name_top varchar(64);
declare var_tbl_name_top varchar(64);
declare done int default 0;
# call assistant_dba.`monitoring_of_pressure_insert_mysql`();

declare tables_mysql_top_cur cursor for 
select sch_mysql, tbl_mysql, sch_top, tbl_top #,state_work 
from assistant_dba_temp.monitoring_of_pressure_check_table_results_mysql_top
where state_work='for_processing';    


DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
	set done=1;
DECLARE CONTINUE HANDLER FOR SQLSTATE '23000'
	set done=1;
SET sql_log_bin = 0; 
#select count(*) into @row_number_tbl from right_list;    
#select @row_number_tbl;
set @sql_create_tbl_store_history= concat(
'create table if not exists assistant_dba.monitoring_of_pressure_history (
`id` bigint unsigned NOT NULL AUTO_INCREMENT,
`THREAD_ID` bigint unsigned NOT NULL,
`PROCESSLIST_ID` bigint unsigned DEFAULT NULL,
`PROCESSLIST_USER` varchar(32) DEFAULT NULL,
`PROCESSLIST_HOST` varchar(255) CHARACTER SET ascii COLLATE ascii_general_ci DEFAULT NULL,
`PROCESSLIST_DB` varchar(64) DEFAULT NULL,
`PROCESSLIST_COMMAND` varchar(16) DEFAULT NULL ,
`PROCESSLIST_TIME` bigint DEFAULT NULL ,
`PROCESSLIST_INFO` longtext, 
`THREAD_OS_ID` bigint unsigned NOT NULL,
`TOTAL_MEMORY` bigint unsigned NOT NULL,
`MAX_TOTAL_MEMORY` bigint unsigned NOT NULL,
`tid` int NOT NULL,
`cpu_pct` decimal(6,2) NOT NULL,
`collision` char(3) NOT NULL,
`command_top` longtext,
`cpuid` int not null,
`cpu_count` int not null,
`date_collect` datetime NOT NULL,
PRIMARY KEY (id),
 KEY (`THREAD_OS_ID`,`date_collect`),
 index ix_date_collect (`date_collect`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;');
# select @sql_create_tbl_store_history;
prepare dynamic_sql_create_tbl_store_history from @sql_create_tbl_store_history;
execute dynamic_sql_create_tbl_store_history;
deallocate prepare dynamic_sql_create_tbl_store_history;
   
open tables_mysql_top_cur;
	while done=0 do
		fetch tables_mysql_top_cur into var_sch_name_mysql, var_tbl_name_mysql, var_sch_name_top, var_tbl_name_top;
        if done=0 then
			set @sql_insert_tbl:=concat('insert into assistant_dba.monitoring_of_pressure_history (\`THREAD_ID\`, \`PROCESSLIST_ID\`, \`PROCESSLIST_USER\`, \`PROCESSLIST_HOST\`, \`PROCESSLIST_DB\`,
			\`PROCESSLIST_COMMAND\`, \`PROCESSLIST_TIME\`, \`PROCESSLIST_INFO\`, \`THREAD_OS_ID\`, \`TOTAL_MEMORY\`, \`MAX_TOTAL_MEMORY\`,
			\`tid\`, \`cpu_pct\`, \`collision\`, \`command_top\`, \`cpuid\`, \`cpu_count\`, \`date_collect\`)
			select t_mysql.\`THREAD_ID\`, t_mysql.\`PROCESSLIST_ID\`, t_mysql.\`PROCESSLIST_USER\`, t_mysql.\`PROCESSLIST_HOST\`, t_mysql.\`PROCESSLIST_DB\`, t_mysql.\`PROCESSLIST_COMMAND\`,
			t_mysql.\`PROCESSLIST_TIME\`, t_mysql.\`PROCESSLIST_INFO\`, t_mysql.\`THREAD_OS_ID\`, t_mysql.\`TOTAL_MEMORY\`,
			t_mysql.\`MAX_TOTAL_MEMORY\`, t_top.\`tid\`, t_top.\`cpu_pct\`, t_top.\`collision\`, t_top.\`command_top\`, t_top.\`cpuid\`,  t_top.\`cpu_count\`, t_mysql.\`date_collect\`
			from \`',var_sch_name_mysql,'\`.\`',var_tbl_name_mysql,'\` t_mysql
			join \`',var_sch_name_top,'\`.\`',var_tbl_name_top,'\` t_top
			on t_top.\`tid\`=t_mysql.\`THREAD_OS_ID\` ;');
			# select @sql_insert_tbl;
			prepare dynamic_sql_insert_tbl from @sql_insert_tbl;
			execute dynamic_sql_insert_tbl;
			deallocate prepare dynamic_sql_insert_tbl;        

			set @sql_drop_tbl_mysql:=concat('drop table if exists \`',var_sch_name_mysql,'\`.\`',var_tbl_name_mysql,'\`;');
			#select @sql_drop_tbl_mysql;
			prepare dynamic_sql_drop_tbl_mysql from @sql_drop_tbl_mysql;
			execute dynamic_sql_drop_tbl_mysql;
			deallocate prepare dynamic_sql_drop_tbl_mysql;        

			set @sql_drop_tbl_top:=concat('drop table if exists \`',var_sch_name_top,'\`.\`',var_tbl_name_top,'\`;');
			#select @sql_drop_tbl_ps;
			prepare dynamic_sql_drop_tbl_top from @sql_drop_tbl_top;
			execute dynamic_sql_drop_tbl_top;
			deallocate prepare dynamic_sql_drop_tbl_top;  
			delete from  assistant_dba_temp.monitoring_of_pressure_check_table_results_mysql_top
			where sch_mysql=var_sch_name_mysql and tbl_mysql=var_tbl_name_mysql and sch_top=var_sch_name_top and tbl_top=var_tbl_name_top;
        end if;
	end while;
close tables_mysql_top_cur;

end$$
DELIMITER ;


drop procedure if exists  assistant_dba.`monitoring_of_pressure_nearly_real_time_mysql`;
DELIMITER $$
CREATE PROCEDURE if not exists  assistant_dba.`monitoring_of_pressure_nearly_real_time_mysql`()
begin
# call assistant_dba.`monitoring_of_pressure_nearly_real_time_mysql`();
declare speciality condition for sqlstate '45000';
SET sql_log_bin = 0; 
select count(*) into @in_check_exists_adt from  information_schema.tables where TABLE_SCHEMA='assistant_dba' and TABLE_NAME='monitoring_of_pressure_history';
if @in_check_exists_adt<1  then
		select 'The table assistant_dba.monitoring_of_pressure_history doesn''t exists. The procedure won''t work.' as msg;
		signal speciality set message_text= 'The table assistant_dba.monitoring_of_pressure_history doesn''t exists. The procedure won''t work.';
end if;

SELECT RPAD(THREAD_ID,(length('THREAD_ID')),' ') as 'THREAD_ID',
RPAD(PROCESSLIST_ID,(length('PROCESSLIST_ID')),' ') as 'PLIST_ID',
RPAD(PROCESSLIST_USER,(length('PLIST_USER')),' ') as 'PLIST_USER',
RPAD(PROCESSLIST_HOST,(length('PLIST_HOST')),' ') as 'PLIST_HOST',
RPAD(PROCESSLIST_DB,(length('PROCESSLIST_DB')),' ') as 'PLIST_DB',
RPAD(PROCESSLIST_TIME,(length('PLIST_TIME')),' ') as 'PLIST_TIME',
RPAD(TOTAL_MEMORY,(length('TOTAL_MEMORY')),' ') as 'TOTAL_MEMORY',
cpu_pct,
RPAD(collision,(length('collision')),' ') as 'collision',
RPAD(concat(cpuid,' of ', cpu_count),(length('cpuid')+7),' ') as 'cpu       ' ,
date_collect as 'date_collect       ',
RPAD(PROCESSLIST_COMMAND,(length('PLIST_COMMAND')),' ') as 'PLIST_COMMAND',
PROCESSLIST_INFO
FROM assistant_dba.monitoring_of_pressure_history
where date_collect=(select max(date_collect) from assistant_dba.monitoring_of_pressure_history) and cpu_pct>0;
end$$
DELIMITER ;



# This procedure involves checking and preparing tables for the following work.
drop PROCEDURE if exists assistant_dba.monitoring_of_pressure_check_prepare_tables_mysql_top;
DELIMITER $$
CREATE PROCEDURE assistant_dba.monitoring_of_pressure_check_prepare_tables_mysql_top()
BEGIN
# call assistant_dba.monitoring_of_pressure_check_prepare_tables_mysql_top();
declare speciality condition for sqlstate '45000';
SET sql_log_bin = 0; 
select count(*) into @in_check_exists_adt from  information_schema.SCHEMATA where SCHEMA_NAME='assistant_dba_temp';
if @in_check_exists_adt<1  then
		create database assistant_dba_temp;
end if;
select count(*) into @in_check_exists_adt from  information_schema.tables where TABLE_SCHEMA='assistant_dba_temp' and TABLE_NAME='monitoring_of_pressure_check_table_results_mysql_top';
#select @in_check_exists_adt_ctrmt;
if @in_check_exists_adt<1  then
	create table assistant_dba_temp.monitoring_of_pressure_check_table_results_mysql_top (
	`id` bigint unsigned NOT NULL AUTO_INCREMENT,
	`sch_mysql` varchar(64) DEFAULT NULL,
	`tbl_mysql` varchar(64) DEFAULT NULL,
	`sch_top` varchar(64) DEFAULT NULL,
	`tbl_top` varchar(64) DEFAULT NULL,
	`state_work` char (20) DEFAULT NULL,
    `date_collect` datetime,
	PRIMARY KEY (id)
	);
end if;


insert into assistant_dba_temp.monitoring_of_pressure_check_table_results_mysql_top (`sch_mysql`, 	`tbl_mysql`, `sch_top`, `tbl_top`, 	`state_work`,`date_collect`)
select t_mysql.TABLE_SCHEMA as sch_mysql, t_mysql.TABLE_NAME as tbl_mysql, t_top.TABLE_SCHEMA as sch_top, t_top.TABLE_NAME as tbl_top,
case 
when  t_mysql.TABLE_SCHEMA is null then 'to_drop'
when t_mysql.TABLE_NAME is null then 'to_drop'
when t_top.TABLE_SCHEMA is null then 'to_drop'
when t_top.TABLE_NAME is null then 'to_drop'
else 'for_processing'
end as state_work, 
concat(left(right(t_mysql.TABLE_NAME,15),4),'-',substring(right(t_mysql.TABLE_NAME,15),5,2),'-',substring(right(t_mysql.TABLE_NAME,15),7,2),' ',substring(right(t_mysql.TABLE_NAME,15),10,2),':',substring(right(t_mysql.TABLE_NAME,15),12,2),':',
substring(right(t_mysql.TABLE_NAME,15),14,2)) as date_collect
from 
(SELECT TABLE_SCHEMA, TABLE_NAME
FROM information_schema.tables
where TABLE_SCHEMA='assistant_dba_temp' and TABLE_NAME like 'mysql_%') as t_mysql
left join
(SELECT TABLE_SCHEMA, TABLE_NAME
FROM information_schema.tables
where TABLE_SCHEMA='assistant_dba_temp' and TABLE_NAME like 'top_%') as t_top
on right(t_top.TABLE_NAME,15)=right(t_mysql.TABLE_NAME,15)
where t_mysql.TABLE_NAME not in (select tbl_mysql from assistant_dba_temp.monitoring_of_pressure_check_table_results_mysql_top where tbl_mysql is not null) 
union 
select t_mysql.TABLE_SCHEMA as sch_mysql, t_mysql.TABLE_NAME as tbl_mysql, t_top.TABLE_SCHEMA as sch_top, t_top.TABLE_NAME as tbl_top,
case 
when  t_mysql.TABLE_SCHEMA is null then 'to_drop'
when t_mysql.TABLE_NAME is null then 'to_drop'
when t_top.TABLE_SCHEMA is null then 'to_drop'
when t_top.TABLE_NAME is null then 'to_drop'
else 'for_processing'
end as state_work, 
concat(left(right(t_top.TABLE_NAME,15),4),'-',substring(right(t_top.TABLE_NAME,15),5,2),'-',substring(right(t_top.TABLE_NAME,15),7,2),' ',substring(right(t_top.TABLE_NAME,15),10,2),':',substring(right(t_top.TABLE_NAME,15),12,2),':',
substring(right(t_top.TABLE_NAME,15),14,2)) as date_collect
from 
(SELECT TABLE_SCHEMA, TABLE_NAME
FROM information_schema.tables
where TABLE_SCHEMA='assistant_dba_temp' and TABLE_NAME like 'mysql_%') as t_mysql
right join
(SELECT TABLE_SCHEMA, TABLE_NAME
FROM information_schema.tables
where TABLE_SCHEMA='assistant_dba_temp' and TABLE_NAME like 'top_%') as t_top
on right(t_top.TABLE_NAME,15)=right(t_mysql.TABLE_NAME,15)
where t_top.TABLE_NAME not in (select tbl_top from assistant_dba_temp.monitoring_of_pressure_check_table_results_mysql_top where tbl_top is not null) ;
END$$                  
DELIMITER ;          


drop procedure if exists  assistant_dba.`monitoring_of_pressure_maintenance`;
DELIMITER $$
CREATE PROCEDURE if not exists  assistant_dba.`monitoring_of_pressure_maintenance`(day_clear int)
begin
#call assistant_dba.`monitoring_of_pressuremaintenance`(13);
declare var_sch_name_to_drop varchar(64);
declare var_tbl_to_drop varchar(64);
declare done int default 0;
declare tables_mysql_top_cur cursor for 
select sch_mysql, tbl_mysql 
from assistant_dba_temp.monitoring_of_pressure_check_table_results_mysql_top
where state_work='to_drop' and sch_mysql is not null and  tbl_mysql is not null 
union all
select sch_top, tbl_top
from assistant_dba_temp.monitoring_of_pressure_check_table_results_mysql_top
where state_work='to_drop' and sch_top is not null and  tbl_top is not null ;     
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
	set done=1;
DECLARE CONTINUE HANDLER FOR SQLSTATE '23000'
	set done=1;
SET sql_log_bin = 0; 
open tables_mysql_top_cur;
	while done=0 do
		fetch tables_mysql_top_cur into var_sch_name_to_drop, var_tbl_to_drop;
        if done=0 then
			set @sql_drop_tbl_mysql_top:=concat('drop table if exists \`',var_sch_name_to_drop,'\`.\`',var_tbl_to_drop,'\`;');
			#select @sql_drop_tbl_mysql;
			prepare dynamic_sql_drop_tbl_mysql_top from @sql_drop_tbl_mysql_top;
			execute dynamic_sql_drop_tbl_mysql_top;
			deallocate prepare dynamic_sql_drop_tbl_mysql_top;        
        end if;
	end while;
close tables_mysql_top_cur;

set @sql_delete_data:=concat('delete from  assistant_dba.monitoring_of_pressure_history 
where date_collect<=now()- interval ',day_clear,' day ;');
prepare dynamic_sql_delete_data from @sql_delete_data;
execute dynamic_sql_delete_data;
deallocate prepare dynamic_sql_delete_data; 
delete from  assistant_dba_temp.monitoring_of_pressure_check_table_results_mysql_top
where state_work='to_drop';
end$$
DELIMITER ;
