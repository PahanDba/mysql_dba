#!/bin/bash
#The bash script for creating the structure.
# By Pavel A Polikov
# Licensed under MIT
#-- Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
#sudo sed -i -e 's/\r$//' /tmp/step1_structure.sh
#sudo chown root  /tmp/step1_structure.sh
#sudo chmod 755  /tmp/step1_structure.sh
#I'm checking to exists the file /home/$USER/.config/procps/toprc
if [ -e "/home/$USER/.config/procps/toprc" ]; then
    echo "The file /home/$USER/.config/procps/toprc exists. The script will work."
else
	echo "The configuration file of top doesn't exist in the directory /home/$USER/.config/procps/. You need to configure the tool called 'top'."
    exit 1
fi



#I'm creating the directory /etc/assistant_dba
if [ -d "/etc/assistant_dba" ]; then
    echo "The directory exists."
else
    sudo mkdir /etc/assistant_dba
fi

#I'm creating the directory /etc/assistant_dba/conf
if [ -d "/etc/assistant_dba/conf" ]; then
    echo "The directory exists."
else
    sudo mkdir /etc/assistant_dba/conf
fi

#I'm creating the directory and subdirectories mkdir /etc/assistant_dba/conf/.config 
if [ -d "/etc/assistant_dba/conf/.config" ]; then
    echo "The directory exists."
else
    sudo mkdir /etc/assistant_dba/conf/.config
	sudo mkdir /etc/assistant_dba/conf/.config/procps
	sudo cp /home/$USER/.config/procps/toprc /etc/assistant_dba/conf/.config/procps/toprc
	sudo sed -i 's/Mode_irixps=0/Mode_irixps=1/' /etc/assistant_dba/conf/.config/procps/toprc
fi



#I'm creating the directory mkdir /etc/assistant_dba/dba_scripts 
if [ -d "/etc/assistant_dba/dba_scripts" ]; then
    echo "The directory exists."
else
    sudo mkdir /etc/assistant_dba/dba_scripts
	sudo mkdir /etc/assistant_dba/dba_scripts/monitoring
fi

#I'm creating the file  /etc/assistant_dba/conf/monitoring.conf
if [ -e "/etc/assistant_dba/conf/monitoring.conf" ]; then
    echo "The file /etc/assistant_dba/conf/monitoring.conf exists. I can't modify this file. You need to remove this file or correct it in the manual mode."
else
    sudo touch /etc/assistant_dba/conf/monitoring.conf
    echo -e '[client]\nhost=ip_your_mysql_server\nport=port_your_mysql_server\nuser=your_user_mysql\npassword=your_password_mysql\n' | sudo tee /etc/assistant_dba/conf/monitoring.conf
fi

