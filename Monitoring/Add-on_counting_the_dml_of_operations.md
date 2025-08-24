Written by Pavel A. Polikov https://github.com/PahanDba/mysql\_dba

Counting the number of DML operation for each table on the MySQL server.


# **Table of contents**
[**Script goal: 'Collect the DML statements for each table on the MySQL server'**](#_toc206869635)

[**System requirements**](#_toc206869636)

[**List of servers for demonstrating the configuration of the add-on 'for counting the number of connections for each user on MySQL server'.**](#_toc206869637)

>    [**Server Master (main master)**](#_toc206869638)

>    [**Server slave44 (slave from main master mysql3043)**](#_toc206869639)

>    [**Server standalone**](#_toc206869640)

[**Configuring the 'add-on' to collect the DML statements for each table on MySQL.**](#_toc206869641)

>    [**Initial conditions**](#_toc206869642)

>    [**Configuring the 'add-on'**](#_toc206869643)

>    [**The description of the logic of the procedure this 'add-on'**](#_toc206869644)

>    [**Examples of executing the procedure**](#_toc206869645)

>    [**Configuring 'add-on' on the replica server**](#_toc206869646)

>    [**Checking how the script works**](#_toc206869647)

[**Summary**](#_toc206869649)


# <a name="_toc206869635">**Script goal: 'Collect the DML statements for each table on the MySQL server'**</a>
- It helps MySQL DBAs collect statistics on the number of DML operations on the tables on the MySQL server.
- It helps MySQL DBAs analyze the load on the tables on the MySQL server during specific time intervals.

# <a name="_toc206869636">**System requirements**</a>

- This add-on works on MySQL 5.7.42, MySQL 8.0, MariaDB 10.6-10.11

# <a name="_toc206869637">**List of servers for demonstrating the configuration of the add-on 'for counting the number of connections for each user on MySQL server'.**</a>

Below is a list of servers that shows the descriptions for each server with installed software used to check the functionality of this ‘add-on’.

## <a name="_toc206869638">**Server Master (main master)**</a>
 	ServerName: mysql3043
 	IP address: 10.10.30.43
 	OS: Debian 11/12
 	RDBMS: MySQL 5.7.42
 	Server configuration: 2 CPU, 4GB RAM, 30GB

## <a name="_toc206869639">**Server slave44 (slave from main master mysql3043)**</a>
 	ServerName: mysql3044
 	IP address: 10.10.30.44
 	OS: Debian 11/12
 	RDBMS: MySQL 8.0.40
 	Server configuration: 2 CPU, 4GB RAM, 30GB

## <a name="_toc206869640">**Server standalone**</a> 
 	ServerName: mysql30226
 	IP address: 10.10.30.226
 	OS: Debian 11/12
 	RDBMS: MariaDB 10.11
 	Server configuration: 2 CPU, 4GB RAM, 30GB

# <a name="_toc206869641"></a>**Configuring the 'add-on' to collect the DML statements for each table on MySQL.**

## <a name="_toc206869642">**Initial conditions**</a>

On all replica servers, you need to enable the event\_scheduler. Use the following command to enable it:

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


## <a name="_toc206869643">**Configuring the ‘add-on’**</a>

1\. I will demonstrate the work of this ‘add-on’ on mysql3043 (main master MySQL 5.7.42) -> mysql3044 (slave from main master mysql3043 MySQL 8.0.40) and standalone mysql30226 (MariaDB 10.11).

2\. Create the necessary objects.

You need to download and execute the script from [https://github.com/PahanDba/mysql_dba/blob/main/Monitoring/count_dml_stmt/count_dml_stmt.sql ](https://github.com/PahanDba/mysql_dba/blob/main/Monitoring/count_dml_stmt/count_dml_stmt.sql) via MySQL on the following servers:

- mysql3043 (Main Master, MySQL 5.7.42)
- mysql3044 (slave from main master mysql3043 MySQL 8.0.40)
- mysql30226 (MariaDB 10.11)

This script performs the following steps:

1\. Creates the `assistant_dba` database if it does not already exist on the server.

2\. Drops the function `assistant_dba.regexp_replace` if it exists and recreates it, which works in MySQL 5.7 similarly to the `REGEXP_REPLACE` function available in MySQL 8.0 and later. This function was taken from [this blog post](https://www.cnblogs.com/rainbow--/p/17026987.html).

3\. Drops the procedure `assistant_dba.count_dml_stmt` if it exists and recreates it. This procedure collects data from the table `performance_schema.table_io_waits_summary_by_table`.

4\. Drops the event `assistant_dba.count_dml_stmt` if it exists and recreates it. This event is scheduled to run every 30 seconds.

5\. Drops the procedure `assistant_dba.count_dml_stmt_analyze` if it exists and recreates it. This procedure helps analyze the DML statements (COUNT\_STAR, COUNT\_READ, COUNT\_WRITE, COUNT\_FETCH, COUNT\_INSERT, COUNT\_UPDATE, COUNT\_DELETE) for any table on the MySQL server during specific time intervals. This procedure considers restarting the MySQL service if it was executed during specific time intervals. This procedure doesn’t account for the manual cleaning of the table performance\_schema.table\_io\_waits\_summary\_by\_table or other ways of cleaning this table.


## <a name="_toc206869644">**The description of the logic of the procedure this ‘add-on’**</a>

This section describes the logic of the procedure `assistant_dba.count_dml_stmt`, which inserts data into a table used to store the number of DML statements for any table on the MySQL server.

1\. The procedure uses the `SET sql_log_bin = 0;` statement to ensure that this operation does not insert unnecessary information into the binary log, which would otherwise be replicated to the replicas.

2\. The procedure checks the MySQL/MariaDB version. If the version is lower than 5.7, the procedure ends with an error.

3\.For MySQL 5.7, the procedure will execute the custom function `assistant_dba.regexp_replace`. For MySQL versions >= 8.0, it will execute the standard `REGEXP_REPLACE` function.

4\. The procedure will create a table in the `assistant_dba` database to store the data. The table name will be generated in the following way:

- The first character will be 't'.
- The second character will be a underscore ('\_').
- The third part will contain the server\_id.
- The fourth part will be a underscore ('\_').
- The fifth part will be the hostname, which can contain the following characters: [a-z], [A-Z], [0-9], or the underscore ('\_').
- The sixth part contains the postfix \_count\_dml\_stmt.

For example, if the server has server\_id = 3043 and hostname = my.sql-3043, the procedure will create a table named `assistant_dba.t_3043_mysql3043_count_dml_stmt`. This naming convention helps to identify which server the data belongs to.

5\. The procedure reads data (COUNT\_STAR, COUNT\_READ, COUNT\_WRITE, COUNT\_FETCH, COUNT\_INSERT, COUNT\_UPDATE, COUNT\_DELETE) from the table `performance_schema.table_io_waits_summary_by_table` and saves it in the table for storing data in the `assistant_dba` database.


The description of the logic of the procedure `assistant_dba.count_dml_stmt_analyze` follows:

1\. The procedure uses the `SET sql_log_bin = 0;` statement to ensure that this operation does not insert unnecessary information into the binary log, which would otherwise be replicated to the replicas.

2\. The procedure is performed as follows:

```
mysql>call assistant_dba.count_dml_stmt_analyze('table_store', 'your_schema','your_table' ,'datetime_start','datetime_finish');
```

table\_store – the table, which stores the values DML (COUNT\_STAR, COUNT\_READ, COUNT\_WRITE, COUNT\_FETCH, COUNT\_INSERT, COUNT\_UPDATE, COUNT\_DELETE) of statements from the table `performance_schema.table_io_waits_summary_by_table`.

your\_schema – the schema, where there is the table and the data about it we want to analyze.

your\_table – the table, which we want to analyze.

datetime\_start – the starting time of the interval in the format 'YYYY-MM-DD HH:MM:SS’, which we need to analyze 

datetime\_finish  – the finishing time of the interval in the format 'YYYY-MM-DD HH:MM:SS’, which we need to analyze.

The procedure has a few algorithms for processing different exceptions:



1\. If any of the dates indicated in the parameters doesn’t exist, then the procedure tries to find the nearest date and time to the specified date and time, on both left and right sides. For example, you set the starting date and time = '2025-06-29 13:47:10'. The procedure is trying to find this date and time. If this date and time can’t be found, the procedure tries to find the nearest date and time to the specified date and time on both left and right sides. For example, the date and time on the left side is = '2025-06-29 13:47:00', and there is a date and time on the right side = '2025-06-29 13:47:30'. The delta between the setting date and time and the date and time on the left side is 10 seconds. The delta between the setting date and time and the date and time on the right side is 20 seconds. The procedure will choose the date and time on the left side = '2025-06-29 13:47:00' because the date and time on the left side is closer to the set date '2025-06-29 13:47:00' because 10 seconds is less than 20 seconds.

2\. Possible variant. When the starting time equals the finishing time, then the procedure shows the error that you need to change the date and time of the interval.

3\. The procedure accounts for restarting the MySQL service if it was performed in this interval. The procedure doesn’t account for the manual cleaning of the table `performance_schema.table_io_waits_summary_by_table` or other ways of cleaning this table.

4\. The procedure take into account the future time, which isn’t in the table, and uses as possible nearest available values for the table, which you analyze from the table to store information about DML of the operations. 


## <a name="_toc206869645">**Examples of executing the procedure**</a>

For example, you launch the procedure with the parameters:

table\_store = `t_3043_mysql3043_count_dml_stmt`

your\_schema = `assistant_dba`

your\_table = `t_3043_mysql3043`

datetime\_start = `2025-06-29 13:47:10`

datetime\_finish = `2025-06-29 21:50:10`.

Below, I’ll demonstrate the different ways to execute the procedure `assistant_dba.count_dml_stmt_analyze`.

1\. The server didn’t work this day.

```
mysql> call assistant_dba.count_dml_stmt_analyze('t_3043_mysql3043_count_dml_stmt', 'assistant_dba','t_3043_mysql3043' ,'2025-06-29 13:47:10','2025-06-29 21:50:10');
```

I get the following result:

You need to change your boundary values '2025-06-29 13:47:10' and '2025-06-29 21:50:10' because after the process of searching for the boundary values, the procedure found that the values of the date and time of the start and the date and time of the finish were equal. This may indicate that your database server was not running during the specified interval, or the store table doesn't have values in this interval. The procedure found the following boundary values instead of '2025-06-29 13:47:10': '2025-06-27 17:55:00', and instead of '2025-06-29 21:50:10': '2025-06-27 17:55:00'.

2\.The finishing date and time of the interval is less than the starting date and time of the interval.

```
mysql> call assistant_dba.count_dml_stmt_analyze('t_3043_mysql3043_count_dml_stmt', 'assistant_dba','t_3043_mysql3043_count_dml_stmt' ,'2025-06-29 23:47:10','2025-06-29 21:50:10');
```

I get the following result:

The finishing date and time of the interval can't be less than the starting date and time of the interval.



3\. The starting date and time of the interval and the finishing date and time of the interval are at different dates at the launch of the MySQL server, so it was possible the MySQL server was restarted or shut down at some time.

```
mysql> call assistant_dba.count_dml_stmt_analyze('t_3043_mysql3043_count_dml_stmt', 'assistant_dba','t_3043_mysql3043_count_dml_stmt' ,'2025-05-12 10:47:10','2025-07-05 21:50:10');
```

Text1 = ‘These are the values of the DML operations on the starting date and time of the interval and the finishing date and time of the interval.’

Text2 = ‘This is the delta of the DML operation values on the starting date and time of the interval and the finishing date and time of the interval in the number of seconds.’

Text3 = ‘This is the average value of the DML operations per second between the starting date and time of the interval and the finishing date and time of the interval.’


**Table 1**


|description|count\_star|count\_read|count\_write|count\_fetch|count\_insert|count\_update|count\_delete|delta\_sec|date\_collect|date\_start|
| :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|Text1|11\.0000|0\.0000|11\.0000|0\.0000|11\.0000|0\.0000|0\.0000| |2025-05-26 18:30:23|2025-05-26 11:27:24|
|Text1|75\.0000|38\.0000|37\.0000|38\.0000|37\.0000|0\.0000|0\.0000| |2025-05-26 18:52:46|2025-05-26 11:27:24|
|Text2|64\.0000|38\.0000|26\.0000|38\.0000|26\.0000|0\.0000|0\.0000|1343|9998-12-12 23:59:59|2025-05-26 11:27:24|
|Text3|0\.0477|0\.0283|0\.0194|0\.0283|0\.0194|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-05-26 11:27:24|
|Text1|1\.0000|0\.0000|1\.0000|0\.0000|1\.0000|0\.0000|0\.0000| |2025-05-29 13:30:33|2025-05-29 12:40:33|
|Text1|95\.0000|88\.0000|7\.0000|88\.0000|7\.0000|0\.0000|0\.0000| |2025-05-29 13:46:00|2025-05-29 12:40:33|
|Text2|94\.0000|88\.0000|6\.0000|88\.0000|6\.0000|0\.0000|0\.0000|927|9998-12-12 23:59:59|2025-05-29 12:40:33|
|Text3|0\.1014|0\.0949|0\.0065|0\.0949|0\.0065|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-05-29 12:40:33|
|Text1|51\.0000|50\.0000|1\.0000|50\.0000|1\.0000|0\.0000|0\.0000| |2025-05-29 13:47:00|2025-05-29 13:46:32|
|Text1|10811\.0000|6940\.0000|3871\.0000|6940\.0000|3871\.0000|0\.0000|0\.0000| |2025-05-29 19:40:00|2025-05-29 13:46:32|
|Text2|10760\.0000|6890\.0000|3870\.0000|6890\.0000|3870\.0000|0\.0000|0\.0000|21180|9998-12-12 23:59:59|2025-05-29 13:46:32|
|Text3|0\.5080|0\.3253|0\.1827|0\.3253|0\.1827|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-05-29 13:46:32|
|Text1|1\.0000|0\.0000|1\.0000|0\.0000|1\.0000|0\.0000|0\.0000| |2025-05-30 10:15:30|2025-05-30 10:15:06|
|Text1|2127\.0000|0\.0000|2127\.0000|0\.0000|2127\.0000|0\.0000|0\.0000| |2025-05-30 19:07:00|2025-05-30 10:15:06|
|Text2|2126\.0000|0\.0000|2126\.0000|0\.0000|2126\.0000|0\.0000|0\.0000|31890|9998-12-12 23:59:59|2025-05-30 10:15:06|
|Text3|0\.0667|0\.0000|0\.0667|0\.0000|0\.0667|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-05-30 10:15:06|
|Text1|1\.0000|0\.0000|1\.0000|0\.0000|1\.0000|0\.0000|0\.0000| |2025-06-19 10:04:01|2025-06-19 10:03:37|
|Text1|2537\.0000|0\.0000|2537\.0000|0\.0000|2537\.0000|0\.0000|0\.0000| |2025-06-19 20:38:00|2025-06-19 10:03:37|
|Text2|2536\.0000|0\.0000|2536\.0000|0\.0000|2536\.0000|0\.0000|0\.0000|38039|9998-12-12 23:59:59|2025-06-19 10:03:37|
|Text3|0\.0667|0\.0000|0\.0667|0\.0000|0\.0667|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-06-19 10:03:37|
|Text1|0\.0000|0\.0000|0\.0000|0\.0000|0\.0000|0\.0000|0\.0000| |2025-06-20 18:18:01|2025-06-20 18:17:41|
|Text1|470\.0000|0\.0000|470\.0000|0\.0000|470\.0000|0\.0000|0\.0000| |2025-06-20 20:15:30|2025-06-20 18:17:41|
|Text2|470\.0000|0\.0000|470\.0000|0\.0000|470\.0000|0\.0000|0\.0000|7049|9998-12-12 23:59:59|2025-06-20 18:17:41|
|Text3|0\.0667|0\.0000|0\.0667|0\.0000|0\.0667|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-06-20 18:17:41|
|Text1|1\.0000|0\.0000|1\.0000|0\.0000|1\.0000|0\.0000|0\.0000| |2025-06-25 12:40:00|2025-06-25 12:39:07|
|Text1|831\.0000|0\.0000|831\.0000|0\.0000|831\.0000|0\.0000|0\.0000| |2025-06-25 13:22:30|2025-06-25 12:39:07|
|Text2|830\.0000|0\.0000|830\.0000|0\.0000|830\.0000|0\.0000|0\.0000|2550|9998-12-12 23:59:59|2025-06-25 12:39:07|
|Text3|0\.3255|0\.0000|0\.3255|0\.0000|0\.3255|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-06-25 12:39:07|
|Text1|1\.0000|0\.0000|1\.0000|0\.0000|1\.0000|0\.0000|0\.0000| |2025-06-25 13:23:00|2025-06-25 13:22:58|
|Text1|26393\.0000|15668\.0000|10725\.0000|15668\.0000|10725\.0000|0\.0000|0\.0000| |2025-06-25 19:49:00|2025-06-25 13:22:58|
|Text2|26392\.0000|15668\.0000|10724\.0000|15668\.0000|10724\.0000|0\.0000|0\.0000|23160|9998-12-12 23:59:59|2025-06-25 13:22:58|
|Text3|1\.1396|0\.6765|0\.4630|0\.6765|0\.4630|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-06-25 13:22:58|
|Text1|1\.0000|0\.0000|1\.0000|0\.0000|1\.0000|0\.0000|0\.0000| |2025-06-27 09:36:03|2025-06-27 09:35:27|
|Text1|7739\.0000|0\.0000|7739\.0000|0\.0000|7739\.0000|0\.0000|0\.0000| |2025-06-27 17:55:00|2025-06-27 09:35:27|
|Text2|7738\.0000|0\.0000|7738\.0000|0\.0000|7738\.0000|0\.0000|0\.0000|29937|9998-12-12 23:59:59|2025-06-27 09:35:27|
|Text3|0\.2585|0\.0000|0\.2585|0\.0000|0\.2585|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-06-27 09:35:27|
|Text1|1\.0000|0\.0000|1\.0000|0\.0000|1\.0000|0\.0000|0\.0000| |2025-07-01 07:48:30|2025-07-01 07:47:46|
|Text1|2945\.0000|0\.0000|2945\.0000|0\.0000|2945\.0000|0\.0000|0\.0000| |2025-07-01 20:04:30|2025-07-01 07:47:46|
|Text2|2944\.0000|0\.0000|2944\.0000|0\.0000|2944\.0000|0\.0000|0\.0000|44160|9998-12-12 23:59:59|2025-07-01 07:47:46|
|Text3|0\.0667|0\.0000|0\.0667|0\.0000|0\.0667|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-07-01 07:47:46|
|Text1|1\.0000|0\.0000|1\.0000|0\.0000|1\.0000|0\.0000|0\.0000| |2025-07-02 17:25:01|2025-07-02 17:24:24|
|Text1|507\.0000|0\.0000|507\.0000|0\.0000|507\.0000|0\.0000|0\.0000| |2025-07-02 19:31:30|2025-07-02 17:24:24|
|Text2|506\.0000|0\.0000|506\.0000|0\.0000|506\.0000|0\.0000|0\.0000|7589|9998-12-12 23:59:59|2025-07-02 17:24:24|
|Text3|0\.0667|0\.0000|0\.0667|0\.0000|0\.0667|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-07-02 17:24:24|
|Text1|0\.0000|0\.0000|0\.0000|0\.0000|0\.0000|0\.0000|0\.0000| |2025-07-03 10:38:32|2025-07-03 10:38:13|
|Text1|50674\.0000|47165\.0000|3509\.0000|47165\.0000|3509\.0000|0\.0000|0\.0000| |2025-07-03 19:16:30|2025-07-03 10:38:13|
|Text2|50674\.0000|47165\.0000|3509\.0000|47165\.0000|3509\.0000|0\.0000|0\.0000|31078|9998-12-12 23:59:59|2025-07-03 10:38:13|
|Text3|1\.6305|1\.5176|0\.1129|1\.5176|0\.1129|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-07-03 10:38:13|
|Text1|1\.0000|0\.0000|1\.0000|0\.0000|1\.0000|0\.0000|0\.0000| |2025-07-04 10:05:32|2025-07-04 10:04:47|
|Text1|1063140\.0000|1049354\.0000|13786\.0000|1049354\.0000|13786\.0000|0\.0000|0\.0000| |2025-07-05 14:47:00|2025-07-04 10:04:47|
|Text2|1063139\.0000|1049354\.0000|13785\.0000|1049354\.0000|13785\.0000|0\.0000|0\.0000|103288|9998-12-12 23:59:59|2025-07-04 10:04:47|
|Text3|10\.2930|10\.1595|0\.1335|10\.1595|0\.1335|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-07-04 10:04:47|


The rows with the value «Text1» in the description column show the values of the DML operations (COUNT\_STAR, COUNT\_READ, COUNT\_WRITE, COUNT\_FETCH, COUNT\_INSERT, COUNT\_UPDATE, COUNT\_DELETE) on the starting date and time of the interval or the finishing date and time of the interval for each value of the date of the start of the MySQL server.

The rows with the value «Text2» in the description column show the difference in values of the DML operations (COUNT\_STAR, COUNT\_READ, COUNT\_WRITE, COUNT\_FETCH, COUNT\_INSERT, COUNT\_UPDATE, COUNT\_DELETE) and the number of seconds between the starting date and time of the interval and the finishing date and time of the interval for the particular date of the start of the MySQL server. The value in the column “date\_collect” equal to ‘9998-12-12 23:59:59’ is necessary only for proper sorting of values.

The rows with the values «Text3» in the description column show the average difference in values of the DML operations (COUNT\_STAR, COUNT\_READ, COUNT\_WRITE, COUNT\_FETCH, COUNT\_INSERT, COUNT\_UPDATE, COUNT\_DELETE) per second which was between the starting date and time of the interval and the finishing date and time of the interval for the particular date of the start of the MySQL server. The value in the column “date\_collect” equal to ‘9999-12-12 23:59:59’ is necessary only for proper sorting of values.

4\. The starting date and time of the interval and the finishing date and time of the interval fall on the same MySQL server start date.

```
mysql> call assistant_dba.count_dml_stmt_analyze('t_3043_mysql3043_count_dml_stmt', 'assistant_dba','t_3043_mysql3043_count_dml_stmt' ,'2025-05-26 18:30:23','2025-05-26 18:52:46');
```

Text1 = ‘These are the values of the DML operations on the starting date and time of the interval and the finishing date and time of the interval.’

Text2 = ‘This is the delta of the values of the DML operations on the starting date and time of the interval and the finishing date and time of the interval, with the number of seconds in the interval.’

Text3 = ‘This is the average value of the DML operations per second between the starting date and time of the interval and the finishing date and time of the interval.’


**Table 2**



|description|count\_star|count\_read|count\_write|count\_fetch|count\_insert|count\_update|count\_delete|delta\_sec|date\_collect|date\_start|
| :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|Text1|11\.0000|0\.0000|11\.0000|0\.0000|11\.0000|0\.0000|0\.0000| |2025-05-26 18:30:23|2025-05-26 11:27:24|
|Text1|75\.0000|38\.0000|37\.0000|38\.0000|37\.0000|0\.0000|0\.0000| |2025-05-26 18:52:46|2025-05-26 11:27:24|
|Text2|64\.0000|38\.0000|26\.0000|38\.0000|26\.0000|0\.0000|0\.0000|1343|9998-12-12 23:59:59|2025-05-26 11:27:24|
|Text3|0\.0477|0\.0283|0\.0194|0\.0283|0\.0194|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-05-26 11:27:24|


The rows with the value «Text1» in the description column show the values of the DML operations (COUNT\_STAR, COUNT\_READ, COUNT\_WRITE, COUNT\_FETCH, COUNT\_INSERT, COUNT\_UPDATE, COUNT\_DELETE) on the starting date and time of the interval or the finishing date and time of the interval for each value of the date of the start of the MySQL server.

The rows with the value «Text2» in the description column show the difference in values of the DML operations (COUNT\_STAR, COUNT\_READ, COUNT\_WRITE, COUNT\_FETCH, COUNT\_INSERT, COUNT\_UPDATE, COUNT\_DELETE) and the number of seconds between the starting date and time of the interval and the finishing date and time of the interval for the particular date of the start of the MySQL server. The value in the column “date\_collect” equal to ‘9998-12-12 23:59:59’ is necessary only for proper sorting of values.

The rows with the values «Text3» in the description column show the average difference in values of the DML operations (COUNT\_STAR, COUNT\_READ, COUNT\_WRITE, COUNT\_FETCH, COUNT\_INSERT, COUNT\_UPDATE, COUNT\_DELETE) per second which was between the starting date and time of the interval and the finishing date and time of the interval for the particular date of the start of the MySQL server. The value in the column “date\_collect” equal to ‘9999-12-12 23:59:59’ is necessary only for proper sorting of values.

5\. The starting date and time of the interval and the finishing date and time of the interval are at one date at the launch of the MySQL server, and the finishing date and time have not yet arrived, i.e., are in the future. (For example, now 2025-07-04 22:53).

```
mysql> call assistant_dba.count_dml_stmt_analyze('t_3043_mysql3043_count_dml_stmt', 'assistant_dba','t_3043_mysql3043_count_dml_stmt' ,'2025-07-04 18:30:23','2025-07-05 18:52:46');
```

In this case, as the finishing date and time of the interval, the procedure will choose the maximum value of the finishing date and time for this object, which is in the store table.


**Table 3**
|description|count\_star|count\_read|count\_write|count\_fetch|count\_insert|count\_update|count\_delete|delta\_sec|date\_collect|date\_start|
| :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|Text1|884048\.0000|882027\.0000|2021\.0000|882027\.0000|2021\.0000|0\.0000|0\.0000| |2025-07-04 18:30:30|2025-07-04 10:04:47|
|Text1|1053600\.0000|1049354\.0000|4246\.0000|1049354\.0000|4246\.0000|0\.0000|0\.0000| |2025-07-04 22:53:00|2025-07-04 10:04:47|
|Text2|169552\.0000|167327\.0000|2225\.0000|167327\.0000|2225\.0000|0\.0000|0\.0000|15750|9998-12-12 23:59:59|2025-07-04 10:04:47|
|Text3|10\.7652|10\.6239|0\.1413|10\.6239|0\.1413|0\.0000|0\.0000| |9999-12-12 23:59:59|2025-07-04 10:04:47|

The rows with the value «Text1» in the description column show the values of the DML operations (COUNT\_STAR, COUNT\_READ, COUNT\_WRITE, COUNT\_FETCH, COUNT\_INSERT, COUNT\_UPDATE, COUNT\_DELETE) on the starting date and time of the interval or the finishing date and time of the interval for each value of the date of the start of the MySQL server.

The rows with the value «Text2» in the description column show the difference in values of the DML operations (COUNT\_STAR, COUNT\_READ, COUNT\_WRITE, COUNT\_FETCH, COUNT\_INSERT, COUNT\_UPDATE, COUNT\_DELETE) and the number of seconds between the starting date and time of the interval and the finishing date and time of the interval for the particular date of the start of the MySQL server. The value in the column “date\_collect” equal to ‘9998-12-12 23:59:59’ is necessary only for proper sorting of values.

The rows with the values «Text3» in the description column show the average difference in values of the DML operations (COUNT\_STAR, COUNT\_READ, COUNT\_WRITE, COUNT\_FETCH, COUNT\_INSERT, COUNT\_UPDATE, COUNT\_DELETE) per second which was between the starting date and time of the interval and the finishing date and time of the interval for the particular date of the start of the MySQL server. The value in the column “date\_collect” equal to ‘9999-12-12 23:59:59’ is necessary only for proper sorting of values.

## <a name="_toc206869646">**Configuring ‘add-on’ on the replica server**</a>

Replica server mysql3044 (slave from main master mysql3043)

You need to connect via MySQL to the server mysql3044 and execute a command to activate the event on the replica server.

```sql
mysql>alter EVENT assistant_dba.`count_dml_stmt` enable;
```

<a name="_toc206869647">**Checking how the script works**</a>

-------------------------------------------------------------
You need to verify that the event is running and inserting data into the table.
Connect via MySQL to the following servers:

- mysql3043 (master)
- mysql3044 (slave of mysql3043)
- mysql30226 (standalone MariaDB)

Then, execute the following query:

**On the mysql3043 server (master):**



```sql
mysql> SELECT * FROM assistant_dba.t_3043_mysql3043_count_dml_stmt
where date_collect=(select max(date_collect) from assistant_dba.t_3043_mysql3043_count_dml_stmt )
order by date_collect desc;
``` 

**Table 4**
|id|object\_type|object\_schema|object\_name|count\_star|count\_read|count\_write|count\_fetch|count\_insert|count\_update|count\_delete|date\_collect|date\_start|
| :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|110827|TABLE|percona\_information|heartbeat|990042|330014|660028|330014|330014|330014|0|2025-07-13 17:33:30|2025-07-13 10:20:27|
|110828|TABLE|assistant\_dba|t\_3043\_mysql3043\_count\_dml\_stmt|122535|122314|221|122314|221|0|0|2025-07-13 17:33:30|2025-07-13 10:20:27|


**On the server mysql3044 (replica)**

```sql
mysql> SELECT * FROM assistant_dba.t_3044_mysql3044_count_dml_stmt 
where date_collect=(select max(date_collect) from assistant_dba.t_3044_mysql3044_count_dml_stmt )
order by date_collect desc limit 2;
```

**Table 5**

|id|object\_type|object\_schema|object\_name|count\_star|count\_read|count\_write|count\_fetch|count\_insert|count\_update|count\_delete|date\_collect|date\_start|
| :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|62752|TABLE|mysql|dd\_properties|0|0|0|0|0|0|0|2025-07-13 17:39:00|2025-07-13 10:21:05|
|62753|TABLE|mysql|schemata|0|0|0|0|0|0|0|2025-07-13 17:39:00|2025-07-13 10:21:05|


**On the server mysql30226 (standalone)**

```sql
mysql> SELECT * FROM assistant_dba.t_1_mysql30226_count_dml_stmt 
where date_collect=(select max(date_collect) from assistant_dba.t_1_mysql30226_count_dml_stmt )
order by date_collect desc limit 2;
```


**Table 6**

|id|object\_type|object\_schema|object\_name|count\_star|count\_read|count\_write|count\_fetch|count\_insert|count\_update|count\_delete|date\_collect|date\_start|
| :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- | :- |
|17285|TABLE|sys|sys\_config|0|0|0|0|0|0|0|2025-07-13 17:40:30|2025-07-13 10:20:06|
|17286|TABLE|tempor\_t2|users|0|0|0|0|0|0|0|2025-07-13 17:40:30|2025-07-13 10:20:06|


# <a name="_toc206869649">**Summary**</a>
This "add-on" helps to analyze the workload on any table on the MySQL server and helps MySQL DBAs understand which table was used with what intensity.\
You can download this script (`count_dml_stmt.sql`) and other scripts from <https://github.com/PahanDba/mysql_dba/>.


