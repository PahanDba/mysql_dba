#!/bin/bash
#Get list backup tasks for move to queue for start backup jobs 
#Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#sudo sed -i -e 's/\r$//' /etc/mysql/dba_scripts/backup/backup2_mariabackup.sh
#sudo chown root  /etc/mysql/dba_scripts/backup/backup2_mariabackup.sh
#sudo chmod 755  /etc/mysql/dba_scripts/backup/backup2_mariabackup.sh
#log_path_mysql_main="/var/log/assistant_dba/mysql"
#Block input parametrs : Begin 
in_task_id=$task_id 
in_bt_id=$bt_id
in_backup_type_description=$backup_type_description 
in_creat_time=$creat_time 
in_wait_task_id=$wait_task_id 
in_enable=$enable 
in_file_log=$file_log 
in_server_id=$server_id
in_server_name=$server_name
in_version=$version
in_ip=$ip
in_backup_task_name=$backup_task_name 
in_path_backup=$path_backup 
in_path_last_backup=$path_last_backup 
in_path_last_full_backup=$path_last_full_backup 
in_path_last_incr_backup=$path_last_incr_backup 
in_server_for_backup=$server_for_backup 
in_user_for_backup=$user_for_backup 
in_process_last_full_backup=$process_last_full_backup 
in_prepare_last_full_backup=$prepare_last_full_backup 
in_process_last_incr_backup=$process_last_incr_backup 
in_prepare_last_incr_backup=$prepare_last_incr_backup
log_backup_all="run_backup.log"
log_error=$in_task_id"_error.log"
log_exec_task_id=$in_task_id".log"
log_path_mysql_backup="/var/log/assistant_dba/mysql/backup/backup2"
path_file_list_alive_mysqlservers=$log_path_mysql_backup/$file_list_alive_mysqlservers
path_file_init_all=$log_path_mysql_backup/$log_backup_all
conn_server="mysql30200"
conn_db="assistant_dba"
conn_db_mysql="mysql"
recipient_mail="you@email_address"
path_file_main_error_log_backup_server=$log_path_mysql_backup/$log_error
path_file_main_task_id_log_backup_server=$log_path_mysql_backup/$log_exec_task_id
dir_path1=$(cd $(dirname "${BASH_SOURCE:-$0}") && pwd)
path1=$dir_path1/$(basename "${BASH_SOURCE:-$0}")
path_config_mysql_backup="/etc/mysql/dba_conf/backup/"
path_config_mysql_localhost="/etc/mysql/dba_conf"
message_for_trap="This error may be an exception that I didn't process in the script. Check the log files $log_error and $log_exec_task_id. server_name:$in_server_name backup_task_name:$in_backup_task_name bt_id:$in_bt_id"
tools_run="/usr/bin/mariadb"
tools_backup="/usr/bin/mariadb-backup"
set -e
trap 'LAST_COMMAND=$CURRENT_COMMAND; CURRENT_COMMAND=$BASH_COMMAND;' debug 
trap 'ERROR_CODE=$?; ERROR_MESSAGE=$message_for_trap; FAILED_COMMAND=$LAST_COMMAND; echo -e "Subject:$message_for_trap  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand before error: \"$FAILED_COMMAND\" \nfailed with message: \"$ERROR_MESSAGE \" " | /usr/sbin/sendmail $recipient_mail; $tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e " call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);call assistant_dba.upd_btrm_wait_task_id($in_task_id); call assistant_dba.upd_btm_last_time($in_bt_id);" ' ERR INT TERM
if [ ! -d "$log_path_mysql_backup" ];  then
	 mkdir -p "$log_path_mysql_backup"
