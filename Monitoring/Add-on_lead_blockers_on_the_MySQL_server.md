Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba

Getting a list of the lead blockers with an indication number of the blocked processes in the MySQL server.


# **Table of contents**
[**Procedure goal: 'Find the lead blockers in the MySQL server'**](#_toc214799395)

[**System requirements**](#_toc214799396)

[**List of servers for demonstrating the 'lead blockers' operation procedure on the MySQL server.**](#_toc214799397)

[**Server standalone MySQL**](#_toc214799398)

[**Server standalone MariaDB**](#_toc214799399)

[**Creation of the 'lead blockers' procedure on the MySQL server**](#_toc214799400)

[**Description of the logic of the 'lead blockers' procedure**](#_toc214799401)

[**Examples of executing the procedure**](#_toc214799402)

[**Summary**](#_toc214799403)



# <a name="_toc214799395"></a>**Procedure goal: 'Find the lead blockers in the MySQL server'**
- It helps MySQL DBAs quickly identify the lead blockers of processes and the number of processes blocked by those leaders in MySQL.


# <a name="_toc214799396"></a>**System requirements**

- The procedure runs on MySQL 8.0, MariaDB 10.6-10.11

# <a name="_hlk160717248"></a><a name="_toc214799397"></a>**List of servers for demonstrating the 'lead blockers' operation procedure on the MySQL server.**

Below is a list of servers that shows the descriptions for each server with installed software used to check the functionality of this procedure.


## <a name="_toc214799398"></a>**Server standalone MySQL** 
     ServerName: mysql3051
     IP address: 10.10.30.51
     OS: Debian 11/12
     RDBMS: MySQL 8.0.43
     Server configuration: 2 CPU, 4GB RAM, 30GB

## <a name="_toc214799399"></a>**Server standalone MariaDB** 
     ServerName: mysql30226
     IP address: 10.10.30.226
     OS: Debian 11/12
     RDBMS: MariaDB 10.11
     Server configuration: 2 CPU, 4GB RAM, 30GB

# <a name="_toc214799400"></a>**Creation of the 'lead blockers' procedure on the MySQL server**.

1\. I will demonstrate how the 'lead blockers' procedure works on mysql3051 (MySQL 8.0.43). The procedure works in a similar way on the mysql30226 server (MariaDB 10.11).

2\. Create the necessary objects. The procedures have different code for MySQL 8.0.X and MariaDB 10.11. You need to choose the appropriate procedure code for your server. The MySQL version is called 'lead_blockers_mysql.sql', and the MariaDB version is called 'lead_blockers_mariadb.sql'.

You need to download and execute the script from [https://github.com/PahanDba/mysql_dba/blob/main/Monitoring/lead_blockers/lead_blockers_mysql.sql](https://github.com/PahanDba/mysql_dba/blob/main/Monitoring/lead_blockers/lead_blockers_mysql.sql) 
or 
     [https://github.com/PahanDba/mysql_dba/blob/main/Monitoring/lead_blockers/lead_blockers_mariadb.sql](https://github.com/PahanDba/mysql_dba/blob/main/Monitoring/lead_blockers/lead_blockers_mariadb.sql)
via MySQL on the following servers:

- mysql3051 (MySQL 8.0.43)
- mysql30226 (MariaDB 10.11)

This script will create the procedure '*lead_blockers'* in the *mysql* database.


# <a name="_toc214799401"></a>**Description of the logic of the 'lead blockers' procedure**

This section describes the logic of the mysql.lead_blockers procedure, which allows us to identify the blocking leaders of processes and the number of processes blocked by those leaders in MySQL.

1. The procedure uses the 'SET sql\_log\_bin = 0;' statement to ensure that this operation does not insert unnecessary information into the binary log, which would otherwise be replicated to the replicas.
1. Due to the way MySQL handles temporary tables, I use permanent tables with a postfix containing the result of the 'SELECT connection_id()' query to store temporary results. On MariaDB, I use temporary tables for this purpose. This approach allows different users to execute the procedure simultaneously.
## <a name="_toc214799402"></a>**Examples of executing the procedure**

This procedure is executed without the parameters.

```sql
call mysql.block_leader();
```

For the demonstration of the way the 'lead blockers' works, I prepared the tables with the data.

```sql
CREATE TABLE assistant_dba.`test_block` (
   `id` int NOT NULL AUTO_INCREMENT,
   `words1` varchar(45) DEFAULT NULL,
   `words2` varchar(45) DEFAULT NULL,
   PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4;

insert into  assistant_dba.`test_block` (words1,words2)
values ('test1_01', 'test2_01'),
('test1_02', 'test2_02'),
('test1_03', 'test2_03'),
('test1_04', 'test2_04'),
('test1_05', 'test2_05'),
('test1_06', 'test2_06'),
('test1_07', 'test2_07'),
('test1_08', 'test2_08'),
('test1_09', 'test2_09'),
('test1_10', 'test2_10'),
('test1_11', 'test2_11'),
('test1_12', 'test2_12');
```

I will create the connections and execute different scripts. Script №1 is used to demonstrate data blocking.
The script is called *script_block1*.

```sql
select now(), connection_id();
START TRANSACTION;
update assistant_dba.`test_block`
set words2='ns'
where id=9;
```

**Table 1**

|**# now()**|**connection_id()**|
| :- | :- |
|08.11.2025 16:31:22|522|

The result shows the query execution time and the process ID of this query.

Now I will create a few connections to work with the row being updated in a transaction using the *select1* script.

```sql
select now(), connection_id();
set session lock_wait_timeout=500;
select * from assistant_dba.`test_block` where id=9 for update;
```

The script will return the result for the first query immediately, while the second query will wait.

**Table 2**

|**# now()**|**connection_id()**|
| :- | :- |
|08.11.2025  16:31:29|533|


The result of the first query shows the start time of the query and its process ID.


The *select2* script

```sql
select now(), connection_id();
set session lock_wait_timeout=500;
select * from assistant_dba.`test_block` where id=9 for update;
```

The script will return the result for the first query only, while the second query will wait.

**Table 3**

|**# now()**|**connection_id()**|
| :- | :- |
|08.11.2025  16:31:31|535|

The result of the first query shows the start time of the query and its process ID.

The *select3* script

```sql
select now(), connection_id();
set session lock_wait_timeout=500;
select * from assistant_dba.`test_block` where id=9 for update;
```

The script will return the result for the first query only, while the second query will wait.

|**# now()**|**connection_id()**|
| :- | :- |
|08.11.2025  16:31:34|537|

The result of the first query shows the start time of the query and its process ID.



I will create the connections and execute different scripts. Script №2 is used to demonstrate data blocking.\
The script is called *script_block2*

```sql
select now(), connection_id();
START TRANSACTION;
update assistant_dba.`test_block`
set words2='ns'
where id=10;
```

The result shows the query execution time and the process ID of the query.

**Table 5**

|**# now()**|**connection_id()**|
| :- | :- |
|08.11.2025 16:31:18|524|



Now I will create a few connections to work with the row being updated in a transaction using the *select4* script.

```sql
select now(), connection_id();
set session lock_wait_timeout=500;
select * from assistant_dba.`test_block` where id=10 for update;
```

The script will return the result of the first query only, while the second query will wait.

**Table 6**

|**# now()**|**connection_id()**|
| :- | :- |
|08.11.2025  16:31:24|529|

The result of the first query shows the start time of the query and its process ID.


The *select5* script

```sql
select now(), connection_id();
set session lock_wait_timeout=500;
select * from assistant_dba.`test_block` where id=10 for update;
```

The script will return the result of the first query only, while the second query will wait.

**Table 7**

|**# now()**|**connection_id()**|
| :- | :- |
|08.11.2025  16:31:27|531|

The result of the first query shows the start time of the query and its process ID.



For illustrative purposes I'll demonstrate in the table how the blocking queries and selection queries look.

**Table 8**

|**script_name**|**where id=**|**# now()**|**connection_id()**|
| :- | :- | :- | :- |
|script_block1|9|08.11.2025  16:31:22|522|
|select1|9|08.11.2025  16:31:29|533|
|select2|9|08.11.2025  16:31:31|535|
|select3|9|08.11.2025  16:31:34|537|
|script_block2|10|08.11.2025  16:31:18|524|
|select4|10|08.11.2025  16:31:24|529|
|select5|10|08.11.2025  16:31:27|531|


Now, I want to find which process is blocking which, so I will execute the mysql.lead_blockers procedure.

```sql
call mysql.lead_blockers();
```

The result of executing the procedure.

2

**Table 9**

|**# waiting_thread**|**kill_cmd**|**pl_w_user**|**pl_w_host**|**blocking_thread**|**waiting_query**|**pl_w_TIME**|**lead_blockers2**|**date_collect**|
| :- | :- | :- | :- | :- | :- | :- | :- | :- |
|522|kill 522;|pavel_polikov|10.10.10.17:56083| |Sleep| |3|08.11.2025  16:31:38|
|524|kill 524;|pavel_polikov|10.10.10.17:56085| |Sleep| |2|08.11.2025  16:31:38|
|533|kill 533;|pavel_polikov|10.10.10.17:56083|522|select * from dba.dba_ppa where id=9 for update|16|2|08.11.2025  16:31:38|
|535|kill 535;|pavel_polikov|10.10.10.17:56092|533|select * from dba.dba_ppa where id=9 for update|9|1|08.11.2025  16:31:38|
|535|kill 535;|pavel_polikov|10.10.10.17:56083|522|select * from dba.dba_ppa where id=9 for update|16|1|08.11.2025  16:31:38|
|529|kill 529;|pavel_polikov|10.10.10.17:56085|524|select * from dba.dba_ppa where id=10 for update|20|1|08.11.2025  16:31:38|
|537|kill 537;|pavel_polikov|10.10.10.17:56094|535|select * from dba.dba_ppa where id=9 for update|7|0|08.11.2025  16:31:38|
|537|kill 537;|pavel_polikov|10.10.10.17:56092|533|select * from dba.dba_ppa where id=9 for update|9|0|08.11.2025  16:31:38|
|537|kill 537;|pavel_polikov|10.10.10.17:56083|522|select * from dba.dba_ppa where id=9 for update|16|0|08.11.2025  16:31:38|
|531|kill 531;|pavel_polikov|10.10.10.17:56085|524|select * from dba.dba_ppa where id=10 for update|20|0|08.11.2025  16:31:38|
|531|kill 531;|pavel_polikov|10.10.10.17:56088|529|select * from dba.dba_ppa where id=10 for update|14|0|08.11.2025  16:31:38|

Written by Pavel A. Polikov https://github.com/PahanDba/mysql\_dba


**waiting_thread** – The process ID of the running process.

**kill_cmd** – The command to kill the process.

**pl_w_user** – The user who started the process.

**pl_w_host** – The host from which the user is connected.

**blocking_thread** – The process id that is blocking the process (from the `waiting_thread` column).

**waiting_query** – The query being executed by the process (from the `waiting_thread` column).

**pl_w_TIME** – The number of seconds the process (from the `waiting_thread` column) has been waiting to complete its query.

**lead_blockers2** – The number of processes blocked by the process (from the `waiting_thread` column).

**date_collect** – The date and time when the `mysql.lead_blockers` procedure was executed.



In Table 9, I can see two processes that are not blocked.

I will examine one of those processes with ID 522 from the waiting_thread column. In the leader_block2 column, it shows that process 522 blocked three processes. In the waiting_thread column, I can see processes 533, 535, and 537. This shows that process 522 blocked processes 533, 535, and 537.

In the leader_block2 column, it shows that process 533 blocked two processes. This means that process 533 also blocked two processes. In the waiting_thread column, I can see processes 535 and 537. This shows that process 533 blocked processes 535 and 537.

In the leader_block2 column, it shows that process 535 blocked one process. This means that process 535 blocked one process. In the waiting_thread column, I can see process 537. This shows that process 535 blocked process 537.

This analysis can show which process actually blocked a particular process.


# <a name="_toc214799403"></a>**Summary**
This procedure helps identify the processes that block certain queries, even if it is not immediately apparent.

You can download this script (**lead_blockers_mariadb.sql** and **lead_blockers_mysql.sql**) and other related scripts from:

<https://github.com/PahanDba/mysql_dba/>.


