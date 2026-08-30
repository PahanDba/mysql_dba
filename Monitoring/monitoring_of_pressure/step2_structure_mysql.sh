#!/bin/bash
#The bash script for creating the structure.
# By Pavel A Polikov
# Licensed under MIT
#-- Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#sudo sed -i -e 's/\r$//' /tmp/step2_structure_mysql.sh
#sudo chown root  /tmp/step2_structure_mysql.sh
#sudo chmod 755  /tmp/step2_structure_mysql.sh
#I'm checking to see different files in the catalogue /tmp.
if [ -e "/tmp/data_mysql.service" ]; then
    echo "/tmp/data_mysql.service exists. The script will work."
else
	echo "The configuration file data_mysql.service doesn't exist in the directory /tmp. You need to put this file in the directory /tmp."
    exit 1
fi

if [ -e "/tmp/data_mysql.sh" ]; then
    echo "/tmp/data_mysql.sh exists. The script will work."
else
	echo "The configuration file data_mysql.sh doesn't exist in the directory /tmp. You need to put this file in the directory /tmp."
    exit 1
fi

if [ -e "/tmp/data_mysql.timer" ]; then
    echo "/tmp/data_mysql.timer exists. The script will work."
else
	echo "The configuration file data_mysql.timer doesn't exist in the directory /tmp. You need to put this file in the directory /tmp."
    exit 1
fi

if [ -e "/tmp/data_top_mysql.service" ]; then
    echo "/tmp/data_top_mysql.service exists. The script will work."
else
	echo "The configuration file data_top_mysql.service doesn't exist in the directory /tmp. You need to put this file in the directory /tmp."
    exit 1
fi

if [ -e "/tmp/data_top_mysql.sh" ]; then
    echo "/tmp/data_top_mysql.sh exists. The script will work."
else
	echo "The configuration file data_top_mysql.sh doesn't exist in the directory /tmp. You need to put this file in the directory /tmp."
    exit 1
fi

if [ -e "/tmp/data_top_mysql.timer" ]; then
    echo "/tmp/data_top_mysql.timer exists. The script will work."
else
	echo "The configuration file data_top_mysql.timer doesn't exist in the directory /tmp. You need to put this file in the directory /tmp."
    exit 1
fi


if [ -e "/tmp/data_maintenance.service" ]; then
    echo "/tmp/data_maintenance.service exists. The script will work."
else
	echo "The configuration file data_maintenance.service doesn't exist in the directory /tmp. You need to put this file in the directory /tmp."
    exit 1
fi

if [ -e "/tmp/data_maintenance.sh" ]; then
    echo "/tmp/data_maintenance.sh exists. The script will work."
else
	echo "The configuration file data_maintenance.sh doesn't exist in the directory /tmp. You need to put this file in the directory /tmp."
    exit 1
fi

if [ -e "/tmp/data_maintenance.timer" ]; then
    echo "/tmp/data_maintenance.timer exists. The script will work."
else
	echo "The configuration file data_maintenance.timer doesn't exist in the directory /tmp. You need to put this file in the directory /tmp."
    exit 1
fi

if [ -e "/tmp/data_check_prepare_insert_mysql.service" ]; then
    echo "/tmp/data_check_prepare_insert_mysql.service exists. The script will work."
else
	echo "The configuration file data_check_prepare_insert_mysql.service doesn't exist in the directory /tmp. You need to put this file in the directory /tmp."
    exit 1
fi

if [ -e "/tmp/data_check_prepare_insert_mysql.sh" ]; then
    echo "/tmp/data_check_prepare_insert_mysql.sh exists. The script will work."
else
	echo "The configuration file data_check_prepare_insert_mysql.sh doesn't exist in the directory /tmp. You need to put this file in the directory /tmp."
    exit 1
fi

if [ -e "/tmp/data_check_prepare_insert_mysql.timer" ]; then
    echo "/tmp/data_check_prepare_insert_mysql.timer exists. The script will work."
else
	echo "The configuration file data_check_prepare_insert_mysql.timer doesn't exist in the directory /tmp. You need to put this file in the directory /tmp."
    exit 1
fi

if [ -e "/tmp/data_nearly_real_time_mysql.sh" ]; then
    echo "/tmp/data_nearly_real_time_mysql.sh exists. The script will work."