fi
remote_port=22
echo "Begin work on $in_ip on $(date +"%Y%m%d %H:%M:%S")" > $path_file_main_task_id_log_backup_server
#I'm be used parametr innodb_log_buffer_size=1G and innodb_log_file_size=10G.
#May be in the future I changed this parameter us calculated vaules
innodb_log_buffer_size_var="1G"
innodb_log_file_size_var="10G"
use_memory="1G"
echo "in_task_id:$in_task_id" >> $path_file_main_task_id_log_backup_server
echo "in_bt_id:$in_bt_id" >> $path_file_main_task_id_log_backup_server
echo "in_backup_type_description:$in_backup_type_description" >> $path_file_main_task_id_log_backup_server
echo "in_creat_time:$in_creat_time" >> $path_file_main_task_id_log_backup_server
echo "in_wait_task_id:$in_wait_task_id" >> $path_file_main_task_id_log_backup_server
echo "in_enable:$in_enable" >> $path_file_main_task_id_log_backup_server
echo "in_file_log:$in_file_log" >> $path_file_main_task_id_log_backup_server
echo "in_server_id:$in_server_id" >> $path_file_main_task_id_log_backup_server
echo "in_server_name:$in_server_name" >> $path_file_main_task_id_log_backup_server
echo "in_version:$in_version" >> $path_file_main_task_id_log_backup_server
echo "in_ip:$in_ip" >> $path_file_main_task_id_log_backup_server
echo "in_backup_task_name:$in_backup_task_name" >> $path_file_main_task_id_log_backup_server
echo "in_path_backup:$in_path_backup" >> $path_file_main_task_id_log_backup_server
echo "in_path_last_backup:$in_path_last_backup" >> $path_file_main_task_id_log_backup_server
echo "in_path_last_full_backup:$in_path_last_full_backup" >> $path_file_main_task_id_log_backup_server
echo "in_path_last_incr_backup:$in_path_last_incr_backup" >> $path_file_main_task_id_log_backup_server
echo "in_server_for_backup:$in_server_for_backup" >> $path_file_main_task_id_log_backup_server
echo "in_user_for_backup:$in_user_for_backup" >> $path_file_main_task_id_log_backup_server
echo "in_process_last_full_backup:$in_process_last_full_backup" >> $path_file_main_task_id_log_backup_server
echo "in_prepare_last_full_backup:$in_prepare_last_full_backup" >> $path_file_main_task_id_log_backup_server
echo "in_process_last_incr_backup:$in_process_last_incr_backup" >> $path_file_main_task_id_log_backup_server
echo "in_prepare_last_incr_backup:$in_prepare_last_incr_backup" >> $path_file_main_task_id_log_backup_server
echo "innodb_log_buffer_size_var:$innodb_log_buffer_size_var" >> $path_file_main_task_id_log_backup_server
echo "innodb_log_file_size_var:$innodb_log_file_size_var" >> $path_file_main_task_id_log_backup_server
echo "use_memory:$use_memory" >> $path_file_main_task_id_log_backup_server
$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_file_log($in_task_id,'$path_file_main_task_id_log_backup_server');"  2>$path_file_main_error_log_backup_server
in_date_start_time=$(date +"%Y-%m-%d %H:%M:%S")
$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_start_time($in_task_id,'$in_date_start_time');"  2>$path_file_main_error_log_backup_server
#I'm checking for availability mariabackup on server database
replace_what_string="mariabackup:"
replace_for_string=""
#in_ip_mariabackup_whereis=$(ssh -p "$remote_port" "$in_user_for_backup@$in_ip" "whereis mariabackup") >> $path_file_main_task_id_log_backup_server 2>$path_file_main_error_log_backup_server
in_ip_mariabackup_whereis=$(ssh -p "$remote_port" "$in_user_for_backup@$in_ip" "whereis mariadb-backup") >> $path_file_main_task_id_log_backup_server 2>$path_file_main_error_log_backup_server
in_ip_mariabackup_whereis_replace_for_check=${in_ip_mariabackup_whereis/$replace_what_string/$replace_for_string}
if [[ ! $in_ip_mariabackup_whereis_replace_for_check = *[!\ ]* ]]; then
	error_message_out="This is server doesn't have mariadb-backup on $in_ip. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name"
	echo "$error_message_out " >> $path_file_main_task_id_log_backup_server
	in_date_end_time=$(date +"%Y-%m-%d %H:%M:%S")
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time($in_task_id,'$in_date_end_time'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100);"  2>$path_file_main_error_log_backup_server 
	echo "backup_tasks_move_from_run_to_log to task_id=$in_task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server	
	echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
	echo "$error_message_out" > $path_file_main_error_log_backup_server
	echo -e "Subject:$error_message_out.  \n\nserver script: $HOSTNAME \npath script: $path1 \nfailed with message: \"$error_message_out \" " | /usr/sbin/sendmail $recipient_mail; 
	exit 1
fi
echo "mariadb-backup whereis from $in_ip $in_ip_mariabackup_whereis" >> $path_file_main_task_id_log_backup_server
#I'm checking for availability mariabackup on server storage backup
replace_what_string="mariadb-backup:"
replace_for_string=""
in_server_for_backup_mariabackup_whereis=$(ssh -p "$remote_port" "$in_user_for_backup@$in_server_for_backup" "whereis mariadb-backup") >> $path_file_main_task_id_log_backup_server 2>$path_file_main_error_log_backup_server
in_server_for_backup_mariabackup_whereis_replace_for_check=${in_server_for_backup_mariabackup_whereis/$replace_what_string/$replace_for_string}
if [[ ! $in_ip_mariabackup_whereis_replace_for_check = *[!\ ]* ]]; then
	error_message_out="This is server doesn't have mariabackup on $in_server_for_backup. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name"
	echo "$error_message_out" >> $path_file_main_task_id_log_backup_server
	in_date_end_time=$(date +"%Y-%m-%d %H:%M:%S")
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time($in_task_id,'$in_date_end_time');call assistant_dba.upd_btrm_task_progress($in_task_id,-100);"  2>$path_file_main_error_log_backup_server 
	echo "backup_tasks_move_from_run_to_log to task_id=$in_task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server	
	echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
	#echo "This is server doesn't have mariabackup on $in_server_for_backup" > $path_file_main_error_log_backup_server
	echo "$error_message_out" > $path_file_main_error_log_backup_server
	echo -e "Subject:$error_message_out.   \n\nserver script: $HOSTNAME \npath script: $path1 \nfailed with message: \"$error_message_out \" " | /usr/sbin/sendmail $recipient_mail; 
	exit 1
