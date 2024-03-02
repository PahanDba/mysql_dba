#!/bin/bash
#Adding backup tasks to the table for running tasks.
#Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#sudo sed -i -e 's/\r$//' /etc/mysql/dba_scripts/backup/backup0.sh
#sudo chown root  /etc/mysql/dba_scripts/backup/backup0.sh
#sudo chmod 755  /etc/mysql/dba_scripts/backup/backup0.sh
log_path_mysql_main="/var/log/assistant_dba/mysql"
log_queue_task_mysql="queue_task_mysql.log"
log_error="queue_task_mysql_error.log"
log_path_mysql_backup="/var/log/assistant_dba/mysql/backup"
path_file_queue_task_mysql=$log_path_mysql_backup/$log_queue_task_mysql
conn_server="mysql30200"
conn_db="assistant_dba"
recipient_mail="you@email_address"
path_file_queue_task_mysql_error=$log_path_mysql_backup/$log_error
server_name=$HOSTNAME
script_main_dir="/etc/mysql/dba_scripts/backup"
path_config_mysql_backup="/etc/mysql/dba_conf/backup/"

#option trap
set -e
trap 'LAST_COMMAND=$CURRENT_COMMAND; CURRENT_COMMAND=$BASH_COMMAND;' debug 
trap 'ERROR_CODE=$?; ERROR_MESSAGE=`cat $path_file_queue_task_mysql_error`; FAILED_COMMAND=$LAST_COMMAND; echo -e "Subject:global Adding backup tasks to the table for running tasks on the server_name: $server_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand before error: \"$FAILED_COMMAND\" \nfailed with message: \"$ERROR_MESSAGE \" " | /usr/sbin/sendmail $recipient_mail;' ERR INT TERM
if [ ! -d "$log_path_mysql_main" ];  then
	 mkdir -p "$log_path_mysql_main"
fi
mariadb --defaults-extra-file=$path_config_mysql_backup$conn_server.cnf -N -D $conn_db -e "call assistant_dba.queue_task_mysql();"  2>$path_file_queue_task_mysql_error


