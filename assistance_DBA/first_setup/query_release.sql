############################################################
##These scripts can take information about database servers and their databases and tables
############################################################

#A list of 'alive' MySQL servers and information about them.
select ls.server_name, ls.ip, ls.connection_string, ls.alive, lst.server_type_desc, lst1.sql_type_desc, 
lms.auth_type, lms.collation_server, lms.server_id_in_cnf, lms.version,
ls.comments, lc.cluster_name, lc.cluster_description
from `assistant_dba`.`list_mysql_server` lms
join `assistant_dba`.`list_server` ls
on ls.server_id=lms.server_id
join `assistant_dba`.`list_server_type` lst
on lst.server_type_id=ls.server_type_id
join `assistant_dba`.`list_sql_type` lst1
on lst1.sql_type_id=ls.sql_type_id
join `assistant_dba`.`list_clusters` lc
on lc.cluster_id=ls.cluster_id
where ls.alive=1;

#A list MySQL servers and databases
SELECT ls.server_name, lmb.base_name
from `assistant_dba`.`list_mysql_bases` lmb
join `assistant_dba`.`list_server` ls
on ls.server_id=lmb.server_id
#where ls.server_name='any_server_name' 
order by ls.server_name, lmb.base_name;


#A list MySQL servers and databases and tables
SELECT ls.server_name, lmb.base_name,  lmt.table_name
from `assistant_dba`.`list_mysql_table` lmt
join `assistant_dba`.`list_mysql_bases` lmb
on lmb.base_id_spr=lmt.base_id_spr
join `assistant_dba`.`list_server` ls
on ls.server_id=lmb.server_id
#where ls.server_name='any_server_name' and lmb.base_name='any_schema_name'
order by ls.server_name, lmb.base_name,  lmt.table_name;

#A list MySQL servers and databases and views
SELECT ls.server_name, lmb.base_name,  lmv.table_name
from `assistant_dba`.`list_mysql_view` lmv
join `assistant_dba`.`list_mysql_bases` lmb
on lmv.base_id_spr=lmb.base_id_spr
join `assistant_dba`.`list_server` ls
on ls.server_id=lmb.server_id
#where ls.server_name='any_server_name'
order by lmv.table_name;

#A list MySQL servers and databases and procedures
SELECT ls.server_name, lmb.base_name,  lmr.routine_name
from `assistant_dba`.`list_mysql_routine` lmr
join `assistant_dba`.`list_mysql_bases` lmb
on lmr.base_id_spr=lmb.base_id_spr
join `assistant_dba`.`list_server` ls
on ls.server_id=lmb.server_id
#where ls.server_name='any_server_name'
order by lmr.routine_name;


#A list MySQL servers and databases and procedures and views and tables with type object
SELECT ls.server_name, lmb.base_name,  lmt.table_name as name_object, 'table' as type_object
from `assistant_dba`.`list_mysql_table` lmt
join `assistant_dba`.`list_mysql_bases` lmb
on lmb.base_id_spr=lmt.base_id_spr
join `assistant_dba`.`list_server` ls
on ls.server_id=lmb.server_id
#where ls.server_name='any_server_name' #and lmb.base_name='any_schema_name'
union all
SELECT ls.server_name, lmb.base_name,  lmv.table_name as name_object, 'view' as type_object
from `assistant_dba`.`list_mysql_view` lmv
join `assistant_dba`.`list_mysql_bases` lmb
on lmv.base_id_spr=lmb.base_id_spr
join `assistant_dba`.`list_server` ls
on ls.server_id=lmb.server_id
#where ls.server_name='any_server_name' #and lmb.base_name='any_schema_name'
union all
SELECT ls.server_name, lmb.base_name,  lmr.routine_name as name_object, routine_type as type_object
from `assistant_dba`.`list_mysql_routine` lmr
join `assistant_dba`.`list_mysql_bases` lmb
on lmr.base_id_spr=lmb.base_id_spr
join `assistant_dba`.`list_server` ls
on ls.server_id=lmb.server_id
#where ls.server_name='any_server_name' #and lmb.base_name='any_schema_name'
order by server_name, base_name, name_object, type_object;



#A list MySQL servers and databases and tables and size tables with different filters
SELECT ls.server_name, lmb.base_name,  lmt.table_name,   
hmt.table_rows, hmt.data_mb, hmt.index_mb, hmt.unsed_mb, hmt.data
FROM `assistant_dba`.`history_mysql_table` hmt
join `assistant_dba`.`list_mysql_table` lmt
on lmt.table_id_spr=hmt.table_id_spr
join `assistant_dba`.`list_mysql_bases` lmb
on lmb.base_id_spr=lmt.base_id_spr
join `assistant_dba`.`list_server` ss
on ls.server_id=lmb.server_id
#where data=curdate() and ls.server_name='server_name'
order by ls.server_name, lmb.base_name,  lmt.table_name;

