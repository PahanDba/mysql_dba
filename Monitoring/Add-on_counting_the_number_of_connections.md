Counting the number of connections for each user on the MySQL server.



# **Table of contents**
[**Script goal ‘Counting the number of connections for each user on the MySQL server’**](#_toc192534151)

[**System requirements**](#_toc192534152)

[**List of servers for demonstrating the configuration of the add-on ‘for counting the number of connections for each user on MySQL server.**](#_toc192534153)

>    [***Server Master (main master)***](#_toc192534154)

>    [***Server slave44 (slave from main master mysql3043)***](#_toc192534155)

>    [***Server standalone***](#_toc192534156)

[**Configuring the 'add-on' to collect statistics about the number of connections opened by each user on MySQL.**](#_toc192534157)

>    [***Initial conditions***](#_toc192534158)

>    [***Configuring the ‘add-on’***](#_toc192534159)

[**Summary**](#_toc192534160)




# <a name="_toc192534151">**Script goal ‘Counting the number of connections for each user on the MySQL server’**</a>
- It helps MySQL DBAs collect statistics on the number of connections at a opened certain time by each user on the MySQL server.


# <a name="_toc192534152">**System requirements**</a>

- This add-on works on MySQL 5.7.42, MySQL 8.0, MariaDB 10.6-10.11

# <a name="_toc192534153">**List of servers for demonstrating the configuration of the add-on ‘for counting the number of connections for each user on MySQL server.**</a>

Below is a list of servers that shows the descriptions for each server with installed software used to check the functionality this ‘add-on’.
## <a name="_toc192534154">***Server Master (main master)***</a>
 	ServerName: mysql3043 
 	IP address: 10.10.30.43 
 	OS: Debian 11/12 
 	RDBMS: MySQL 5.7.42 
 	Server configuration: 2 CPU, 4GB RAM, 30GB 

## <a name="_toc192534155">***Server slave44 (slave from main master mysql3043)***</a>
 	ServerName: mysql3044 
 	IP address: 10.10.30.44 
 	OS: Debian 11/12 
 	RDBMS: MySQL 8.0.40 
 	Server configuration: 2 CPU, 4GB RAM, 30GB 

## <a name="_toc192534156">***Server standalone***</a> 
 	ServerName: mysql30226 
 	IP address: 10.10.30.226 
 	OS: Debian 11/12 
 	RDBMS: MariaDB 10.11 
 	Server configuration: 2 CPU, 4GB RAM, 30GB 


# <a name="_toc192534157">**Configuring the 'add-on' to collect statistics about the number of connections opened by each user on MySQL.**</a>
## <a name="_toc192534158">***Initial conditions***</a> 

On all replica servers, you need to enable the event_scheduler. Use the following command to enable it:

```sql
mysql> SET GLOBAL event_scheduler = 1;
```

Warning! Before enabling this parameter, ensure that no events will be executed on the replica server. I recommend running the following commands for each event on the master server:

```sql
mysql> ALTER EVENT schema.`event_name` DISABLE ON SLAVE;
ALTER EVENT schema.`event_name` ENABLE;
```

Alternatively, you can execute the following command on the replica server:

```sql
mysql> ALTER EVENT schema.`event_name` DISABLE ON SLAVE;
```

In the future, when creating a new event on the master server, always use the DISABLE ON SLAVE parameter to prevent the event from being executed on the replica server, if that is your intention.


## <a name="_toc192534159">***Configuring the ‘add-on’***</a>

### 1\. I will demonstrate the work of this ‘add-on’ on mysql3043 (main master MySQL 5.7.42) -> mysql3044 (slave from main master mysql3043 MySQL 8.0.40) and standalone mysql30226 (MariaDB 10.11).

### 2\. Create the necessary objects. 
   You need to download and execute the script from <https://github.com/PahanDba/mysql_dba/Monitoring/count_number_connections/count_number_connections_users.sql> via MySQL on the following servers:
- mysql3043 (Main Master, MySQL 5.7.42)
- mysql30226 (MariaDB 10.11)

This script performs the following steps:

#### 1\. Creates the assistant_dba database if it does not already exist on the server.

#### 2\. Creates the function assistant_dba.regexp_replace, which works in MySQL 5.7 similarly to the REGEXP_REPLACE function available in MySQL 8.0 and later. This function was taken from [this blog post](https://www.cnblogs.com/rainbow--/p/17026987.html).

#### 3\. Creates the procedure assistant_dba.count_con_each_users.

#### 4\. Drops the event assistant_dba.dba_count_con_each_users if it exists and recreates it. This event is scheduled to run every 30 seconds.



##### a) Function creation script.

```sql
mysql> create database if not exists assistant_dba;
drop function if exists assistant_dba.`regexp_replace`;
DELIMITER $$
CREATE  FUNCTION assistant_dba.`regexp_replace`(ori_str varchar(64),pattern VARCHAR(64),repl_str VARCHAR(64)) RETURNS longtext CHARSET utf8mb4
    DETERMINISTIC
BEGIN  
#Thank you for this function the website https://www.cnblogs.com/rainbow--/p/17026987.html
#This is an analog of function regexp_replace from MySQL 8.0 to MySQL 5.7
	DECLARE tmp_str LONGTEXT;  
	DECLARE target_str LONGTEXT;  
	DECLARE str0 LONGTEXT;  
	DECLARE i1 INT;
	DECLARE i2 INT;
	SET tmp_str = ori_str; 
	loop0: LOOP
		IF NOT tmp_str REGEXP pattern THEN  
			LEAVE loop0;  
		END IF;
		SET i1 = 1;
		SET i2 = CHAR_LENGTH(tmp_str);
		loop1: LOOP
			SET str0 = SUBSTR(tmp_str, i1, i2-i1+1);
			IF NOT str0 REGEXP pattern THEN
				SET i1 = i1-1; 
				LEAVE loop1;
			ELSE
				SET i1 = i1+1;
			END IF;
		END LOOP;
		loop2: LOOP
			SET str0 = SUBSTR(tmp_str, i1, i2-i1+1);
			IF NOT str0 REGEXP pattern THEN
				SET i2 = i2+1; 
				LEAVE loop2;
			ELSE
				SET i2 = i2-1;  
			END IF;
		END LOOP;
		SET target_str = SUBSTR(tmp_str, i1, i2-i1+1);
		SET tmp_str = REPLACE(tmp_str, target_str, repl_str);
	END LOOP;  
	RETURN tmp_str;
END$$
DELIMITER ;
;
```

##### b) Will create the procedure to insert data about the number of connections opened by each user on the MySQL server.

The logic of the procedure assistant_dba.dba_count_con_each_users is as follows:

1\. The procedure uses the SET sql_log_bin = 0; statement to ensure that this operation does not insert unnecessary information into the binary log, which would otherwise be replicated to the replicas.

2\. The procedure checks the MySQL/MariaDB version. If the version is lower than 5.7, the procedure ends with an error.

3\.For MySQL 5.7, the procedure will execute the custom function assistant_dba.regexp_replace. For MySQL versions >= 8.0, it will execute the standard REGEXP_REPLACE function.

4\. The procedure will create a table in the assistant_dba database to store the data. The table name will be generated in the following way:

-  The first character will be 't'.
-  The second character will be a underscore ('_').
-  The third part will contain the server_id.
-  The fourth part will be a underscore ('_').
-  The fifth part will be the hostname, which can contain the following characters: [a-z], [A-Z], [0-9], or the underscore ('_').

For example, if the server has server_id = 3043 and hostname = my.sql-3043, the procedure will create a table named assistant_dba.t_3043_mysql3043. This naming convention helps to identify which server the data belongs to.


```sql
mysql> drop procedure if exists `assistant_dba`.`count_con_each_users`;
DELIMITER $$
create procedure `assistant_dba`.`count_con_each_users` ()
begin
declare speciality condition for sqlstate '45000';
SET sql_log_bin = 0;
set @error_mysql_version:= concat ('Warning! This procedure doesn''t work with MySQL less than 5.7.') ;
set @error_check_function:= concat ('Warning! The function ''assistant_dba.regexp_replace'' doesn''t exist on this database server.') ;
#call `assistant_dba`.`count_con_each_users` ();
set @var_server_id := (select @@server_id);
set @var_server_name :=(select @@hostname);
set @var_server_version := (select @@version);
set @var_first_number_server_version := concat(SUBSTRING_INDEX(@@version, '.', 1),'.', SUBSTRING_INDEX(SUBSTRING_INDEX(@@version, '.', 2), '.', -1)) ;
#I check the version MySQL. If MySQL has a version less than 5.7, then this procedure has finished with an error.
    if @var_first_number_server_version<5.7 then
       signal speciality set message_text = @error_mysql_version;
	end if;
if @var_first_number_server_version<8 then 
	set @check_version=5;
	set @check_function=(select  coalesce((select 1 from information_schema.routines where ROUTINE_SCHEMA='assistant_dba' and ROUTINE_NAME='regexp_replace' and ROUTINE_TYPE='FUNCTION'),0,1));
    if @check_function!=1 then
       signal speciality set message_text = @error_check_function;
	end if;
    #I'll create the table which called server_idsevername. For example, the global variables has values server_id=3043 and hostname=mysql3043.
    #The table will be named t_3043_mysql3043.
    #I remove from the hostname the characters that do not satisfy the condition [a-z] or [A-Z] or [0-9] or _.
    set @var_server_name_end :=(select assistant_dba.`regexp_replace`(@var_server_name ,'[^a-zA-Z0-9_]',''));
    set @tblname_count_con_each_users=concat('t_',@var_server_id,'_',(select assistant_dba.`regexp_replace`(@var_server_name ,'[^a-zA-Z0-9_]','')));
end if;    
if @var_first_number_server_version>=8 then 
	set @check_version=5;
	set @check_function=(select  coalesce((select 1 from information_schema.routines where ROUTINE_SCHEMA='assistant_dba' and ROUTINE_NAME='regexp_replace' and ROUTINE_TYPE='FUNCTION'),0,1));
    if @check_function!=1 then
       signal speciality set message_text = @error_check_function;
	end if;
    #I'll create the table which called server_idsevername. For example, the global variables has values server_id=3043 and hostname=mysql3043.
    #The table will be named 3043mysql3043.
    #I remove from the hostname the characters that do not satisfy the condition [a-z] or [A-Z] or [0-9] or _.
    set @tblname_count_con_each_users=concat('t_',@var_server_id,'_',(select regexp_replace(@var_server_name ,'[^a-zA-Z0-9_]','')));
end if;  
	set @sql_create_tbl :=concat(' CREATE TABLE if not exists \`assistant_dba\`.',@tblname_count_con_each_users,' (\`id\` INT UNSIGNED NOT NULL AUTO_INCREMENT, \`user_name\` VARCHAR(64) NOT NULL, \`host_name\`  VARCHAR(64) NOT NULL, cnt int not null, date_collect datetime not null, PRIMARY KEY (\`id\`), key \`IX_user_host_date_collect\` (\`user_name\` asc, \`host_name\` asc, \`date_collect\`) ); '); 
		prepare dynamic_create_tbl from @sql_create_tbl;
		execute dynamic_create_tbl;
        deallocate prepare dynamic_create_tbl;
	set @sql_insert :=concat(' insert into \`assistant_dba\`.',@tblname_count_con_each_users,' (\`user_name\` , \`host_name\`, \`cnt\` , \`date_collect\`) 
								select distinct user, left(host,(locate(":",host))-1) host_name,count(*) cnt, now() date_collect
                                from information_schema.processlist 
                                group by user, host_name; '); 
        #select @sql_insert;
		prepare dynamic_insert from @sql_insert;
		execute dynamic_insert;
        deallocate prepare dynamic_insert;
end$$
DELIMITER ;
```

##### c) Creating the event for the automatic execution of a procedure on the schedule.

```sql
mysql> drop event if exists assistant_dba.`dba_count_con_each_users`;
DELIMITER $$
CREATE EVENT assistant_dba.`dba_count_con_each_users` ON SCHEDULE EVERY 30 second STARTS '2024-12-14 00:00:00' ON COMPLETION NOT PRESERVE DISABLE ON SLAVE COMMENT 'Collecting information how many connections each user opened.' DO BEGIN
  call assistant_dba.count_con_each_users(); 
END$$
DELIMITER ;
alter EVENT assistant_dba.`dba_count_con_each_users` enable;
```


### 3. Configuring ‘add-on’ on the replica server.

Replica server mysql3044 (slave from main master mysql3043)

You need to connect via MySQL to the server mysql3044 and execute a command to activate the event on the replica server.


```sql
mysql> alter EVENT assistant_dba.`dba_count_con_each_users` enable;
```
### 4. Checking how work the script.
You need to check that the event works and inserts data into the table.

Connect via MySQL to the following servers:

- mysql3043 (master)
- mysql3044 (slave of mysql3043)
- mysql30226 (standalone MariaDB)

Then, execute the following query:

##### On the mysql3043 server (master):



```sql
mysql> SELECT * FROM assistant_dba.t_3043_mysql3043
where date_collect=(select max(date_collect) from assistant_dba.t_3043_mysql3043 )
order by date_collect desc, cnt desc, user_name;
```


|**# id**|**user_name**|**host_name**|**cnt**|**date_collect**|
| :- | :- | :- | :- | :- |
|722|test|10.10.10.15|2|14.12.2024  14:57:30|
|720|pavel_polikov|10.10.10.15|2|14.12.2024  14:57:30|
|718|event_scheduler|Localhost|1|14.12.2024  14:57:30|
|719|pavel_polikov|%|1|14.12.2024  14:57:30|
|721|pavel_polikov|10.10.30.44|1|14.12.2024  14:57:30|

To check the correct data in our table, you could execute the following query:

```sql
mysql> select * from information_schema.processlist;
select distinct user, case 
when locate(":",host)>0 then left(host,(locate(":",host))-1)
else
host
end  host_name, count(*) cnt, now() date_collect
from information_schema.processlist
group by user, host_name
order by  date_collect  desc, cnt desc, user;
```

You will see that in the table assistant_dba.t_3043_mysql3043, there is an additional row where user_name = 'pavel_polikov' and host_name = '%'. This row indicates that the event, which runs every 30 seconds, was triggered by the user pavel_polikov@%.


|**# ID**|**USER**|**HOST**|**DB**|**COMMAND**|**TIME**|**STATE**|**INFO**|
| :- | :- | :- | :- | :- | :- | :- | :- |
|118|pavel_polikov|10.10.10.15:4216| |Sleep|0| | |
|12|test|10.10.10.15:3627| |Sleep|77| | |
|10|pavel_polikov|10.10.10.15:3622| |Query|0|executing|select * from information_schema.processlist|
|13|event_scheduler|localhost| |Daemon|1|Waiting for next activation| |
|119|test|10.10.10.15:4222| |Sleep|77| | |
|2|pavel_polikov|10.10.30.44:44132| |Binlog Dump|7879|Master has sent all binlog to slave; waiting for more updates| |


|**# user**|**host_name**|**cnt**|**date_collect**|
| :- | :- | :- | :- |
|pavel_polikov|10.10.10.15|2|14.12.2024 14:58:00|
|test|10.10.10.15|2|14.12.2024 14:58:00|
|pavel_polikov|10.10.30.44|1|14.12.2024 14:58:00|
|event_scheduler|localhost|1|14.12.2024 14:58:00|

##### On the server mysql3044 (replica)

```sql
mysql> SELECT * FROM assistant_dba.t_3044_mysql3044 
where date_collect=(select max(date_collect) from assistant_dba.t_3044_mysql3044 )
order by date_collect desc, cnt desc, user_name;;
```



|**# id**|**user_name**|**host_name**|**cnt**|**date_collect**|
| :- | :- | :- | :- | :- |
|2741|system user| |5|14.12.2024  15:02:30|
|2740|pavel_polikov|10.10.10.15|2|14.12.2024  15:02:30|
|2744|event_scheduler|localhost|1|14.12.2024  15:02:30|
|2743|pavel_polikov|%|1|14.12.2024  15:02:30|
|2742|system user|connecting host|1|14.12.2024  15:02:30|

To check the correct data in the table, you can execute the following query:


```sql
mysql> select * from information_schema.processlist;
select distinct user, case 
when locate(":",host)>0 then left(host,(locate(":",host))-1)
else
host
end  host_name, count(*) cnt, now() date_collect
from information_schema.processlist
group by user, host_name
order by  date_collect  desc, cnt desc, user;
```


You will see that when checking the table assistant_dba.t_3044_mysql3044, there is one extra row containing user_name = 'pavel_polikov' and host_name = '%'. This row indicates that the event, which runs every 30 seconds, was triggered by the user pavel_polikov@%.


|**# ID**|**USER**|**HOST**|**DB**|**COMMAND**|**TIME**|**STATE**|**INFO**|
| :- | :- | :- | :- | :- | :- | :- | :- |
|177|pavel_polikov|10.10.10.15:3624| |Query|0|executing|select * from information_schema.processlist|
|10|system user| | |Connect|2653|Waiting for an event from Coordinator| |
|11|system user| | |Connect|9629|Waiting for an event from Coordinator| |
|12|system user| | |Connect|9628|Waiting for an event from Coordinator| |
|13|system user| | |Connect|9628|Waiting for an event from Coordinator| |
|341|pavel_polikov|10.10.10.15:4592| |Sleep|0| | |
|5|system user|connecting host| |Connect|9629|Waiting for source to send event| |
|6|system user| | |Query|2653|Replica has read all relay log; waiting for more updates| |
|7|event_scheduler|localhost| |Daemon|7|Waiting for next activation| |

|**# user**|**host_name**|**cnt**|**date_collect**|
| :- | :- | :- | :- |
|system user| |5|14.12.2024  15:03:00|
|pavel_polikov|10.10.10.15|2|14.12.2024  15:03:00|
|event_scheduler|localhost|1|14.12.2024  15:03:00|
|system user|connecting host|1|14.12.2024  15:03:00|

##### On the server mysql3226 (standalone)

```sql
mysql> SELECT * FROM assistant_dba.t_1_mysql30226 
where date_collect=(select max(date_collect) from assistant_dba.t_1_mysql30226 )
order by date_collect desc, cnt desc, user_name;
```


|**# id**|**user_name**|**host_name**|**cnt**|**date_collect**|
| :- | :- | :- | :- | :- |
|338|pavel_polikov|10.10.10.15|2|14.12.2024  15:04:30|
|336|event_scheduler|localhost|1|14.12.2024  15:04:30|
|337|pavel_polikov|%|1|14.12.2024  15:04:30|

The result of the check will be as follows:

- **user_name** – shows the username without the hostname.
- **host_name** – shows the hostname or IP address from which the user connected.
- **cnt** – shows the number of connections opened by the user from this hostname.
- **date_collect** – shows the datetime when this information was collected.

# <a name="_toc192534160">**Summary**</a>
This 'add-on' shows how many connections each user opened at a certain time on the MySQL server.
You can download this script (count_number_connections_users.sql) and other scripts from <https://github.com/PahanDba/mysql_dba/>.
