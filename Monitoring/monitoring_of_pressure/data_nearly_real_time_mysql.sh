#!/bin/bash
#The bash script for data processing of the result of the MySQL.
# By Pavel A Polikov
# Licensed under MIT
#-- Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#sudo sed -i -e 's/\r$//' /etc/assistant_dba/dba_scripts/monitoring/data_nearly_real_time_mysql.sh
#sudo chown root  /etc/assistant_dba/dba_scripts/monitoring/data_nearly_real_time_mysql.sh
#sudo chmod 755  /etc/assistant_dba/dba_scripts/monitoring/data_nearly_real_time_mysql.sh

#Parameters
path_config_mysql_conn="/etc/assistant_dba/conf/monitoring.conf"
#conn string
conn_db_main="assistant_dba"
conn_db_main_temp="assistant_dba_temp"


mysql --defaults-extra-file=$path_config_mysql_conn -e "call assistant_dba.monitoring_of_pressure_nearly_real_time_mysql();" 