fi
echo "mariadb-backup whereis from $in_server_for_backup $in_server_for_backup_mariabackup_whereis" >> $path_file_main_task_id_log_backup_server
#I'm checking for version mariabackup on server database
in_ip_mariabackup_version=$(ssh -p "$remote_port" "$in_user_for_backup@$in_ip" "mariadb-backup -v" 2>&1) >> $path_file_main_task_id_log_backup_server 2>$path_file_main_error_log_backup_server
echo "mariabackup version '$in_ip_mariabackup_version' on $in_ip" >> $path_file_main_task_id_log_backup_server
#I'm checking for version mariabackup on server storage backup
in_server_for_backup_mariabackup_version=$(ssh -p "$remote_port" "$in_user_for_backup@$in_server_for_backup" "mariadb-backup -v"  2>&1) >> $path_file_main_task_id_log_backup_server 2>$path_file_main_error_log_backup_server
echo "mariabackup version '$in_server_for_backup_mariabackup_version' on $in_server_for_backup" >> $path_file_main_task_id_log_backup_server
##############################
#comparison versions for working
in_ip_mariabackup_version_sql=$(awk -F ' ' '{print $6}' <<< $in_ip_mariabackup_version)
in_server_for_backup_mariabackup_version_sql=$(awk -F ' ' '{print $6}' <<< $in_server_for_backup_mariabackup_version)
echo "in_ip_mariabackup_version_sql:$in_ip_mariabackup_version_sql" >> $path_file_main_task_id_log_backup_server
echo "in_server_for_backup_mariabackup_version_sql:$in_server_for_backup_mariabackup_version_sql" >> $path_file_main_task_id_log_backup_server
rezult_comparsion_versions=$($tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -N -D $conn_db -e "call assistant_dba.compare_version_mariabackup('$in_ip_mariabackup_version_sql','$in_server_for_backup_mariabackup_version_sql');"  2>$path_file_main_error_log_backup_server)
echo "rezult_comparsion_versions: $rezult_comparsion_versions" >> $path_file_main_task_id_log_backup_server
rezult_comparsion_versions_good=1
#############################
#if [[ $in_ip_mariabackup_version != $in_server_for_backup_mariabackup_version ]]; then
#if [[ $rezult_comparsion_versions -ne $rezult_comparsion_versions_good ]]; then
if [[ $rezult_comparsion_versions -ne $rezult_comparsion_versions_good ]]; then
	error_message_out="On servers $in_ip and $in_server_for_backup differents versions mariabackup. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name"
	echo "$error_message_out" >> $path_file_main_task_id_log_backup_server
	in_date_end_time=$(date +"%Y-%m-%d %H:%M:%S")
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time($in_task_id,'$in_date_end_time'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100);"  2>$path_file_main_error_log_backup_server 
	echo "backup_tasks_move_from_run_to_log to task_id=$in_task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server	
	echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
	echo "$error_message_out" > $path_file_main_error_log_backup_server
	echo -e "Subject:$error_message_out.   \n\nserver script: $HOSTNAME \npath script: $path1 \nfailed with message: \"$error_message_out \" " | /usr/sbin/sendmail $recipient_mail; 
	exit 1
fi

#I'm checking user in group sudo
sudo_check_server_for_database=$(ssh -p "$remote_port" "$in_user_for_backup@$in_ip" "id -Gn $in_user_for_backup"  2>&1) >> $path_file_main_task_id_log_backup_server 2>$path_file_main_error_log_backup_server
echo "checking user in group sudo $in_user_for_backup@$in_ip, sudo_check_server_for_database:$sudo_check_server_for_database" >> $path_file_main_task_id_log_backup_server
#if grep -q 'sudo|root' $sudo_check_server_for_database; then
if [[ "$sudo_check_server_for_database" == *"root"* ]] || [[ "$sudo_check_server_for_database" == *"sudo"* ]]; then
	echo "user $in_user_for_backup@$in_ip in group sudo, sudo_check_server_for_database:$sudo_check_server_for_database" >> $path_file_main_task_id_log_backup_server
else	
	error_message_out="The user $in_user_for_backup cann't use command sudo on servers $in_ip on ssh. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name"
	echo "$error_message_out" >> $path_file_main_task_id_log_backup_server
	in_date_end_time=$(date +"%Y-%m-%d %H:%M:%S")
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time($in_task_id,'$in_date_end_time'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100);"  2>$path_file_main_error_log_backup_server 
	echo "backup_tasks_move_from_run_to_log to task_id=$in_task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server	
	echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
	#echo "On servers $in_ip and $in_server_for_backup differents versions mariabackup." > $path_file_main_error_log_backup_server
	echo "$error_message_out" > $path_file_main_error_log_backup_server
	echo -e "Subject:$error_message_out.   \n\nserver script: $HOSTNAME \npath script: $path1 \nfailed with message: \"$error_message_out \" " | /usr/sbin/sendmail $recipient_mail; 
	exit 1
fi



