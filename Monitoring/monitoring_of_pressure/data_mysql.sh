#!/bin/bash
#The bash script for data processing of the result of the MySQL.
# By Pavel A Polikov
# Licensed under MIT
#-- Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#sudo sed -i -e 's/\r$//' /etc/assistant_dba/dba_scripts/monitoring/data_mysql.sh
#sudo chown root  /etc/assistant_dba/dba_scripts/monitoring/data_mysql.sh
#sudo chmod 755  /etc/assistant_dba/dba_scripts/monitoring/data_mysql.sh

#Parameters
path_config_mysql_conn="/etc/assistant_dba/conf/monitoring.conf"
#conn string
conn_db_main="assistant_dba"
conn_db_main_temp="assistant_dba_temp"


cpu_count=$(cat /proc/cpuinfo | grep processor | wc -l)
dir_p='/tmp'
date_in=$(date +"%Y-%m-%d %H:%M:%S")
date_p=$(date +"%Y%m%d_%H%M%S")
path_to_export=$dir_p/"mysql_"$date_p".txt"
tblname_mysql="mysql_"$date_p

#Result from mysql
sql_to_file=("select pst.thread_id,
case 
when pst.processlist_id is null then 0
when pst.processlist_id is not null then pst.processlist_id
end as processlist_id, 
case
when pst.processlist_user is null then 'NULL'
when pst.processlist_user is not null then pst.processlist_user
end as processlist_user, 
case
when pst.processlist_host is null then 'NULL'
when pst.processlist_host is not null then pst.processlist_host
end as processlist_host,
case
when pst.processlist_db is null then 'NULL'
when pst.processlist_db is not null then pst.processlist_db
end as processlist_db,
case
when pst.processlist_command is null then 'NULL'
when pst.processlist_command is not null then pst.processlist_command
end as processlist_command,
case
when pst.processlist_time is null then 0
when pst.processlist_time is not null then pst.processlist_time
end as processlist_time,
case
when pst.processlist_info is null then 'NULL'
when pst.processlist_info is not null then pst.processlist_info
end as processlist_info,
pst.thread_os_id, pst.total_memory, 
pst.max_total_memory, '$date_in' as date_collect
from performance_schema.threads pst
#where pst.thread_os_id is not null ;")


mysql --defaults-extra-file=$path_config_mysql_conn -e "use mysql; $sql_to_file;" > $path_to_export

#sql scripts
#I created intermediate database.
sql_create_assistant_dba_temp=("SET sql_log_bin = 0; create database if not exists $conn_db_main_temp;")
mysql --defaults-extra-file=$path_config_mysql_conn -e "use mysql; $sql_create_assistant_dba_temp;" 

#I dropping and creating the intermediate table for the data of mysql 
sql_drop_tblname_mysql=("SET sql_log_bin = 0; drop table if exists $conn_db_main_temp.$tblname_mysql;")
mysql --defaults-extra-file=$path_config_mysql_conn -e "use mysql; $sql_drop_tblname_mysql;" 
sql_create_tblname_mysql=("SET sql_log_bin = 0; 
create table $conn_db_main_temp.$tblname_mysql (THREAD_ID bigint unsigned NOT NULL,
   PROCESSLIST_ID bigint unsigned DEFAULT NULL,
   PROCESSLIST_USER varchar(32) DEFAULT NULL,
   PROCESSLIST_HOST varchar(255) CHARACTER SET ascii COLLATE ascii_general_ci DEFAULT NULL,
   PROCESSLIST_DB varchar(64) DEFAULT NULL,
   PROCESSLIST_COMMAND varchar(16) DEFAULT NULL,
   PROCESSLIST_TIME bigint DEFAULT NULL,
   PROCESSLIST_INFO longtext,
   THREAD_OS_ID bigint unsigned NOT NULL,
   TOTAL_MEMORY bigint unsigned NOT NULL,
   MAX_TOTAL_MEMORY bigint unsigned NOT NULL,
   date_collect datetime NOT NULL,
   PRIMARY KEY (THREAD_ID,date_collect)
 ); 
")

mysql --defaults-extra-file=$path_config_mysql_conn -e "use mysql; $sql_create_tblname_mysql;" 


sql_load_mysql="SET sql_log_bin = 0; LOAD DATA INFILE '$path_to_export' INTO TABLE $conn_db_main_temp.$tblname_mysql FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"
mysql --defaults-extra-file=$path_config_mysql_conn -e "use mysql; $sql_load_mysql;"



#sql_drop_tblname_mysql=("SET sql_log_bin = 0; drop table if exists $conn_db_main_temp.$tblname_mysql;")
#mysql --defaults-extra-file=$path_config_mysql_conn -e "use mysql; $sql_drop_tblname_mysql;" 

rm $path_to_export
