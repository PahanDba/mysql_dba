#!/bin/bash
#The bash script for deleting the structure and the services of the add-on for the MariaDB.
# By Pavel A Polikov
# Licensed under MIT
#-- Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#sudo sed -i -e 's/\r$//' /tmp/structure_remove_mariadb.sh
#sudo chown root  /tmp/structure_remove_mariadb.sh
#sudo chmod 755  /tmp/structure_remove_mariadb.sh


sudo systemctl stop data_mariadb; sudo systemctl stop data_top_mariadb;  sudo systemctl stop data_maintenance; sudo systemctl stop data_check_prepare_insert_mariadb.sh;
sudo systemctl disable data_mariadb; sudo systemctl disable data_top_mariadb; sudo systemctl disable data_maintenance; sudo systemctl disable data_check_prepare_insert_mariadb.sh;
sudo rm /etc/systemd/system/data_mariadb.service;
sudo rm /etc/assistant_dba/dba_scripts/monitoring/data_mariadb.sh;
sudo rm /etc/systemd/system/data_mariadb.timer;
sudo rm /etc/systemd/system/data_top_mariadb.service;
sudo rm /etc/assistant_dba/dba_scripts/monitoring/data_top_mariadb.sh;
sudo rm /etc/systemd/system/data_top_mariadb.timer;
sudo rm /etc/systemd/system/data_maintenance.service;
sudo rm /etc/assistant_dba/dba_scripts/monitoring/data_maintenance.sh;
sudo rm /etc/systemd/system/data_maintenance.timer;
sudo rm /etc/systemd/system/data_check_prepare_insert_mariadb.service;
sudo rm /etc/assistant_dba/dba_scripts/monitoring/data_check_prepare_insert_mariadb.sh;
sudo rm /etc/systemd/system/data_check_prepare_insert_mariadb.timer;
sudo rm -rf /etc/assistant_dba;

sudo systemctl daemon-reload;