#I'm checking the count of core CPUs in the server database.
#If count Core: 
# <4 then parallel=1  pigz=1
# >= 4 <=5 then parallel=1  pigz=2
# >=6 then  parallel=Core/3 Divide by 3 and take an integer number.  pigz=Core/2 Divide by 2 and take an integer number. 
in_ip_cpu_count=$(ssh -p "$remote_port" "$in_user_for_backup@$in_ip" "cat /proc/cpuinfo | grep processor | wc -l" 2>&1) >> $path_file_main_task_id_log_backup_server 2>$path_file_main_error_log_backup_server
if [[ $in_ip_cpu_count -lt 4 ]]; then
in_parallel=1
in_pigz=1
echo "parameter in_parallel=$in_parallel " >> $path_file_main_task_id_log_backup_server
echo "parameter in_pigz=$in_pigz " >> $path_file_main_task_id_log_backup_server
fi
if [[ $in_ip_cpu_count -ge 4 ]] && [[ $in_ip_cpu_count -le 5 ]]; then
in_parallel=1
in_pigz=2
echo "parameter in_parallel=$in_parallel " >> $path_file_main_task_id_log_backup_server
echo "parameter in_pigz=$in_pigz " >> $path_file_main_task_id_log_backup_server
fi
if [[ $in_ip_cpu_count -ge 6 ]] ; then
in_parallel=expr $in_ip_cpu_count / 3
in_pigz=expr $in_ip_cpu_count / 2
echo "parameter in_parallel=$in_parallel " >> $path_file_main_task_id_log_backup_server
echo "parameter in_pigz=$in_pigz " >> $path_file_main_task_id_log_backup_server
fi
#Check galera option
command_for_ssh_galera_check="$tools_run --defaults-extra-file=$path_config_mysql_localhost/localhost.cnf -N -D $conn_db_mysql -e \"select variable_value from information_schema.global_variables where variable_name='wsrep_on';\""  #2>&1 >> $path_file_main_task_id_log_backup_server
#ssh -t -p $remote_port $in_user_for_backup@$in_ip  "$command_for_ssh_galera_check"  >> $path_file_main_task_id_log_backup_server  2>&1 >> $path_file_main_task_id_log_backup_server
galera_check=$(ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_galera_check" 2>&1) >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
echo "galera_check:$galera_check" >> $path_file_main_task_id_log_backup_server
if [[ "$galera_check" == "ON" ]]; then
	galera_option="--galera-info"
	slave_option=" "
fi
if [[ "$galera_check" == "OFF" ]]; then
	galera_option=" "
	slave_option="--slave-info --safe-slave-backup"
fi
echo "galera_option:$galera_option" >> $path_file_main_task_id_log_backup_server
echo "slave_option:$slave_option" >> $path_file_main_task_id_log_backup_server
#Full backup
if [[ "$in_backup_type_description" == "full" ]] ; then
echo "Run FULL backup block" >> $path_file_main_task_id_log_backup_server	
full_path_backup_ssh=$in_path_backup"/full_$(date +"%Y%m%d_%H%M")"
#check_galera=$($tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -N -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server)
echo "full_path_backup_ssh:$full_path_backup_ssh" >> $path_file_main_task_id_log_backup_server
	#This is step 0-1 of all backup process - mkdir for backup.
	command_for_ssh_mkdir="ssh $in_user_for_backup@$in_server_for_backup -t \"if [ ! -d \"$full_path_backup_ssh\" ];  then
		 mkdir -p \"$full_path_backup_ssh\"
	fi \"" 
	echo "command_for_ssh_mkdir:"$command_for_ssh_mkdir >> $path_file_main_task_id_log_backup_server
	subject_error="In mkdir for backup was error. Server_name: $in_server_for_backup task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_mkdir" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	#Can't open dir 
	#failed
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id); "  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
	#This is step 0-2 of all backup process - mkdir for backup.
	command_for_ssh_mkdir_local="if [ ! -d \"$full_path_backup_ssh\" ];  then
		 mkdir -p \"$full_path_backup_ssh\"
	fi " 
	echo "command_for_ssh_mkdir_local:"$command_for_ssh_mkdir_local >> $path_file_main_task_id_log_backup_server
	subject_error="In mkdir for backup was error. Server_name: $in_ip task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_mkdir_local" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	#Can't open dir 
	#failed
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id); "  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
	#This is step 1 of all backup process - execute backup. Only to Full backup task!!!!
	echo "start time execute backup on $in_ip on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	in_date_start_time_backup=$(date +"%Y-%m-%d %H:%M:%S")
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_start_time_backup($in_task_id,'$in_date_start_time_backup');"  2>$path_file_main_error_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_task_progress($in_task_id,5);"  2>$path_file_main_error_log_backup_server
	command_for_ssh="sudo /usr/bin/mariadb-backup --defaults-extra-file=$path_config_mysql_localhost/localhost.cnf --backup --tmpdir=/tmp --parallel=$in_parallel $galera_option $slave_option --innodb_log_buffer_size=$innodb_log_buffer_size_var --innodb_log_file_size=$innodb_log_file_size_var --stream=xbstream --target-dir=/temp/snap | /usr/bin/pigz -f -p $in_pigz | ssh  $in_user_for_backup@$in_server_for_backup  -t \"/usr/bin/pigz -f -dc -p $in_pigz | mbstream -x -C $full_path_backup_ssh --parallel=$in_parallel\" " 
	echo "command_for_ssh:"$command_for_ssh >> $path_file_main_task_id_log_backup_server
	subject_error="In during execute backup was error. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	subject_error="In during execute backup was error"
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
	echo "end time execute backup on $in_ip on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	in_date_end_time_backup=$(date +"%Y-%m-%d %H:%M:%S")
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_backup($in_task_id,'$in_date_end_time_backup');"  2>$path_file_main_error_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_task_progress($in_task_id,65);"  2>$path_file_main_error_log_backup_server
	#This is step 2 of all backup process - prepare backup.
	echo "start time prepare on $in_ip on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	in_date_start_time_prepare=$(date +"%Y-%m-%d %H:%M:%S")
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_start_time_prepare($in_task_id,'$in_date_start_time_prepare');"  2>$path_file_main_error_log_backup_server
	command_for_ssh_prepare="ssh -q $in_user_for_backup@$in_server_for_backup -t \"/usr/bin/mariadb-backup --defaults-extra-file=$path_config_mysql_localhost/localhost.cnf  --prepare -use-memory=$use_memory --target-dir=$full_path_backup_ssh\"" 
	echo "command_for_ssh_prepare:"$command_for_ssh_prepare >> $path_file_main_task_id_log_backup_server
	subject_error="In during prepare backup was error."
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_prepare" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	if grep -q 'ERROR:' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($upd_btrm_wait_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
	echo "end time prepare backup on $in_ip on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	in_date_end_time_backup=$(date +"%Y-%m-%d %H:%M:%S")
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$in_date_end_time_backup');"  2>$path_file_main_error_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time($in_task_id,'$in_date_end_time_backup');"  2>$path_file_main_error_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_task_progress($in_task_id,100);"  2>$path_file_main_error_log_backup_server
	echo "update path_last_full_backup to server_name:$in_server_name on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_bpvm_path_last_full_backup($server_id, '$full_path_backup_ssh');"  2>$path_file_main_error_log_backup_server
	echo "update path_last_incr_backup to server_name:$in_server_name on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	empity_string=""
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_bpvm_path_last_incr_backup($server_id, '$empity_string');"  2>$path_file_main_error_log_backup_server
	echo "backup_tasks_move_from_run_to_log to task_id=$in_task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server	
	echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
	echo "update last_time on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server
	echo "update path_last_full_backup in backup_task_log_mysql on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btlm_path_last_full_backup($in_task_id,'$full_path_backup_ssh');"  2>$path_file_main_error_log_backup_server
	echo "update path_old_incr_backup in backup_task_log_mysql on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btlm_path_old_incr_backup($in_task_id,'$empity_string');"  2>$path_file_main_error_log_backup_server
	echo "update path_cur_incr_backup in backup_task_log_mysql on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btlm_path_cur_incr_backup($in_task_id,'$empity_string');"  2>$path_file_main_error_log_backup_server
	echo "update path_diff_backup in backup_task_log_mysql on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btlm_path_diff_backup($in_task_id,'$empity_string');"  2>$path_file_main_error_log_backup_server
	#This is step 3 copy file xtrabackup from backup server to database server to catalog backup_path_variable_mysql
	command_for_ssh_copy_xtrabackup=" scp $in_user_for_backup@$in_server_for_backup:$full_path_backup_ssh/xtrabackup* $full_path_backup_ssh/ " 
	echo "command_for_ssh_copy_xtrabackup:"$command_for_ssh_copy_xtrabackup >> $path_file_main_task_id_log_backup_server
	subject_error="This is process copy was error. Server_name: $in_ip task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_copy_xtrabackup" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	#Can't open dir 
	#failed
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); "  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
if [[ "$galera_check" == "ON" ]]; then
	#This is step 4 copy file mariadb_backup from backup server to database server to catalog backup_path_variable_mysql
	command_for_ssh_copy_mariadb_backup=" scp $in_user_for_backup@$in_server_for_backup:$full_path_backup_ssh/mariadb_backup* $full_path_backup_ssh/ " 
	echo "command_for_ssh_copy_mariadb_backup:"$command_for_ssh_copy_mariadb_backup >> $path_file_main_task_id_log_backup_server
	subject_error="This is process copy was error. Server_name: $in_ip task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_copy_mariadb_backup" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	#Can't open dir 
	#failed
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); "  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
	#This is step 5 copy file donor_galera_info from backup server to database server to catalog backup_path_variable_mysql
	command_for_ssh_copy_donor_galera_info=" scp $in_user_for_backup@$in_server_for_backup:$full_path_backup_ssh/donor_galera_info* $full_path_backup_ssh/ " 
	echo "command_for_ssh_copy_donor_galera_info:"$command_for_ssh_copy_donor_galera_info >> $path_file_main_task_id_log_backup_server
	subject_error="This is process copy was error. Server_name: $in_ip task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_copy_donor_galera_info" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	#Can't open dir 
	#failed
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); "  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi	
fi
fi
#INCR backup
if [[ "$in_backup_type_description" == "incr" ]] ; then
	echo "Run INCR backup block" >> $path_file_main_task_id_log_backup_server	
	subject_error="For this server: $in_server_name, the full backup task was not performed. task_id:$in_task_id backup task name: $in_backup_task_name  "
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	echo "in_path_last_full_backup:$in_path_last_full_backup" >> $path_file_main_task_id_log_backup_server
	echo "old in_path_last_incr_backup:$in_path_last_incr_backup" >> $path_file_main_task_id_log_backup_server	
	if [ -z "${in_path_last_full_backup}" ] ||  [[ ! $in_path_last_full_backup = *[!\ ]* ]] || [[ "$in_path_last_full_backup" == "NULL" ]] || [[ "$in_path_last_full_backup" == "" ]] || [[ "$in_path_last_full_backup" == " " ]]; then
		echo "$subject_error on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject: $subject_error.   \n\nserver script: $HOSTNAME \npath script: $path1  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi 
	incr_path_backup_ssh=$in_path_last_full_backup"_incr_$(date +"%Y%m%d_%H%M")"
	echo "new in_path_last_incr_backup:$incr_path_backup_ssh" >> $path_file_main_task_id_log_backup_server		
	#This is step 0-1 of all backup process - mkdir for backup.
	command_for_ssh_mkdir="ssh $in_user_for_backup@$in_server_for_backup -t \"if [ ! -d \"$incr_path_backup_ssh\" ];  then
		 mkdir -p \"$incr_path_backup_ssh\"
	fi \"" 
	echo "command_for_ssh_mkdir:"$command_for_ssh_mkdir >> $path_file_main_task_id_log_backup_server
	subject_error="In mkdir for backup was error. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_mkdir" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
	###################################
	#This is step 0-2 of all backup process - mkdir for backup.
	command_for_ssh_mkdir_local="if [ ! -d \"$incr_path_backup_ssh\" ];  then
		 mkdir -p \"$incr_path_backup_ssh\"
	fi " 
	echo "command_for_ssh_mkdir_local:"$command_for_ssh_mkdir_local >> $path_file_main_task_id_log_backup_server
	subject_error="In mkdir for backup was error. Server_name: $in_ip task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_mkdir_local" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	#Can't open dir 
	#failed
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		#echo "In mkdir for backup was error in $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		#echo -e "Subject:In mkdir backup was error. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi	
	#This is step 1 of all backup process - execute backup.
	echo "start time execute backup on $in_ip on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	in_date_start_time_backup=$(date +"%Y-%m-%d %H:%M:%S")
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_start_time_backup($in_task_id,'$in_date_start_time_backup');"  2>$path_file_main_error_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_task_progress($in_task_id,5);"  2>$path_file_main_error_log_backup_server
	if [ -z "${in_path_last_incr_backup}" ] ||  [[ ! $in_path_last_incr_backup = *[!\ ]* ]] || [[ "$in_path_last_incr_backup" == "NULL" ]] || [[ "$in_path_last_incr_backup" == "" ]] || [[ "$in_path_last_incr_backup" == " " ]]; then
		in_path_last_full_backup_for_incr=$in_path_last_full_backup
		echo "in_path_last_full_backup_for_incr:$in_path_last_full_backup_for_incr" >> $path_file_main_task_id_log_backup_server	
	else
		in_path_last_full_backup_for_incr=$in_path_last_incr_backup
		echo "in_path_last_full_backup_for_incr:$in_path_last_full_backup_for_incr" >> $path_file_main_task_id_log_backup_server	
	fi 
	command_for_ssh="sudo /usr/bin/mariadb-backup --defaults-extra-file=$path_config_mysql_localhost/localhost.cnf --backup --tmpdir=/tmp --parallel=$in_parallel $galera_option $slave_option --innodb_log_buffer_size=$innodb_log_buffer_size_var --innodb_log_file_size=$innodb_log_file_size_var --stream=xbstream --target-dir=/temp/snap --incremental-basedir=$in_path_last_full_backup_for_incr | /usr/bin/pigz -f -p $in_pigz | ssh  $in_user_for_backup@$in_server_for_backup  -t \"/usr/bin/pigz -f -dc -p $in_pigz | mbstream -x -C $incr_path_backup_ssh --parallel=$in_parallel\" " 
	echo "command_for_ssh:"$command_for_ssh >> $path_file_main_task_id_log_backup_server
	subject_error="In during execute backup was error. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	subject_error="In during execute backup was error"
	if grep -q 'ERROR:' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
	echo "end time execute backup on $in_ip on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	in_date_end_time_backup=$(date +"%Y-%m-%d %H:%M:%S")
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_backup($in_task_id,'$in_date_end_time_backup');"  2>$path_file_main_error_log_backup_server
#1
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time($in_task_id,'$in_date_end_time_backup');"  2>$path_file_main_error_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_task_progress($in_task_id,100);"  2>$path_file_main_error_log_backup_server
	echo "update path_last_incr_backup to server_name:$in_server_name on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_bpvm_path_last_incr_backup($server_id, '$incr_path_backup_ssh');"  2>$path_file_main_error_log_backup_server
	echo "backup_tasks_move_from_run_to_log to task_id=$in_task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server	
	echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
	echo "update last_time on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server

	echo "update path_last_full_backup in backup_task_log_mysql on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btlm_path_last_full_backup($in_task_id,'$in_path_last_full_backup');"  2>$path_file_main_error_log_backup_server
	echo "update path_old_incr_backup in backup_task_log_mysql on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btlm_path_old_incr_backup($in_task_id,'$in_path_last_incr_backup');"  2>$path_file_main_error_log_backup_server
	echo "update path_cur_incr_backup in backup_task_log_mysql on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btlm_path_cur_incr_backup($in_task_id,'$incr_path_backup_ssh');"  2>$path_file_main_error_log_backup_server
	echo "update path_diff_backup in backup_task_log_mysql on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btlm_path_diff_backup($in_task_id,'""');"  2>$path_file_main_error_log_backup_server
	#This is step 3 copy file xtrabackup from backup server to database server to catalog backup_path_variable_mysql
