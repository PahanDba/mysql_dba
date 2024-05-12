drop procedure if exists mysql.block_leader;
delimiter $$;
create procedure mysql.block_leader ()
/*
shows locks on the server, sorts by the number of blocked processes
Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
Developed and tested on the RDBMS MariDB 10.11.
call mysql.block_leader();
*/
begin
DROP TEMPORARY TABLE  if exists mysql.dba_all_waiting_locks;  
CREATE TEMPORARY TABLE mysql.dba_all_waiting_locks (
  `waiting_thread` bigint(21) unsigned  NULL,
  `waiting_query` varchar(1024) null,
  `pl_w_user` varchar(128) NULL,
  `pl_w_host` varchar(64) NULL,
  `blocking_thread` bigint(21) unsigned NULL,
  `blocking_query` varchar(1024),
  `pl_w_TIME` int(7) NULL,
  `pl_w_STATE` varchar(64) null,
  `pl_w_INFO` longtext null,
  `pl_w_command` varchar(16) NULL
  ) ENGINE=Aria;
insert into  mysql.dba_all_waiting_locks (`waiting_thread`, `waiting_query`, `pl_w_user`, `pl_w_host`,
  `blocking_thread`, `blocking_query`,
  `pl_w_TIME`, `pl_w_STATE`, `pl_w_INFO`, `pl_w_command`)
SELECT 
  r.trx_mysql_thread_id waiting_thread,#The MySQL thread ID
  r.trx_query waiting_query, #The SQL statement that is being executed by the transaction
  pl_w.user pl_w_user,
  pl_w.host pl_w_host,
  b.trx_mysql_thread_id blocking_thread, #The MySQL thread ID
  b.trx_query blocking_query, #The SQL statement that is being executed by the transaction. 
  pl_w.TIME pl_w_TIME, pl_w.STATE pl_w_STATE, pl_w.INFO pl_w_INFO, pl_w.command pl_w_command
FROM information_schema.innodb_lock_waits w #This table indicates which transactions are waiting for a given lock, or for which lock a given transaction is waiting
INNER JOIN information_schema.innodb_trx b #The INNODB_TRX table provides information about every transaction currently executing inside InnoDB, including whether the transaction is waiting for a lock, when the transaction started, and the SQL statement the transaction is executing, if any. 
  ON b.trx_id = w.blocking_trx_id
INNER JOIN information_schema.innodb_trx r #The INNODB_TRX table provides information about every transaction currently executing inside InnoDB, including whether the transaction is waiting for a lock, when the transaction started, and the SQL statement the transaction is executing, if any. 
  ON r.trx_id = w.requesting_trx_id
INNER JOIN information_schema.processlist AS pl_w 
on pl_w.id= b.trx_mysql_thread_id;
DROP TEMPORARY TABLE  if exists mysql.dba_only_block;  
CREATE TEMPORARY TABLE mysql.dba_only_block (
  `waiting_thread` bigint(21) unsigned NULL,
  `waiting_query` varchar(1024) null,
  `pl_w_user` varchar(128) NULL,
  `pl_w_host` varchar(64) NULL,
  `blocking_thread` bigint(21) unsigned NULL,
  `blocking_query` varchar(1024) null,
  `pl_w_TIME` int(7) NULL,
  `pl_w_STATE` varchar(64) null,
  `pl_w_INFO` longtext null,
  `pl_w_command` varchar(16) NULL
  ) ENGINE=Aria;
insert into  mysql.dba_only_block (
  `waiting_thread`, `waiting_query`, `pl_w_user`, `pl_w_host`,
  `blocking_thread`, `blocking_query`,
  `pl_w_TIME`, `pl_w_STATE`, `pl_w_INFO`, `pl_w_command`)
SELECT ID, COMMAND, USER, HOST, 
       null, null,
       null, null, null,null
FROM information_schema.PROCESSLIST pl
where 
pl.id in (select blocking_thread from mysql.dba_all_waiting_locks where blocking_thread=pl.id)
and
pl.id not in (select waiting_thread from mysql.dba_all_waiting_locks where waiting_thread=pl.id);
insert into  mysql.dba_only_block (
  `waiting_thread`, `waiting_query`, `pl_w_user`, `pl_w_host`,
    `blocking_thread`, `blocking_query`,
    `pl_w_TIME`, `pl_w_STATE`, `pl_w_INFO`, `pl_w_command`)
select `waiting_thread`, `waiting_query`, `pl_w_user`, `pl_w_host`,
  `blocking_thread`, `blocking_query`,
  `pl_w_TIME`, `pl_w_STATE`, `pl_w_INFO`, `pl_w_command`
from mysql.dba_all_waiting_locks 
where (blocking_thread<>0 or waiting_thread in (select blocking_thread from mysql.dba_all_waiting_locks));
WITH recursive recursive_cte (waiting_thread, blocking_thread)
AS 
(
SELECT DISTINCT waiting_thread, blocking_thread
FROM mysql.dba_only_block
UNION distinct
SELECT e.waiting_thread, d.blocking_thread
FROM mysql.dba_only_block e
INNER JOIN recursive_cte d
ON d.waiting_thread=e.blocking_thread
WHERE d.blocking_thread!=0
)
SELECT  distinct der.waiting_thread, concat('kill ',der.waiting_thread,';') as kill_cmd,
der.pl_w_user,
der.pl_w_host,
der.blocking_thread,
der.waiting_query,
der.pl_w_TIME,
count(cte.blocking_thread) AS leader_block2,
now() as date_collect
FROM (SELECT DISTINCT  waiting_thread,
pl_w_user,
pl_w_host,
blocking_thread,
waiting_query,
pl_w_TIME 
FROM  mysql.dba_only_block) der
LEFT JOIN recursive_cte cte
ON der.waiting_thread=cte.blocking_thread AND cte.blocking_thread!=0
GROUP BY  
der.waiting_thread, der.blocking_thread, der.waiting_query, der.pl_w_user
ORDER BY leader_block2 DESC;
DROP TEMPORARY TABLE  if exists mysql.dba_all_waiting_locks;  
DROP TEMPORARY TABLE  if exists mysql.dba_only_block;
end $$;
delimiter //
