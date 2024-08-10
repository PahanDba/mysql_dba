#!/bin/bash
#input parametrs scripts prefix in_
#sudo sed -i -e 's/\r$//' /etc/mysql/dba_scripts/users/03_users_mysqlserver.sh
#sudo chown root  /etc/mysql/dba_scripts/users/03_users_mysqlserver.sh
#sudo chmod 755  /etc/mysql/dba_scripts/users/03_users_mysqlserver.sh
recipient_mail="you@email_address"
in_server_id=$server_id
in_server_name=$server_name
in_connection_string=$connection_string 
in_ip=$ip
in_port=$port
in_conn_super_main_server=$conn_super_main_server
log_users_server=$in_server_name"_all.log"
log_error=$in_server_name"_error.log"
log_path_mysql_users_servername="/var/log/dw_dba/mysql/users/"$in_server_name
#ouput file
file_list_alive_mysqlservers="list_alive_mysqlservers.txt"
file_global_priv="out_q_global_priv.txt"
file_global_priv_end="out_q_global_priv_end.txt"
file_users_list=$server_name"_users_list.txt"
file_procs_priv=$server_name"_out_procs_priv.txt"
file_procs_priv_end=$server_name"_out_procs_priv_end.txt"
path_file_main_log_users_server=$log_path_mysql_users_servername/$log_users_server
path_file_main_error_log_users_server=$log_path_mysql_users_servername/$log_error
path_file_q_global_priv="/etc/mysql/dba_scripts/users/q_global_priv.sql"
path_out_users_list=$log_path_mysql_users_servername/$file_users_list
path_out_q_global_priv=$log_path_mysql_users_servername/$file_global_priv
path_out_q_global_priv_end=$log_path_mysql_users_servername/$file_global_priv_end
path_out_procs_priv=$log_path_mysql_users_servername/$file_procs_priv
path_out_procs_priv_end=$log_path_mysql_users_servername/$file_procs_priv_end
#conn string
conn_db_main="dw_dba"
conn_db_main_temp="dw_dba_temp"
path_config_mysql_users="/etc/mysql/conf_dba/users/"
#get name and fullname executed script
dir_path1=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)
path1=$dir_path1/$(basename "${BASH_SOURCE:-$0}")
#option trap
set -e
trap 'LAST_COMMAND=$CURRENT_COMMAND; CURRENT_COMMAND=$BASH_COMMAND;' debug 
trap 'ERROR_CODE=$?; ERROR_MESSAGE=`cat $path_file_main_error_log_init_server`; FAILED_COMMAND=$LAST_COMMAND; echo -e "Subject:глобальная ошибка сбора данных по серверу $server_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand before error: \"$FAILED_COMMAND\" \nfailed with message: \"$ERROR_MESSAGE \" " | /usr/sbin/sendmail $recipient_mail;' ERR INT TERM
#main script
if [  -d "$log_path_mysql_users_servername" ];  then
        rm  -r "$log_path_mysql_users_servername"
        mkdir -p "$log_path_mysql_users_servername"
else
        mkdir -p "$log_path_mysql_users_servername"
