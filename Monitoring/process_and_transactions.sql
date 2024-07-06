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

#The process list of open transactions has a detailed description.
select pst.processlist_id, isilw.blocking_trx_id, pst.processlist_user, pst.processlist_host, pst.processlist_db, pst.processlist_command, pst.processlist_time, pst.processlist_state, pst.processlist_info, 
isit.trx_started, isit.trx_requested_lock_id, isil.lock_id, isit.trx_state,  isit.trx_wait_started, isit.trx_weight, isit.trx_query, isit.trx_operation_state,
isit.trx_tables_in_use, isit.trx_tables_locked, isit.trx_lock_memory_bytes, isit.trx_rows_locked, isit.trx_rows_modified, 
 CASE
           WHEN isil.lock_mode = 'S' THEN 'SHARED'
           WHEN isil.lock_mode = 'X' THEN 'EXCLUSIVE'
           WHEN isil.lock_mode = 'IS' THEN 'INTENTION_SHARED'
           WHEN isil.lock_mode = 'IX' THEN 'INTENTION_EXCLUSIVE'
           ELSE isil.lock_mode END                               AS lock_mode,
isil.lock_type, isil.lock_table, isil.lock_index, 
pst.thread_id, pst.parent_thread_id, pst.thread_os_id,
now() as 'data_collect'
from performance_schema.threads pst
join information_schema.innodb_trx isit
on pst.processlist_id=isit.trx_mysql_thread_id
join information_schema.innodb_locks isil
on isil.lock_trx_id=isit.trx_id
left join information_schema.innodb_lock_waits isilw
on isilw.requesting_trx_id=isit.trx_id
order by isil.lock_id, isit.trx_weight desc;