else
	echo "The configuration file data_nearly_real_time_mysql.sh doesn't exist in the directory /tmp. You need to put this file in the directory /tmp."
    exit 1
fi

#I'm copying different files in the special directoryies.

sudo cp /tmp/data_mysql.service /etc/systemd/system/data_mysql.service
sudo cp /tmp/data_mysql.sh /etc/assistant_dba/dba_scripts/monitoring/data_mysql.sh
sudo cp /tmp/data_mysql.timer /etc/systemd/system/data_mysql.timer
sudo cp /tmp/data_top_mysql.service /etc/systemd/system/data_top_mysql.service
sudo cp /tmp/data_top_mysql.sh /etc/assistant_dba/dba_scripts/monitoring/data_top_mysql.sh
sudo cp /tmp/data_top_mysql.timer /etc/systemd/system/data_top_mysql.timer
sudo cp /tmp/data_maintenance.service /etc/systemd/system/data_maintenance.service
sudo cp /tmp/data_maintenance.sh /etc/assistant_dba/dba_scripts/monitoring/data_maintenance.sh
sudo cp /tmp/data_maintenance.timer /etc/systemd/system/data_maintenance.timer
sudo cp /tmp/data_check_prepare_insert_mysql.service /etc/systemd/system/data_check_prepare_insert_mysql.service
sudo cp /tmp/data_check_prepare_insert_mysql.sh /etc/assistant_dba/dba_scripts/monitoring/data_check_prepare_insert_mysql.sh
sudo cp /tmp/data_check_prepare_insert_mysql.timer /etc/systemd/system/data_check_prepare_insert_mysql.timer
sudo cp /tmp/data_nearly_real_time_mysql.sh /etc/assistant_dba/dba_scripts/monitoring/data_nearly_real_time_mysql.sh

#I'm preparing different files to the work.
sudo sed -i -e 's/\r$//' /etc/systemd/system/data_mysql.service
sudo sed -i -e 's/\r$//' /etc/assistant_dba/dba_scripts/monitoring/data_mysql.sh
sudo chown root /etc/assistant_dba/dba_scripts/monitoring/data_mysql.sh
sudo chmod 755  /etc/assistant_dba/dba_scripts/monitoring/data_mysql.sh
sudo sed -i -e 's/\r$//' /etc/systemd/system/data_mysql.timer
sudo sed -i -e 's/\r$//' /etc/systemd/system/data_top_mysql.service
sudo sed -i -e 's/\r$//' /etc/assistant_dba/dba_scripts/monitoring/data_top_mysql.sh
sudo chown root /etc/assistant_dba/dba_scripts/monitoring/data_top_mysql.sh
sudo chmod 755  /etc/assistant_dba/dba_scripts/monitoring/data_top_mysql.sh
sudo sed -i -e 's/\r$//' /etc/systemd/system/data_top_mysql.timer
sudo sed -i -e 's/\r$//' /etc/assistant_dba/dba_scripts/monitoring/data_maintenance.sh
sudo chown root  /etc/assistant_dba/dba_scripts/monitoring/data_maintenance.sh
sudo chmod 755  /etc/assistant_dba/dba_scripts/monitoring/data_maintenance.sh
sudo sed -i -e 's/\r$//' /etc/assistant_dba/dba_scripts/monitoring/data_check_prepare_insert_mysql.sh
sudo chown root  /etc/assistant_dba/dba_scripts/monitoring/data_check_prepare_insert_mysql.sh
sudo chmod 755  /etc/assistant_dba/dba_scripts/monitoring/data_check_prepare_insert_mysql.sh
sudo sed -i -e 's/\r$//' /etc/assistant_dba/dba_scripts/monitoring/data_nearly_real_time_mysql.sh
sudo chown root  /etc/assistant_dba/dba_scripts/monitoring/data_nearly_real_time_mysql.sh
sudo chmod 755  /etc/assistant_dba/dba_scripts/monitoring/data_nearly_real_time_mysql.sh

#I'm enabling different services.
sudo systemctl daemon-reload
sudo systemctl start data_mysql; sudo systemctl start data_top_mysql;  sudo systemctl start data_check_prepare_insert_mysql;
sudo systemctl enable data_mysql; sudo systemctl enable data_top_mysql; sudo systemctl enable data_check_prepare_insert_mysql;
sleep 30
sudo systemctl start data_maintenance; sudo systemctl enable data_maintenance;