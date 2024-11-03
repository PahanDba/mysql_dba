Sync speed of replication on the MySQL replica in seconds

[**Script goal**](#Script-goal)  
 
[**System requirements**](#System-requirements)  
 
[**List of servers for demonstrating the configuration of the replication application speed check on replicas**](#list-of-servers)  
 
>    [Server Master (main master)](#server-master) 
 
>    [Server slave31 (slave from main master mysql3030)](#server-slave31) 
 
>    [Server slave32 (slave from slave31 mysql3031)](#server-slave32) 
 
[**Configuring the 'add-on' to check the replication commit speed on the replica servers**](#configuring-theaddontitle)  
 
>    [Initial conditions](#Initial-conditions) 

>    [Configuring the 'add-on'](#Configuring-the-add-on) 

[**Summary**](#Summary) 
 
# <a id="Script-goal">**Script goal**</a>

- It helps MySQL DBAs analyze how quickly the Replica synchronizes with the master in seconds. I demonstrate the option for how many replication seconds of lag occur on the replica per second of real time.

# <a id="System-requirements">**System requirements**</a>

- It’s necessary for the ‘Master’ MySQL server to have the pt-heartbeat tool from the Percona Toolkit running.
- You need to know the database and table names on the 'master' MySQL server that the pt-heartbeat tool interacts with.
- You must create the specified table, event, and stored procedure on each 'replica' server independently of the 'master' server.
- This solution has been tested for the following configurations: master -> slave1, and master -> slave1 -> slave3 (cascade replication).

# <a id="list-of-servers">**List of servers for demonstrating the configuration of the replication application speed check on replicas**</a>

- Below is a list of servers that shows the descriptions for each server with installed software used to check the replication synchronization speed on the MySQL replica in seconds. This list helps in understanding and configuring this 'add-on'.

## <a id="server-master">***Server Master (main master)***</a>

 	ServerName: mysql3030
	IP address: 10.10.30.30
	OS: Debian 11/12
	RDBMS: MariaDB 10.11
	Software for executed 'add-on': Percona Toolkit is installed, and pt-heartbeat is configured and running.
	Server configuration: 2 CPU, 4GB RAM, 30GB  

## <a id="server-slave31">***Server slave31 (slave from main master mysql3030)***</a>

 	ServerName: mysql3031 
	IP address: 10.10.30.31 
	OS: Debian 11/12 
	RDBMS: MariaDB 10.11 
	Server configuration: 2 CPU, 4GB RAM, 30GB 

## <a id="server-slave32">***Server slave32 (slave from slave31 mysql3031)***</a>

	ServerName: mysql3032 
	IP address: 10.10.30.32 
	OS: Debian 11/12 
	RDBMS: MariaDB 10.11 
	Server configuration: 2 CPU, 4GB RAM, 30GB 
 
# <a id="configuring-theaddontitle">**Configuring the add-on to check the replication commit speed on the replica servers**</a> 



## <a id="Initial-conditions">***Initial conditions***</a>

1. The pt-heartbeat tool is configured and running on the master server (MySQL). To install and configure pt-heartbeat, visit the website https://www.percona.com/percona-toolkit. For example, on the master server (mysql3030), pt-heartbeat uses the table percona_information.heartbeat..   

2. On all replica servers, you need to enable the event_scheduler. The following command will enable the event_scheduler:

```sql
MariaDB> 
set global event_scheduler=1;
```

Warning! Before enabling this parameter, ensure that no events on the replica server will be executed. I recommend executing the following commands for each event on the master server.   

```sql
MariaDB> 
alter event schema.`event_name` DISABLE ON SLAVE;
alter event schema.`event_name` enable;
```

alternatively, you can execute the command on the replica

```sql
MariaDB> 
alter event schema.`event_name` DISABLE ON SLAVE;
```

In the future, when creating a new event on the master server, always use the parameter 'DISABLE ON SLAVE' to prevent the event from executing on the replica server, if that is your intention.

3. This script creates a table for the pt-heartbeat to work.

```sql
MariaDB> 
CREATE TABLE percona_information.`heartbeat` (
`ts` varchar(26) NOT NULL,
`server_id` int(10) unsigned NOT NULL,
`file` varchar(255) DEFAULT NULL,
`position` bigint(20) unsigned DEFAULT NULL,
`relay_master_log_file` varchar(255) DEFAULT NULL,
`exec_master_log_pos` bigint(20) unsigned DEFAULT NULL,
PRIMARY KEY (`server_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```


## <a id="Configuring-the-add-on">***Configuring the 'add-on'***</a>

1. I will demonstrate how this 'add-on' works in the following configuration: mysql3030 (main master) -> mysql3031 (slave of main master mysql3030) -> mysql3032 (slave of mysql3031).

2. Warning! In this script, you need to change the string 'my_server_slave' to your replica server name so that you can distinguish the tables and other objects for each replica server.

3. Create the necessary objects.

  a) Create the table to store data about the replication commit speed on the replica server.

```sql
MariaDB> 
drop table if exists percona_information.check_speed_replication_on_my_server_slave;
CREATE TABLE percona_information.check_speed_replication_on_my_server_slave (  `server_id` int(10) unsigned NOT NULL,
`date_collect` varchar(26) NOT NULL,
`lag_repl_sec_on_slave` varchar(26) NOT NULL,
`replica_name` varchar(64) NOT NULL,
`replica_id` int(10) unsigned NOT NULL,
PRIMARY KEY (`date_collect`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

b) Create the procedure to insert data about the replication commit speed on the replica server.

```sql
MariaDB> drop procedure if exists mysql.check_speed_replication_on_my_server_slave;
DELIMITER $$
CREATE PROCEDURE mysql.check_speed_replication_on_my_server_slave()
begin
insert percona_information.check_speed_replication_on_my_server_slave (`server_id`, `date_collect`, `lag_repl_sec_on_slave`,     `replica_name`, `replica_id`)
SELECT server_id,now() as 'date_collect',
format(time_to_sec(timediff (now(6), ts)),1) as lag_repl_sec_on_slave, @@hostname as replica_name,@@server_id as replica_id 
FROM percona_information.heartbeat;
end$$
DELIMITER ;
```

c) Create the event to start the procedure on the scheduler.

```sql
MariaDB> 
DELIMITER $$
CREATE EVENT mysql.`dba_check_speed_replication_on_my_server_slave` ON SCHEDULE EVERY 30 second STARTS '2024-09-01 00:00:00' ON COMPLETION NOT PRESERVE DISABLE ON SLAVE COMMENT 'Analysis of the speed commit of replication on my_server_slave.' DO BEGIN
  call mysql.check_speed_replication_on_my_server_slave(); 
END$$
DELIMITER ;
alter EVENT mysql.`dba_check_speed_replication_on_my_server_slave` enable;
```

4. Configuring ‘add-on’ on the replica server.

a) Replica server mysql3031 (slave from main master mysql3030)
I previously stopped replication on the mysql3031 server (slave of the main master mysql3030) by executing the command.

```sql
MariaDB> stop slave;
```

I connect to MySQL on the replica server mysql3031 (slave of the main master mysql3030).
In my case, the scripts for the server will look like this:

```sql
MariaDB> 
drop table if exists percona_information.check_speed_replication_on_mysql3031;
CREATE TABLE percona_information.check_speed_replication_on_mysql3031 (
  `server_id` int(10) unsigned NOT NULL,
  `date_collect` varchar(26) NOT NULL,
  `lag_repl_sec_on_slave` varchar(26) NOT NULL,
  `replica_name` varchar(64) NOT NULL,
  `replica_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`date_collect`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

```sql
MariaDB> 
drop procedure if exists mysql.check_speed_replication_on_mysql3031;
DELIMITER $$
CREATE PROCEDURE mysql.check_speed_replication_on_mysql3031 ()
begin
insert percona_information.check_speed_replication_on_mysql3031 (`server_id`, `date_collect`, `lag_repl_sec_on_slave`,     `replica_name`, `replica_id`)
SELECT server_id,now() as 'date_collect',
format(time_to_sec(timediff (now(6), ts)),1) as lag_repl_sec_on_slave, @@hostname as replica_name,@@server_id as replica_id 
FROM percona_information.heartbeat;
end$$
DELIMITER ;
```

```sql
MariaDB> 
DELIMITER $$
CREATE EVENT mysql.`dba_check_speed_replication_on_mysql3031` ON SCHEDULE EVERY 30 second STARTS '2024-09-01 00:00:00' ON COMPLETION NOT PRESERVE DISABLE ON SLAVE COMMENT 'Analysis of the speed commit of replication on mysql3031.' DO BEGIN
  call mysql.check_speed_replication_on_mysql3031 (); 
END$$
DELIMITER ;
alter EVENT mysql.`dba_check_speed_replication_on_mysql3031` enable;
```

In order to ensure that my event is working and adding data to the table, it is necessary to execute the following scripts:
This shows a list of all events and their status. I'm interested in mysql.dba_check_speed_replication_on_mysql3031.

```sql
MariaDB> 
select event_schema, event_name, definer, status, on_completion, created, last_altered, last_executed, event_comment from information_schema.events
order by event_name;
```

| **#event_schema** | **event_name**                           | **definer**     | **status** | **on_completion** | **created**         | **last_altered**    | **last_executed**   | **event_comment**                                         |
|-------------------|------------------------------------------|-----------------|------------|-------------------|---------------------|---------------------|---------------------|-----------------------------------------------------------|
| mysql             | dba_check_speed_replication_on_mysql3031 | pavel_polikov@% | ENABLED    | NOT PRESERVE      | 07.09.2024 15:41:30 | 07.09.2024 15:43:00 | 07.09.2024 16:15:30 | Analysis of the speed commit of replication on mysql3031. |


In the 'last_executed' column, I can see the last time the event was executed. I’m verifying that my event mysql.dba_check_speed_replication_on_mysql3031 is storing data in the table percona_information.check_speed_replication_on_mysql3031


```sql
MariaDB> 
select server_id, date_collect, lag_repl_sec_on_slave, replica_name, replica_id, lag_repl_sec_on_slave_prev, date_collect_prev,
format (replace (lag_repl_sec_on_slave_prev, ',','') - replace (lag_repl_sec_on_slave, ',',''),2) as  lag_repl_delta,
format(time_to_sec(timediff (date_collect,date_collect_prev)),1) as date_collect_delta,
format(((replace (lag_repl_sec_on_slave_prev, ',','') - replace (lag_repl_sec_on_slave, ',',''))/(format(time_to_sec(timediff (date_collect,date_collect_prev)),1))),2) as lag_repl_speed_sec_real_sec_status
from
(select server_id, date_collect, lag_repl_sec_on_slave, replica_name,replica_id, lag(lag_repl_sec_on_slave) over (order by date_collect) lag_repl_sec_on_slave_prev, 
lag(date_collect) over (order by date_collect) date_collect_prev
from percona_information.check_speed_replication_on_mysql3031 ) as my_subquery;
```


| **#server_id** | **date_collect**        | **lag_repl_sec_on_slave** | **replica_name** | **replica_id** | **lag_repl_sec_on_slave_prev** | **date_collect_prev**   | **lag_repl_delta** | **date_collect_delta** | **lag_repl_speed_sec_real_sec_status** |
|----------------|-------------------------|---------------------------|------------------|----------------|--------------------------------|-------------------------|--------------------|------------------------|----------------------------------------|
| 3030           | 07.09.2024 15:47:00     | 0                         | mysql3031        | 3031           |                                |                         |                    |                        |                                        |
| 3030           | 07.09.2024 15:47:30     | 0                         | mysql3031        | 3031           | 0                              | 07.09.2024 15:47:00     | 0                  | 30                     | 0                                      |
| 3030           | 07.09.2024 15:48:00     | 29.4                      | mysql3031        | 3031           | 0                              | 07.09.2024 15:47:30     | -29.4              | 30                     | -0.98                                  |
| 3030           | 07.09.2024 15:48:30     | 59.4                      | mysql3031        | 3031           | 29.4                           | 07.09.2024 15:48:00     | -30                | 30                     | -1                                     |
| 3030           | 07.09.2024 15:49:00     | 89.4                      | mysql3031        | 3031           | 59.4                           | 07.09.2024 15:48:30     | -30                | 30                     | -1                                     |
| 3030           | 07.09.2024 15:49:30     | 119.4                     | mysql3031        | 3031           | 89.4                           | 07.09.2024 15:49:00     | -30                | 30                     | -1                                     |
| 3030           | 07.09.2024 15:50:00     | 149.4                     | mysql3031        | 3031           | 119.4                          | 07.09.2024 15:49:30     | -30                | 30                     | -1                                     |
| 3030           | 07.09.2024 15:50:30     | 179.4                     | mysql3031        | 3031           | 149.4                          | 07.09.2024 15:50:00     | -30                | 30                     | -1                                     |
| 3030           | 07.09.2024 15:51:00     | 209.4                     | mysql3031        | 3031           | 179.4                          | 07.09.2024 15:50:30     | -30                | 30                     | -1                                     |
| 3030           | 07.09.2024 15:51:30     | 239.4                     | mysql3031        | 3031           | 209.4                          | 07.09.2024 15:51:00     | -30                | 30                     | -1                                     |
| 3030           | 07.09.2024 15:52:00     | 269.4                     | mysql3031        | 3031           | 239.4                          | 07.09.2024 15:51:30     | -30                | 30                     | -1                                     |
| 3030           | 07.09.2024 15:52:30     | 299.4                     | mysql3031        | 3031           | 269.4                          | 07.09.2024 15:52:00     | -30                | 30                     | -1                                     |
| 3030           | 07.09.2024 15:53:00     | 329.4                     | mysql3031        | 3031           | 299.4                          | 07.09.2024 15:52:30     | -30                | 30                     | -1                                     |
| 3030           | 07.09.2024 15:53:30     | 359.4                     | mysql3031        | 3031           | 329.4                          | 07.09.2024 15:53:00     | -30                | 30                     | -1                                     |



In the columns 'lag_repl_delta' и 'lag_repl_speed_sec_real_sec_status' there are negative values. This means that replication on the replica server mysql3031 cannot catch up with the state of the master server mysql3030; the replica server continues to lag behind. Conversely, if the columns 'lag_repl_delta' and 'lag_repl_speed_sec_real_sec_status' show positive values that are decreasing, it means that the replication on the replica server is catching up with the state of the master server.

Description of the fields in the result:  
server_id - @@server_id of the master server. 
date_collect - Datetime when the event was collected.  
lag_repl_sec_on_slave - The number of seconds that the replication is lagging on the current slave.  
replica_name - @@hostname of the slave server.  
replica_id - @@server_id of the slave server.  
lag_repl_sec_on_slave_prev - The previous value for how many seconds the replication lagged on the current slave.  
date_collect_prev - Previous value of the datetime when the event was collected.  
lag_repl_delta - The difference between the previous and current seconds of replication lag on the current slave.  
date_collect_delta - The time difference in seconds between the previous and current datetime.  
lag_repl_speed_sec_real_sec_status - Indicates how many seconds of replication were committed in one real second on the slave server.  

b) The replica server mysql3032 (slave of mysql3031).  
I am repeating which the same operations on the replica server mysql3032 (slave of mysql3031) that I performed on the replica server mysql3031 (slave of the main master mysql3030). Instead of the string mysql3031, I will use mysql3032 for the mysql3032 server (slave of mysql3031). Below, I have included the commands.

```sql
MariaDB> 
drop table if exists percona_information.check_speed_replication_on_mysql3032;
CREATE TABLE percona_information.check_speed_replication_on_mysql3032 (
  `server_id` int(10) unsigned NOT NULL,
  `date_collect` varchar(26) NOT NULL,
  `lag_repl_sec_on_slave` varchar(26) NOT NULL,
  `replica_name` varchar(64) NOT NULL,
  `replica_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`date_collect`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

```sql
MariaDB> 
drop procedure if exists mysql.check_speed_replication_on_mysql3032;
DELIMITER $$
CREATE PROCEDURE mysql.check_speed_replication_on_mysql3032 ()
begin
insert percona_information.check_speed_replication_on_mysql3032 (`server_id`, `date_collect`, `lag_repl_sec_on_slave`,     `replica_name`, `replica_id`)
SELECT server_id,now() as 'date_collect',
format(time_to_sec(timediff (now(6), ts)),1) as lag_repl_sec_on_slave, @@hostname as replica_name,@@server_id as replica_id 
FROM percona_information.heartbeat;
end$$
DELIMITER ;
```

```sql
MariaDB> 
DELIMITER $$
CREATE EVENT mysql.`dba_check_speed_replication_on_mysql3032` ON SCHEDULE EVERY 30 second STARTS '2024-09-01 00:00:00' ON COMPLETION NOT PRESERVE DISABLE ON SLAVE COMMENT 'Analysis of the speed commit of replication on mysql3032.' DO BEGIN
  call mysql.check_speed_replication_on_mysql3032 (); 
END$$
DELIMITER ;
alter EVENT mysql.`dba_check_speed_replication_on_mysql3032` enable;
```

In order to ensure that my event is working and adding data to the table, it is necessary to execute the following scripts:
This shows a list of all events and their status. I'm particularly interested in mysql.dba_check_speed_replication_on_mysql3032.


```sql
MariaDB> 
select event_schema, event_name, definer, status, on_completion, created, last_altered, last_executed, event_comment from information_schema.events
order by event_name;
```

| **#event_schema** | **event_name**                           | **definer**     | **status** | **on_completion** | **created**         | **last_altered**    | **last_executed**   | **event_comment**                                         |
|-------------------|------------------------------------------|-----------------|------------|-------------------|---------------------|---------------------|---------------------|-----------------------------------------------------------|
| mysql             | dba_check_speed_replication_on_mysql3031 | pavel_polikov@% | ENABLED    | NOT PRESERVE      | 07.09.2024 15:41:30 | 07.09.2024 15:41:30 |                     | Analysis of the speed commit of replication on mysql3031. |
| mysql             | dba_check_speed_replication_on_mysql3032 | pavel_polikov@% | ENABLED    | NOT PRESERVE      | 07.09.2024 17:05:30 | 07.09.2024 17:05:30 |                     | Analysis of the speed commit of replication on mysql3032. |



The last_executed column shows the last time the event was executed. The status column indicates that the event mysql.dba_check_speed_replication_on_mysql3031 is SLAVESIDE_DISABLED.
I check that the event mysql.dba_check_speed_replication_on_mysql3032 saves data in the table percona_information.check_speed_replication_on_mysql3032."

```sql
MariaDB> 
select server_id, date_collect, lag_repl_sec_on_slave, replica_name, replica_id, lag_repl_sec_on_slave_prev, date_collect_prev,
format (replace (lag_repl_sec_on_slave_prev, ',','') - replace (lag_repl_sec_on_slave, ',',''),2) as  lag_repl_delta,
format(time_to_sec(timediff (date_collect,date_collect_prev)),1) as date_collect_delta,
format(((replace (lag_repl_sec_on_slave_prev, ',','') - replace (lag_repl_sec_on_slave, ',',''))/(format(time_to_sec(timediff (date_collect,date_collect_prev)),1))),2) as lag_repl_speed_sec_real_sec_status
from
(select server_id, date_collect, lag_repl_sec_on_slave, replica_name,replica_id, lag(lag_repl_sec_on_slave) over (order by date_collect) lag_repl_sec_on_slave_prev, 
lag(date_collect) over (order by date_collect) date_collect_prev
from percona_information.check_speed_replication_on_mysql3032 ) as my_subquery;
```



| **#server_id** | **date_collect**        | **lag_repl_sec_on_slave** | **replica_name** | **replica_id** | **lag_repl_sec_on_slave_prev** | **date_collect_prev**   | **lag_repl_delta** | **date_collect_delta** | **lag_repl_speed_sec_real_sec_status** |
|----------------|-------------------------|---------------------------|------------------|----------------|--------------------------------|-------------------------|--------------------|------------------------|----------------------------------------|
| 3030           | 07.09.2024 17:06:30     | 4,739.4                   | mysql3032        | 3032           |                                |                         |                    |                        |                                        |
| 3030           | 07.09.2024 17:07:00     | 4,769.4                   | mysql3032        | 3032           | 4,739.4                        | 07.09.2024 17:06:30     | 0                  | -30                    | -1                                     |
| 3030           | 07.09.2024 17:07:30     | 4,799.4                   | mysql3032        | 3032           | 4,769.4                        | 07.09.2024 17:07:00     | -29.4              | -30                    | -1                                     |
| 3030           | 07.09.2024 17:08:00     | 4,829.4                   | mysql3032        | 3032           | 4,799.4                        | 07.09.2024 17:07:30     | -30                | -30                    | -1                                     |
| 3030           | 07.09.2024 17:08:30     | 4,859.4                   | mysql3032        | 3032           | 4,829.4                        | 07.09.2024 17:08:00     | -30                | -30                    | -1                                     |
| 3030           | 07.09.2024 17:09:00     | 4,889.4                   | mysql3032        | 3032           | 4,859.4                        | 07.09.2024 17:08:30     | -30                | -30                    | -1                                     |
| 3030           | 07.09.2024 17:09:30     | 4,919.4                   | mysql3032        | 3032           | 4,889.4                        | 07.09.2024 17:09:00     | -30                | -30                    | -1                                     |
| 3030           | 07.09.2024 17:10:00     | 4,949.4                   | mysql3032        | 3032           | 4,919.4                        | 07.09.2024 17:09:30     | -30                | -30                    | -1                                     |
| 3030           | 07.09.2024 17:10:30     | 4,979.4                   | mysql3032        | 3032           | 4,949.4                        | 07.09.2024 17:10:00     | -30                | -30                    | -1                                     |
| 3030           | 07.09.2024 17:11:00     | 5,009.4                   | mysql3032        | 3032           | 4,979.4                        | 07.09.2024 17:10:30     | -30                | -30                    | -1                                     |
| 3030           | 07.09.2024 17:11:30     | 5,039.4                   | mysql3032        | 3032           | 5,009.4                        | 07.09.2024 17:11:00     | -30                | -30                    | -1                                     |




In the columns 'lag_repl_delta' и 'lag_repl_speed_sec_real_sec_status' there are negative values. This means that on the replica server mysql3032 cannot catch up with the state of the master server mysql3030; the replica server continues to lag behind. Conversely, if the columns 'lag_repl_delta' and 'lag_repl_speed_sec_real_sec_status' show positive values that are decreasing, it means that the replication on the replica server is catching up with the state of the master server.

Description of the fields in the result:  
server_id - @@server_id of the master server.  
date_collect - Datetime when the event was collected.  
lag_repl_sec_on_slave - The number of seconds that the replication is lagging on the current slave.  
replica_name - @@hostname of the slave server.  
replica_id - @@server_id of the slave server.  
lag_repl_sec_on_slave_prev - The previous value for how many seconds the replication lagged on the current slave.  
date_collect_prev - Previous value of the datetime when the event was collected.  
lag_repl_delta - The difference between the previous and current seconds of replication lag on the current slave.  
date_collect_delta - The time difference in seconds between the previous and current datetime.  
lag_repl_speed_sec_real_sec_status - Indicates how many seconds of replication were committed in one real second on the slave server.  

## <a id="Summary">***Summary***</a> 

This document describes the configuration and functionality of an 'add-on' designed to monitor replication speed in MySQL. The 'add-on' uses the pt-heartbeat tool from the Percona Toolkit to assess replication lag between master and replica servers. It outlines the necessary steps to set up the add-on, including enabling the event scheduler on replica servers and creating the required database objects.
You can download this script (/replication/sync_speed_of_replication.sql) and other scripts from https://github.com/PahanDba/mysql_dba/.




Written by Pavel A. Polikov <https://github.com/PahanDba/mysql_dba>