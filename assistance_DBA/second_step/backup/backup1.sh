#!/bin/bash
#Get list backup tasks for move to queue for start backup jobs 
#Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#sudo sed -i -e 's/\r$//' /etc/mysql/dba_scripts/backup/backup1.sh
#sudo chown root  /etc/mysql/dba_scripts/backup/backup1.sh
#sudo chmod 755  /etc/mysql/dba_scripts/backup/backup1.sh
log_path_mysql_main="/var/log/assistant_dba/mysql"
log_backup_all="run_backup.log"
log_error="run_task_error.log"
log_path_mysql_backup="/var/log/assistant_dba/mysql/backup"
path_file_list_alive_mysqlservers=$log_path_mysql_backup/$file_list_alive_mysqlservers
path_file_init_all=$log_path_mysql_backup/$log_backup_all
conn_server="mysql30200"
conn_db="assistant_dba"
recipient_mail="you@email_address"
path_file_main_error_log_backup_server=$log_path_mysql_backup/$log_error
server_name=$HOSTNAME
script_main_dir="/etc/mysql/dba_scripts/backup"
#run_script="backup2.sh"
run_script_mariadb="backup2_mariabackup.sh"
path_config_mysql_backup="/etc/mysql/dba_conf/backup/"
tools_run="/usr/bin/mariadb"
#option trap
set -e
trap 'LAST_COMMAND=$CURRENT_COMMAND; CURRENT_COMMAND=$BASH_COMMAND;' debug 
trap 'ERROR_CODE=$?; ERROR_MESSAGE=`cat $path_file_main_error_log_backup_server`; FAILED_COMMAND=$LAST_COMMAND; echo -e "Subject:global error get queue for backup on server_name: $server_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand before error: \"$FAILED_COMMAND\" \nfailed with message: \"$ERROR_MESSAGE \" " | /usr/sbin/sendmail $recipient_mail;' ERR INT TERM
if [ ! -d "$log_path_mysql_main" ];  then
	 mkdir -p "$log_path_mysql_main"
fi
results_check_count=( $(mariadb  --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -N -D $conn_db -e "call assistant_dba.run_task_mysql(0);"  2>$path_file_main_error_log_backup_server) )
if (( $results_check_count == 0)); then
	echo "Backup tasks for run don't found."
	exit 0
fi
if (( $results_check_count > 0)); then
	echo "Backup tasks were found. This is good a news."
	while ifs=$'\t' read task_id bt_id backup_type_description creat_time wait_task_id enable file_log server_id server_name version ip backup_task_name path_backup path_last_backup path_last_full_backup path_last_incr_backup server_for_backup user_for_backup process_last_full_backup prepare_last_full_backup process_last_incr_backup prepare_last_incr_backup ;do
		version1=${version,,}
		if [[ "$version1" == *"mariadb"* ]]; then
			source $script_main_dir/$run_script_mariadb $task_id $bt_id $backup_type_description $creat_time $wait_task_id $enable $file_log $server_id $server_name $version $ip $backup_task_name $path_backup $path_last_backup $path_last_full_backup $path_last_incr_backup $server_for_backup $user_for_backup $process_last_full_backup $prepare_last_full_backup $process_last_incr_backup $prepare_last_incr_backup & 2>$path_file_main_error_log_backup_server 
		fi
	done  < <($tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -N -D $conn_db -e "call assistant_dba.run_task_mysql(1);"  2>$path_file_main_error_log_backup_server)
fi