#Calculateing count values in table hystory  databases and tables and size tables with different filters
SELECT count(*) 
FROM `assistant_dba`.`history_mysql_table` fmt
join `assistant_dba`.`list_mysql_table` smt
on smt.table_id_spr=fmt.table_id_spr
join `assistant_dba`.`list_mysql_bases` smb
on smb.base_id_spr=smt.base_id_spr
join `assistant_dba`.`list_server` ss
on ss.server_id=smb.server_id;
#where data=curdate() and ss.server_name='server_name';

#Dates in table histiry 
select distinct(fmt.data) FROM `assistant_dba`.`history_mysql_table` fmt
join `assistant_dba`.`list_mysql_table` smt
on smt.table_id_spr=fmt.table_id_spr
join `assistant_dba`.`list_mysql_bases` smb
on smb.base_id_spr=smt.base_id_spr
join `assistant_dba`.`list_server` ss
on ss.server_id=smb.server_id
#where ss.server_name='server_name'
order by fmt.data desc;


#A list MySQL servers and global variables with different filters
SELECT ss.server_name, smgv.var_name, #fmt.table_id_spr,   
fmgv.variable_value, fmgv.data
FROM `assistant_dba`.`history_mysql_global_var` fmgv
join `assistant_dba`.`list_mysql_glob_var` smgv
on smgv.var_id_spr=fmgv.var_id_spr
join `assistant_dba`.`list_server` ss
on ss.server_id=smgv.server_id
#where fmgv.data=curdate() and ss.server_name='server_name'
order by ss.server_name, smgv.var_name ;


#Calculating count values global variables with different filters
SELECT count(*)
FROM `assistant_dba`.`history_mysql_global_var` fmgv
join `assistant_dba`.`list_mysql_glob_var` smgv
on smgv.var_id_spr=fmgv.var_id_spr
join `assistant_dba`.`list_server` ss
on ss.server_id=smgv.server_id;
#where fmgv.data=curdate() and ss.server_name='server_name';

#Dates in table history of global variables with different filters
SELECT distinct(fmgv.data)
FROM `assistant_dba`.`history_mysql_global_var` fmgv
join `assistant_dba`.`list_mysql_glob_var` smgv
on smgv.var_id_spr=fmgv.var_id_spr
join `assistant_dba`.`list_server` ss
on ss.server_id=smgv.server_id
#where ss.server_name='server_name';
order by fmgv.data asc;

############################################################
##These scripts cab take information about 
############################################################
select * from assistant_dba.list_clusters;
select * from assistant_dba.list_server_type;
select * from assistant_dba.list_sql_type;

############################################################
##These scripts can take information about backup tasks
############################################################

SELECT * FROM `assistant_dba`.`backup_path_variable_mysql`;
select * from `assistant_dba`.`backup_task_mysql`; 
SELECT * FROM `assistant_dba`.`backup_task_log_mysql`;
SELECT * FROM `assistant_dba`.`backup_task_run_mysql`;



############################################################
##Examples
############################################################
/*
CALL `assistant_dba`.`add_new_server_type`('prod');
CALL `assistant_dba`.`add_new_sql_type`('mysql');
CALL `assistant_dba`.`add_new_cluster`('standalone','only standalone server');
CALL `assistant_dba`.`add_new_cluster`('percona cluster','percona xtradb cluster');
CALL `assistant_dba`.`add_new_server_mysql`('mysql30200', '10.10.30.200', 'mysql30200', 1, 'prod','mysql',3306, 'system assistant DBA','not add ip address','standalone');
CALL `assistant_dba`.`add_new_server_mysql`('mysql30226', '10.10.30.226', 'mysql30226', 1, 'prod','mysql',3306, 'standalone server','not add ip address','standalone');
CALL `assistant_dba`.`add_new_server_mysql`('mysql3081', '10.10.30.81', 'mysql3081', 1, 'prod','mysql',3306, 'node 1 from percona xtradb cluster','not add ip address','percona cluster');
CALL `assistant_dba`.`add_new_server_mysql`('mysql3082', '10.10.30.82', 'mysql3082', 1, 'prod','mysql',3306, 'node 2 from percona xtradb cluster','not add ip address','percona cluster');
CALL `assistant_dba`.`add_new_server_mysql`('mysql3083', '10.10.30.83', 'mysql3083', 1, 'prod','mysql',3306, 'node 3 from percona xtradb cluster','not add ip address','percona cluster');


CALL `assistant_dba`.`add_backup_path_variable_mysql`('mysql30226', '/var/lib/smuggler30226', '10.10.30.210', 'smuggler30226');
call `assistant_dba`.`add_backup_task_mysql` ('mysql30226','full',1,1,1,1,1,1,0, '16:50',0,'23:00',1,10);
call `assistant_dba`.`add_backup_task_mysql` ('mysql30226','diff',1,1,1,1,1,1,0, '2:30',60,'23:00',1,10);
call `assistant_dba`.`add_backup_task_mysql` ('mysql30226','incr',1,1,1,1,1,1,0, '12:30',120,'23:00',1,10);
*/