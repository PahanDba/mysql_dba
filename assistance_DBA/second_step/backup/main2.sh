#!/bin/bash
#Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#sudo sed -i -e 's/\r$//' /etc/mysql/dba_scripts/main2.sh
#sudo chown root  /etc/mysql/dba_scripts/main2.sh
#sudo chmod 755  /etc/mysql/dba_scripts/main2.sh
log_path_mysql_main="/var/log/assistant_dba/mysql"
log_init_all="step2_init_all.log"
log_error="get_list_mysqlserver_error.log"
#log_get_list_servers="01_get_list_mysqlserver.log"
log_path_mysql_init="/var/log/assistant_dba/mysql/init"
file_list_alive_mysqlservers="list_alive_mysqlservers.txt"
path_file_list_alive_mysqlservers=$log_path_mysql_init/$file_list_alive_mysqlservers
path_file_init_all=$log_path_mysql_init/$log_init_all
path_file_main_error_log_init_server=$log_path_mysql_init/$log_error
server_name=$HOSTNAME
script_main_dir="/etc/mysql/dba_scripts/init"

run_script="main3.sh"
#sp_main_dir="/etc/mysql/dba_scripts/init/scrips_sql"
#sp_create_db="01_create_db.sql"
#path_create_db=$sp_main_dir/$sp_create_db
conn_db="assistant_dba"
conn_super_main_server="mysql30200"
recipient_mail="you@email_address"
#option trap
set -e
trap 'LAST_COMMAND=$CURRENT_COMMAND; CURRENT_COMMAND=$BASH_COMMAND;' debug 
trap 'ERROR_CODE=$?; ERROR_MESSAGE=`cat $path_file_main_error_log_init_server`; FAILED_COMMAND=$LAST_COMMAND; echo -e "Subject:global error collect data on server_name: $server_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand before error: \"$FAILED_COMMAND\" \nfailed with message: \"$ERROR_MESSAGE \" " | /usr/sbin/sendmail $recipient_mail;' ERR INT TERM
echo "Begin run $script_main_dir/$run_script for each mysql servers from $path_file_list_alive_mysqlservers  in $(date +"%Y%m%d %H:%M:%S")" > $path_file_init_all #$log_path_mysql_main/$log_init_all
if [ -e $script_main_dir/$run_script ]
then
echo "script $script_main_dir/$run_script exists - It's OK" >> $log_path_mysql_main/$log_init_all 
else
echo "script $script_main_dir/$run_script - not exists - Break" > $path_file_main_error_log_init_server
echo -e "Subject:global error collect data on server_name: $server_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand before error: \"$script_main_dir/$run_script\" \nfailed with message: \"script $script_main_dir/$run_script - not exists - Break \" " | /usr/sbin/sendmail $recipient_mail
exit 0
fi

while IFS=$'\t' read -r server_id server_name connection_string ip port
do
#mariadb  --defaults-extra-file=/etc/mysql/conf.d/$server_name.cnf < $path_create_db
source $script_main_dir/$run_script $server_id $server_name $connection_string $ip $port $conn_super_main_server & 2>$path_file_main_error_log_init_server
#/bin/bash $script_main_dir/$run_script $server_id $server_name $connection_string $ip $port $conn_super_main_server &
echo "run script $script_main_dir/$run_script with parametrs $server_id $server_name $connection_string $ip $port in $(date +"%Y%m%d %H:%M:%S")" >> $log_path_mysql_main/$log_init_all 
done < <(tail -n +2 $path_file_list_alive_mysqlservers)
echo "End run $script_main_dir/$run_script for each mysql servers from $path_file_list_alive_mysqlservers  in $(date +"%Y%m%d %H:%M:%S")" >> $log_path_mysql_main/$log_init_all
