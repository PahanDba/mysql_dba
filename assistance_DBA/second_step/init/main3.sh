#!/bin/bash
#Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#input parametrs scripts prefix in_
#sudo sed -i -e 's/\r$//' /etc/mysql/dba_scripts/init/main3.sh
#sudo chown root  /etc/mysql/dba_scripts/init/main3.sh
#sudo chmod 755  /etc/mysql/dba_scripts/init/main3.sh
recipient_mail="you@email_address"
in_server_id=$server_id
in_server_name=$server_name
in_connection_string=$connection_string 
in_ip=$ip
in_port=$port
in_conn_super_main_server=$conn_super_main_server
log_init_server=$in_server_name"_all.log"
#log_get_list_servers="01_get_list_mysqlserver.log"
log_error=$in_server_name"_error.log"
log_path_mysql_init_servername="/var/log/assistant_dba/mysql/init/"$in_server_name
#ouput file
file_list_alive_mysqlservers="list_alive_mysqlservers.txt"
file_filtered_option_server_mysql=$server_name"_options_server.txt"
file_db_list=$server_name"_db_list.txt"
file_good_db_list=$server_name"_good_db_list.txt"
file_global_var_value=$server_name"_global_var_value.txt"
file_good_global_var_value=$server_name"_good_global_var_value.txt"
file_good_global_var_value_ext=$server_name"_good_global_var_value_ext.txt"
file_db_tbl_analyze=$server_name"_db_tbl_analyze.txt"
##############begin for delete?
#block procedure and sql script
#sp_main_dir="/etc/mysql/dba_scripts/init/scripts_sql"
#sp_create_db="01_create_db.sql" !not use
#sp_create_get_filtered_option_server_mysql="02_get_filtered_option_server_mysql.sql" !not use
#sp_get_db_list="03_get_db_list.sql" !not use
##############end for delete?
#block full path logs and procedure and sql script
#path_create_db=$sp_main_dir/$sp_create_db !not use
#path_create_get_filtered_option_server_mysql=$sp_main_dir/$sp_create_get_filtered_option_server_mysql !not use
#path_create_get_db_list=$sp_main_dir/$sp_get_db_list !not use
path_file_main_log_init_server=$log_path_mysql_init_servername/$log_init_server
path_file_main_error_log_init_server=$log_path_mysql_init_servername/$log_error
path_out_filtered_option_server_mysql=$log_path_mysql_init_servername/$file_filtered_option_server_mysql
path_out_db_list=$log_path_mysql_init_servername/$file_db_list
path_out_good_db_list=$log_path_mysql_init_servername/$file_good_db_list
path_out_global_var_value=$log_path_mysql_init_servername/$file_global_var_value
path_out_good_global_var_value=$log_path_mysql_init_servername/$file_good_global_var_value
path_out_good_global_var_value_ext=$log_path_mysql_init_servername/$file_good_global_var_value_ext
path_out_db_tbl_analyze=$log_path_mysql_init_servername/$file_db_tbl_analyze
path_config_mysql_init="/etc/mysql/dba_conf/init/"
#conn string
conn_db_main="assistant_dba"
conn_db_main_temp="assistant_dba_temp"
#get name and fullname executed script
dir_path1=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)
path1=$dir_path1/$(basename "${BASH_SOURCE:-$0}")
#option trap
set -e
trap 'LAST_COMMAND=$CURRENT_COMMAND; CURRENT_COMMAND=$BASH_COMMAND;' debug 
trap 'ERROR_CODE=$?; ERROR_MESSAGE=`cat $path_file_main_error_log_init_server`; FAILED_COMMAND=$LAST_COMMAND; echo -e "Subject:The global error about collecting data on the server $server_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand before error: \"$FAILED_COMMAND\" \nfailed with message: \"$ERROR_MESSAGE \" " | /usr/sbin/sendmail $recipient_mail;' ERR INT TERM
#main script
if [  -d "$log_path_mysql_init_servername" ];  then
        rm  -r "$log_path_mysql_init_servername"
        mkdir -p "$log_path_mysql_init_servername"