if [[ "$galera_check" == "OFF" ]]; then	
	command_for_ssh_copy_xtrabackup=" scp $in_user_for_backup@$in_server_for_backup:$incr_path_backup_ssh/xtrabackup* $incr_path_backup_ssh/ " 
	echo "command_for_ssh_copy_xtrabackup:"$command_for_ssh_copy_xtrabackup >> $path_file_main_task_id_log_backup_server
	subject_error="This is process copy was error. Server_name: $in_ip task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_copy_xtrabackup" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	#Can't open dir 
	#failed
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
fi	
if [[ "$galera_check" == "ON" ]]; then
	#This is step 4 copy file mariadb_backup from backup server to database server to catalog backup_path_variable_mysql
	command_for_ssh_copy_mariadb_backup=" scp $in_user_for_backup@$in_server_for_backup:$incr_path_backup_ssh/mariadb_backup* $incr_path_backup_ssh/ " 
	echo "command_for_ssh_copy_mariadb_backup:"$command_for_ssh_copy_mariadb_backup >> $path_file_main_task_id_log_backup_server
	subject_error="This is process copy was error. Server_name: $in_ip task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_copy_mariadb_backup" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	#Can't open dir 
	#failed
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); "  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
	#This is step 5 copy file donor_galera_info from backup server to database server to catalog backup_path_variable_mysql
	command_for_ssh_copy_donor_galera_info=" scp $in_user_for_backup@$in_server_for_backup:$incr_path_backup_ssh/donor_galera_info* $incr_path_backup_ssh/ " 
	echo "command_for_ssh_copy_donor_galera_info:"$command_for_ssh_copy_donor_galera_info >> $path_file_main_task_id_log_backup_server
	subject_error="This is process copy was error. Server_name: $in_ip task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_copy_donor_galera_info" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	#Can't open dir 
	#failed
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); "  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi	
fi
fi
########################################
#DIFF backup
if [[ "$in_backup_type_description" == "diff" ]] ; then
	echo "Run DIFF backup block" >> $path_file_main_task_id_log_backup_server	
	subject_error="For this server: $in_server_name, the full backup task was not performed. task_id:$in_task_id backup task name: $in_backup_task_name  "
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	echo "in_path_last_full_backup:$in_path_last_full_backup" >> $path_file_main_task_id_log_backup_server
	if [ -z "${in_path_last_full_backup}" ] ||  [[ ! $in_path_last_full_backup = *[!\ ]* ]] || [[ "$in_path_last_full_backup" == "NULL" ]] || [[ "$in_path_last_full_backup" == "" ]] || [[ "$in_path_last_full_backup" == " " ]]; then
		echo "$subject_error on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject: $subject_error.   \n\nserver script: $HOSTNAME \npath script: $path1  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi 
	diff_path_backup_ssh=$in_path_last_full_backup"_diff_$(date +"%Y%m%d_%H%M")"
	echo "diff_path_backup_ssh:$diff_path_backup_ssh" >> $path_file_main_task_id_log_backup_server		
	#This is step 0-1 of all backup process - mkdir for backup.
	command_for_ssh_mkdir="ssh $in_user_for_backup@$in_server_for_backup -t \"if [ ! -d \"$diff_path_backup_ssh\" ];  then
		 mkdir -p \"$diff_path_backup_ssh\"
	fi \"" 
	echo "command_for_ssh_mkdir:"$command_for_ssh_mkdir >> $path_file_main_task_id_log_backup_server
	subject_error="In mkdir for backup was error. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_mkdir" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
	###################################
	#This is step 0-2 of all backup process - mkdir for backup.
	command_for_ssh_mkdir_local="if [ ! -d \"$diff_path_backup_ssh\" ];  then
		 mkdir -p \"$diff_path_backup_ssh\"
	fi " 
	echo "command_for_ssh_mkdir_local:"$command_for_ssh_mkdir_local >> $path_file_main_task_id_log_backup_server
	subject_error="In mkdir for backup was error. Server_name: $in_ip task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_mkdir_local" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	#Can't open dir 
	#failed
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		#echo "In mkdir for backup was error in $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		#echo -e "Subject:In mkdir backup was error. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi	
	#This is step 1 of all backup process - execute backup.
	echo "start time execute backup on $in_ip on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	in_date_start_time_backup=$(date +"%Y-%m-%d %H:%M:%S")
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_start_time_backup($in_task_id,'$in_date_start_time_backup');"  2>$path_file_main_error_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_task_progress($in_task_id,5);"  2>$path_file_main_error_log_backup_server
	command_for_ssh="sudo /usr/bin/mariadb-backup --defaults-extra-file=$path_config_mysql_localhost/localhost.cnf --backup --tmpdir=/tmp --parallel=$in_parallel $galera_option $slave_option --innodb_log_buffer_size=$innodb_log_buffer_size_var --innodb_log_file_size=$innodb_log_file_size_var --stream=xbstream --target-dir=/temp/snap --incremental-basedir=$in_path_last_full_backup | /usr/bin/pigz -f -p $in_pigz | ssh  $in_user_for_backup@$in_server_for_backup  -t \"/usr/bin/pigz -f -dc -p $in_pigz | mbstream -x -C $diff_path_backup_ssh --parallel=$in_parallel\" " 
	echo "command_for_ssh:"$command_for_ssh >> $path_file_main_task_id_log_backup_server
	subject_error="In during execute backup was error. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	subject_error="In during execute backup was error"
	if grep -q 'ERROR:' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error. Server_name: $in_server_name task_id:$in_task_id backup task name: $in_backup_task_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
	echo "end time execute backup on $in_ip on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	in_date_end_time_backup=$(date +"%Y-%m-%d %H:%M:%S")
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_backup($in_task_id,'$in_date_end_time_backup');"  2>$path_file_main_error_log_backup_server
#2
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time($in_task_id,'$in_date_end_time_backup');"  2>$path_file_main_error_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_task_progress($in_task_id,100);"  2>$path_file_main_error_log_backup_server
	#echo "update path_last_incr_backup to server_name:$in_server_name on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	#$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_bpvm_path_last_incr_backup($server_id, '$incr_path_backup_ssh');"  2>$path_file_main_error_log_backup_server
	echo "backup_tasks_move_from_run_to_log to task_id=$in_task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server	
	echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
	echo "update last_time on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server

	echo "update path_last_full_backup in backup_task_log_mysql on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btlm_path_last_full_backup($in_task_id,'$in_path_last_full_backup');"  2>$path_file_main_error_log_backup_server
	echo "update path_old_incr_backup in backup_task_log_mysql on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btlm_path_old_incr_backup($in_task_id,'""');"  2>$path_file_main_error_log_backup_server
	echo "update path_cur_incr_backup in backup_task_log_mysql on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btlm_path_cur_incr_backup($in_task_id,'""');"  2>$path_file_main_error_log_backup_server
	echo "update path_diff_backup in backup_task_log_mysql on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btlm_path_diff_backup($in_task_id,'$diff_path_backup_ssh');"  2>$path_file_main_error_log_backup_server
