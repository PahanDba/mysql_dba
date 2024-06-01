#MariaDB from 10.11
#The top 100 processes, ordered by duration execution descending time_ms, exclude the commands 'Daemon','Binlog Dump'.
select pl.id, pl.user, pl.host, pl.db, pl.command, 
itx.trx_state, #Transaction execution state; one of RUNNING, LOCK WAIT, ROLLING BACK or COMMITTING.
itx.trx_started, #Time that the transaction started.
itx.trx_operation_state,  #Transaction's current state, or NULL.
pl.time as time_sec, pl.time_ms, 
pl.state, #Current state of the thread
pl.info, now() 
from information_schema.processlist pl
join information_schema.innodb_trx itx
on itx.trx_mysql_thread_id=pl.id
where command not in ('Daemon','Binlog Dump') and time_ms>0
order by time_ms desc 
limit 100;


#The process list of open transactions is ordered by duration of execution and descending time_ms.
select pl.id, pl.user, pl.host, pl.db, pl.command, 
itx.trx_state, #Transaction execution state; one of RUNNING, LOCK WAIT, ROLLING BACK or COMMITTING.
itx.trx_started, #Time that the transaction started.
itx.trx_operation_state,  #Transaction's current state, or NULL.
pl.time as time_sec, pl.time_ms, 
pl.state, #Current state of the thread
pl.info, now() 
from information_schema.processlist pl
join information_schema.innodb_trx itx
on itx.trx_mysql_thread_id=pl.id
where command not in ('Daemon','Binlog Dump') and pl.command='sleep' 
and (itx.trx_state='RUNNING' or itx.trx_state='LOCK WAIT') 
and (itx.trx_operation_state='' or itx.trx_operation_state is null)
and (pl.info is null or pl.info='') and time_ms>0
order by time_ms desc 
limit 100;