else
        mkdir -p "$log_path_mysql_init_servername"
fi
echo "Begin work servername $in_server_name in $(date +"%Y%m%d %H:%M:%S")"  >  $path_file_main_log_init_server
tbl_server_name="\`mysql\`.\`tt_spr_mysql_server_"$in_server_name"\`" #variable table name with dependencies server name
################begin test for get mistake
#script create temporary table with dependencies server name dynamic
#sql_server_options=("drop temporary table if exists $tbl_server_name;
#create temporary table $tbl_server_name (
#id int not null auto_increment,
#server_id int null,
#collation_server nvarchar(255) null,
#version nvarchar(255) null,
#PRIMARY KEY (\`id\`)
#);
#insert into $tbl_server_name (server_id)
#select VARIABLE_VALUE from \`information_schema\`.\`GLOBAL_VARIABLES\` where VARIABLE_NAME in ('server_id');
#update $tbl_server_name 
#set collation_server=(select VARIABLE_VALUE from \`information_schema\`.\`GLOBAL_VARIABLES\` where VARIABLE_NAME in ('collation_server'))
#where id=1;
#update $tbl_server_name 
#set version  = (select VARIABLE_VALUE from \`information_schema\`.\`GLOBAL_VARIABLES\` where VARIABLE_NAME in ('version'))
#where id=1;
#select server_id, collation_server, version from $tbl_server_name ;
#drop temporary table if exists $tbl_server_name;
#")
################end test for get mistake
#check mysql: MariaDB or MySQL/Percona
get_query_mysql_fork=("select @@version;")
name_mysql_fork1=$(mariadb  --defaults-extra-file=$path_config_mysql_init$in_server_name.cnf -N -e "$get_query_mysql_fork") > $path_out_filtered_option_server_mysql 2>$path_file_main_error_log_init_server #$path_out_db_list
echo "name_mysql_fork: $name_mysql_fork1" >> $path_file_main_log_init_server
#tools_run="/usr/bin/mariadb"
name_mysql_fork=${name_mysql_fork1,,}
if [[ "$name_mysql_fork" == *"mariadb"* ]]; then
	#get list databases on remote server
	sql_get_db_list=("select "$in_server_id" as in_server_id, "\"$in_server_name\"" as server_name, SCHEMA_NAME, DEFAULT_CHARACTER_SET_NAME,DEFAULT_COLLATION_NAME, SCHEMA_COMMENT 
	from information_schema.SCHEMATA
	order by SCHEMA_NAME;
	")
else
	sql_get_db_list=("select "$in_server_id" as in_server_id, "\"$in_server_name\"" as server_name, SCHEMA_NAME, DEFAULT_CHARACTER_SET_NAME,DEFAULT_COLLATION_NAME, 'This is not MariaDB. ' as SCHEMA_COMMENT
	from information_schema.SCHEMATA
	order by SCHEMA_NAME;
	")
fi



sql_server_options=("select @@server_id as 'server_id' , @@collation_server as 'collation_server', @@version as 'version';
")

#create intermediate table catalog databases with prefix $in_server_name on main server system
tbl_server_name_list_db="dba_"$in_server_id"_list_db" #variable table name with dependencies server name
db_concat_tbl_list_db="\`"$conn_db_main_temp"\`.\`"$tbl_server_name_list_db"\`"
sql_db_remote_server=("drop table if exists $db_concat_tbl_list_db;
create table $db_concat_tbl_list_db (
id int not null auto_increment,
server_id int not null,
server_name nvarchar(255) not null,
schema_name varchar(64),
default_character_set_name varchar(32),
default_collation_name varchar(64),
schema_comment varchar(1024) null,
PRIMARY KEY (\`id\`)
);
")
#echo "$sql_get_db_list"
echo "Export option on $server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_init_server 
mariadb  --defaults-extra-file=$path_config_mysql_init$in_server_name.cnf  -e "$sql_server_options" > $path_out_filtered_option_server_mysql 2>$path_file_main_error_log_init_server #$path_out_db_list
echo "Run procedure for update data  on $in_server_name in $(date +"%Y%m%d %H:%M:%S") "  >>  $path_file_main_log_init_server
while IFS=$'\t' read -r server_id collation_server version
	do
	mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.insert_filtered_option_server_mysql($in_server_id, $server_id,'$collation_server', '$version')" 2>$path_file_main_error_log_init_server
done < <(tail -n +2 $path_out_filtered_option_server_mysql)
echo "Export list database from  $server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_init_server
mariadb  --defaults-extra-file=$path_config_mysql_init$in_server_name.cnf -e "$sql_get_db_list" > $path_out_db_list 2>$path_file_main_error_log_init_server
#create intermediate table catalog databases with prefix $in_server_name on main server system
echo "create intermediate table catalog databases with prefix $in_server_id for $in_server_name on main server system $in_conn_super_main_server in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_init_server
mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "use $conn_db_main_temp; $sql_db_remote_server" 2>$path_file_main_error_log_init_server
echo "Import intermediate table catalog databases with prefix $in_server_name on main server system $in_conn_super_main_server in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_init_server
while IFS=$'\t' read -r server_id server_name schema_name default_character_set_name default_collation_name schema_comment
	do
	mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.insert_list_db('$conn_db_main_temp','$tbl_server_name_list_db', $in_server_id, '$in_server_name','$schema_name','$default_character_set_name', '$default_collation_name', '$schema_comment')"  2>$path_file_main_error_log_init_server
done < <(tail -n +2 $path_out_db_list)
#ANALYZE table
echo "Get list all tables for analyze on $in_server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_init_server
sql_list_db_tbl_for_analyze="SELECT  table_schema, table_name  from information_schema.tables where table_type='BASE TABLE' order by table_schema, table_name"
mariadb  --defaults-extra-file=$path_config_mysql_init$in_server_name.cnf -e "$sql_list_db_tbl_for_analyze"  > $path_out_db_tbl_analyze 2>$path_file_main_error_log_init_server
echo "Run analyze for table on $in_server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_init_server
#while IFS=$'\t' read -r table_schema, table_name
#	do
#	mariadb  --defaults-extra-file=/etc/mysql/conf_dba/$in_server_name.cnf -e ""  2>$path_file_main_error_log_init_server
#done < <(tail -n +2 $path_out_db_tbl_analyze)
echo "Check database: add new database and update option database on main server system $in_conn_super_main_server in $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_init_server
mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.check_db('$conn_db_main_temp','$tbl_server_name_list_db',$in_server_id) ;" 2>$path_file_main_error_log_init_server
echo "Export list database for work from $in_server_name in $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_init_server
mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.get_list_db_my_spr($in_server_id)"  > $path_out_good_db_list 2>$path_file_main_error_log_init_server
echo "Force run analyze table on $in_server_name in $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_init_server
mariadb  --defaults-extra-file=$path_config_mysql_init$in_server_name.cnf -e "call mysql.dba_analyze_table()"   >>  $path_file_main_log_init_server 
echo "Start export all list table and view and routine for each database from $in_server_name in $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_init_server
while IFS=$'\t' read -r base_id_spr server_id server_name base_name characterset collation_desc
	do
	echo "Export list table and view for database $base_name from $in_server_name in to file $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_init_server
	#filename for each database for export all information about tables
	file_tbl_list=$in_server_id"_tbl_list_"$base_name".txt"
	file_view_list=$in_server_id"_view_list_"$base_name".txt"
	file_routine_list=$in_server_id"_routine_list_"$base_name".txt"
	path_out_tbl_list_db=$log_path_mysql_init_servername/$file_tbl_list
	path_out_view_list_db=$log_path_mysql_init_servername/$file_view_list
	path_out_routine_list_db=$log_path_mysql_init_servername/$file_routine_list
	#query run on remote server $in_server_name
	sql_export_tbl_each_db="SELECT "$base_id_spr" as base_id_spr, "$server_id" as server_id, "\"$server_name\"" as server_name, "\"$base_name\"" as base_name, "\"$characterset\"" as  characterset, "\"$collation_desc\"" as collation_desc,
		 table_name, table_type, engine, row_format, table_collation, table_comment, ROUND(DATA_LENGTH / 1024 / 1024, 2) AS data_mb, ROUND(INDEX_LENGTH / 1024 / 1024, 2) AS index_mb,
			ROUND(DATA_FREE / 1024 / 1024, 2) AS unsed_mb, TABLE_ROWS AS table_rows  from \`information_schema\`.\`tables\` where table_schema='$base_name'  and table_type='BASE TABLE'"
	mariadb  --defaults-extra-file=$path_config_mysql_init$in_server_name.cnf -e "$sql_export_tbl_each_db"  > $path_out_tbl_list_db 2>$path_file_main_error_log_init_server
#	sql_export_view_each_db="SELECT "$base_id_spr" as base_id_spr, "$server_id" as server_id, "\"$server_name\"" as server_name, "\"$base_name\"" as base_name, "\"$characterset\"" as  characterset, "\"$collation_desc\"" as collation_desc,
#		 table_name, view_definition, check_option, is_updatable, definer, security_type, character_set_client, collation_connection, algorithm
#		 from \`information_schema\`.\`views\` where table_schema='$base_name'; "
	if [[ "$name_mysql_fork" == *"mariadb"* ]]; then
		sql_export_view_each_db="SELECT "$base_id_spr" as base_id_spr, "$server_id" as server_id, "\"$server_name\"" as server_name, "\"$base_name\"" as base_name, "\"$characterset\"" as  characterset, "\"$collation_desc\"" as collation_desc,
			 table_name, view_definition, check_option, is_updatable, definer, security_type, character_set_client, collation_connection, algorithm
			 from \`information_schema\`.\`views\` where table_schema='$base_name'; "
	else
		sql_export_view_each_db="SELECT "$base_id_spr" as base_id_spr, "$server_id" as server_id, "\"$server_name\"" as server_name, "\"$base_name\"" as base_name, "\"$characterset\"" as  characterset, "\"$collation_desc\"" as collation_desc,
			 table_name, view_definition, check_option, is_updatable, definer, security_type, character_set_client, collation_connection, 'NotMariaDB' as algorithm
			 from \`information_schema\`.\`views\` where table_schema='$base_name'; "

	fi
	mariadb  --defaults-extra-file=$path_config_mysql_init$in_server_name.cnf -e "$sql_export_view_each_db"  > $path_out_view_list_db 2>$path_file_main_error_log_init_server
	sql_export_routine_each_db="SELECT "$base_id_spr" as base_id_spr, "$server_id" as server_id, "\"$server_name\"" as server_name, "\"$base_name\"" as base_name, "\"$characterset\"" as  characterset, "\"$collation_desc\"" as collation_desc,
		 routine_name, routine_type, data_type, coalesce(character_maximum_length,0) as character_maximum_length, coalesce(character_octet_length,0) as character_octet_length, coalesce(numeric_precision,0) as numeric_precision, coalesce(numeric_scale,0) as numeric_scale, coalesce(datetime_precision,0) as datetime_precision, coalesce(character_set_name,'') as character_set_name, collation_name, dtd_identifier, routine_body,
         routine_definition, external_name, external_language, parameter_style, is_deterministic, sql_data_access, sql_path, security_type, created, last_altered, sql_mode, routine_comment, definer, character_set_client,
         collation_connection, database_collation from \`information_schema\`.\`ROUTINES\` where routine_schema='$base_name'; "
	mariadb  --defaults-extra-file=$path_config_mysql_init$in_server_name.cnf -e "$sql_export_routine_each_db"  > $path_out_routine_list_db 2>$path_file_main_error_log_init_server
	#table name for intermediate work type $in_server_name"_tbl_list_"$base_name  on main server system
	tbl_server_name_db="\`"$conn_db_main_temp"\`.\`t_"$in_server_id"_"$base_name"\`"
	#create intermediate table catalog tables with prefix $in_server_name"_tbl_list_"$base_name and table size on main server system
	sql_db_tbl=("drop table if exists $tbl_server_name_db;
	create table $tbl_server_name_db (
	base_id_spr INT NOT NULL,
	server_id INT  NOT NULL,
	server_name nvarchar(255) not null,
	base_name NVARCHAR(64) NOT NULL,
	characterset NVARCHAR(32) NOT NULL,
	collation_desc NVARCHAR(255) NOT NULL,
	table_name NVARCHAR(255) NOT NULL,
	table_type NVARCHAR(255) NULL,
	engine NVARCHAR(255) NULL,
	row_format NVARCHAR(255) NULL,
	table_collation NVARCHAR(255) NULL,
	table_comment NVARCHAR(255) NULL,
	data_mb DECIMAL(20,2) NULL,
	index_mb DECIMAL(20,2) NULL,
	unsed_mb DECIMAL(20,2) NULL,
	table_rows BIGINT(20) NULL
	);
	")
	sql_load_db_tbl="LOAD DATA INFILE '$path_out_tbl_list_db' INTO TABLE $tbl_server_name_db FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"
	view_server_name_db="\`"$conn_db_main_temp"\`.\`v_"$in_server_id"_"$base_name"\`"
	#create intermediate table catalog tables with prefix $in_server_name"_tbl_list_"$base_name and table size on main server system
	sql_db_view=("drop table if exists $view_server_name_db;
	create table $view_server_name_db (
	base_id_spr INT NOT NULL,
	server_id INT  NOT NULL,
	server_name nvarchar(255) not null,
	base_name NVARCHAR(64) NOT NULL,
	characterset NVARCHAR(32) NOT NULL,
	collation_desc NVARCHAR(255) NOT NULL,
    table_name NVARCHAR(255) NOT NULL,
    view_definition longtext NULL,
    check_option varchar(8)  NULL,
    is_updatable  varchar(3) NULL,
    definer varchar(384) NULL,
    security_type varchar(7) NULL,
    character_set_client varchar(32) NULL,
    collation_connection varchar(64) NULL,
    algorithm varchar(10)  NULL
	);
	")
	sql_load_db_view="LOAD DATA INFILE '$path_out_view_list_db' INTO TABLE $view_server_name_db FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"
	routine_server_name_db="\`"$conn_db_main_temp"\`.\`r_"$in_server_id"_"$base_name"\`"
	#create intermediate table catalog tables with prefix $in_server_name"_tbl_list_"$base_name and table size on main server system
	sql_db_routine=("drop table if exists $routine_server_name_db;
	create table $routine_server_name_db (
	base_id_spr INT NOT NULL,
	server_id INT  NOT NULL,
	server_name nvarchar(255) not null,
	base_name NVARCHAR(64) NOT NULL,
	characterset NVARCHAR(32) NOT NULL,
	collation_desc NVARCHAR(255) NOT NULL,
    routine_name varchar(64) NOT NULL,
    routine_type varchar(13) NOT NULL,
    data_type varchar(64) NOT NULL,
    character_maximum_length bigint(20) DEFAULT NULL,
    character_octet_length bigint(20) DEFAULT NULL,
    numeric_precision int(21) DEFAULT NULL,
    numeric_scale int(21) DEFAULT NULL,
    datetime_precision bigint(21) unsigned DEFAULT NULL,
    character_set_name varchar(64) DEFAULT NULL,
    collation_name varchar(64) DEFAULT NULL,
    dtd_identifier longtext DEFAULT NULL,
    routine_body varchar(8) NOT NULL,
    routine_definition longtext DEFAULT NULL,
    external_name varchar(64) DEFAULT NULL,
    external_language varchar(64) DEFAULT NULL,
    parameter_style varchar(8) NOT NULL,
    is_deterministic varchar(3) NOT NULL,
    sql_data_access varchar(64) NOT NULL,
    sql_path varchar(64) DEFAULT NULL,
    security_type varchar(7) NOT NULL,
    created datetime NOT NULL,
    last_altered datetime NOT NULL,
    sql_mode varchar(8192) NOT NULL,
    routine_comment longtext NOT NULL,
    definer varchar(384) NOT NULL,
    character_set_client varchar(32) NOT NULL,
    collation_connection varchar(64) NOT NULL,
    database_collation varchar(64) NOT NULL	
	);
	")
	sql_load_db_routine="LOAD DATA INFILE '$path_out_routine_list_db' INTO TABLE $routine_server_name_db FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"
	echo "Create table  $tbl_server_name_db and $view_server_name_db and $routine_server_name_db on $in_server_name and load data for processing in $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_init_server
	amount_symbol_name_db=${#base_name}
	#check lenght database name. If lenght database name greate 45 symbol? collection data skip
	if [[ $amount_symbol_name_db -gt 61 ]]
		then echo -e "Subject:The global error about collecting data on the server $in_server_name and database $base_name   \n\nskip collection data from database $base_name on server_name $in_server_name" | /usr/sbin/sendmail $recipient_mail
		else
		echo "script name $path1 catch error on $base_name on $tbl_server_name_db and $view_server_name_db and $routine_server_name_db  for $in_server_name " > $path_file_main_error_log_init_server
		echo "$sql_load_db_tbl ;"   >>  $path_file_main_log_init_server
		mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "$sql_db_tbl" 2>$path_file_main_error_log_init_server  #< $path_out_tbl_list_db
		mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "$sql_load_db_tbl" >> $path_file_main_log_init_server 2>$path_file_main_error_log_init_server # &1 
		echo "$sql_load_db_view ;"   >>  $path_file_main_log_init_server		
		mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "$sql_db_view" 2>$path_file_main_error_log_init_server  #< $path_out_tbl_list_db
		mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "$sql_load_db_view" >> $path_file_main_log_init_server 2>$path_file_main_error_log_init_server # &1 
		echo "$sql_load_db_routine;"   >>  $path_file_main_log_init_server				
		mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "$sql_db_routine" >> $path_file_main_log_init_server 2>$path_file_main_error_log_init_server  #< $path_out_tbl_list_db
		mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "$sql_load_db_routine" >> $path_file_main_log_init_server 2>$path_file_main_error_log_init_server # &1 
#пока только заполнил список процедур в промежуточную таблицу
		echo "insert-update data in spr_mysql_table and spr_mysql_view tables on $in_server_name $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_init_server
		echo "call assistant_dba.check_table($server_id,'$in_server_name','$base_name', '$tbl_server_name_db') ;"   >>  $path_file_main_log_init_server
		echo "call assistant_dba.check_view($server_id,'$in_server_name','$base_name', '$view_server_name_db') ;"   >>  $path_file_main_log_init_server
		echo "call assistant_dba.check_routine($server_id,'$in_server_name','$base_name', '$routine_server_name_db') ;"   >>  $path_file_main_log_init_server		
		mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.check_table($server_id,'$in_server_name','$base_name', '$tbl_server_name_db') ;" >> $path_file_main_log_init_server 2>$path_file_main_error_log_init_server #&1 
		mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.check_view($server_id,'$in_server_name','$base_name', '$view_server_name_db') ;" >> $path_file_main_log_init_server 2>$path_file_main_error_log_init_server #&1 		
		mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.check_routine($server_id,'$in_server_name','$base_name', '$routine_server_name_db') ;" >> $path_file_main_log_init_server 2>$path_file_main_error_log_init_server #&1 		
		echo "delete data get date in history_mysql_table for database $base_name on $in_server_name $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_init_server
		echo "call assistant_dba.insert_history_table($server_id,'$in_server_name','$base_name',$base_id_spr, '$tbl_server_name_db') ;"   >>  $path_file_main_log_init_server 2>$path_file_main_error_log_init_server
		mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.insert_history_table($server_id,'$in_server_name','$base_name', $base_id_spr, '$tbl_server_name_db') ;"  >> $path_file_main_error_log_init_server 2>$path_file_main_error_log_init_server #&1 
		line_error_check=$(sed -n '$=' $path_file_main_error_log_init_server)
		if [[ $line_error_check -gt 1 ]]
			then echo -e"Subject:collect data \n\n sad"  | /usr/sbin/sendmail $recipient_mail  
			exit
		fi;
		echo "Export list table for database $base_name from $in_server_name in $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_init_server	
	fi;
done < <(tail -n +2 $path_out_good_db_list)
echo "End export all list table for each database from $in_server_name in $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_init_server
echo "Export global variable with $server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_init_server 
if [[ "$name_mysql_fork" == *"mariadb"* ]]; then
	#sql_export_global_variable="SELECT "$in_server_id" as server_id, variable_name, replace(VARIABLE_VALUE, "'"'"'"'"'","'"'"\\'"'"'")  FROM information_schema.GLOBAL_VARIABLES order by variable_name;"
	sql_export_global_variable="SELECT "$in_server_id" as server_id, variable_name, VARIABLE_VALUE FROM information_schema.GLOBAL_VARIABLES order by variable_name;"
#	sql_export_global_variable="SELECT "$in_server_id" as server_id, variable_name, VARIABLE_VALUE INTO OUTFILE '$path_out_global_var_value'
#       FIELDS TERMINATED BY '@@@@@' 
#        LINES TERMINATED BY '\n' FROM information_schema.GLOBAL_VARIABLES order by variable_name;"
else
	sql_export_global_variable="SELECT "$in_server_id" as server_id, variable_name, VARIABLE_VALUE FROM performance_schema.global_variables order by variable_name;"
#	sql_export_global_variable="SELECT "$in_server_id" as server_id, variable_name, VARIABLE_VALUE INTO OUTFILE '$path_out_global_var_value'
#        FIELDS TERMINATED BY '@@@@@' 
#        LINES TERMINATED BY '\n'  FROM performance_schema.global_variables order by variable_name;"
fi
#sql_export_global_variable="SELECT "$in_server_id" as server_id, variable_name, VARIABLE_VALUE FROM information_schema.GLOBAL_VARIABLES order by variable_name;"
echo "sql_export_global_variable:$sql_export_global_variable" >>  $path_file_main_log_init_server 
mariadb  --defaults-extra-file=$path_config_mysql_init$in_server_name.cnf  -e "$sql_export_global_variable;" > $path_out_global_var_value 2>$path_file_main_error_log_init_server
echo "Import global variable on $server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_init_server 
tbl_server_name_global_var="dba_"$in_server_id"_global_var" #variable table name with dependencies server name for global var
db_concat_global_var="\`"$conn_db_main_temp"\`.\`"$tbl_server_name_global_var"\`"
sql_global_var_remote_server=("drop table if exists $db_concat_global_var;
create table $db_concat_global_var (
id int not null auto_increment,
server_id int not null,
variable_name varchar(64) not null,
variable_value varchar(4096),
PRIMARY KEY (\`id\`)
);
")
#replace special characters
sed -i -e "s/'/\\\'/g" $path_out_global_var_value
mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "use $conn_db_main_temp; $sql_global_var_remote_server" 2>$path_file_main_error_log_init_server
while IFS=$'\t' read -r server_id variable_name variable_value
	do
	#mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.insert_global_var('$conn_db_main_temp','$tbl_server_name_global_var', $in_server_id, '$variable_name','$variable_value')"  2>$path_file_main_error_log_init_server
	echo "call assistant_dba.insert_global_var('$conn_db_main_temp','$tbl_server_name_global_var', $in_server_id, '$variable_name','$variable_value');" >>  $path_file_main_log_init_server 
	mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.insert_global_var('$conn_db_main_temp','$tbl_server_name_global_var', $in_server_id, '$variable_name','$variable_value')"  2>$path_file_main_error_log_init_server
done < <(tail -n +2 $path_out_global_var_value)	
echo "Check global variable: add new global variable on main server system $in_conn_super_main_server in $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_init_server
mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.check_global_var('$conn_db_main_temp','$tbl_server_name_global_var',$in_server_id) ;" 2>$path_file_main_error_log_init_server
echo "Export list global variable for work for $in_server_name in $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_init_server
mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.get_list_global_var_spr($in_server_id)"  > $path_out_good_global_var_value 2>$path_file_main_error_log_init_server
echo "Export list global variable for work from $in_server_name in $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_init_server
if [ -f "$path_out_good_global_var_value_ext" ]; 
	then rm $path_out_good_global_var_value_ext 2>$path_file_main_error_log_init_server
fi
while IFS=$'\t' read -r var_id_spr server_id server_name variable_name
	do
	if [[ "$name_mysql_fork" == *"mariadb"* ]]; then
		sql_export_global_variable_ext="SELECT "$var_id_spr" as var_id_spr, "$server_id" as server_id, variable_name, VARIABLE_VALUE FROM information_schema.GLOBAL_VARIABLES where variable_name='$variable_name' order by variable_name;"
	else
		sql_export_global_variable_ext="SELECT "$var_id_spr" as var_id_spr, "$server_id" as server_id, variable_name, VARIABLE_VALUE FROM performance_schema.global_variables where variable_name='$variable_name' order by variable_name;"
	fi
	#sql_export_global_variable_ext="SELECT "$var_id_spr" as var_id_spr, "$server_id" as server_id, variable_name, VARIABLE_VALUE FROM information_schema.GLOBAL_VARIABLES where variable_name='$variable_name' order by variable_name;"
	mariadb  --defaults-extra-file=$path_config_mysql_init$in_server_name.cnf -N -e "$sql_export_global_variable_ext"  >> $path_out_good_global_var_value_ext 2>$path_file_main_error_log_init_server
done < <(tail -n +2 $path_out_good_global_var_value)	
echo "Import global variable extended on $server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_init_server 
tbl_server_name_global_var_ext="dba_"$in_server_id"_global_var_ext" #variable table name with dependencies server name for global var
db_concat_global_var_ext="\`"$conn_db_main_temp"\`.\`"$tbl_server_name_global_var_ext"\`"
sql_global_var_ext_remote_server=("drop table if exists $db_concat_global_var_ext;
create table $db_concat_global_var_ext (
id int not null auto_increment,
server_id int not null,
var_id_spr bigint not null,
variable_name varchar(64) not null,
variable_value varchar(4096),
PRIMARY KEY (\`id\`)
);
")
mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "use $conn_db_main_temp; $sql_global_var_ext_remote_server" 2>$path_file_main_error_log_init_server
#replace special characters
sed -i -e "s/'/\\\'/g" $path_out_good_global_var_value_ext
while IFS=$'\t' read -r var_id_spr server_id variable_name variable_value
	do
	mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.insert_global_var_ext('$conn_db_main_temp','$tbl_server_name_global_var_ext', $var_id_spr, $server_id, '$variable_name','$variable_value')"  2>$path_file_main_error_log_init_server
done < <(tail -n +1 $path_out_good_global_var_value_ext)	
echo "Insert data in history_mysql_global_var from  $db_concat_global_var_ext on $in_conn_super_main_server in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_init_server 
echo "call assistant_dba.insert_history_global_var($in_server_id,'$conn_db_main_temp');" >>  $path_file_main_log_init_server 
mariadb  --defaults-extra-file=$path_config_mysql_init$in_conn_super_main_server.cnf -e "call assistant_dba.insert_history_global_var($in_server_id,'$conn_db_main_temp');" 2>$path_file_main_error_log_init_server
echo "End work servername $in_server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_init_server
#echo  -e "Subject:Общий  сбор данных по серверу $in_server_name \n\nработа по сбору данных с сервера $in_server_name закончена $(date +"%Y%m%d %H:%M:%S") "  | sendmail pavel.polikov@1win.pro


#LOAD DATA INFILE '/home/teacher_names.csv' INTO TABLE teacher_names FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\n' IGNORE 1 ROWS;
