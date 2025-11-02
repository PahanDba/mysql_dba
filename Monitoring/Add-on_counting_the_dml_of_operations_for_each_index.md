Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba

Counting the number of DML operations for each index in a table on the MySQL server.


# **Table of contents**
[**Script goal: 'Collect DML statements for each index in the tables on the MySQL server'**](#_toc212741350)

[**System requirements**](#_toc212741351)

[**List of servers for demonstrating the configuration of the 'add-on' for counting DML statements for each index in the tables on the MySQL server.**](#_toc212741352)

[**Server Master (main master)**](#_toc212741353)

[**Server slave44 (slave from main master mysql3043)**](#_toc212741354)

[**Server standalone**](#_toc212741355)

[**Configuring the 'add-on' to collect DML statements for each index in the tables on MySQL.**](#_toc212741356)

[**Initial conditions**](#_toc212741357)

[**Configuring the 'add-on'**](#_toc212741358)

[**The description of the logic of the procedures this 'add-on'**](#_toc212741359)

[**Examples of executing the procedure**](#_toc212741360)

[**Configuring 'add-on' on the replica server**](#_toc212741361)

[**Summary**](#_toc212741362)


# <a name="_toc212741350"></a>**Script goal: 'Collect DML statements for each index in the tables on the MySQL server'**
- It helps MySQL DBAs collect statistics on the number of DML operations on the indexes in the tables on the MySQL server.
- It helps MySQL DBAs analyze the load on the indexes in the tables on the MySQL server during specific time intervals.


# <a name="_toc212741351"></a>**System requirements**

- This add-on works on MySQL 5.7.42, MySQL 8.0, MariaDB 10.6-10.11



# <a name="_hlk160717248"></a><a name="_toc212741352"></a>**List of servers for demonstrating the configuration of the 'add-on' for counting DML statements for each index in the tables on the MySQL server.**

Below is a list of servers that shows the descriptions for each server with installed software used to check the functionality of this 'add-on'.


## <a name="_toc212741353"></a>**Server Master (main master)**
 	ServerName: mysql3043
 	IP address: 10.10.30.43
 	OS: Debian 11/12
 	RDBMS: MySQL 5.7.42
 	Server configuration: 2 CPU, 4GB RAM, 30GB

## <a name="_toc212741354"></a>**Server slave44 (slave from main master mysql3043)**
 	ServerName: mysql3044
 	IP address: 10.10.30.44
 	OS: Debian 11/12
 	RDBMS: MySQL 8.0.40
 	Server configuration: 2 CPU, 4GB RAM, 30GB

## <a name="_toc212741355"></a>**Server standalone** 
 	ServerName: mysql30226
 	IP address: 10.10.30.226
 	OS: Debian 11/12
 	RDBMS: MariaDB 10.11
 	Server configuration: 2 CPU, 4GB RAM, 30GB

# <a name="_toc212741356"></a>**Configuring the 'add-on' to collect DML statements for each index in the tables on MySQL.**

## <a name="_toc212741357"></a>**Initial conditions** 


On all replica servers, you need to enable the event_scheduler. Use the following command to enable it:

```sql
mysql> SET GLOBAL event_scheduler = 1;
```

Warning! Before enabling this parameter, ensure that no events will be executed on the replica server. I recommend running the following commands for each event on the master server:

```sql
mysql> ALTER EVENT schema.`event_name` DISABLE ON SLAVE;
mysql> ALTER EVENT schema.`event_name` ENABLE;
```

Alternatively, you can execute the following command on the replica server:

```sql
mysql> ALTER EVENT schema.`event_name` DISABLE ON SLAVE;
```

In the future, when creating a new event on the master server, always use the DISABLE ON SLAVE parameter to prevent the event from being executed on the replica server, if that is your intention.



## <a name="_toc212741358"></a>**Configuring the 'add-on'**

1\. I will demonstrate the work of this 'add-on' on mysql3043 (main master MySQL 5.7.42) -> mysql3044 (slave from main master mysql3043 MySQL 8.0.40) and standalone mysql30226 (MariaDB 10.11).

2\. Create the necessary objects.

You need to download and execute the script from [https://github.com/PahanDba/mysql_dba/blob/main/Monitoring/count_dml_stmt_index/count_dml_stmt_index.sql](https://github.com/PahanDba/mysql_dba/blob/main/Monitoring/count_dml_stmt_index/count_dml_stmt_index.sql) via MySQL on the following servers:

- mysql3043 (Main Master, MySQL 5.7.42)
- mysql3044 (slave from main master mysql3043 MySQL 8.0.40)
- mysql30226 (MariaDB 10.11)

This script performs the following steps:

1\. Creates the assistant_dba database if it does not already exist on the server.

2\. Creates the function assistant_dba.regexp_replace, which works in MySQL 5.7 similarly to the REGEXP_REPLACE function available in MySQL 8.0 and later. This function was taken from [this blog post](https://www.cnblogs.com/rainbow--/p/17026987.html).

3\. Creates the procedure assistant_dba.count_dml_stmt_index. This procedure collects data from the table performance_schema.table_io_waits_summary_by_index_usage.

4\. Drops the event assistant_dba.count_dml_stmt_index if it exists and recreates it. This event is scheduled to run every 30 seconds.

5\. Creates the procedure ssistant_dba.count_dml_stmt_index_analyze. This procedure helps analyze the DML statements (COUNT_STAR, COUNT_READ, COUNT_WRITE, COUNT_FETCH, COUNT_INSERT, COUNT_UPDATE, COUNT_DELETE) for any table on the MySQL server during specific time intervals. This procedure considers restarting the MySQL service if it was executed during specific time intervals. This procedure doesn't account for the manual cleaning of the table performance_schema.table_io_waits_summary_by_index_usage or other ways of cleaning this table.



## <a name="_toc212741359"></a>**The description of the logic of the procedures this 'add-on'** 

This section describes the logic of the procedure assistant_dba.count_dml_stmt_index, which inserts data into a table used to store the number of DML statements for each index in a table on a MySQL server.

1\. The procedure uses the SET sql_log_bin = 0; statement to ensure that this operation does not insert unnecessary information into the binary log, which would otherwise be replicated to the replicas.

2\. The procedure checks the MySQL/MariaDB version. If the version is lower than 5.7, the procedure ends with an error.

3\.For MySQL 5.7, the procedure will execute the custom function assistant_dba.regexp_replace. For MySQL versions >= 8.0, it will execute the standard REGEXP\_REPLACE function.

4\. The procedure will create a table in the assistant_dba database to store the data. The table name will be generated in the following way:

- The first character will be 't'.
- The second character will be a underscore ('_').
- The third part will contain the server_id.
- The fourth part will be a underscore ('_').
- The fifth part will be the hostname, which can contain the following characters: [a-z], [A-Z], [0-9], or the underscore ('_').
- The sixth part contains the postfix _count_dml_stmt_index.

For example, if the server has server_id = 3043 and hostname = my.sql-3043, the procedure will create a table named assistant_dba.t_3043_mysql3043_count_dml_stmt_index. This naming convention helps to identify which server the data belongs to.

5\. The procedure reads data (COUNT_STAR, COUNT_READ, COUNT_WRITE, COUNT_FETCH, COUNT_INSERT, COUNT_UPDATE, COUNT_DELETE) from the table performance_schema.table_io_waits_summary_by_index_usage and saves it in the table for storing data in the assistant_dba database.



The description of the logic of the procedure assistant_dba.`count_dml_stmt_index_analyze` follows:

1\. The procedure uses the SET sql_log_bin = 0; statement to ensure that this operation does not insert unnecessary information into the binary log, which would otherwise be replicated to the replicas.

2\. The procedure is performed as follows:

```sql
mysql> call assistant_dba.count_dml_stmt_index_analyze ('table_store', 'your_schema','your_table' ,'datetime_start','datetime_finish');
```

table_store – the table, which stores the values DML (COUNT_STAR, COUNT_READ, COUNT_WRITE, COUNT_FETCH, COUNT_INSERT, COUNT_UPDATE, COUNT_DELETE) of statements from the table performance_schema.table_io_waits_summary_by_index_usage.

your_schema – the schema, where there is the table and the data about it we want to analyze.

your_table – the table, which we want to analyze.

datetime_start – the starting time of the interval in the format 'YYYY-MM-DD HH:MM:SS', which we need to analyze 

datetime_finish  – the finishing time of the interval in the format 'YYYY-MM-DD HH:MM:SS', which we need to analyze.

The procedure has a few algorithms for processing different exceptions:



1\. If any of the dates indicated in the parameters doesn't exist, then the procedure tries to find the nearest date and time to the specified date and time, on both left and right sides. For example, you set the starting date and time = '2025-06-29 13:47:10'. The procedure is trying to find this date and time. If this date and time can't be found, the procedure tries to find the nearest date and time to the specified date and time on both left and right sides. For example, the date and time on the left side is = '2025-06-29 13:47:00', and there is a date and time on the right side = '2025-06-29 13:47:30'. The delta between the setting date and time and the date and time on the left side is 10 seconds. The delta between the setting date and time and the date and time on the right side is 20 seconds. The procedure will choose the date and time on the left side = '2025-06-29 13:47:00' because the date and time on the left side is closer to the set date '2025-06-29 13:47:00' because 10 seconds is less than 20 seconds.

2\. Possible variant. When the starting time equals the finishing time, then the procedure shows the error that you need to change the date and time of the interval.

3\. The procedure accounts for restarting the MySQL service if it was performed in this interval. The procedure doesn't account for the manual cleaning of the table performance_schema.table_io_waits_summary_by_index_usage or other ways of cleaning this table.

4\. The procedure take into account the future time, which isn't in the table, and uses as possible nearest available values for the table, which you analyze from the table to store information about DML of the operations.

5\. The procedure considers all indexes that were created before the finish date and time.

## <a name="_toc212741360"></a>**Examples of executing the procedure**

For example, you launch the procedure with the parameters:

table_store = t_3043_mysql3043_count_dml_stmt_index

your_schema = tempor_t4

your_table = users1_2m

datetime_start = 2025-10-26 14:15:30

datetime_finish = 2025-10-26 19:15:30.


Below, I'll demonstrate the different ways to execute the procedure assistant_dba.count_dml_stmt_index_analyze.


1\. The server didn't work this day.

```sql
mysql> call assistant_dba.count_dml_stmt_index_analyze('t_3043_mysql3043_count_dml_stmt_index', 'tempor_t4','users1_2m' ,'2025-10-25 14:15:30','2025-10-25 15:15:30');
```

I get the following result:

You need to change your boundary values '2025-10-25 14:15:30' and '2025-10-25 15:15:30' because after the process of searching for the boundary values, the procedure found that the values of the date and time of the start and the date and time of the finish were equal. This may indicate that your database server was not running during the specified interval, or the store table doesn't have values in this interval. The procedure found the following boundary values instead of '2025-10-25 14:15:30': '2025-10-24 19:15:30', and instead of '2025-06-29 21:50:10': '2025-10-25 15:15:30'.

2\.The finishing date and time of the interval is less than the starting date and time of the interval.

```
mysql> call assistant_dba.count_dml_stmt_index_analyze('t_3043_mysql3043_count_dml_stmt_index', 'tempor_t4','users1_2m' ,'2025-10-26 18:38:30','2025-10-26 17:38:30');
```

I get the following result:

The finishing date and time of the interval can't be less than the starting date and time of the interval.



3\. The starting date and time of the interval and the finishing date and time of the interval are at different dates at the launch of the MySQL server, so it was possible the MySQL server was restarted or shut down at some time.

```
mysql> call assistant_dba.count_dml_stmt_index_analyze('t_3043_mysql3043_count_dml_stmt_index', 'tempor_t4','users1_2m' ,'2025-10-23 10:00:30','2025-10-26 14:52:30');
```

Text1 = 'These are the values of the DML operations on the starting date and time of the interval and the finishing date and time of the interval.'

Tex2 = 'This is the delta of the DML operation values on the starting date and time of the interval and the finishing date and time of the interval in the number of seconds.'

Text3 = 'This is the average value of the DML operations per second between the starting date and time of the interval and the finishing date and time of the interval.'



**Table1**



|**# description**|**object_schema**|**object_name**|**index_name**|**COUNT_STAR**|**COUNT_READ**|**COUNT_WRITE**|**COUNT_FETCH**|**COUNT_INSERT**|**COUNT_UPDATE**|**COUNT_DELETE**|**delta\_sec**|**date_collect**|**date_start**|
| :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|Text1|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0| |23.10.2025  9:48:30|23.10.2025  9:22:37|
|Text1|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0| |23.10.2025  9:48:30|23.10.2025  9:22:37|
|Text1|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0| |23.10.2025  9:48:30|23.10.2025  9:22:37|
|Text1|tempor_t4|users1_2m|NULL|120000|0|120000|0|120000|0|0| |23.10.2025  10:59:00|23.10.2025  9:22:37|
|Text1|tempor_t4|users1_2m|NULL|1200000|0|1200000|0|1200000|0|0| |23.10.2025  19:11:00|23.10.2025  9:22:37|
|Text1|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0| |23.10.2025  19:11:00|23.10.2025  9:22:37|
|Text1|tempor_t4|users1_2m|u12k_ix_name|5400000|5400000|0|5400000|0|0|0| |23.10.2025  19:11:00|23.10.2025  9:22:37|
|Text1|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0| |23.10.2025  19:11:00|23.10.2025  9:22:37|
|Text2|tempor_t4|users1_2m|NULL|1080000|0|1080000|0|1080000|0|0|29520|12.12.9998  23:59:59|23.10.2025  9:22:37|
|Text2|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0|33750|12.12.9998  23:59:59|23.10.2025  9:22:37|
|Text2|tempor_t4|users1_2m|u12k_ix_name|5400000|5400000|0|5400000|0|0|0|33750|12.12.9998  23:59:59|23.10.2025  9:22:37|
|Text2|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0|33750|12.12.9998  23:59:59|23.10.2025  9:22:37|
|Text3|tempor_t4|users1_2m|NULL|36\.5854|0|36\.5854|0|36\.5854|0|0| |12.12.9999  23:59:59|23.10.2025  9:22:37|
|Text3|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0| |12.12.9999  23:59:59|23.10.2025  9:22:37|
|Text3|tempor_t4|users1_2m|u12k_ix_name|160|160|0|160|0|0|0| |12.12.9999  23:59:59|23.10.2025  9:22:37|
|Text3|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0| |12.12.9999  23:59:59|23.10.2025  9:22:37|
|Text1|tempor_t4|users1_2m|NULL|120000|0|120000|0|120000|0|0| |26.10.2025  14:46:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0| |26.10.2025  14:46:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0| |26.10.2025  14:46:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0| |26.10.2025  14:46:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|NULL|240000|0|240000|0|240000|0|0| |26.10.2025  14:52:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0| |26.10.2025  14:52:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0| |26.10.2025  14:52:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0| |26.10.2025  14:52:30|26.10.2025  14:20:28|
|Text2|tempor_t4|users1_2m|NULL|120000|0|120000|0|120000|0|0|360|12.12.9998  23:59:59|26.10.2025  14:20:28|
|Text2|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0|360|12.12.9998  23:59:59|26.10.2025  14:20:28|
|Text2|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0|360|12.12.9998  23:59:59|26.10.2025  14:20:28|
|Text2|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0|360|12.12.9998  23:59:59|26.10.2025  14:20:28|
|Text3|tempor_t4|users1_2m|NULL|333.3333|0|333.3333|0|333.3333|0|0| |12.12.9999  23:59:59|26.10.2025  14:20:28|
|Text3|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0| |12.12.9999  23:59:59|26.10.2025  14:20:28|
|Text3|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0| |12.12.9999  23:59:59|26.10.2025  14:20:28|
|Text3|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0| |12.12.9999  23:59:59|26.10.2025  14:20:28|


The rows with the value «Text1» in the description column show the values of the DML operations (COUNT_STAR, COUNT_READ, COUNT_WRITE, COUNT_FETCH, COUNT_INSERT, COUNT_UPDATE, COUNT_DELETE) on the starting date and time of the interval or the finishing date and time of the interval for each value of the date of the start of the MySQL server.

The rows with the value «Text2» in the description column show the difference in values of the DML operations (COUNT_STAR, COUNT_READ, COUNT_WRITE, COUNT_FETCH, COUNT_INSERT, COUNT_UPDATE, COUNT_DELETE) and the number of seconds between the starting date and time of the interval and the finishing date and time of the interval for the particular date of the start of the MySQL server. The value in the column “date_collect” equal to '9998-12-12 23:59:59' is necessary only for proper sorting of values.

The rows with the values «Text3» in the description column show the average difference in values of the DML operations (COUNT_STAR, COUNT_READ, COUNT_WRITE, COUNT_FETCH, COUNT_INSERT, COUNT_UPDATE, COUNT_DELETE) per second which was between the starting date and time of the interval and the finishing date and time of the interval for the particular date of the start of the MySQL server. The value in the column “date_collect” equal to '9999-12-12 23:59:59' is necessary only for proper sorting of values.

4\. The starting date and time of the interval and the finishing date and time of the interval fall on the same MySQL server start date.

```
mysql> call assistant_dba.count_dml_stmt_index_analyze('t_3043_mysql3043_count_dml_stmt_index', 'tempor_t4','users1_2m' ,'2025-10-26 14:00:30','2025-10-26 15:12:30');
```

Text1 = 'These are the values of the DML operations on the starting date and time of the interval and the finishing date and time of the interval.'

Tex2 = 'This is the delta of the values of the DML operations on the starting date and time of the interval and the finishing date and time of the interval, with the number of seconds in the interval.'

Text3 = 'This is the average value of the DML operations per second between the starting date and time of the interval and the finishing date and time of the interval.'

**Table 2**


|**# description**|**object_schema**|**object_name**|**index_name**|**COUNT_STAR**|**COUNT_READ**|**COUNT_WRITE**|**COUNT_FETCH**|**COUNT_INSERT**|**COUNT_UPDATE**|**COUNT_DELETE**|**delta\_sec**|**date_collect**|**date_start**|
| :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|Text1|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0| |26.10.2025  14:46:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0| |26.10.2025  14:46:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0| |26.10.2025  14:46:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|NULL|120000|0|120000|0|120000|0|0| |26.10.2025  14:46:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|NULL|240000|0|240000|0|240000|0|0| |26.10.2025  15:12:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0| |26.10.2025  15:12:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0| |26.10.2025  15:12:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0| |26.10.2025  15:12:30|26.10.2025  14:20:28|
|Text2|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0|1560|12.12.9998  23:59:59|26.10.2025  14:20:28|
|Text2|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0|1560|12.12.9998  23:59:59|26.10.2025  14:20:28|
|Text2|tempor_t4|users1_2m|NULL|120000|0|120000|0|120000|0|0|1560|12.12.9998  23:59:59|26.10.2025  14:20:28|
|Text2|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0|1560|12.12.9998  23:59:59|26.10.2025  14:20:28|
|Text3|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0| |12.12.9999  23:59:59|26.10.2025  14:20:28|
|Text3|tempor_t4|users1_2m|NULL|76\.9231|0|76.9231|0|76.9231|0|0| |12.12.9999  23:59:59|26.10.2025  14:20:28|
|Text3|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0| |12.12.9999  23:59:59|26.10.2025  14:20:28|
|Text3|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0| |12.12.9999  23:59:59|26.10.2025  14:20:28|




The rows with the value «Text1» in the description column show the values of the DML operations (COUNT_STAR, COUNT_READ, COUNT_WRITE, COUNT_FETCH, COUNT_INSERT, COUNT_UPDATE, COUNT_DELETE) on the starting date and time of the interval or the finishing date and time of the interval for each value of the date of the start of the MySQL server.

The rows with the value «Text2» in the description column show the difference in values of the DML operations (COUNT_STAR, COUNT_READ, COUNT_WRITE, COUNT_FETCH, COUNT_INSERT, COUNT_UPDATE, COUNT_DELETE) and the number of seconds between the starting date and time of the interval and the finishing date and time of the interval for the particular date of the start of the MySQL server. The value in the column “date_collect” equal to '9998-12-12 23:59:59' is necessary only for proper sorting of values.

The rows with the values «Text3» in the description column show the average difference in values of the DML operations (COUNT_STAR, COUNT_READ, COUNT_WRITE, COUNT_FETCH, COUNT_INSERT, COUNT_UPDATE, COUNT_DELETE) per second which was between the starting date and time of the interval and the finishing date and time of the interval for the particular date of the start of the MySQL server. The value in the column “date_collect” equal to '9999-12-12 23:59:59' is necessary only for proper sorting of values.

5\. The starting and finishing timestamps fall within the same MySQL server uptime session, but the finishing timestamp is in the future\
(For example, the current time is 2025-07-04 22:53.)

```
mysql> call assistant_dba.count_dml_stmt_index_analyze('t_3043_mysql3043_count_dml_stmt_index', 'tempor_t4','users1_2m' ,'2025-10-26 15:30:30','2025-10-26 18:29:30');    
```

In this case, since the specified finishing timestamp has not yet occurred, the procedure will automatically select the latest available finishing timestamp for this object from the storage table.

**Table 3**
|**# description**|**object_schema**|**object_name**|**index_name**|**COUNT_STAR**|**COUNT_READ**|**COUNT_WRITE**|**COUNT_FETCH**|**COUNT_INSERT**|**COUNT_UPDATE**|**COUNT_DELETE**|**delta\_sec**|**date_collect**|**date_start**|
| :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|Text1|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0| |26.10.2025  15:30:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0| |26.10.2025  15:30:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|NULL|240000|0|240000|0|240000|0|0| |26.10.2025  15:30:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0| |26.10.2025  15:30:30|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0| |26.10.2025  16:32:00|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0| |26.10.2025  16:32:00|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0| |26.10.2025  16:32:00|26.10.2025  14:20:28|
|Text1|tempor_t4|users1_2m|NULL|240000|0|240000|0|240000|0|0| |26.10.2025  16:32:00|26.10.2025  14:20:28|
|Text2|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0|3690|12.12.9998  23:59:59|26.10.2025  14:20:28|
|Text2|tempor_t4|users1_2m|NULL|0|0|0|0|0|0|0|3690|12.12.9998  23:59:59|26.10.2025  14:20:28|
|Text2|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0|3690|12.12.9998  23:59:59|26.10.2025  14:20:28|
|Text2|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0|3690|12.12.9998  23:59:59|26.10.2025  14:20:28|
|Text3|tempor_t4|users1_2m|NULL|0|0|0|0|0|0|0| |12.12.9999  23:59:59|26.10.2025  14:20:28|
|Text3|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0| |12.12.9999  23:59:59|26.10.2025  14:20:28|
|Text3|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0| |12.12.9999  23:59:59|26.10.2025  14:20:28|
|Text3|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0| |12.12.9999  23:59:59|26.10.2025  14:20:28|

The rows with the value «Text1» in the description column show the values of the DML operations (COUNT_STAR, COUNT_READ, COUNT_WRITE, COUNT_FETCH, COUNT_INSERT, COUNT_UPDATE, COUNT_DELETE) on the starting date and time of the interval or the finishing date and time of the interval for each value of the date of the start of the MySQL server.

The rows with the value «Text2» in the description column show the difference in values of the DML operations (COUNT_STAR, COUNT_READ, COUNT_WRITE, COUNT_FETCH, COUNT_INSERT, COUNT_UPDATE, COUNT_DELETE) and the number of seconds between the starting date and time of the interval and the finishing date and time of the interval for the particular date of the start of the MySQL server. The value in the column “date_collect” equal to '9998-12-12 23:59:59' is necessary only for proper sorting of values.

The rows with the values «Text3» in the description column show the average difference in values of the DML operations (COUNT_STAR, COUNT_READ, COUNT_WRITE, COUNT_FETCH, COUNT_INSERT, COUNT_UPDATE, COUNT_DELETE) per second which was between the starting date and time of the interval and the finishing date and time of the interval for the particular date of the start of the MySQL server. The value in the column “date_collect” equal to '9999-12-12 23:59:59' is necessary only for proper sorting of values.


## <a name="_toc212741361"></a>**Configuring 'add-on' on the replica server**


Replica server mysql3044 (slave from main master mysql3043)

You need to connect via MySQL to the server mysql3044 and execute a command to activate the event on the replica server.

```sql
mysql>alter EVENT assistant_dba.`count_dml_stmt_index` enable;
```

**Checking how the script works**
You need to verify that the event is running and inserting data into the table.

Connect via MySQL to the following servers:

- mysql3043 (master)
- mysql3044 (slave of mysql3043)
- mysql30226 (standalone MariaDB)

Then, execute the following query:

**On the mysql3043 server (master):**



```sql
mysql> SELECT * FROM assistant_dba.t_3043_mysql3043_count_dml_stmt_index
where date_collect=(select max(date_collect) from assistant_dba.t_3043_mysql3043_count_dml_stmt_index )
order by date_collect desc; 
```



**Table 4**
|**# id**|**object_type**|**object_schema**|**object_name**|**index_name**|**COUNT_STAR**|**COUNT_READ**|**COUNT_WRITE**|**COUNT_FETCH**|**COUNT_INSERT**|**COUNT_UPDATE**|**COUNT_DELETE**|**date_collect**|**date_start**|
| :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|57264|TABLE|percona\_information|heartbeat|PRIMARY|842947|842947|0|842947|0|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57265|TABLE|percona\_information|heartbeat|NULL|1685894|0|1685894|0|842947|842947|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57266|TABLE|assistant_dba|t_3043_mysql3043_count_dml_stmt_index|PRIMARY|0|0|0|0|0|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57267|TABLE|assistant_dba|t_3043_mysql3043_count_dml_stmt_index|IX_object_schema_object_name_date_collect|80851|80851|0|80851|0|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57268|TABLE|assistant_dba|t_3043_mysql3043_count_dml_stmt_index|NULL|238663|234374|4289|234374|4289|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57269|TABLE|assistant_dba|t_3043_mysql3043_count_dml_stmt|PRIMARY|0|0|0|0|0|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57270|TABLE|assistant_dba|t_3043_mysql3043_count_dml_stmt|IX_object_schema_object_name_date_collect|2252|2252|0|2252|0|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57271|TABLE|assistant_dba|t_3043_mysql3043_count_dml_stmt|ix_date_collect|1|1|0|1|0|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57272|TABLE|assistant_dba|t_3043_mysql3043_count_dml_stmt|NULL|275651|274012|1639|274012|1639|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57273|TABLE|assistant_dba|new_table2|PRIMARY|0|0|0|0|0|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57274|TABLE|assistant_dba|t_3043_mysql3043|PRIMARY|0|0|0|0|0|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57275|TABLE|assistant_dba|t_3043_mysql3043|IX_object_schema_object_name_date_collect|0|0|0|0|0|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57276|TABLE|tempor_t4|users1_2m|PRIMARY|0|0|0|0|0|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57277|TABLE|tempor_t4|users1_2m|u12k_ix_name|0|0|0|0|0|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28| 
|57278|TABLE|tempor_t4|users1_2m|u12k_ix_name_country_region|0|0|0|0|0|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|
|57279|TABLE|tempor_t4|users1_2m|NULL|240000|0|240000|0|240000|0|0|26.10.2025  16:41:30|26.10.2025  14:20:28|



**On the server mysql3044 (replica)**

```sql
mysql> SELECT * FROM assistant_dba.t_3044_mysql3044_count_dml_stmt_index 
where date_collect=(select max(date_collect) from assistant_dba.t_3044_mysql3044_count_dml_stmt_index )
order by date_collect 
limit 20; 
```



**Table 5**
|**# id**|**object_type**|**object_schema**|**object_name**|**index_name**|**COUNT_STAR**|**COUNT_READ**|**COUNT_WRITE**|**COUNT_FETCH**|**COUNT_INSERT**|**COUNT_UPDATE**|**COUNT_DELETE**|**date_collect**|**date_start**|
| :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|639571|TABLE|mysql|schemata|PRIMARY|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639572|TABLE|mysql|schemata|catalog_id|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639573|TABLE|mysql|schemata|default_collation_id|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639574|TABLE|mysql|tablespace_files|tablespace_id|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639575|TABLE|mysql|tablespace_files|file_name|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639576|TABLE|mysql|tablespaces|PRIMARY|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639577|TABLE|mysql|tablespaces|name|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639578|TABLE|mysql|check_constraints|PRIMARY|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639579|TABLE|mysql|check_constraints|schema_id|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639580|TABLE|mysql|check_constraints|table_id|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639581|TABLE|mysql|column_type_elements|PRIMARY|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639582|TABLE|mysql|columns|PRIMARY|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639583|TABLE|mysql|columns|table_id|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639584|TABLE|mysql|columns|table_id_2|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639585|TABLE|mysql|columns|collation_id|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639586|TABLE|mysql|columns|srs_id|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639587|TABLE|mysql|foreign_key_column_usage|PRIMARY|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639588|TABLE|mysql|foreign_key_column_usage|foreign_key_id|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639589|TABLE|mysql|foreign_key_column_usage|column_id|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|
|639590|TABLE|mysql|foreign_keys|PRIMARY|0|0|0|0|0|0|0|26.10.2025  16:45:00|26.10.2025  14:20:53|




**On the server mysql30226 (standalone)**

```sql
mysql> SELECT * FROM assistant_dba.t_1_mysql30226_count_dml_stmt_index
where date_collect=(select max(date_collect) from assistant_dba.t_1_mysql30226_count_dml_stmt_index )
order by date_collect desc limit 20;
```

**Table 6**
|**# id**|**object_type**|**object_schema**|**object_name**|**index_name**|**COUNT_STAR**|**COUNT_READ**|**COUNT_WRITE**|**COUNT_FETCH**|**COUNT_INSERT**|**COUNT_UPDATE**|**COUNT_DELETE**|**date_collect**|**date_start**|
| :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|1|TABLE|sys|sys_config|PRIMARY|0|0|0|0|0|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|2|TABLE|tempor_t2|users|PRIMARY|0|0|0|0|0|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|3|TABLE|tempor_t2|users|Ix_name|0|0|0|0|0|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|4|TABLE|tempor_t2|users|ix_all|0|0|0|0|0|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|5|TABLE|dba_test|dba_ppa|PRIMARY|0|0|0|0|0|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|6|TABLE|dba_test|dba_ppa|NULL|6|2|4|2|4|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|7|TABLE|assistant_dba|t_1_mysql30226|PRIMARY|0|0|0|0|0|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|8|TABLE|assistant_dba|t_1_mysql30226|IX\_user\_host\_date_collect|0|0|0|0|0|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|9|TABLE|assistant_dba|t_1_mysql30226|NULL|476|0|476|0|476|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|10|TABLE|assistant_dba|t_1_mysql30226_count_dml_stmt|PRIMARY|0|0|0|0|0|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|11|TABLE|assistant_dba|t_1_mysql30226_count_dml_stmt|IX_object_schema_object_name_date_collect|0|0|0|0|0|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|12|TABLE|assistant_dba|t_1_mysql30226_count_dml_stmt|NULL|44638|43682|956|43682|956|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|13|TABLE|assistant_dba|t_1_mysql30226_count_dml_stmt_index|PRIMARY|0|0|0|0|0|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|14|TABLE|assistant_dba|t_1_mysql30226_count_dml_stmt_index|IX_object_schema_object_name_date_collect|0|0|0|0|0|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|
|15|TABLE|assistant_dba|t_1_mysql30226_count_dml_stmt_index|NULL|26|12|14|12|14|0|0|26.10.2025  18:10:30|26.10.2025  16:50:41|

# <a name="_toc212741362"></a>**Summary**
This add-on helps analyze the workload on any indexes in any table on the MySQL server and assists MySQL DBAs in understanding how frequently each index in the table was used.

You can download this script (count_dml_stmt_index.sql) and other related scripts from:

<https://github.com/PahanDba/mysql_dba/>.


