#!/bin/bash
#The bash script for data processing of the result of the tool called 'top'.
# By Pavel A Polikov
# Licensed under MIT
#-- Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#sudo sed -i -e 's/\r$//' /etc/assistant_dba/dba_scripts/monitoring/data_top_mysql.sh
#sudo chown root  /etc/assistant_dba/dba_scripts/monitoring/data_top_mysql.sh
#sudo chmod 755  /etc/assistant_dba/dba_scripts/monitoring/data_top_mysql.sh


#Parameters
path_config_mysql_conn="/etc/assistant_dba/conf/monitoring.conf"
path_config_top="/etc/assistant_dba/conf"
#conn string
conn_db_main="assistant_dba"
conn_db_main_temp="assistant_dba_temp"

#Current value HOME
home_orig=$(echo $HOME)


cpu_count=$(cat /proc/cpuinfo | grep processor | wc -l)
dir_p='/tmp'
date_in=$(date +"%Y-%m-%d %H:%M:%S")
date_p=$(date +"%Y%m%d_%H%M%S")
path_to_export=$dir_p/"top_"$date_p".txt"
tblname_top="top_"$date_p

#Result from top
#TOP_DATA=$(
COLUMNS=512 HOME=$path_config_top top -H -n 2 -d 1 -b | awk -v awk_cpu_count="$cpu_count" -v awk_date_in="$date_in" '
  /^top -/ { snap++ }
  snap == 2 && $2 == "mysql" && $1 ~ /^[0-9]+$/ && $NF ~ /^[0-9]+$/ {
#    print $1","$9","$NF
    print $1","$9",NO,"$12","$NF","awk_cpu_count","awk_date_in
  }' | sed 's/,$/\n/' > $path_to_export
#')


#while IFS=',' read -r tid cpu_top cpuid; do
#  echo "${tid},${cpu_top},${cpuid}"
#done <<< "$TOP_DATA" >> $OUTFILE


#sql scripts
#I created intermediate database if it's doesn't exists.
sql_create_assistant_dba_temp=("SET sql_log_bin = 0; create database if not exists $conn_db_main_temp;")
mysql --defaults-extra-file=$path_config_mysql_conn -e "use mysql; $sql_create_assistant_dba_temp;" 

#I dropping and creating the intermediate table for the data of ps 
sql_drop_tblname_top=("SET sql_log_bin = 0; drop table if exists $conn_db_main_temp.$tblname_top;")
mysql --defaults-extra-file=$path_config_mysql_conn -e "use mysql; $sql_drop_tblname_top;" 
sql_create_tblname_top=("SET sql_log_bin = 0; 
create table $conn_db_main_temp.$tblname_top (tid INT NOT NULL ,cpu_pct decimal(6,2) NOT NULL, collision char(3) NOT NULL, command_top longtext, cpuid int NOT NULL, cpu_count int NOT NULL, date_collect datetime not null, PRIMARY KEY pk__tid_date_collect (tid, date_collect));
")
mysql --defaults-extra-file=$path_config_mysql_conn -e "use mysql; $sql_create_tblname_top;" 

#Load the data from the file to the intermediate table 
sql_load_top=("SET sql_log_bin = 0; LOAD DATA INFILE '$path_to_export' INTO TABLE $conn_db_main_temp.$tblname_top FIELDS TERMINATED BY ','; call  assistant_dba.monitoring_of_pressure_check_pct_per_core_mysql ('$conn_db_main_temp','$tblname_top') ;")
mysql --defaults-extra-file=$path_config_mysql_conn -e "use mysql; $sql_load_top;" 

#sql_drop_tblname_ps=("SET sql_log_bin = 0; drop table if exists $conn_db_main_temp.$tblname_top;")
#mysql --defaults-extra-file=$path_config_mysql_conn -e "use mysql; $sql_drop_tblname_top;" 

#Remove the file
rm $path_to_export

HOME=$home_orig
