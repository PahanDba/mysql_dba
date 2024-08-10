#!/bin/bash
#Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#input parametrs scripts prefix in_
#sudo sed -i -e 's/\r$//' /etc/mysql/dba_scripts/users/user0.sh
#sudo chown root  /etc/mysql/dba_scripts/users/user0.sh
#sudo chmod 755  /etc/mysql/dba_scripts/users/user0.sh
log_path_mysql_main="/var/log/assistant_dba/mysql"
log_users_all="users_step1_all.log"
log_error="users_get_list_mysqlserver_error.log"
log_path_mysql_users="/var/log/assistant_dba/mysql/users"
file_list_alive_mysqlservers="users_list_mysqlservers.txt"
path_file_list_alive_mysqlservers=$log_path_mysql_users/$file_list_alive_mysqlservers
path_file_users_all=$log_path_mysql_users/$log_users_all
conn_server="mysql30200"
conn_db="assistant_dba"
recipient_mail="you@email_address"
path_file_main_error_log_users_server=$log_path_mysql_users/$log_error
server_name=$HOSTNAME
path_config_mysql_users="/etc/mysql/dba_conf/users/"
path1=${0}
#option trap
set -e
trap 'LAST_COMMAND=$CURRENT_COMMAND; CURRENT_COMMAND=$BASH_COMMAND;' debug 
trap 'ERROR_CODE=$?; ERROR_MESSAGE=`cat $path_file_main_error_log_users_server`; FAILED_COMMAND=$LAST_COMMAND; echo -e "Subject:global error collect users on server_name: $server_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand before error: \"$FAILED_COMMAND\" \nfailed with message: \"$ERROR_MESSAGE \" " | /usr/sbin/sendmail $recipient_mail;' ERR INT TERM
if [ ! -d "$log_path_mysql_main" ];  then
	 mkdir -p "$log_path_mysql_main"
fi
#date_log=$(date +"%Y%m%d %H:%M")
#echo "Create if not exists directory $log_path_mysql_main in $(date +"%Y%m%d %H:%M:%S")" > $path_file_users_all  #$log_path_mysql_main/$log_name_all
#if [ ! -d "$log_path_mysql_users" ];  then
#         mkdir -p "$log_path_mysql_users"
#else 
#	rm -r "$log_path_mysql_users"
#fi
if [  -d "$log_path_mysql_users" ];  then
	rm -r "$log_path_mysql_users"
	mkdir -p "$log_path_mysql_users"
else
	mkdir -p "$log_path_mysql_users"
fi

#date_log=$(date +"%Y%m%d %H:%M")
echo "Create if not exists directory $log_path_mysql_users $(date +"%Y%m%d %H:%M:%S")" > $path_file_users_all #$log_path_mysql_main/$log_name_all
#export list all mysql servers to file
echo "Start export listt all mysql servers for users in file $path_file_list_alive_mysqlservers $(date +"%Y%m%d %H:%M:%S")"  >> $path_file_users_all

mariadb  --defaults-extra-file=$path_config_mysql_users$conn_server.cnf -D $conn_db -e "call assistant_dba.get_alive_users_server_mysql();" > $path_file_list_alive_mysqlservers 2>$path_file_main_error_log_users_server
echo "End export list all mysql servers for users in file $path_file_list_alive_mysqlservers $(date +"%Y%m%d %H:%M:%S")" >> $path_file_users_all