fi
echo "Begin work servername $in_server_name in $(date +"%Y%m%d %H:%M:%S")"  >  $path_file_main_log_users_server
#get list users on remote server
sql_get_users_list=("select  "$in_server_id" as server_id, "\"$in_server_name\"" as server_name,user, host, if(ifnull(json_value(\`mysql\`.\`global_priv\`.\`Priv\`,'$.account_locked'),0) = 1,'Y','N') AS \`account_locked\`,
if(ifnull(json_value(\`mysql\`.\`global_priv\`.\`Priv\`,'$.password_last_changed'),1) = 0,'Y','N') AS \`password_expired\`,
elt(ifnull(json_value(\`mysql\`.\`global_priv\`.\`Priv\`,'$.is_role'),0) + 1,'N','Y') AS \`is_role\` 
from mysql.global_priv;
")
#create temporary table users
	tbl_server_name_users="tu_"$in_server_id"_users"
	db_concat_tbl_list_users="\`"$conn_db_main_temp"\`.\`"$tbl_server_name_users"\`"
	sql_users_tbl=("drop table if exists $db_concat_tbl_list_users;
	create table $db_concat_tbl_list_users (
	server_id INT  NOT NULL,
	server_name nvarchar(255) not null,
	user char(128),
	host char(255),
	locked varchar(1)  NULL,
	password_expired varchar(1) NULL,
	is_role varchar(1) NULL
	);
	")
	#load users to temporary table for proccesing	
	sql_load_users_tbl="LOAD DATA INFILE '$path_out_users_list' INTO TABLE $db_concat_tbl_list_users FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"
	tbl_server_name_global_priv="tgp_"$in_server_id""
	db_concat_tbl_list_global_priv="\`"$conn_db_main_temp"\`.\`"$tbl_server_name_global_priv"\`"
	sql_global_priv_tbl=("drop table if exists $db_concat_tbl_list_global_priv;
	CREATE TABLE $db_concat_tbl_list_global_priv (
		server_id INT  NOT NULL,
		server_name nvarchar(255) not null,
		user char(128),
		host char(255),
	  \`select_priv\` VARCHAR(1) NOT NULL,
	  \`insert_priv\` VARCHAR(1) NOT NULL,
	  \`update_priv\` VARCHAR(1) NOT NULL,
	  \`delete_priv\` VARCHAR(1) NOT NULL,
	  \`create_priv\` VARCHAR(1) NOT NULL,
	  \`drop_priv\` VARCHAR(1) NOT NULL,
	  \`reload_priv\` VARCHAR(1) NOT NULL,
	  \`shutdown_priv\` VARCHAR(1) NOT NULL,
	  \`process_priv\` VARCHAR(1) NOT NULL,
	  \`file_priv\` VARCHAR(1) NOT NULL,
	  \`grant_priv\` VARCHAR(1) NOT NULL,
	  \`references_priv\` VARCHAR(1) NOT NULL,
	  \`index_priv\` VARCHAR(1) NOT NULL,
	  \`alter_priv\` VARCHAR(1) NOT NULL,
	  \`show_db_priv\` VARCHAR(1) NOT NULL,
	  \`super_priv\` VARCHAR(1) NOT NULL,
	  \`create_tmp_table_priv\` VARCHAR(1) NOT NULL,
	  \`lock_tables_priv\` VARCHAR(1) NOT NULL,
	  \`execute_priv\` VARCHAR(1) NOT NULL,
	  \`repl_slave_priv\` VARCHAR(1) NOT NULL,
	  \`repl_client_priv\` VARCHAR(1) NOT NULL,
	  \`create_view_priv\` VARCHAR(1) NOT NULL,
	  \`show_view_priv\` VARCHAR(1) NOT NULL,
	  \`create_routine_priv\` VARCHAR(1) NOT NULL,
	  \`alter_routine_priv\` VARCHAR(1) NOT NULL,
	  \`create_user_priv\` VARCHAR(1) NOT NULL,
	  \`event_priv\` VARCHAR(1) NOT NULL,
	  \`trigger_priv\` VARCHAR(1) NOT NULL,
	  \`create_tablespace_priv\` VARCHAR(1) NOT NULL,
	  \`delete_history_priv\` VARCHAR(1) NOT NULL,
	  \`ssl_type\` VARCHAR(255) NULL,
	  \`ssl_cipher\` VARCHAR(255) NULL,
	  \`x509_issuer\` VARCHAR(255) NULL,
	  \`x509_subject\` VARCHAR(255) NULL,
	  \`max_questions\` INT NULL,
	  \`max_updates\` INT NULL,
	  \`max_connections\` INT NULL,
	  \`max_user_connections\` INT NULL,
	  \`plugin\` VARCHAR(255) NULL,
	  \`password_expired\` VARCHAR(1) NOT NULL,
	  \`is_role\` VARCHAR(1) NOT NULL,
	  \`default_role\` VARCHAR(64) NULL,
	  \`max_statement_time\` DECIMAL(12,6) NULL,
	  \`account_locked\` TINYINT(1) NULL);
	")
   #load global_priv to temporary table for proccesing	
   sql_load_global_priv_tbl="LOAD DATA INFILE '$path_out_q_global_priv' INTO TABLE $db_concat_tbl_list_global_priv FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"
!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!   
   tbl_server_name_procs_priv="tpp_"$in_server_id""
   db_concat_tbl_list_procs_priv="\`"$conn_db_main_temp"\`.\`"$tbl_server_name_procs_priv"\`"
   sql_procs_priv_tbl=("drop table if exists $db_concat_tbl_list_procs_priv;
   CREATE TABLE $db_concat_tbl_list_procs_priv (
    server_id int(10) NOT NULL,
    server_name varchar(255) NOT NULL,
    \`User\` char(128) NOT NULL, 
    \`Host\` char(255) NOT NULL,
    \`Db\` char(64) NOT NULL,
    \`Routine_name\` char(64) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
    \`Routine_type\` enum('FUNCTION','PROCEDURE','PACKAGE','PACKAGE BODY') NOT NULL,
    \`Grantor\` varchar(384) NOT NULL,
    \`Proc_priv\` set('Execute','Alter Routine','Grant') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL);
  ")
  #load procs_priv to temporary table for proccesing  
  sql_load_procs_priv_tbl="LOAD DATA INFILE '$path_out_procs_priv' INTO TABLE $db_concat_tbl_list_procs_priv FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"

echo "Export users on $server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_users_server 
mariadb  --defaults-extra-file=$path_config_mysql_users$in_server_name.cnf  -e "$sql_get_users_list" > $path_out_users_list 2>$path_file_main_error_log_users_server #$path_out_db_list
#echo "$sql_users_tbl;"   >>  $path_file_main_log_users_server
#mariadb  --defaults-extra-file=$path_config_mysql_users$in_conn_super_main_server.cnf -e "$sql_users_tbl" >> $path_file_main_log_users_server 2>$path_file_main_error_log_users_server # &1 
echo "$sql_users_tbl;"   >>  $path_file_main_log_users_server
mariadb  --defaults-extra-file=$path_config_mysql_users$in_conn_super_main_server.cnf -e "$sql_users_tbl" >> $path_file_main_log_users_server 2>$path_file_main_error_log_users_server # &1 
echo "$sql_load_users_tbl;"   >>  $path_file_main_log_users_server
mariadb  --defaults-extra-file=$path_config_mysql_users$in_conn_super_main_server.cnf -e "$sql_load_users_tbl" >> $path_file_main_log_users_server 2>$path_file_main_error_log_users_server # &1 

echo "insert-update data in spr_mysql_users users on $in_server_name $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_users_server
mariadb  --defaults-extra-file=$path_config_mysql_users$in_conn_super_main_server.cnf -e "call dw_dba.check_users('$conn_db_main_temp','$tbl_server_name_users',$in_server_id) ;" >> $path_file_main_log_users_server 2>$path_file_main_error_log_users_server #&1 

#echo "mariadb  --defaults-extra-file=$path_config_mysql_users$in_server_name.cnf  < $path_file_q_global_priv > $path_out_q_global_priv 2>$path_file_main_error_log_users_server #$path_out_db_list"
#mariadb  --defaults-extra-file=$path_config_mysql_users$in_server_name.cnf  < $path_file_q_global_priv $in_server_id $in_server_name > $path_out_q_global_priv 2>$path_file_main_error_log_users_server #$path_out_db_list
#mariadb  --defaults-extra-file=$path_config_mysql_users$in_server_name.cnf  < $path_file_q_global_priv $in_server_id $in_server_name > $path_out_q_global_priv 2>$path_file_main_error_log_users_server #$path_out_db_list
echo "prepare script for run export global_priv on $in_server_name $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_users_server
sed 's/server_id_var/'"$in_server_id"'/g; s/server_name_var/'"$in_server_name"'/g;' $path_file_q_global_priv  > $path_out_q_global_priv_end
mariadb  --defaults-extra-file=$path_config_mysql_users$in_server_name.cnf  < $path_out_q_global_priv_end  > $path_out_q_global_priv 2>$path_file_main_error_log_users_server #$path_out_db_list
echo "$sql_global_priv_tbl;"   >>  $path_file_main_log_users_server
mariadb  --defaults-extra-file=$path_config_mysql_users$in_conn_super_main_server.cnf -e "$sql_global_priv_tbl" >> $path_file_main_log_users_server 2>$path_file_main_error_log_users_server # &1 
echo "$sql_load_global_priv_tbl;"   >>  $path_file_main_log_users_server
mariadb  --defaults-extra-file=$path_config_mysql_users$in_conn_super_main_server.cnf -e "$sql_load_global_priv_tbl" >> $path_file_main_log_users_server 2>$path_file_main_error_log_users_server # &1 
echo "insert-update data in history_mysql_global_priv about $in_server_name $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_users_server
mariadb  --defaults-extra-file=$path_config_mysql_users$in_conn_super_main_server.cnf -e "call dw_dba.insert_history_global_priv('$conn_db_main_temp','$tbl_server_name_global_priv',$in_server_id) ;" >> $path_file_main_log_users_server 2>$path_file_main_error_log_users_server #&1 
echo "Export users and proc_priv from $server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_users_server 
if [ -f "$path_out_procs_priv" ]; 
  then rm $path_out_procs_priv 2>$path_file_main_error_log_users_server
fi
#echo "debig $path_out_users_list"
while IFS=$'\t' read -r server_id server_name user host account_locked password_expired is_role
  do
  #echo "debug $user"
  #echo "debug $host"
  #echo "debug $account_locked"
  sql_get_users_proc_priv=("select  "$in_server_id" as server_id, "\"$in_server_name\"" as server_name, "\"$user\"" as user, "\"$host\"" as  host, db, routine_name, routine_type, grantor, proc_priv
  from mysql.procs_priv where user='$user' and host='$host';
  ")
  #echo "$sql_get_users_proc_priv" >>  $path_file_main_log_users_server
  mariadb  --defaults-extra-file=$path_config_mysql_users$in_server_name.cnf -e "$sql_get_users_proc_priv" >> $path_out_procs_priv  2>$path_file_main_error_log_users_server
done < <(tail -n +2 $path_out_users_list)
sed  -i '/^[server_id       server_name     user    host    db      routine_name    routine_type    grantor proc_priv]/d' $path_out_procs_priv 
sed  -i '1i server_id       server_name     user    host    db      routine_name    routine_type    grantor proc_priv' $path_out_procs_priv
echo "$sql_procs_priv_tbl;"   >>  $path_file_main_log_users_server
mariadb  --defaults-extra-file=$path_config_mysql_users$in_conn_super_main_server.cnf -e "$sql_procs_priv_tbl" >> $path_file_main_log_users_server 2>$path_file_main_error_log_users_server # &1 
echo "$sql_load_procs_priv_tbl;"   >>  $path_file_main_log_users_server
mariadb  --defaults-extra-file=$path_config_mysql_users$in_conn_super_main_server.cnf -e "$sql_load_procs_priv_tbl" >> $path_file_main_log_users_server 2>$path_file_main_error_log_users_server # &1
echo "insert-update data in fact_mysql_procs_priv about $in_server_name $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_main_log_users_server
mariadb  --defaults-extra-file=$path_config_mysql_users$in_conn_super_main_server.cnf -e "call dw_dba.insert_history_procs_priv('$conn_db_main_temp','$tbl_server_name_procs_priv',$in_server_id) ;" >> $path_file_main_log_users_server 2>$path_file_main_error_log_users_server #&1

echo "End work servername $in_server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_main_log_users_server
