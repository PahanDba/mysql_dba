
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