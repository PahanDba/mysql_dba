#!/bin/bash
#Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#sudo sed -i -e 's/\r$//' /etc/mysql/dba_scripts/main1.sh
#sudo chown root  /etc/mysql/dba_scripts/main1.sh
#sudo chmod 755  /etc/mysql/dba_scripts/main1.sh
log_path_mysql_main="/var/log/assistant_dba/mysql"
log_init_all="step1_init_all.log"
log_error="get_list_mysqlserver_error.log"
#log_get_list_servers="01_get_list_mysqlserver.log"
log_path_mysql_init="/var/log/assistant_dba/mysql/init"
file_list_alive_mysqlservers="list_alive_mysqlservers.txt"
path_file_list_alive_mysqlservers=$log_path_mysql_init/$file_list_alive_mysqlservers
path_file_init_all=$log_path_mysql_init/$log_init_all
conn_server="mysql30200"
conn_db="assistant_dba"
recipient_mail="you@email_address"
path_file_main_error_log_init_server=$log_path_mysql_init/$log_error
server_name=$HOSTNAME
path_config_mysql_init="/etc/mysql/dba_conf/init/"
#option trap
set -e
trap 'LAST_COMMAND=$CURRENT_COMMAND; CURRENT_COMMAND=$BASH_COMMAND;' debug 
trap 'ERROR_CODE=$?; ERROR_MESSAGE=`cat $path_file_main_error_log_init_server`; FAILED_COMMAND=$LAST_COMMAND; echo -e "Subject:global error collect data on server_name: $server_name  \n\nserver script: $HOSTNAME \npath script: $path1 \ncommand before error: \"$FAILED_COMMAND\" \nfailed with message: \"$ERROR_MESSAGE \" " | /usr/sbin/sendmail $recipient_mail;' ERR INT TERM
if [ ! -d "$log_path_mysql_main" ];  then
	 mkdir -p "$log_path_mysql_main"
fi
#date_log=$(date +"%Y%m%d %H:%M")
#echo "Create if not exists directory $log_path_mysql_main in $(date +"%Y%m%d %H:%M:%S")" > $path_file_init_all  #$log_path_mysql_main/$log_name_all
#if [ ! -d "$log_path_mysql_init" ];  then
#         mkdir -p "$log_path_mysql_init"
#else 
#	rm -r "$log_path_mysql_init"
#fi
if [  -d "$log_path_mysql_init" ];  then
	rm -r "$log_path_mysql_init"
	mkdir -p "$log_path_mysql_init"
else
	mkdir -p "$log_path_mysql_init"
fi

#date_log=$(date +"%Y%m%d %H:%M")
echo "Create if not exists directory $log_path_mysql_init $(date +"%Y%m%d %H:%M:%S")" > $path_file_init_all #$log_path_mysql_main/$log_name_all
#export list all mysql servers to file
echo "Start export listt all mysql servers in file $path_file_list_alive_mysqlservers $(date +"%Y%m%d %H:%M:%S")"  >> $path_file_init_all

mariadb  --defaults-extra-file=$path_config_mysql_init$conn_server.cnf -D $conn_db -e "call assistant_dba.get_alive_init_server_mysql();" > $path_file_list_alive_mysqlservers 2>$path_file_main_error_log_init_server
echo "End export list all mysql servers in file $path_file_list_alive_mysqlservers $(date +"%Y%m%d %H:%M:%S")" >> $path_file_init_all

