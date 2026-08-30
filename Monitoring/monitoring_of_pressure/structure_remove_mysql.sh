#!/bin/bash
#The bash script for deleting the structure and the services of the add-on for the MySQL.
# By Pavel A Polikov
# Licensed under MIT
#-- Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#sudo sed -i -e 's/\r$//' /tmp/structure_remove_mysql.sh
#sudo chown root  /tmp/structure_remove_mysql.sh
#sudo chmod 755  /tmp/structure_remove_mysql.sh
sudo systemctl stop data_mysql; sudo systemctl stop data_top_mysql;  sudo systemctl stop data_maintenance; sudo systemctl stop data_check_prepare_insert;
sudo systemctl disable data_mysql; sudo systemctl disable data_top_mysql; sudo systemctl disable data_maintenance; sudo systemctl disable data_check_prepare_insert;
sudo rm /etc/systemd/system/data_mysql.service;
sudo rm /etc/assistant_dba/dba_scripts/monitoring/data_mysql.sh;
sudo rm /etc/systemd/system/data_mysql.timer;
sudo rm /etc/systemd/system/data_top_mysql.service;
sudo rm /etc/assistant_dba/dba_scripts/monitoring/data_top_mysql.sh;
sudo rm /etc/systemd/system/data_top_mysql.timer;
sudo rm /etc/systemd/system/data_maintenance.service;
sudo rm /etc/assistant_dba/dba_scripts/monitoring/data_maintenance.sh;
sudo rm /etc/systemd/system/data_maintenance.timer;
sudo rm /etc/systemd/system/data_check_prepare_insert.service;
sudo rm /etc/assistant_dba/dba_scripts/monitoring/data_check_prepare_insert.sh;
sudo rm /etc/systemd/system/data_check_prepare_insert.timer;
sudo rm -rf /etc/assistant_dba;

sudo systemctl daemon-reload;

