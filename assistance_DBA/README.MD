Assistance DBA system

[**System goals**](#System-goals)  
 
[**System features**](#System-features)

[**List of Servers for Demonstrating the Setup and Operation of the ‘Assistance DBA’ System**](#List-of-Servers-for-Demonstrating)
>    [Server for the ‘Assistance DBA’ system](#Server-system)

>    [Server of backup storage for MariaDB 10.11](#Server-of-backup-storage-for-MariaDB-10_11)    

>    [Server of backup storage for MariaDB 11.3](#Server-of-backup-storage-for-MariaDB-11_3)    

>    [Server MariaDB Galera cluster (3 nodes in a cluster)](#Server-MariaDB-Galera-cluster)    

>    [Server MariaDB standalone](#Server-MariaDB-standalone)    

>    [Server MariaDB standalone (restore from backup)](#Server-MariaDB-standalone-restore)    

>    [Server of backup storage for Percona XtraDB Cluster](#Server-of-backup-storage-for-Percona-XtraDB-Cluster)    

>    [Server Percona XtraDB Cluster (node 1)](#Server-Percona-XtraDB-Cluster-node-1)    

>    [Server Percona XtraDB Cluster (node 2)](#Server-Percona-XtraDB-Cluster-node-1)    

>    [Server Percona XtraDB Cluster (node 3)](#Server-Percona-XtraDB-Cluster-node-1)    

[**Initial system setup**](#Initial-system-setup)

>    [System configuration at the operating system level. Part 1](#System-configuration-at-the-operating-system-level-Part-1)

>    [System configuration at the MariaDB level](#System-configuration-at-the-MariaDB-level)

>    [System configuration at the operating system level. Part 2](#System-configuration-at-the-operating-system-level-Part-2)

>    [Configuration of scripts](#Configuration-of-scripts)

[**Configuration of a config file for the system**](#Configuration-of-a-config-file-for-the-system)

[**An example of adding a new server MariaDB to the system to collect data**](#An-example-of-adding-a-new-server-MariaDB-to-the-system-to-collect-data)

[**An example of adding a new server MySQL/Percona (XtraDB Cluster) to the system to collect data**](#An-example-of-adding-a-new-server-MySQL-Percona-XtraDB-Cluster-to-the-system-to-collect-data)

[**Configuring the backup module**](#Configuring-the-backup-module)

[**Operation of the backup module**](#Operation-of-the-backup-module)

[**Restore from backups**](#Restore-from-backups)

[**The structure of ‘Assistance DBA’ system database**](#The-structure-system-database)

>    [Tables](#Tables)

>    [Stored procedures](#Stored-procedures)

[**Scripts for collected information about the database size from each table each database in server MySQL**](#Scripts-for-collected-information-server-MySQL)

# <a id="System-goals">**System goals**</a>

- It helps MySQL DBAs store historical data about table sizes and global variables of the database server.
- Centralized management of database server backups with access to the history of executed backups.

# <a id="System-features">**System features**</a>

- Developed and tested on the operating systems Debian 11/12 and RDBMS MariDB 10.11.
- Supports and executes backups for MariaDB in various configurations, including standalone servers, Galera clusters, and master-slave replication from both master and slave nodes.
- Consists of bash scripts and stored procedures in MySQL.

# <a id="List-of-Servers-for-Demonstrating">**List of Servers for Demonstrating the Setup and Operation of the ‘Assistance DBA’ System.**</a> 

Below is a list of servers that shows the descriptions for each server with installed software. This list helps to understand and configure the ‘Assistance DBA’ system.

## <a id="Server-system">***Server for the ‘Assistance DBA’ system***</a>  

ServerName: mysql30200   
IP address: 10.10.30.200   
OS: Debian 11/12   
RDBMS: MariaDB 10.11   
Software for executed database backups: mariadb-backup   
Server configuration: 2 CPU, 4GB RAM, 30GB   

## <a id="Server-of-backup-storage-for-MariaDB-10_11">***Server of backup storage for MariaDB 10.11***</a>   

ServerName: mysql30210   
IP address: 10.10.30.210   
OS: Debian 11/12   
RDBMS: MariaDB 10.11   
Software for executed database backups: mariadb-backup   
Server configuration: 12 CPU, 10GB RAM, 200GB   

## <a id="Server-of-backup-storage-for-MariaDB-11_3">***Server of backup storage for MariaDB 11.3***</a> 

ServerName: mysql30211   
IP address: 10.10.30.211   
OS: Debian 11/12   
RDBMS: MariaDB 11.3   
Software for executed database backups: mariadb-backup   
Server configuration: 8 CPU, 10GB RAM, 200GB   

## <a id="Server-MariaDB-Galera-cluster">***Server MariaDB Galera cluster (3 nodes in a cluster)***</a> 

Node 1   
ServerName: mysql30220   
IP address: 10.10.30.220   
OS: Debian 11/12   
RDBMS: MariaDB 11.3   
Software for executed database backups: mariadb-backup   
Server configuration: 2 CPU, 4GB RAM, 50GB   

Node 2   
ServerName: mysql30221   
IP address: 10.10.30.221   
OS: Debian 11/12   
RDBMS: MariaDB 11.3   
Software for executed database backups: mariadb-backup   
Server configuration: 2 CPU, 4GB RAM, 50GB   

Node 3   
ServerName: mysql30222   
IP address: 10.10.30.222   
OS: Debian 11/12   
RDBMS: MariaDB 11.3   
Software for executed database backups: mariadb-backup   
Server configuration: 2 CPU, 4GB RAM, 50GB   

## <a id="Server-MariaDB-standalone">***Server MariaDB standalone***</a> 

ServerName: mysql30226   
IP address: 10.10.30.226   
OS: Debian 11/12   
RDBMS: MariaDB 10.11   
Software for executed database backups: mariadb-backup   
Server configuration: 2 CPU, 4GB RAM, 50GB   

## <a id="Server-MariaDB-standalone-restore">***Server MariaDB standalone (restore from backup)***</a> 

ServerName: mysql30227   
IP address: 10.10.30.227   
OS: Debian 11/12   
RDBMS: MariaDB 11.3   
Software for executed database backups: mariadb-backup   
Server configuration: 2 CPU, 4GB RAM, 50GB   

## <a id="Server-of-backup-storage-for-Percona-XtraDB-Cluster">***Server of backup storage for Percona XtraDB Cluster***</a> 

ServerName: mysql3081   
IP address: 10.10.30.81   
OS: Debian 11/12   
RDBMS:   
Software for executed database backups: xtrabackup version 8.0.35-30   
Server configuration: 2 CPU, 4GB RAM, 50GB   

## <a id="Server-Percona-XtraDB-Cluster-node-1">***Server Percona XtraDB Cluster (node 1)***</a> 

ServerName: mysql3081   
IP address: 10.10.30.81   
OS: Debian 11/12   
RDBMS: 8.0.35-27.1   
Software for executed database backups: xtrabackup version 8.0.35-30   
Server configuration: 2 CPU, 4GB RAM, 50GB   

## <a id="Server-Percona-XtraDB-Cluster-node-2">***Server Percona XtraDB Cluster (node 2)***</a> 

ServerName: mysql3082   
IP address: 10.10.30.82   
OS: Debian 11/12   
RDBMS: 8.0.35-27.1   
Software for executed database backups: xtrabackup version 8.0.35-30   
Server configuration: 2 CPU, 4GB RAM, 50GB   

## <a id="Server-Percona-XtraDB-Cluster-node-3">***Server Percona XtraDB Cluster (node 3)***</a> 

ServerName: mysql3083   
IP address: 10.10.30.83   
OS: Debian 11/12   
RDBMS: 8.0.35-27.1   
Software for executed database backups: xtrabackup version 8.0.35-30   
Server configuration: 2 CPU, 4GB RAM, 50GB   

# <a id="Initial-system-setup">**Initial system setup**</a> 

1. Module for Data Collection.   
\- Collects information about the size of the tables from each database on each database server.   
\- Main module.   

2. Module backup database.   
\- Performs database backups using mariadb-backup.   
\- Allow to perform Full, Differential, and Incremental backup tasks.   
\- Depends on the ‘Module for Data Collection’.   

   Types of backups.   
\- Full backup: It performs a backup which saves data from all schemas and tables on the server, is done once a day.   
\- Diff backup: It performs a backup which saves data since the last Full backup and includes all schemas and tables on the server, is done once a day.   
\- Incr backup: It performs a backup which saves data since the last Full backup or the last Incremental backup and includes all schemas and tables on the server.   

## <a id="System-configuration-at-the-operating-system-level-Part-1">***System configuration at the operating system level. Part 1***</a> 

Configuration of the ‘mysql30200’ server for working with MariaDB and creating users in the operation system.

You need to create a make user user ‘maverick’ in the operating system. The scripts in cron will be executed under this user.

``` bash
bash
yourusername@mysql30200:~$ sudo useradd -m -s /bin/bash -d /home/maverick maverick
yourusername@mysql30200:~$ sudo passwd maverick
maverickP@$$wd12
yourusername@mysql30200:~$ sudo mkdir -m 700 /home/maverick/.ssh
yourusername@mysql30200:~$ sudo chown -R maverick /home/maverick/
yourusername@mysql30200:~$ sudo su maverick
maverick@mysql30200: :~$ ssh-keygen -t rsa
yourusername@mysql30200:~$ sudo apt install mariadb-backup
```

This password, ‘maverickP@$$wd12’, is only a test password.

You need to configure the Sendmail. The Sendmail is used for sending emails. You can use any software to send emails. If you use another software for sending emails instead of Sendmail, you need to change the code for sending emails in all Bash scripts.

An example of configuring Sendmail

```bash
bash
yourusername@mysql30200:~$ sudo apt install sendmail
```

You need to add in the file /etc/mail/sendmail.cf next lines:

```vi
vi
# dnl #
# dnl # Masquerading options
# FEATURE(`always_add_domain')dnl
# MASQUERADE_AS(`hostname_sending_email')dnl
# FEATURE(`allmasquerade')dnl
# FEATURE(`masquerade_envelope')dnl
```

Change ‘hostname_sending_email’ to your server’s name. After changing ‘hostname_sending_email’ you need to execute:

```bash
bash
yourusername@mysql30200:~$ sudo sendmailconfig
```

In my case:

```vi
vi
# dnl #
# dnl # Masquerading options
# FEATURE(`always_add_domain')dnl
# MASQUERADE_AS(`mysql30200.workgroup')dnl
# FEATURE(`allmasquerade')dnl
# FEATURE(`masquerade_envelope')dnl
```

After applying this option, a message about errors will be written in the file /var/mail/username, where ‘username’ is your username.

## <a id="System-configuration-at-the-MariaDB-level">***System configuration at the MariaDB level***</a> 

1. Connect to the server ‘mysql30200’ in MariaDB with privileges for creating objects, users, and grant privileges.
2. Execute the script /first_step/st1_create_structure.sql. This script creates two databases: ‘assistant_dba’ (the main database for the ‘Assistance DBA’ system) and ‘assistant_dba_temp’ (an external database for the ‘Assistance DBA’ system), along with the necessary structure.
3. Execute the script /first_step/st2_grant_on_system.sql. This script creates user ‘maverick’@’%’ with password ‘mysql12’ (Attention!!! You need to change this password.) and grants privileges required for the system's operation.

## <a id="System-configuration-at-the-operating-system-level-Part-2">***System configuration at the operating system level. Part 2***</a> 

1. Connect to the server ‘mysql30200’ via SSH. Create the following directories:

	```bash
	bash
	yourusername@mysql30200:~$ sudo mkdir /etc/mysql/dba_conf
	yourusername@mysql30200:~$ sudo mkdir /etc/mysql/dba_conf/init
	yourusername@mysql30200:~$ sudo mkdir /etc/mysql/dba_conf/backup
	yourusername@mysql30200:~$ sudo mkdir /etc/mysql/dba_scripts
	yourusername@mysql30200:~$ sudo mkdir /var/log/assistant_dba
	yourusername@mysql30200:~$ sudo chown maverick -R /var/log/assistant_dba
	```

2. Copy all files and directories from /second_setup/ to /etc/mysql/dba_scripts. The structure of files and directories should be like this:

	```bash
	bash
	/etc/mysql/dba_scripts/main1.sh
	/etc/mysql/dba_scripts/main2.sh
	/etc/mysql/dba_scripts/backup/backup0.sh
	/etc/mysql/dba_scripts/backup/backup1.sh
	/etc/mysql/dba_scripts/backup/backup2_mariabackup.sh
	/etc/mysql/dba_scripts/init/main3.sh
	```

3. Execute the commands specified in the comments to each file.

	```bash
	bash
	# sudo sed -i -e 's/\\r$//' /etc/mysql/dba_scripts/backup/backup0.sh    
	# sudo chown root /etc/mysql/dba_scripts/backup/backup0.sh    
	# sudo chmod 755 /etc/mysql/dba_scripts/backup/backup0.sh    
	```

	Or you should copy and run the following commands:

	```bash
	bash
	yourusername@mysql30200:~$ sudo sed -i -e 's/\\r$//' /etc/mysql/dba_scripts/main1.sh
	yourusername@mysql30200:~$ sudo chown root /etc/mysql/dba_scripts/main1.sh
	yourusername@mysql30200:~$ sudo chmod 755 /etc/mysql/dba_scripts/main1.sh
	yourusername@mysql30200:~$ sudo sed -i -e 's/\\r$//' /etc/mysql/dba_scripts/main2.sh
	yourusername@mysql30200:~$ sudo chown root /etc/mysql/dba_scripts/main2.sh
	yourusername@mysql30200:~$ sudo chmod 755 /etc/mysql/dba_scripts/main2.sh
	yourusername@mysql30200:~$ sudo sed -i -e 's/\\r$//' /etc/mysql/dba_scripts/init/main3.sh
	yourusername@mysql30200:~$ sudo chown root /etc/mysql/dba_scripts/init/main3.sh
	yourusername@mysql30200:~$ sudo chmod 755 /etc/mysql/dba_scripts/init/main3.sh
	yourusername@mysql30200:~$ sudo sed -i -e 's/\\r$//' /etc/mysql/dba_scripts/backup/backup0.sh
	yourusername@mysql30200:~$ sudo chown root /etc/mysql/dba_scripts/backup/backup0.sh
	yourusername@mysql30200:~$ sudo chmod 755 /etc/mysql/dba_scripts/backup/backup0.sh
	yourusername@mysql30200:~$ sudo sed -i -e 's/\\r$//' /etc/mysql/dba_scripts/backup/backup1.sh
	yourusername@mysql30200:~$ sudo chown root /etc/mysql/dba_scripts/backup/backup1.sh
	yourusername@mysql30200:~$ sudo chmod 755 /etc/mysql/dba_scripts/backup/backup1.sh
	yourusername@mysql30200:~$ sudo sed -i -e 's/\\r$//' /etc/mysql/dba_scripts/backup/backup2_mariabackup.sh
	yourusername@mysql30200:~$ sudo chown root /etc/mysql/dba_scripts/backup/backup2_mariabackup.sh
	yourusername@mysql30200:~$ sudo chmod 755 /etc/mysql/dba_scripts/backup/backup2_mariabackup.sh
	```

	This script will remove unprintable symbols and establish permissions on the file system for executing scripts.

## <a id="Configuration-of-scripts">***Configuration of scripts***</a> 

1. Open files in any editor:

	```vi
	vi
	/etc/mysql/dba_scripts/main1.sh
	/etc/mysql/dba_scripts/main2.sh
	/etc/mysql/dba_scripts/backup/backup0.sh
	/etc/mysql/dba_scripts/backup/backup1.sh
	/etc/mysql/dba_scripts/backup/backup2_mariabackup.sh
	/etc/mysql/dba_scripts/init/main3.sh
	```

2. You need to change the following parameters in the scripts:

- conn_server="mysql30200" # change “mysql30200” to your server name for the ‘Assistance DBA’ system.
- recipient_mail="you@email_address" #change “you@email_address” to your own email to receive messages about errors.

3. Connect to the server ‘mysql30200’ in MariaDB and execute preparatory operations for the registration of servers:

	```sql
	sql
	MariaDB> call `assistant_dba`.`add_new_server_type`('prod'); #Registration of the new types of servers. Example prod, test, developer, analytic.
	MariaDB> call `assistant_dba`.`add_new_sql_type`('mysql'); #Registration of the new types of RDBMS. Example mysql, postgresql, clickhouse.
	MariaDB> call `assistant_dba`.`add_new_cluster`('standalone','only standalone server'); #Registration of the new types of clusters. Example standalone, galera, master-slave.
	```

	If you need to add new values, you need to execute these procedures.

4. For automatic executing scripts, you need to add these scripts to the cron:

	```bash
	bash
	/etc/mysql/dba_scripts/main1.sh
	/etc/mysql/dba_scripts/main2.sh
	```

	Set a schedule to execute it once a day.

	This script is executed first:

	```bash
	bash
	/etc/mysql/dba_scripts/main1.sh
	```

	This script is executed second, in 10 minutes (You should set intervals that depend on your real workload. You may need to increase the interval if the first script takes more theh 10 minutes.)

	```bash
	bash
	/etc/mysql/dba_scripts/main2.sh
	```

	After the proper configuration, this system will gather information about tables (tables of type ‘base table’) from every database server that is registered in the system.

# <a id="Configuration-of-a-config-file-for-the-system">**Configuration of a config file for the system**</a> 

1. Connect to the server ‘Assistance DBA’ (‘mysql30200’). Make a config file with the template /etc/mysql/dba_conf/server_name.cnf.

	Example of the config file server_name.cnf:

	```vi
	vi
	[client]
	host=remote database server MySQL (server name or ip address)
	port=3306
	user=user for connecting to the server MariaDB
	password=user’s password
	```

	In my case, the file name is /etc/mysql/dba_conf/mysql30200.cnf

	```vi
	vi
	[client]
	host=10.10.30.200
	port=3306
	user=maverick
	password=mysql12
	```

	This is a configuration file that is required to connect to the system in MariaDB. For your case, you need to use your own values.

2. You need to register a new server in the system in MariaDB. For example, I registered the ‘mysql30200’ server in the ‘Assistance DBA’ system in order to collect information about it.

	```sql
	sql
	MariaDB> call `assistant_dba`.`add_new_server_mysql`('mysql30200', '10.10.30.200', 'mysql30200', 1, 'prod','mysql',3306, 'system assistant DBA','not add ip address','standalone');
	```

	```sql
	sql
	# server_name_in - short server name
	# ip_in - ip address
	# connection_string - how to you connect server. Usually short server name
	# alive_in - It is =1 if server alive and =0 if server dead
	# server_type_desc_in - type server. You can choise type server from table `assistant_dba`.`list_server_type`
	# sql_type_desc_in - type RDBMS. You can choise type RDBMS from table `assistant_dba`.`list_sql_type`. Until this work only mysql/mariadb.
	# port_in - port for connect server
	# comments_in - Comment for description your server.
	# ip_add_in -extra ip address
	# cluster_name_in - cluster name. You can choise type server from table `assistant_dba`.`list_clusters`
	```

3. Connect to the added server (‘mysql30200’) in MariaDB. You need to create a user; in my case, the host, port, username, and password are in the file /etc/mysql/dba_conf/init/mysql30200.cnf. Execute the script /first_step/st3_grant_on_remote.sql. This script will create a procedure to force analysis of all tables on the server and grant the necessary privileges.
4. Check the registered server on the system. Connect via SSH to the server ‘Assistance DBA’ (server name: ‘mysql30200’, username: ‘maverick’). Execute the first script, /etc/mysql/dba_scripts/main1.sh. If there are errors during script processing, an error file will be generated at /var/log/assistant_dba/mysql/init/get_list_mysqlserver_error.log. If the bash scripts and the post client are configured correctly, you will receive an email at the email address specified in the parameter recipient_mail. If there are no errors during script processing, a file containing the list of servers will be stored at /var/log/assistant_dba/mysql/init/list_alive_mysqlservers.txt.

	If you registered one server, then there will be rows in the file /var/log/assistant_dba/mysql/init/list_alive_mysqlservers.txt

	```vi
	vi
	server_id server_name connection_string ip port
	1 mysql30200 mysql30200 10.10.30.200 3306
	```

	Execute the second script /etc/mysql/dba_scripts/main2.sh.

	This script runs the /etc/mysql/dba_scripts/init/main3.sh script for each server from the /var/log/assistant_dba/mysql/init/list_alive_mysqlservers.txt file.

5. A directory with the server name will be created in the /var/log/assistant_dba/mysql/init/ directory (in my case /var/log/assistant_dba/mysql/init/mysql30200). In this directory, there will be files with intermediate data, an error file (if errors occur) with not zero size and a working log.

	If the scripts are completed without errors, the system will add information about the server. To receive information about servers registered in the system, you need to use the script /first_step/query_release.sql.

# <a id="An-example-of-adding-a-new-server-MariaDB-to-the-system-to-collect-data">**An example of adding a new server MariaDB to the system to collect data**</a> 

To add a new server ‘mysql30226’ to the ‘Assistance DBA’ system, connect to the server ‘mysql30200’ via SSH and create a config file for ‘mysql30226’ /etc/mysql/dba_conf/init/mysql30226.cnf.

```vi
vi
[client]
host=10.10.30.226
port=3306
user=maverick
password=mysql12
```

and register a new server.

```sql
sql
MariaDB> call `assistant_dba`.`add_new_server_mysql`('mysql30226', '10.10.30.226', 'mysql30226', 1, 'prod','mysql',3306, 'system assistant DBA','not add ip address','standalone');
```

Connect to the server ‘mysql30226’ in MariaDB. Execute the script /first_step/st3_grant_on_remote.sql. This script will create a procedure to force analysis of all tables on the server and grant the necessary privileges.

Connect to the server ‘mysql30200’ via SSH. Run the scripts: /etc/mysql/dba_scripts/main1.sh and /etc/mysql/dba_scripts/main2.sh. If the scripts are completed without errors, the system will add information about the server.

# <a id="An-example-of-adding-a-new-server-MySQL-Percona-XtraDB-Cluster-to-the-system-to-collect-data">**An example of adding a new server MySQL/Percona (XtraDB Cluster) to the system to collect data.**</a> 

To add a new server ‘mysql3081’ to the ‘Assistance DBA’ system, connect to the server ‘mysql30200’ via SSH and create a config file for ‘mysql3081’ /etc/mysql/dba_conf/init/mysql3081.cnf.

```vi
vi
[client]
host=10.10.30.81
port=3306
user=maverick
password=mysql12
```

Add of the new types of clusters:

```sql  
sql
MariaDB>CALL `assistant_dba`.`add_new_cluster`('percona cluster','percona xtradb cluster');
```

register the new servers Percona XtraDB Cluster.

```sql
sql
MariaDB>CALL `assistant_dba`.`add_new_server_mysql`('mysql3081', '10.10.30.81', 'mysql3081', 1, 'prod','mysql',3306, 'node 1 percona xtradb cluster','not add ip address','percona cluster');
MariaDB>CALL `assistant_dba`.`add_new_server_mysql`('mysql3082', '10.10.30.82', 'mysql3082', 1, 'prod','mysql',3306, 'node 2 percona xtradb cluster','not add ip address','percona cluster');
MariaDB>CALL `assistant_dba`.`add_new_server_mysql`('mysql3083', '10.10.30.83', 'mysql3083', 1, 'prod','mysql',3306, 'node 3 percona xtradb cluster','not add ip address','percona cluster');
```

Connect to the server ‘mysql3081’ in MySQL. Execute the script /first_step/st3_grant_on_remote.sql. This script will create a procedure to force analysis of all tables on the server and grant the necessary privileges.

Connect to the server ‘mysql30200’ via SSH. Run the scripts: /etc/mysql/dba_scripts/main1.sh and /etc/mysql/dba_scripts/main2.sh. If the scripts are completed without errors, the system will add information about the server.

# <a id="Configuring-the-backup-module">**Configuring the backup module**</a> 

1. To configure the backup module I will use the server that stores the backups. In my case this server is: ‘mysql30210’ – 10.10.30.210. Debian 11/12. MariaDB 10.11, mariadb-backup. 12 CPU, 10GB RAM, 200GB. On this server, mariadb-backup should be installed, which is compatible with the version of mariadb-backup on the database server that will be used for backup. Upon setup, the version compatibility table was initially populated for mariadb-backup 10.11 and compatibility versions 10.11 11 ('10.11.1-MariaDB', '10.11.2-MariaDB', '10.11.3-MariaDB', '10.11.4-MariaDB', '10.11.5-MariaDB', '10.11.6-MariaDB', '10.11.7-MariaDB'). For adding new compatibility versions for mariadb-backup, follow the example provided below.

	For MariaDB
	```sql
	sql
	MariaDB> insert into `assistant_dba`.`version_major_minor_mariadb` (version_number) values ('10.11');
	MariaDB> insert into `assistant_dba`.`version_compability_mariadb` (version_number,id_major_minor) values ('10.11.1-MariaDB', (select id_major_minor from assistant_dba.version_major_minor_mariadb where version_number='10.11')), ('10.11.2-MariaDB', (select id_major_minor from `assistant_dba`.`version_major_minor_mariadb` where version_number='10.11')), ('10.11.3-MariaDB', (select id_major_minor from `assistant_dba`.`version_major_minor_mariadb` where version_number='10.11')), ('10.11.4-MariaDB', (select id_major_minor from `assistant_dba`.`version_major_minor_mariadb` where version_number='10.11')), ('10.11.5-MariaDB', (select id_major_minor from `assistant_dba`.`version_major_minor_mariadb` where version_number='10.11')), ('10.11.6-MariaDB', (select id_major_minor from `assistant_dba`.`version_major_minor_mariadb` where version_number='10.11')), ('10.11.7-MariaDB', (select id_major_minor from `assistant_dba`.`version_major_minor_mariadb` where version_number='10.11'));
	```

	or

	```sql
	MariaDB> call `assistant_dba`.`add_version_major_minor_mariadb`('10.11');
	MariaDB> call `assistant_dba`.`add_version_compability_mariadb`('10.11.1-MariaDB','10.11');
	MariaDB> call `assistant_dba`.`add_version_compability_mariadb`('10.11.2-MariaDB','10.11');
	MariaDB> call `assistant_dba`.`add_version_compability_mariadb`('10.11.3-MariaDB','10.11');
	MariaDB> call `assistant_dba`.`add_version_compability_mariadb`('10.11.4-MariaDB','10.11');
	MariaDB> call `assistant_dba`.`add_version_compability_mariadb`('10.11.5-MariaDB','10.11');
	MariaDB> call `assistant_dba`.`add_version_compability_mariadb`('10.11.6-MariaDB','10.11');
	MariaDB> call `assistant_dba`.`add_version_compability_mariadb`('10.11.7-MariaDB','10.11');
	```

	For Percona/MySQL

	```sql
	sql
	MariaDB> call `assistant_dba`.`add_version_major_minor_mysql_percona`('8.0.35');
	MariaDB> call `assistant_dba`.`add_version_compability_mysql_percona`('8.0.35-30','8.0.35');
	```

2. Will create a backup of ‘mysql30226’ server. Connect to the ‘mysql30210’ server (backup storage server) via SSH and create the user ‘smuggler$postfix’, which will be used to perform the backup. ‘$postfix’ is any identifier that distinguishes different users for performing backups on different database servers. Create a user on the ‘mysql30210’ server – ‘smuggler30226’. Create SSH-key for this user. Create a directory /var/lib/smuggler30226. All backups from the ‘mysql30226’ server will be stored in this directory. Attention: all “weak passwords” are instructions only.

	For MariaDB
	```bash
	bash
	yourusername@mysql30210:~# sudo useradd -m -s /bin/bash -d /home/smuggler30226 smuggler30226
	yourusername@mysql30210:~# sudo mkdir -m 700 /home/smuggler30226/.ssh
	yourusername@mysql30210:~# sudo passwd smuggler30226
	smuggler30226mysql12
	yourusername@mysql30210:~# sudo chown -R smuggler30226 /home/smuggler30226/
	yourusername@mysql30210:~# sudo su smuggler30226
	smuggler30226@mysql30210:/yourusername$ ssh-keygen -t rsa
	smuggler30226@mysql30210:/yourusername$ exit
	yourusername@mysql30210:~# sudo mkdir /var/lib/smuggler30226
	yourusername@mysql30210:~# sudo chown -R smuggler30226 /var/lib/smuggler30226
	yourusername@mysql30210:~# sudo apt install pigz mariadb-backup
	```

	For Percona/MySQL

	Will create a backup of ‘mysql3081’ server. Connect to the ‘mysql3080’ server (backup storage server to Percona/MySQL) via SSH and create the user ‘smuggler$postfix’, which will be used to perform the backup. ‘$postfix’ is any identifier that distinguishes different users for performing backups on different database servers. Create a user on the ‘mysql3080’ server – ‘smuggler3081’. Create SSH-key for this user. Create a directory /var/lib/smuggler3081. All backups from the ‘mysql3081’ server will be stored in this directory. Attention: all “weak passwords” are instructions only.

	```bash
	bash
	yourusername@mysql3080:~# sudo useradd -m -s /bin/bash -d /home/smuggler3081 smuggler3081
	yourusername@mysql3080:~# sudo mkdir -m 700 /home/smuggler3081/.ssh
	yourusername@mysql3080:~# sudo passwd smuggler3081
	smuggler3081mysql12
	yourusername@mysql3080:~# sudo chown -R smuggler3081 /home/smuggler3081/
	yourusername@mysql3080:~# sudo su smuggler3081
	smuggler3081@mysql3080:/yourusername$ ssh-keygen -t rsa
	smuggler3081@mysql3080:/yourusername$ exit
	yourusername@mysql3080:~# sudo mkdir /var/lib/smuggler3081
	yourusername@mysql3080:~# sudo chown -R smuggler3081 /var/lib/smuggler3081
	yourusername@mysql3080:~# sudo apt install pigz percona-xtrabackup-80 lz4 zstd
	```

3. Connect to the server ‘mysql30226’ (Database server) via SSH and make a user in the operation system with the same name as in the previous paragraph. This user will execute the backup process. In my case the user will be named ‘smuggler30226’. Generate an SSH key for the user ‘smuggler30226’. Copy the SSH public key from the ‘mysql30226’ server to the ‘mysql30210’ server. Install ‘pigz’ and ‘mariadb-backup’ on the ‘mysql30226’ server. Add the user ‘smuggler30226’ to the root group and configure sudo without a password prompt. If you don't this operation, database backup won't work. The software ‘setfacl’ won’t help if you change permissions on the directory MySQL and add a new object (the table will be created in the catalog), then the permissions to the new directory won't apply, and the backup will end with an error. In the backup script, ensure that the user is a member of the root and sudo groups. The term "weak passwords" here is for instructional purposes only.
	
	For MariaDB

	```bash
	bash
	yourusername@mysql30226:~# sudo useradd -m -s /bin/bash -d /home/smuggler30226 smuggler30226
	yourusername@mysql30226:~# sudo mkdir -m 700 /home/smuggler30226/.ssh
	yourusername@mysql30226:~# sudo passwd smuggler30226
	smuggler30226mysql12
	yourusername@mysql30226:~# sudo chown -R smuggler30226 /home/smuggler30226/
	yourusername@mysql30226:~# sudo su smuggler30226
	smuggler30226@mysql30226:/yourusername$ ssh-keygen -t rsa
	smuggler30226@mysql30226:/yourusername$ ssh-copy-id -i ~/.ssh/id_rsa.pub smuggler30226@10.10.30.210
	yourusername@mysql30226:~$ sudo apt install pigz mariadb-backup
	yourusername@mysql30226:~$ sudo usermod -a -G root smuggler30226
	yourusername@mysql30226:~$ su -l
	root@mysql30226:~# echo "smuggler30226 ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
	yourusername@mysql30226:~# mkdir /var/lib/smuggler30226
	yourusername@mysql30226:~# chown -R smuggler30226 /var/lib/smuggler30226
	```

	For Percona/MySQL

	Connect to the server ‘mysql3081’ (Database server) via SSH and make a user in the operation system with the same name as in the previous paragraph. This user will execute the backup process. In my case the user will be named ‘smuggler3081’. Generate an SSH key for the user ‘smuggler3081’. Copy the SSH public key from the ‘mysql3081’ server to the ‘mysql3080’ server. Install ‘pigz’, ‘percona-xtrabackup-80’, ‘lz4’, ‘zstd’ on the ‘mysql3081’ server. Add the user ‘smuggler3081’ to the root group and configure sudo without a password prompt. If you don't this operation, database backup won't work. The software setfacl won’t help if you change permissions on the directory MySQL and add a new object (the table will be created in the catalog), then the permissions to the new directory won't apply, and the backup will end with an error. In the backup script, ensure that the user is a member of the root and sudo groups. The term "weak passwords" here is for instructional purposes only.

	```bash
	bash
	yourusername@mysql3081:~# sudo useradd -m -s /bin/bash -d /home/smuggler3081 smuggler3081
	yourusername@mysql3081:~# sudo mkdir -m 700 /home/smuggler3081/.ssh
	yourusername@mysql3081:~# sudo passwd smuggler3081
	smuggler3081mysql12
	yourusername@mysql3081:~# sudo chown -R smuggler3081 /home/smuggler3081/
	yourusername@mysql3081:~# sudo su smuggler3081
	smuggler3081@mysql3081:/yourusername$ ssh-keygen -t rsa
	smuggler3081@mysql3081:/yourusername$ ssh-copy-id -i ~/.ssh/id_rsa.pub smuggler3081@10.10.30.80
	yourusername@mysql3081:~$ sudo apt install pigz percona-xtrabackup-80 lz4 zstd
	yourusername@mysql3081:~$ sudo usermod -a -G root smuggler3081
	yourusername@mysql3081:~$ su -l
	root@mysql3081:~# echo "smuggler3081 ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
	yourusername@mysql3081:~# mkdir /var/lib/smuggler3081
	yourusername@mysql3081:~# chown -R smuggler3081 /var/lib/smuggler3081
	```

4. Connect to the ‘mysql30226’ server (Database server) in MariaDB and create a user with permission to execute backups.

	For MariaDB

	```sql
	sql
	MariaDB> create user 'mariabackup_dba'@'localhost' identified by 'repuse1234';
	MariaDB> grant reload, process, lock tables, binlog monitor on *.* to 'mariabackup_dba'@'localhost';
	MariaDB> grant slave monitor on *.* to 'mariabackup_dba'@'localhost';
	MariaDB> grant connect admin, replication slave admin on *.* to 'mariabackup_dba'@'localhost';
	MariaDB> grant replication client on *.* to 'mariabackup_dba'@'localhost';
	```

	For Percona/MySQL

	Connect to the ‘mysql3081’ server (Database server) in MySQL and create a user with permission to execute backups.

	```sql
	sql
	mysql> create user 'xtrabackup_dba'@'localhost' identified by 'repuse1234';
	mysql> GRANT BACKUP_ADMIN, PROCESS, RELOAD, LOCK TABLES, REPLICATION CLIENT ON *.* TO 'xtrabackup_dba'@'localhost';
	mysql> GRANT SELECT ON performance_schema.log_status TO 'xtrabackup_dba'@'localhost' ;
	mysql> GRANT SELECT ON performance_schema.keyring_component_status TO 'xtrabackup_dba'@'localhost' ;
	mysql> GRANT SELECT ON performance_schema.replication_group_members TO 'xtrabackup_dba'@'localhost' ;
	mysql> FLUSH PRIVILEGES;
	```

5. Connect to the server ‘mysql30226’ (Database server) via SSH. Create a config file for the backup. You need to take the username and password from the previous paragraph.

	For MariaDB

	```bash
	bash
	yourusername@mysql30226:~# sudo mkdir /etc/mysql/dba_conf
	yourusername@mysql30226:~# sudo vi /etc/mysql/dba_conf/localhost.cnf

	vi
	[client]
	host=localhost
	port=3306
	user=mariabackup_dba
	password=repuse1234
	```

	For Percona/MySQL

	Connect to the server ‘mysql3081’ (Database server Percona) via SSH. Create a config file for the backup. You need to take the username and password from the previous paragraph.

	```bash
	bash
	yourusername@mysql3081:~# sudo mkdir /etc/mysql/dba_conf
	yourusername@mysql3081:~# sudo vi /etc/mysql/dba_conf/localhost.cnf

	vi
	[client]
	host=localhost
	port=3306
	user=xtrabackup_dba
	password=repuse1234
	```

6. Connect to the server ‘mysql30200’ (Assistance DBA system) via SSH. You need to exchange SSH-keys between the ‘maverick’ user on ‘mysql30200’ and the ‘smuggler30226’ user on ‘mysql30226’ (Database server). Additionally, exchange SSH keys between the ‘maverick’ user on ‘mysql30200’ and the ‘smuggler30226’ user on ‘mysql30210’ (Backup storage server). These exchanges are necessary for executing backups via SSH from the database server to the backup storage server. This preparation operation saves time during the restoration process from the backup.

	For MariaDB

	```bash
	bash
	maverick@mysql30200$ ssh-copy-id -i ~/.ssh/id_rsa.pub smuggler30226@10.10.30.226
	maverick@mysql30200$ ssh-copy-id -i ~/.ssh/id_rsa.pub smuggler30226@10.10.30.210
	```

	For Percona/MySQL

	Connect to the server ‘mysql30200’ (Assistance DBA system) via SSH. You need to exchange SSH-keys between the ‘maverick’ user on ‘mysql30200’ and the ‘smuggler3081’ user on ‘mysql3081’ (Database server Percona). Additionally, exchange SSH keys between the ‘maverick’ user on ‘mysql30200’ and the ‘smuggler3081’ user on ‘mysql3080’ (Backup storage server). These exchanges are necessary for executing backups via SSH from the database server to the backup storage server. This preparation operation saves time during the restoration process from the backup.

	```bash
	bash
	maverick@mysql30200$ ssh-copy-id -i ~/.ssh/id_rsa.pub smuggler3081@10.10.30.81
	maverick@mysql30200$ ssh-copy-id -i ~/.ssh/id_rsa.pub smuggler3081@10.10.30.80
	```

7. Connect to the server ‘mysql30200’ (Assistance DBA system) in MariaDB. You need to create tasks for the backup for the server ‘mysql30226’.

	For MariaDB

	```sql
	sql
	MariaDB> call `assistant_dba`.`add_backup_path_variable_mysql`('mysql30226', '/var/lib/smuggler30226', '10.10.30.210', 'smuggler30226');
	MariaDB> call `assistant_dba`.`add_backup_task_mysql` ('mysql30226','full',1,1,1,1,1,1,0, '16:50',0,'23:00',1,10);
	MariaDB> call `assistant_dba`.`add_backup_task_mysql` ('mysql30226','diff',1,1,1,1,1,1,0, '2:30',60,'23:00',1,10);
	MariaDB> call `assistant_dba`.`add_backup_task_mysql` ('mysql30226','incr',1,1,1,1,1,1,0, '12:30',120,'23:00',1,10);
	```

	For Percona/MySQL

	Connect to the server ‘mysql30200’ (Assistance DBA system) in MariaDB. You need to create tasks for the backup for the server ‘mysql3081’.

	```sql
	sql
	MariaDB> call `assistant_dba`.`add_backup_path_variable_mysql`('mysql3081', '/var/lib/smuggler3081', '10.10.30.80', 'smuggler3081');
	MariaDB> call `assistant_dba`.`add_backup_task_mysql` ('mysql3081','full',1,1,1,1,1,1,0, '12:50',0,'23:00',1,10);
	MariaDB> call `assistant_dba`.`add_backup_task_mysql` ('mysql3081','diff',1,1,1,1,1,1,0, '2:30',60,'23:00',1,10);
	MariaDB> call `assistant_dba`.`add_backup_task_mysql` ('mysql3081','incr',1,1,1,1,1,1,0, '12:30',120,'23:00',1,10);
	```

	Description of procedure parameters

	```sql
	MariaDB> call `assistant_dba`.`add_backup_task_mysql`('mysql30226','full',1,1,1,1,1,1,0, '16:50',0,'23:00',1,10);
	```
	‘mysql30226’ – server name

	'full'-Type of backups. The possible values: full, diff, incr.

	1 - A sign of a backup progress on this day on Monday. If 1 then the task is executed on this day, if 0 then the task isn’t executed on this day.

	1 - A sign of a backup progress on this day on Tuesday. If 1 then the task is executed on this day, if 0 then the task isn’t executed on this day.

	1 - A sign of a backup progress on this day on Wednesday. If 1 then the task is executed on this day, if 0 then the task isn’t executed on this day.

	1 - A sign of a backup progress on this day on Thursday. If 1 then the task is executed on this day, if 0 then the task isn’t executed on this day.

	1 - A sign of a backup progress on this day on Friday. If 1 then the task is executed on this day, if 0 then the task isn’t executed on this day.

	1 - A sign of a backup progress on this day on Saturday. If 1 then the task is executed on this day, if 0 then the task isn’t executed on this day.

	0 - A sign of a backup progress on this day on Sunday. If 1 then the task is executed on this day, if 0 then the task isn’t executed on this day. 

	'16:50' – This is the time when the backup task should start running for the first time on this day.

	0 – The interval at which the backup task is executed, again in minutes. The possible values range from 0 to 720. This value is equal to 0 for the full backup task. This value may be greater than 0 for the diff backup tasks; if you need to execute this task more than once a day. If the diff backup task interval equals 0, then the interval equals 1440. If the incr backup task interval equals 0, then the interval equals 60.

	'23:00' – This is the time when the backup task should end running on this day. Attention! If the task is of full backup type, the start time is always equal to the task end time. If you change the end time value in the manual mode in the table, some errors may occur.

	1 –active task. If the value equals 1, the task is enabled; if the value equals 0, the task is disabled.

	10 – The period of backup files storage in days. In the future, I will probably add automatic deletion of old backup files of tasks.

	To add tasks for backup, always first add tasks of full backup type. If the full backup task isn't created, the procedure doesn't add tasks of incr or diff types for this database server.

	8. Create a config file with a parameter of connecting to the server ‘Assistance DBA system’ in the directory /etc/mysql/dba_conf/backup/. In my case, I created a config file at etc/mysql/dba_conf/backup/mysql30200.cnf.

	```vi
	vi
	[client]
	host=10.10.30.200
	port=3306
	user=maverick
	password=mysql12
	```

9. Create a directory on the server ‘mysql30200’ (Assistance DBA system) for the log files ‘Assistance DBA’ system and grant permissions to the user ‘maverick’. The bash scripts will be executed from the user ‘maverick’.

	```bash
	bash
	yourusername@mysql30226:~# sudo mkdir /var/log/assistant_dba/
	yourusername@mysql30226:~# sudo chown -R maverick /var/log/assistant_dba/
	```

# <a id="Operation-of-the-backup-module">**Operation of the backup module.**</a> 

1. Connect to the server ‘mysql30200’ in MariaDB as the user who created the database structure. Execute the query

	```sql
	sql
	MariaDB> select * from `assistant_dba`.`backup_task_mysql`;
	```

	Query processing result

	| **\# bt_id** | **backup_task_name** | **server_id** | **backup_type_id** | **Monday** | **Tuesday** | **Wednesday** | **Thursday** | **Friday** | **Saturday** | **Sunday** | **start_time** | **interval_min** | **end_time** | **last_time** | **next_time** | **enable** | **storage_time_days** |
	| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
	| 1   | mysql30226_full | 2   | 1   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 16:50:00 | 0   | 16:50:00 | &nbsp; | &nbsp; | 1   | 10  |
	| 2   | mysql30226_diff | 2   | 2   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 2:30:00 | 60  | 23:00:00 | &nbsp; | &nbsp; | 1   | 10  |
	| 3   | mysql30226_incr | 2   | 3   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 12:30:00 | 120 | 23:00:00 | &nbsp; | &nbsp; | 1   | 10  |

	bt_id – The number of the backup task in the system.

	backup_task_name – The backup task name in the form of servername_typebackup.

	server_id – server_id from assistant_dba.list_server.

	backup_type_id - backup_type_id from assistant_dba.backup_type_mysql.

	| **\# backup_type_id** | **backup_type_description** | **backup_type_comments** |
	| --- | --- | --- |
	| 1   | full | Full backup. It performs a backup which saves data from all schemas and tables on the server, is done once a day. |
	| 2   | diff | Diff backup. It performs a backup which saves data since the last Full backup and includes all schemas and tables on the server, is done once a day. |
	| 3   | incr | Incr backup. It performs a backup which saves data since the last Full backup or the last Incremental backup and includes all schemas and tables on the server. |

	Columns from Monday to Sunday indicate the work on these days.

	Start_time, interval_min, end_time – See the description above.

	Last_time – This is the last start task time.

	Next_time – This is the next start task time.

	Enable – This task is enabled. Indication of the enabled task.

	Storage_time_days - This parameter indicates the number of days for backup files are storage on the storage server. In the future, this parameter will be used to delete old backup files.

	The query result shows that the tasks weren’t executed.

	These scripts below move tasks to the queue for execution and launch:

	```bash
	bash
	/etc/mysql/dba_scripts/backup/backup0.sh
	/etc/mysql/dba_scripts/backup/backup1.sh
	```

	This script, /etc/mysql/dba_scripts/backup/backup0.sh creates a new record in the table for the queue for execution and launch.

	This script, /etc/mysql/dba_scripts/backup/backup1.sh sends tasks for execution.

2. Connect to the server ‘mysql30200’ as the user ‘maverick’ via SSH (or switch to the sessions of the user ‘maverick’). Execute the script /etc/mysql/dba_scripts/backup/backup0.sh. When you execute the script in manual mode via SSH, you will get the following result:

	```bash
	bash
	maverick@mysql30200:/home/yourusername$ date
	Sun Feb 25 02:29:13 PM MSK 2024
	maverick@mysql30200:/home/yourusername$
	maverick@mysql30200:/home/yourusername$ /etc/mysql/dba_scripts/backup/backup0.sh
	+-----------------------+------+------+---------------------+
	| This is backup task: | full | 1 | 2024-02-26 16:50:00 |
	+-----------------------+------+------+---------------------+
	maverick@mysql30200:/home/yourusername$
	```

	You can see information: type of backup - full, bt_id -1, the next start time task - 2024-02-26 16:50:00.

3. You can check that the script was executed. Connect to the server ‘mysql30200’ in MariaDB. Execute this query:

	```sql
	sql
	MariaDB> select * from `assistant_dba`.`backup_task_mysql`;
	```

	You get the result.

	| **\# bt_id** | **backup_task_name** | **server_id** | **backup_type_id** | **Monday** | **Tuesday** | **Wednesday** | **Thursday** | **Friday** | **Saturday** | **Sunday** | **start_time** | **interval_min** | **end_time** | **last_time** | **next_time** | **enable** | **storage_time_days** |
	| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
	| 1   | mysql30226_full | 2   | 1   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 16:50:00 | 0   | 16:50:00 | &nbsp; | 26.02.2024 16:50 | 1   | 10  |
	| 2   | mysql30226_diff | 2   | 2   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 2:30:00 | 60  | 23:00:00 | &nbsp; | &nbsp; | 1   | 10  |
	| 3   | mysql30226_incr | 2   | 3   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 12:30:00 | 120 | 23:00:00 | &nbsp; | &nbsp; | 1   | 10  |

	You can see that for the task ‘bt_id=1’ there is a record in the column ‘next_time’. It means that next time for running this task is at 16:50 26.02.2024 (the start time of this script /etc/mysql/dba_scripts/backup/backup0.sh is Sun Feb 25 02:29:13 PM MSK 2024).

	Execute this query:

	```sql
	sql
	MariaDB> select * from `assistant_dba`.`backup_task_run_mysql`;
	```

	You get the result.

	| **\# task_id** | **bt_id** | **creat_time** | **start_time** | **start_time_backup** | **end_time_backup** | **start_time_prepare** | **end_time_prepare** | **end_time** | **wait_task_id** | **task_progress** | **enable** | **file_log** |
	| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
	| 1   | 1   | 25.02.2024 14:16 | &nbsp; | &nbsp; | &nbsp; | &nbsp; | &nbsp; | &nbsp; | &nbsp; | &nbsp; | 1   | &nbsp; |

	Description of the result

	Task_id – This is the counter for all tasks that are executed or will be executed.

	Bt_id – This is backup task id from \`assistant_dba\`.\`backup_task_mysql\`

	Creat_time – This is the time when the task was added to the table \`assistant_dba\`.\`backup_task_run_mysql\`

	Start_time – This is the time when the task was launched

	Start_time_backup – This is the time when the backup started

	end_time_backup – This is the time when the backup ended

	Start_time_prepare – This is the time when the prepare backup started. Applicable for full backups only. Used to save time when you restore from a backup.

	end_time_ prepare – This is the time when the prepare backup ended. Applicable for full backups only. Used to save time when you restore from a backup.

	Wait_task_id – Shows which \`task_id\` blocks this task. It limits to execution of backup tasks from one server. At a time, only one backup task can be executed on one database server: a full backup or a diff backup, or an incr backup.

	Task_progress – Shows the conditional values of the task execution process.

	Enable – This sign indicates whether this task needs to be processed. If 0 then the task is skip, if 1 then task will be processed.

	File_log – Shows the log file name. The log file name has a template, task_id.log. A log error file is always created from a template, task_id_error.log. If the task was executed without errors, then the file takes 0 bytes. If the task was executed with errors, then the file size is more than 0 bytes. A few errors aren't recorded in the log error file. For example, I couldn't catch an error when the service MySQL didn't start.

4. Execute this script /etc/mysql/dba_scripts/backup/backup1.sh. In the manual mode run via SSH you get two results:

	If there were tasks in queue for execution:

	```bash
	bash
	maverick@mysql30200:/home/yourusername$ /etc/mysql/dba_scripts/backup/backup1.sh
	Backup tasks were found. This is good a news.
	maverick@mysql30200:/home/yourusername$
	```

	If there were no tasks for execution:

	```bash
	bash
	maverick@mysql30200:/home/yourusername$ /etc/mysql/dba_scripts/backup/backup1.sh
	Backup tasks for run don't found.
	maverick@mysql30200:/home/yourusername$
	```

	After task ended, execute the next queries:

	```sql
	sql
	MariaDB> select * from assistant_dba.backup_path_variable_mysql;
	```

	| **\# id** | **server_id** |     | **path_backup** | **path_last_full_backup** | **path_last_incr_backup** | **server_for_backup** | **user_for_backup** |
	| --- | --- | --- | --- | --- | --- | --- | --- |
	| 1   | 2   |     | /var/lib/smuggler30226 | /var/lib/smuggler30226/full_20240225_1450 | &nbsp; | 10.10.30.210 | smuggler30226 |

	id – auto_increment

	server_id – server_id from \`assistant_dba\`.\`list_server\`

	path_backup – directory for the backup files. Added by the procedure: call \`assistant_dba\`.\`add_backup_path_variable_mysql\`('mysql30226', '/var/lib/smuggler30226', '10.10.30.210', 'smuggler30226');

	path_last_full_backup – directory, where the full backup was executed.

	path_last_incr_backup – directory, where the last incr backup was executed.

	server_for_backup –Backup storage server for backups on this database server. Added by the procedure: call \`assistant_dba\`.\`add_backup_path_variable_mysql\`('mysql30226', '/var/lib/smuggler30226', '10.10.30.210', 'smuggler30226');

	user_for_backup – user which starts mariadb-backup via SSH. Added by the procedure: call \`assistant_dba\`.\`add_backup_path_variable_mysql\`('mysql30226', '/var/lib/smuggler30226', '10.10.30.210', 'smuggler30226');

	```sql
	sql
	MariaDB> select * from `assistant_dba`.`backup_task_mysql`;
	```

	| **\# bt_id** | **backup_task_name** | **server_id** | **backup_type_id** | **Monday** | **Tuesday** | **Wednesday** | **Thursday** | **Friday** | **Saturday** | **Sunday** | **start_time** | **interval_min** | **end_time** | **last_time** | **next_time** | **enable** | **storage_time_days** |
	| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
	| 1   | mysql30226_full | 2   | 1   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 16:50:00 | 0   | 16:50:00 | 25.02.2024 14:50 | 26.02.2024 16:50 | 1   | 10  |
	| 2   | mysql30226_diff | 2   | 2   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 2:30:00 | 60  | 23:00:00 | &nbsp; | &nbsp; | 1   | 10  |
	| 3   | mysql30226_incr | 2   | 3   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 12:30:00 | 120 | 23:00:00 | &nbsp; | &nbsp; | 1   | 10  |

	After completing the task, an entry will appear in the ‘last_time’ column. This is the time when the task was last launched. This record is updated after completing the task.

	```sql
	sql
	MariaDB> select * from `assistant_dba`.`backup_task_run_mysql`;
	```

	This query gets an empty result when you don't execute any tasks or there are no tasks in the queue for execution.

	```sql
	sql
	MariaDB> select * from `assistant_dba`.`backup_task_log_mysql`;
	```

	| **\# task_id** | **bt_id** | **creat_time** | **start_time** | **start_time_backup** | **end_time_backup** | **start_time_prepare** | **end_time_prepare** | **end_time** | **wait_task_id** | **task_progress** | **enable** | **file_log** | **path_last_full_backup** | **path_old_incr_backup** | **path_cur_incr_backup** | **path_diff_backup** |
	| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
	| 1   | 1   | 25.02.2024 14:16 | 25.02.2024 14:49 | 25.02.2024 14:50 | 25.02.2024 14:50 | 25.02.2024 14:50 | 25.02.2024 14:50 | 25.02.2024 14:50 | &nbsp; | 100 | 1   | /var/log/assistant_dba/mysql/backup/backup2/1.log | /var/lib/smuggler30226/full_20240225_1450 | &nbsp; | &nbsp; | &nbsp; |

	After ending the task, with or without errors, the information about the task moves from the table \`assistant_dba\`.\`backup_task_run_mysql\` to the table \`assistant_dba\`.\`backup_task_log_mysql\`.

	The task processing log can be seen in the files /var/log/assistant_dba/mysql/backup/backup2/1.log and /var/log/assistant_dba/mysql/backup/backup2/1_error.log

5. Execute the script /etc/mysql/dba_scripts/backup/backup0.sh in manual mode via SSH in the session of the user ‘maverick’ on the server ‘mysql30200’.

	```bash
	bash
	maverick@mysql30200:/home/yourusername$ /etc/mysql/dba_scripts/backup/backup0.sh
	+-----------------------+------+------+---------------------+
	| This is backup task: | diff | 2 | 2024-02-26 02:30:00 |
	+-----------------------+------+------+------+
	+-----------------------+------+------+---------------------+
	| This is backup task: | incr | 3 | 2024-02-26 12:30:00 |
	+-----------------------+------+------+---------------------+
	maverick@mysql30200:/home/yourusername$
	```

	The result of completing the script:

	‘bt_id=2’, the time of the next launch of the task ‘task_id=2’ at 2024-02-26 02:30:00 is calculated;

	‘bt_id=3’, the time of the next launch of the task ‘task_id=3’ at 2024-02-26 12:30:00 is calculated;

	Execute queries

	```sql
	sql
	MariaDB> select * from `assistant_dba`.`backup_task_mysql`;
	```

	| **\# bt_id** | **backup_task_name** | **server_id** | **backup_type_id** | **Monday** | **Tuesday** | **Wednesday** | **Thursday** | **Friday** | **Saturday** | **Sunday** | **start_time** | **interval_min** | **end_time** | **last_time** | **next_time** | **enable** | **storage_time_days** |
	| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
	| 1   | mysql30226_full | 2   | 1   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 16:50:00 | 0   | 16:50:00 | 25.02.2024 14:50 | 26.02.2024 16:50 | 1   | 10  |
	| 2   | mysql30226_diff | 2   | 2   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 2:30:00 | 60  | 23:00:00 | &nbsp; | 26.02.2024 02:30 | 1   | 10  |
	| 3   | mysql30226_incr | 2   | 3   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 12:30:00 | 120 | 23:00:00 | &nbsp; | 26.02.2024 12:30 | 1   | 10  |

	You can see values in the column the ‘next_time’ for the ‘bt_id=2’ and ‘bt_id=3’.

	```sql
	sql
	MariaDB> select * from `assistant_dba`.`backup_task_run_mysql`;
	```

	| **\# task_id** | **bt_id** | **creat_time** | **start_time** | **start_time_backup** | **end_time_backup** | **start_time_prepare** | **end_time_prepare** | **end_time** | **wait_task_id** | **task_progress** | **enable** | **file_log** |
	| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
	| 2   | 2   | 25.02.2024 15:29 | &nbsp; | &nbsp; | &nbsp; | &nbsp; | &nbsp; | &nbsp; | &nbsp; | &nbsp; | 1   | &nbsp; |
	| 3   | 3   | 25.02.2024 15:29 | &nbsp; | &nbsp; | &nbsp; | &nbsp; | &nbsp; | &nbsp; | 2   | &nbsp; | 1   | &nbsp; |

	For the task ‘task_id=3’ in the column ‘wait_task_id’ the value is 2. This shows that the task ‘task_id=3’ won’t start until ‘task_id=2’ ends.

	6. Connect to the server ‘mysql30200’ as the user ‘maverick’ (or switch to the sessions of the user ‘maverick’). Execute this script /etc/mysql/dba_scripts/backup/backup1.sh.

	The result:

	```bash
	bash
	maverick@mysql30200:/home/yourusername$ /etc/mysql/dba_scripts/backup/backup1.sh
	Backup tasks were found. This is good a news.
	maverick@mysql30200:/home/yourusername$
	```

7. You can execute script /etc/mysql/dba_scripts/backup/backup1.sh in manual mode until you get the message that there are no startup tasks:

	```bash
	bash
	maverick@mysql30200:/home/yourusername$ /etc/mysql/dba_scripts/backup/backup1.sh
	Backup tasks for run don't found.
	maverick@mysql30200:/home/yourusername$
	```

	Execute queries

	```sql
	sql
	MariaDB> select * from `assistant_dba`.`backup_path_variable_mysql`;
	```

	| **\# id** | **server_id** | **path_backup** | **path_last_full_backup** | **path_last_incr_backup** | **server_for_backup** | **user_for_backup** |
	| --- | --- | --- | --- | --- | --- | --- |
	| 1   | 2   | /var/lib/smuggler30226 | /var/lib/smuggler30226/full_20240225_1450 | /var/lib/smuggler30226/full_20240225_1450_incr_20240225_1547 | 10.10.30.210 | smuggler30226 |

	The value is added to the column path_last_incr_backup.

	```sql
	sql
	MariaDB> select * from `assistant_dba`.`backup_task_mysql`;
	```

	| **\# bt_id** | **backup_task_name** | **server_id** | **backup_type_id** | **Monday** | **Tuesday** | **Wednesday** | **Thursday** | **Friday** | **Saturday** | **Sunday** | **start_time** | **interval_min** | **end_time** | **last_time** | **next_time** | **enable** | **storage_time_days** |
	| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
	| 1   | mysql30226_full | 2   | 1   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 16:50:00 | 0   | 16:50:00 | 25.02.2024 14:50 | 26.02.2024 16:50 | 1   | 10  |
	| 2   | mysql30226_diff | 2   | 2   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 2:30:00 | 60  | 23:00:00 | 25.02.2024 15:45 | 26.02.2024 2:30 | 1   | 10  |
	| 3   | mysql30226_incr | 2   | 3   | 1   | 1   | 1   | 1   | 1   | 1   | 0   | 12:30:00 | 120 | 23:00:00 | 25.02.2024 15:47 | 26.02.2024 12:30 | 1   | 10  |

	```sql
	sql
	MariaDB> select * from `assistant_dba`.`backup_task_run_mysql`;
	```

	The result will be empty if there aren't any tasks in the queue or being executed.

	```sql
	sql
	MariaDB> select * from `assistant_dba`.`backup_task_log_mysql`;
	```

	| **\# task_id** | **bt_id** | **creat_time** | **start_time** | **start_time_backup** | **end_time_backup** | **start_time_prepare** | **end_time_prepare** | **end_time** | **wait_task_id** | **task_progress** | **enable** | **file_log** | **path_last_full_backup** | **path_old_incr_backup** | **path_cur_incr_backup** | **path_diff_backup** |
	| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
	| 1   | 1   | 25.02.2024 14:16 | 25.02.2024 14:49 | 25.02.2024 14:50 | 25.02.2024 14:50 | 25.02.2024 14:50 | 25.02.2024 14:50 | 25.02.2024 14:50 | &nbsp; | 100 | 1   | /var/log/assistant_dba/mysql/backup/backup2/1.log | /var/lib/smuggler30226/full_20240225_1450 | &nbsp; | &nbsp; | &nbsp; |
	| 2   | 2   | 25.02.2024 15:29 | 25.02.2024 15:45 | 25.02.2024 15:45 | 25.02.2024 15:45 | &nbsp; | &nbsp; | 25.02.2024 15:45 | &nbsp; | 100 | 1   | /var/log/assistant_dba/mysql/backup/backup2/2.log | /var/lib/smuggler30226/full_20240225_1450 | &nbsp; | &nbsp; | /var/lib/smuggler30226/full_20240225_1450_diff_20240225_1545 |
	| 3   | 3   | 25.02.2024 15:29 | 25.02.2024 15:47 | 25.02.2024 15:47 | 25.02.2024 15:47 | &nbsp; | &nbsp; | 25.02.2024 15:47 | &nbsp; | 100 | 1   | /var/log/assistant_dba/mysql/backup/backup2/3.log | /var/lib/smuggler30226/full_20240225_1450 | NULL | /var/lib/smuggler30226/full_20240225_1450_incr_20240225_1547 | &nbsp; |

	This result shows where the backup is stored.

	The template of directory name for backup tasks.

	For full task: full_YYYYMMDD_HHMM, Example full_20240225_1450

	For diff task: full_YYYYMMDD_HHMM_diff_YYYYMMDD_HHMM, for example full_20240225_1450_ diff_20240225_1545

	For incr task: full_YYYYMMDD_HHMM_incr_YYYYMMDD_HHMM, for example full_20240225_1450_ incr_20240225_1545

	Attention: The directories are created on the storage backup server and store backup files. The directories are created on the database server and store the following files: xtrabackup\*, donor_galera_info, or mariadb_backup\*, depending on the MariaDB/MySQL/Percona configuration.

	To enable the backup module, you need to add tasks to the cron session for the user ‘maverick’ for the following scripts: /etc/mysql/dba_scripts/backup/backup0.sh and /etc/mysql/dba_scripts/backup/backup1.sh. It is recommended to schedule these tasks to run once a minute.

# <a id="Restore-from-backups">**Restore from backups.**</a> 

When restoring databases from backups, it's important to remember that the preparation operation ready been completed for full backups. For incremental or differential backups, you need to follow the typical procedure for restoration. For example, I will restore the backup database from the server ‘mysql30220’.

1. Execute this query on the server ‘mysql30200’. (Assistant DBA system)

	```sql
	sql
	select ls.server_name, bpvm.path_backup, bpvm.server_for_backup, bpvm.user_for_backup
	from `assistant_dba`.`backup_path_variable_mysql` bpvm
	join `assistant_dba`.`list_server` ls
	on ls.server_id=bpvm.server_id
	where ls.server_name='mysql30220';
	```

	The result

	| **\# server_name** | **path_backup** | **server_for_backup** | **user_for_backup** |
	| --- | --- | --- | --- |
	| mysql30220 | /var/lib/smuggler30220 | 10.10.30.211 | smuggler30220 |

2. Will restore backups to the server ‘mysql30227’ (standalone server). This server functions as a standalone MariaDB server. Connect to the server ‘mysql30211’ via SSH.
3. Get the list of ‘mysql30220’ server backups:

	```bash
	bash
	yourusername@mysql30211:~$ sudo ls -la /var/lib/smuggler30220/
	full_20240228_2133
	full_20240228_2133_diff_20240228_2137
	full_20240228_2133_diff_20240229_1054
	full_20240228_2133_incr_20240229_1045
	full_20240228_2133_incr_20240229_1059
	```

4. Copy directories from the result above from the server ‘mysql30211’ to the server ‘mysql30227’ in the directory /tmp or any other directory.

	The example for coping

	```bash
	bash
	sudo scp -r /var/lib/smuggler30220 yourusername@10.10.30.227:/tmp
	```

5. Connect to the server ‘mysql30227’ via SSH. You need to restore the backup from full_20240228_2133_incr_20240229_1059. The full backup full_20240228_2133 is ready to be restored. You need to restore all incremental backups sequentially. In my case, they are: full_20240228_2133_incr_20240229_1045 and full_20240228_2133_incr_20240229_1059. Execute the following commands in the shell:

	```bash
	bash
	yourusername@mysql30227:~$ sudo /usr/bin/mariadb-backup --prepare --target-dir=/tmp/smuggler30220/full_20240228_2133 --incremental-dir=/tmp/smuggler30220/full_20240228_2133_incr_20240229_1045
	```
	After the command completion the last line will be the following:

	```bash
	bash
	completed OK!
	```

	For Percona/MySQL

	The restore process for Percona/MySQL is similar to that of MariaDB. The difference between the restore process for Percona/MySQL and that of MariaDB is the command ‘xtrabackup’ and the parameter ‘--apply-log-only’.

	```bash
	bash
	yourusername@mysql30227:~$ sudo /usr/bin/xtrabackup --prepare --apply-log-only -use-memory=1G --target-dir=/tmp/smuggler3081/full_20240325_2044
	```

	After complete command last string will be:

	```bash
	bash
	completed OK!
	```

6. Execute the second command for the next incremental backup:

	```bash
	bash
	yourusername@mysql30227:~$ sudo /usr/bin/mariadb-backup --prepare --target-dir=/tmp/smuggler30220/full_20240228_2133 --incremental-dir=/tmp/smuggler30220/full_20240228_2133_incr_20240229_1059
	```

	After the command completion the last line will be the following:

	```bash
	bash
	completed OK!
	```

	For Percona/MySQL

	Execute the second command for the next incremental backup

	```bash
	bash
	yourusername@mysql30227:~$ sudo /usr/bin/xtrabackup --prepare --apply-log-only -use-memory=1G --target-dir=/tmp/smuggler3081/full_20240325_2044 --incremental-dir=/tmp/smuggler3081/full_20240325_2044_incr_20240325_2056
	```

	After the command completion the last line will be the following:

	```bash
	bash
	completed OK!
	```

	For Percona/MySQL

	Execute the third command for the next incremental backup

	```bash
	bash
	yourusername@mysql30227:~$ sudo /usr/bin/xtrabackup --prepare --apply-log-only -use-memory=1G --target-dir=/tmp/smuggler3081/full_20240325_2044 --incremental-dir=/tmp/smuggler3081/full_20240325_2044_incr_20240326_1104
	```

	After the command completion the last line will be the following:

	```bash
	bash
	completed OK!
	```

7. You need to stop the MySQL service and check its status. The MySQL service must be stopped.

	```bash
	bash
	yourusername@mysql30227:~$ sudo systemctl stop mysql
	yourusername@mysql30227:~$ sudo systemctl status mysql
	```

8. Remove all files and directories from catalog mysql.

	```bash
	bash
	yourusername@mysql30227:~$ sudo rm -rf /var/lib/mysql/\*
	```

9. Copy all directories and files from /tmp/smuggler30220/full_20240228_2133 to /var/lib/mysql/ and grant privileges.

	```bash
	bash
	yourusername@mysql30227:~$ sudo cp -r /tmp/smuggler30220/full_20240228_2133/\* /var/lib/mysql
	yourusername@mysql30227:~$ sudo chown -R mysql:mysql /var/lib/mysql
	```

10. Start service MySQL and check the log:

	```bash
	bash
	yourusername@mysql30227:~$ sudo systemctl start mysql
	yourusername@mysql30227:~$ sudo tail -f /var/log/mysql/error.log
	2024-03-02 18:00:14 0 [Note] InnoDB: File './ibtmp1' size is now 12.000MiB.
	2024-03-02 18:00:14 0 [Note] InnoDB: log sequence number 213752; transaction id 83
	2024-03-02 18:00:14 0 [Note] Plugin 'FEEDBACK' is disabled.
	2024-03-02 18:00:14 0 [Note] InnoDB: Loading buffer pool(s) from /var/lib/mysql/ib_buffer_pool
	2024-03-02 18:00:14 0 [Note] Plugin 'wsrep-provider' is disabled.
	2024-03-02 18:00:14 0 [Note] Server socket created on IP: '127.0.0.1'.
	2024-03-02 18:00:14 0 [Note] InnoDB: Buffer pool(s) load completed at 240302 18:00:14
	2024-03-02 18:00:14 0 [Note] mariadbd: Event Scheduler: Loaded 0 events
	2024-03-02 18:00:14 0 [Note] /usr/sbin/mariadbd: ready for connections.
	Version: '11.3.2-MariaDB-1:11.3.2+maria~deb12' socket: '/run/mysqld/mysqld.sock' port: 3306 mariadb.org binary distribution
	```

	The log file shows that service started without errors.

11. Connect to the server ‘mysql30227’ and get the list of databases:

	```bash
	bash
	yourusername@mysql30227:~$ mysql -uroot -p
	mysql: Deprecated program name. It will be removed in a future release, use '/usr/bin/mariadb' instead
	Enter password:
	Welcome to the MariaDB monitor. Commands end with ; or \g.
	Your MariaDB connection id is 43
	Server version: 11.3.2-MariaDB-1:11.3.2+maria~deb12 mariadb.org binary distribution
	Copyright (c) 2000, 2018, Oracle, MariaDB Corporation Ab and others.
	Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.
	MariaDB [(none)]> show databases;
	+--------------------+
	| Database |
	+--------------------+
	| incr_schema_1100 |
	| information_schema |
	| mysql |
	| performance_schema |
	| sys |
	+--------------------+
	5 rows in set (0.000 sec)
	MariaDB [(none)]>
	```

	The server is ready for work.

12. For diff backup operation the preparation will be the following:

	```bash
	bash
	yourusername@mysql30227:~$ sudo /usr/bin/mariadb-backup --prepare --target-dir=/tmp/smuggler30220/full_20240228_2133 --incremental-dir=/tmp/smuggler30220/ full_20240228_2133_diff_20240229_1054
	```

# <a id="The-structure-system-database">**The structure of ‘Assistance DBA’ system database.**</a> 

# <a id="Tables">***Tables***</a> 

1. This table stores the servers types. For example, prod, test, developer, analytic. ***assistant_dba.list_server_type***   
2. This table stores sql servers types. For example, mysql, postgresql, clickhouse. ***assistant_dba.list_sql_type***   
3. This table stores the names of clusters. For example, standalone, galera, master-slave, superhidden. ***assistant_dba.list_clusters***    
4. This table stores all servers. ***assistant_dba.list_server***    
5. This table stores MySQL servers. ***assistant_dba.list_mysql_server***    
6. This table stores the databases from all MySQL servers. ***assistant_dba.list_mysql_bases***    
7. The catalog of tables of databases on MySQL servers. ***assistant_dba.list_mysql_table***   
8. This table stores the names of all tables from each database from each MySQL server. ***assistant_dba.history_mysql_table***   
9. The table stores variables from all MySQL server. ***assistant_dba.list_mysql_glob_var***   
10. This table stores the history for each global variable from each MySQL server. ***assistant_dba.history_mysql_global_var***   
11. This table stores routines from each database from each MySQL server. ***assistant_dba.list_mysql_routine***   
12. This table stores views from each database from each MySQL server. ***assistant_dba.list_mysql_view***   
13. This table stores the users from all MySQL server. ***assistant_dba.list_mysql_users***   
14. This table stores the types of backup. See the comment in the table in columns ‘backup_type_description’ and ‘backup_type_comments’. ***assistant_dba.backup_type_mysql***   
15. This table stores all backup tasks with schedules. ***assistant_dba.backup_task_mysql***   
16. This table stores paths backups servers MySQL. ***assistant_dba.backup_path_variable_mysql***   
17. This table stores backup tasks ready for execution. ***assistant_dba.backup_task_run_mysql***   
18. This table stores the history of backup tasks. ***assistant_dba.backup_task_log_mysql***   
19. This table stores MariaDB versions with major and minor symbols. ***assistant_dba.version_major_minor_mariadb***   
20. This table stores MariaDB versions with all symbols. ***assistant_dba.version_compability_mariadb***   

# <a id="Stored-procedures">***Stored procedures***</a> 

1. This procedure adds a new server type (prod, test, developer, analytic). ***assistant_dba.add_new_server_type***   
2. This procedure adds a new sql type (mysql, postgresql, clickhouse.). ***assistant_dba.add_new_sql_type***   
3. This procedure adds a new cluster.. ***assistant_dba.add_new_cluster***   
4. This procedure adds a new database server. ***assistant_dba.add_new_server_mysql***   
5. This procedure retrieves the 'alive' MySQL servers for the data collection module. ***assistant_dba. get_alive_init_server_mysql***   
6. This procedure refreshes information about MySQL servers for the data collection module. ***assistant_dba.insert_filtered_option_server_mysql***   
7. This procedure inserts the databases list in a temporary table into the database assistant_dba_temp. ***assistant_dba.insert_list_db***   
8. This procedure inserts and updates the information about server_name in the database. ***assistant_dba.check_db***   
9. This procedure gets the database list for the selected server_name: ***assistant_dba.get_list_db_my_spr***   
10. This procedure forces table analysis in all schemas and all tables excluding performance_schema. ***mysql.dba_analyze_table***   
11. This procedure inserts and updates information about tables from each database from each MySQL server. ***assistant_dba.check_table***   
12. This procedure involves inserting historical data about the size of the table. ***assistant_dba.insert_history_table***   
13. This procedure inserts global variables into staging tables for the MySQL servers. ***assistant_dba.insert_global_var***   
14. This procedure inserts the new global variables for MySQL server. ***assistant_dba.check_global_var***   
15. This procedure gets a list of global variables for the MySQL server. ***assistant_dba.get_list_global_var_spr***   
16. This procedure inserts values into a global variable in a temporary table for each MySQL server. ***assistant_dba.insert_global_var_ext***   
17. This procedure inserts historical data about global variables. ***assistant_dba.insert_history_global_var***   
18. This procedure inserts and updates information about routines from each database from each MySQL server. ***assistant_dba.check_routine***   
19. This procedure inserts and updates information about views from each database from each MySQL server. ***assistant_dba.check_view***   
20. This procedure adds backup path variable mysql. ***assistant_dba.add_backup_path_variable_mysql***   
21. This procedure adds a new backup task. ***assistant_dba.add_backup_task_mysql***   
22. Calculation of the next run of backup tasks. ***assistant_dba.task_scheduler_mysql***   
23. Adding backup tasks to the table for running tasks. ***assistant_dba.queue_task_mysql***   
24. Selecting backup tasks for execution. ***assistant_dba.run_task_mysql***   
25. Update start time of all task=task_id. ***assistant_dba.upd_btrm_start_time***   
26. Update start time of backup task=task_id. ***assistant_dba.upd_btrm_start_time_backup***   
27. Update end time of backup task=task_id. ***assistant_dba.upd_btrm_end_time_backup***   
28. Update end time of all task=task_id. ***assistant_dba.upd_btrm_end_time***   
29. Update file_log task=task_id. ***assistant_dba.upd_btrm_file_log***   
30. Update task_progress task=task_id. ***assistant_dba.upd_btrm_task_progress***   
31. Update start_time_prepare task=task_id. ***assistant_dba.upd_btrm_start_time_prepare***   
32. Update end_time_prepare task=task_id. ***assistant_dba.upd_btrm_end_time_prepare***   
33. Moving the row bt_id from backup_task_run_mysql to backup_task_log_mysql. ***assistant_dba.backup_tasks_move_from_run_to_log***   
34. Update path_last_full_backup. ***assistant_dba.upd_bpvm_path_last_full_backup***   
35. Update wait_task_id. ***assistant_dba. upd_btrm_wait_task_id***   
36. Get path_last_full_backup. ***assistant_dba.get_bpvm_path_last_full_backup***   
37. Update path_last_incr_backup. ***assistant_dba.upd_bpvm_path_last_inc_backup***   
38. Update path_last_full_backup in backup_task_log_mysql. ***assistant_dba.upd_btlm_path_last_full_backup***   
39. Update path_old_incr_backup in backup_task_log_mysql. ***assistant_dba.upd_btlm_path_old_incr_backup***   
40. Update path_cur_incr_backup in backup_task_log_mysql. ***assistant_dba.upd_btlm_path_cur_incr_backup***   
41. Update path_diff_backup in backup_task_log_mysql. ***assistant_dba.upd_btlm_path_diff_backup***   
42. Update last_time in backup_task_mysql. ***assistant_dba.upd_btm_last_time***   
43. Check compare_version_mariabackup. ***assistant_dba.compare_version_mariabackup***   
44. add the version number major_minor_mariadb. ***assistant_dba.add_version_major_minor_mariadb***   
45. add the version number major_minor_mariadb. ***assistant_dba.add_version_compability_mariadb***   

# <a id="Scripts-for-collected-information-server-MySQL">**Scripts for collected information about the database size from each table each database in server MySQL**</a>

1. This script, main1.sh exports a list of servers in MySQL, which you need to collect information about, to /var/log/assistant_db/mysql/init/list_alive_mysqlservers.txt.
2. This script, main2.sh reads a list of servers from file /var/log/assistant_db/mysql/init/list_alive_mysqlservers.txt and gives its content to the main script, /etc/mysql/dba_scripts/init/main3.sh.
3. This script /etc/mysql/dba_scripts/init/main3.sh performs the following operations on all servers, which are in the file /var/log/assistant_db/mysql/init/list_alive_mysqlservers.txt:

- updated information about the database server MySQL.
- updated list of databases on the database server MySQL.
- updated information about the database properties on the database server MySQL.
- updated the list of tables on each database on the database server MySQL.
- updated - corrected information about the size ща each table in each database on the database server MySQL on every day script work.
- updated the information about the list of global variables on the database server MySQL.
- updated - corrected information about each global variable on database server MySQL on every day script work.
- updated information about procedures and functions of each database on the database server MySQL.
- updated information about views in each database on the database server MySQL.

4. The log of the script /etc/mysql/dba_scripts/main1.sh is located in /var/log/assistant_db/mysql/init/step1_init_all.log
5. The log of the script /etc/mysql/dba_scripts/main2.sh is located in /var/log/assistant_db/mysql/init/step2_init_all.log.
6. Log and the results of the works of script /etc/mysql/dba_scripts/init/main3.sh on each database server MySQL are created in /var/log/assistant_db/mysql/init/db_servername_mysql

For example: the server name ‘server_name_dba’

- General log of the server work log is log, is created in /var/log/assistant_db/mysql/init/server_name_dba/server_name_dba_all.log. Detailed log with date and time.
- Usually the log of errors contains the last error which is sent via email /var/log/assistant_db/mysql/init/server_name_dba/server_name_dba_error.log. In the end, if it worked OK, this file size will be 0 bytes.
- This file, /var/log/assistant_db/mysql/init/server_name_dba/server_name_dba_options_server.txt contains information about the database server.
- This file, /var/log/assistant_db/mysql/init/server_name_dba/server_name_dba_db_list.txt contains a list of databases, exported from remote server MySQL
- This file, /var/log/assistant_db/mysql/init/server_name_dba/server_name_dba_good_db_list.txt contains a list of databases, which provides necessary information about the size of the tables.
- The files of type /var/log/assistant_db/mysql/init/server_name_dba/1_tbl_list_db_name.txt

/var/log/assistant_db/mysql/init/server_name_dba/server_id_from_system_tbl_list_db_name.txt contain information about each tables in this database.

- The files of type /var/log/assistant_db/mysql/init/server_name_dba/server_name_dba_global_var_value.txt /var/log/assistant_db/mysql/init/server_name_dba/server_id_from_system_global_var_value.txt contain information about global variables of database server MySQL.
- The files of type /var/log/assistant_db/mysql/init/server_name_dba/server_name_dba_good_global_var_value.txt /var/log/assistant_db/mysql/init/server_name_dba/server_id_from_system_good_global_var_value.txt contain information about global variables in database server MySQL with id from the catalog of the system database.
- The files of type /var/log/assistant_db/mysql/init/server_name_dba/server_name_dba_good_global_var_value_ext.txt /var/log/assistant_db/mysql/init/server_name_dba/server_id_from_system_good_global_var_value_ext.txt contains information about global variables of database server MySQL with id from catalog of the system database + values of these variables for uploading in the database.

Written by Pavel A. Polikov <https://github.com/PahanDba/mysql_dba>