if [[ "$galera_check" == "OFF" ]]; then	
	command_for_ssh_copy_xtrabackup=" scp $in_user_for_backup@$in_server_for_backup:$diff_path_backup_ssh/xtrabackup* $diff_path_backup_ssh/ " 
	echo "command_for_ssh_copy_xtrabackup:"$command_for_ssh_copy_xtrabackup >> $path_file_main_task_id_log_backup_server
	subject_error="This is process copy was error. Server_name: $in_ip task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_copy_xtrabackup" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	#Can't open dir 
	#failed
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); call assistant_dba.upd_btm_last_time($in_bt_id);"  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
fi	
if [[ "$galera_check" == "ON" ]]; then
	#This is step 4 copy file mariadb_backup from backup server to database server to catalog backup_path_variable_mysql
	command_for_ssh_copy_mariadb_backup=" scp $in_user_for_backup@$in_server_for_backup:$diff_path_backup_ssh/mariadb_backup* $diff_path_backup_ssh/ " 
	echo "command_for_ssh_copy_mariadb_backup:"$command_for_ssh_copy_mariadb_backup >> $path_file_main_task_id_log_backup_server
	subject_error="This is process copy was error. Server_name: $in_ip task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_copy_mariadb_backup" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	#Can't open dir 
	#failed
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); "  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi
	#This is step 5 copy file donor_galera_info from backup server to database server to catalog backup_path_variable_mysql
	command_for_ssh_copy_donor_galera_info=" scp $in_user_for_backup@$in_server_for_backup:$diff_path_backup_ssh/donor_galera_info* $diff_path_backup_ssh/ " 
	echo "command_for_ssh_copy_donor_galera_info:"$command_for_ssh_copy_donor_galera_info >> $path_file_main_task_id_log_backup_server
	subject_error="This is process copy was error. Server_name: $in_ip task_id:$in_task_id backup task name: $in_backup_task_name"
	ssh -p $remote_port $in_user_for_backup@$in_ip "$command_for_ssh_copy_donor_galera_info" 2>&1 >> $path_file_main_task_id_log_backup_server 2>&1 >> $path_file_main_task_id_log_backup_server
	date_for_trap=$(date +"%Y-%m-%d %H:%M:%S")
	#Can't open dir 
	#failed
	if grep -q 'ERROR:\|Can''t open dir\|failed' $path_file_main_task_id_log_backup_server; then
		echo "$subject_error on $(date +"%Y %m %d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_end_time_prepare($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_end_time($in_task_id,'$date_for_trap'); call assistant_dba.upd_btrm_task_progress($in_task_id,-100); "  2>$path_file_main_error_log_backup_server
		echo "backup_tasks_move_from_run_to_log on server ip:$in_ip task_id:$in_task_id  on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
		$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server
		echo -e "Subject:$subject_error  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand  " | /usr/sbin/sendmail $recipient_mail;
		exit 1
	fi	
fi		
fi


#######################################
if [[  "$in_backup_type_description" != "diff" ]] && [[ ! "$in_backup_type_description" != "incr" ]] && [[ ! "$in_backup_type_description" != "full" ]] ; then
	echo "This type of backup was not found. Error. " >> $path_file_main_task_id_log_backup_server
	echo "backup_tasks_move_from_run_to_log to task_id=$in_task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.backup_tasks_move_from_run_to_log($in_task_id);"  2>$path_file_main_error_log_backup_server	
	echo "Cleaning wait_task_id=$task_id on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server
	$tools_run --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -D $conn_db -e "call assistant_dba.upd_btrm_wait_task_id($in_task_id);"  2>$path_file_main_error_log_backup_server
	exit 1
fi



echo "End work on $in_ip on $(date +"%Y%m%d %H:%M:%S")" >> $path_file_main_task_id_log_backup_server







