#!/bin/bash
#Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#input parametrs scripts prefix in_
#sudo sed -i -e 's/\r$//' /etc/mysql/dba_scripts/users/users2_mariadb.sh
#sudo chown root  /etc/mysql/dba_scripts/users/users2_mariadb.sh
#sudo chmod 755  /etc/mysql/dba_scripts/users/users2_mariadb.sh
#Block input parametrs : Begin 

in_server_id=$server_id
in_server_name=$server_name
in_connection_string=$connection_string
in_ip=$ip
in_port=$port
in_version=$version
log_users_all=$server_name"_user_all.log"
log_users_error=$server_name"_user_error.log"
file_users_list=$server_name"_users_list.txt"
file_priveleges_list=$server_name"_privileges_list.txt"
log_path_mysql_user_servername="/var/log/assistant_dba/mysql/users/"$in_server_name
path_file_users_all=$log_path_mysql_user_servername/$log_users_all
path_file_users_error=$log_path_mysql_user_servername/$log_users_error
path_out_users_list=$log_path_mysql_user_servername/$file_users_list
path_out_privileges_list=$log_path_mysql_user_servername/$file_priveleges_list
conn_server="mysql30200"
conn_db_main="assistant_dba"
conn_db_main_temp="assistant_dba_temp"
conn_db_mysql="mysql"
recipient_mail="you@email_address"
dir_path1=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)
path1=$dir_path1/$(basename "${BASH_SOURCE:-$0}")
path_config_mysql_users="/etc/mysql/dba_conf/users/"
tools_run="/usr/bin/mariadb"

#option trap
set -e
trap 'LAST_COMMAND=$CURRENT_COMMAND; CURRENT_COMMAND=$BASH_COMMAND;' debug 
trap 'ERROR_CODE=$?; ERROR_MESSAGE=`cat $path_file_users_error`; FAILED_COMMAND=$LAST_COMMAND; echo -e "Subject:global error on server: $server_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand before error: \"$FAILED_COMMAND\" \nfailed with message: \"$ERROR_MESSAGE \" " | /usr/sbin/sendmail $recipient_mail;' ERR INT TERM
#main script
if [  -d "$log_path_mysql_user_servername" ];  then
        rm  -r "$log_path_mysql_user_servername"
        mkdir -p "$log_path_mysql_user_servername"
else
        mkdir -p "$log_path_mysql_user_servername"
fi
echo "Begin work servername $in_server_name in $(date +"%Y%m%d %H:%M:%S")"  >  $path_file_users_all
echo "Touch $path_file_users_error on $in_server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_users_all
touch $path_file_users_error

#get list users on remote server
query_get_user=("select  "$in_server_id" as server_id, "\"$in_server_name\"" as server_name,user, host, if(ifnull(json_value(\`mysql\`.\`global_priv\`.\`Priv\`,'$.account_locked'),0) = 1,'Y','N') AS \`account_locked\`,
if(ifnull(json_value(\`mysql\`.\`global_priv\`.\`Priv\`,'$.password_last_changed'),1) = 0,'Y','N') AS \`password_expired\`,
elt(ifnull(json_value(\`mysql\`.\`global_priv\`.\`Priv\`,'$.is_role'),0) + 1,'N','Y') AS \`is_role\` 
from mysql.global_priv;
")
#create temporary table users
	tbl_srv_users="tblu_"$in_server_id"_users"
	db_tbl_users="\`"$conn_db_main_temp"\`.\`"$tbl_srv_users"\`"
	query_tbl_users=("drop table if exists $db_tbl_users;
	create table $db_tbl_users (
	server_id INT  NOT NULL,
	server_name nvarchar(255) not null,
	user char(128),
	host char(255),
	locked varchar(1)  NULL,
	password_expired varchar(1) NULL,
	is_role varchar(1) NULL
	);
	")
	query_load_users="LOAD DATA INFILE '$path_out_users_list' INTO TABLE $db_tbl_users FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"
echo "Export users on $server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_users_all 
$tools_run --defaults-extra-file=$path_config_mysql_users$in_server_name.cnf  -e "$query_get_user" > $path_out_users_list 2>$path_file_users_error 
echo "$query_tbl_users $(date +"%Y%m%d %H:%M:%S") "   >>  $path_file_users_all
$tools_run --defaults-extra-file=$path_config_mysql_users$conn_server.cnf -e "$query_tbl_users" >> $path_file_users_all 2>$path_file_users_error # &1 
echo "Import users from on $server_name $query_load_users $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_users_all
$tools_run --defaults-extra-file=$path_config_mysql_users$conn_server.cnf -e "$query_load_users" >> $path_file_users_all 2>$path_file_users_error # &1 
echo "insert-update data in list_mysql_users on $in_server_name $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_users_all
$tools_run  --defaults-extra-file=$path_config_mysql_users$conn_server.cnf -e "call assistant_dba.check_users('$conn_db_main_temp','$tbl_srv_users',$in_server_id) ;" >> $path_file_users_all 2>$path_file_users_error #&1 
echo "export privileges from $in_server_name $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_users_all
$tools_run  --defaults-extra-file=$path_config_mysql_users$in_server_name.cnf -e "call mysql.dba_user_priv_mariadb() ;" > $path_out_privileges_list 2>$path_file_users_error #&1 
#create temporary table privileges
	tbl_srv_priv="tblu_"$in_server_id"_priv"
	db_tbl_priv="\`"$conn_db_main_temp"\`.\`"$tbl_srv_priv"\`"
	query_tbl_priv=("drop table if exists $db_tbl_priv;
	create table $db_tbl_priv (
#	server_id INT  NOT NULL,
#	server_name nvarchar(255) not null,
	user_get char(32),
	host_get char(255),
	database_get char(64),
	table_get char(64),
	col_get char(64),
    role_get char(32),
    grant_admin_role_get char(5),
    grant_stmt longtext,
	data_collect datetime
	);
	")
	query_load_priv="LOAD DATA INFILE '$path_out_privileges_list' INTO TABLE $db_tbl_priv FIELDS TERMINATED BY '\t' LINES TERMINATED BY '\n' IGNORE 1 ROWS;"
echo "query_tbl_priv: $query_tbl_priv;"   >>  $path_file_users_all
$tools_run --defaults-extra-file=$path_config_mysql_users$conn_server.cnf -e "$query_tbl_priv" >> $path_file_users_all 2>$path_file_users_error # &1 
echo "Import users from on $server_name $query_load_priv;"   >>  $path_file_users_all
$tools_run --defaults-extra-file=$path_config_mysql_users$conn_server.cnf -e "$query_load_priv" >> $path_file_users_all 2>$path_file_users_error # &1 
echo "insert into history_mariadb_privileges from $in_server_name $(date +"%Y%m%d %H:%M:%S")"   >>  $path_file_users_all
$tools_run  --defaults-extra-file=$path_config_mysql_users$conn_server.cnf -e "call assistant_dba.save_track_user_permissions_mariadb('$conn_db_main_temp','$tbl_srv_priv',$in_server_id) ;" >> $path_file_users_all 2>$path_file_users_error #&1 
	




echo "End work servername $in_server_name in $(date +"%Y%m%d %H:%M:%S")"  >>  $path_file_users_all

