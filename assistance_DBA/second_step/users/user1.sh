#!/bin/bash
#Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#input parametrs scripts prefix in_
#sudo sed -i -e 's/\r$//' /etc/mysql/dba_scripts/users/user1.sh
#sudo chown root  /etc/mysql/dba_scripts/users/user1.sh
#sudo chmod 755  /etc/mysql/dba_scripts/users/user1.sh
log_path_mysql_main="/var/log/assistant_dba/mysql"
log_users_all="users_step2_all.log"
log_error="users_run_list_mysqlserver_error.log"
log_path_mysql_users="/var/log/assistant_dba/mysql/users"
file_list_alive_mysqlservers="users_list_mysqlservers.txt"
path_file_list_alive_mysqlservers=$log_path_mysql_users/$file_list_alive_mysqlservers
path_file_users_all=$log_path_mysql_main/$log_users_all
conn_server="mysql30200"
conn_db="assistant_dba"
recipient_mail="you@email_address"
path_file_main_error_log_users_server=$log_path_mysql_users/$log_error
server_name=$HOSTNAME
path_config_mysql_users="/etc/mysql/dba_conf/users/"
conn_db="assistant_dba"
conn_super_main_server="mysql30200"
recipient_mail="you@email_address"
dir_path1=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)
path1=$dir_path1/$(basename "${BASH_SOURCE:-$0}")
run_script_mariadb="users2_mariadb.sh"
run_script_mysql="users2_mysql.sh"
tools_run="/usr/bin/mariadb"
script_main_dir="/etc/mysql/dba_scripts/users"

#echo > $path_file_main_error_log_users_server
#option trap
set -eu
trap 'CURRENT_COMMAND=$BASH_COMMAND; LAST_COMMAND=$CURRENT_COMMAND; ' debug 
trap 'ERROR_CODE=$?; ERROR_MESSAGE=`cat $path_file_main_error_log_users_server`; FAILED_COMMAND=$LAST_COMMAND; echo -e "Subject:global error run script \"$path1\" collect users from server_name: \"$server_name\" \nserver script: \"$HOSTNAME"\ \npath script: \"$path1"\ \ncommand before error: \"$FAILED_COMMAND\" \nfailed with message: \"$ERROR_MESSAGE \" " | /usr/sbin/sendmail $recipient_mail;' ERR INT TERM #EXIT
if [ ! -d "$log_path_mysql_main" ];  then
	 mkdir -p "$log_path_mysql_main"
fi
touch $path_file_main_error_log_users_server
echo "Begin run $path1 for each mysql servers from $path_file_list_alive_mysqlservers  in $(date +"%Y%m%d %H:%M:%S")" > $log_path_mysql_main/$log_users_all
while IFS=$'\t' read -r server_id server_name connection_string ip port version
do
version1=${version,,}
		if [[ "$version1" == *"mariadb"* ]]; then
			if [[ -r "$script_main_dir/$run_script_mariadb" ]]; then
				echo "run $script_main_dir/$run_script_mariadb $server_id $server_name $connection_string $ip $port $version in $(date +"%Y%m%d %H:%M:%S")" >> $log_path_mysql_main/$log_users_all
				source $script_main_dir/$run_script_mariadb $server_id $server_name $connection_string $ip $port $version & 2>$path_file_main_error_log_users_server
			else
				echo "File $script_main_dir/$run_script_mariadb is missing or unreadable.  Exiting." > $path_file_main_error_log_users_server
				#err_msg=`cat $path_file_main_error_log_users_server`				
				err_msg=$(cat $path_file_main_error_log_users_server)
				echo -e "Subject:global error run script collect users from server_name:\"$server_name\" \nserver script: \"$HOSTNAME\" \npath script: \"$path1\" \nfailed with message: \"$err_msg \" " | /usr/sbin/sendmail $recipient_mail
				#exit 0
			fi
		else
			if [[ -r "$script_main_dir/$run_script_mysql" ]]; then
				echo "run $script_main_dir/$run_script_mysql $server_id $server_name $connection_string $ip $port $version in $(date +"%Y%m%d %H:%M:%S")" >> $log_path_mysql_main/$log_users_all
				source $script_main_dir/$run_script_mysql $server_id $server_name $connection_string $ip $port $version & 2>$path_file_main_error_log_users_server
			else
				echo "File $script_main_dir/$run_script_mysql is missing or unreadable.  Exiting." > $path_file_main_error_log_users_server
				err_msg=$(cat $path_file_main_error_log_users_server)
				echo -e "Subject:global error run script collect users from server_name:\"$server_name\" \nserver script: \"$HOSTNAME\" \npath script: \"$path1\" \nfailed with message: \"$err_msg \" " | /usr/sbin/sendmail $recipient_mail
				#exit 0
			fi
		fi
done < <(tail -n +2 $path_file_list_alive_mysqlservers)
echo "End run $path1 for each mysql servers from $path_file_list_alive_mysqlservers  in $(date +"%Y%m%d %H:%M:%S")" >> $log_path_mysql_main/$log_users_all