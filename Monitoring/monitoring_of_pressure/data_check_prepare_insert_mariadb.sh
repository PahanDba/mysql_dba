#!/bin/bash
#The bash script executes the following procedures: assistant_dba.`monitoring_of_pressure_insert_mariadb`() and assistant_dba.monitoring_of_pressure_check_prepare_tables_mysql_top.
# By Pavel A Polikov
# Licensed under MIT
#-- Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#sudo sed -i -e 's/\r$//' /etc/assistant_dba/dba_scripts/monitoring/data_check_prepare_insert.sh
#sudo chown root  /etc/assistant_dba/dba_scripts/monitoring/data_check_prepare_insert.sh
#sudo chmod 755  /etc/assistant_dba/dba_scripts/monitoring/data_check_prepare_insert.sh

#Parameters
path_config_mysql_conn="/etc/assistant_dba/conf/monitoring.conf"
#conn string
conn_db_main="assistant_dba"
conn_db_main_temp="assistant_dba_temp"

#Result from mysql
mysql --defaults-extra-file=$path_config_mysql_conn -e "call assistant_dba.monitoring_of_pressure_check_prepare_tables_mysql_top(); call assistant_dba.monitoring_of_pressure_insert_mariadb(); "

