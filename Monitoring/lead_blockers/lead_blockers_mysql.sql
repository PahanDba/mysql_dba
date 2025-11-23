
drop procedure if exists mysql.lead_blockers;
delimiter $$;
create procedure mysql.lead_blockers ()
/*
shows locks on the server, sorts by the number of blocked processes
Written by Pavel A. Polikov https://github.com/PahanDba/mysql_dba
Developed and tested on the RDBMS MySQL 8.0.
call mysql.lead_blockers();
*/
begin
SET sql_log_bin = 0;
set @connection_id_var :=(select connection_id());
set @tblname_dba_all_waiting_locks :=concat('dba_all_waiting_locks_',@connection_id_var);
set @tblname_dba_only_block :=concat('dba_only_block_',@connection_id_var);

set @sql_drop_tbl :=concat(' DROP TABLE  if exists  \`mysql\`.',@tblname_dba_all_waiting_locks,' ; '); 
prepare dynamic_drop_tbl from @sql_drop_tbl;
execute dynamic_drop_tbl;
deallocate prepare dynamic_drop_tbl;

set @sql_create_tbl :=concat(' CREATE TABLE if not exists \`mysql\`.',@tblname_dba_all_waiting_locks,' 
							(\`waiting_thread\` bigint(21) unsigned  NULL, \`waiting_query\` varchar(1024) null,
                            \`pl_w_user\` varchar(128) NULL, \`pl_w_host\` varchar(64) NULL, \`blocking_thread\` bigint(21) unsigned NULL,
                            \`blocking_query\` varchar(1024), \`pl_w_TIME\` int(7) NULL, \`pl_w_STATE\` varchar(64) null,
                            \`pl_w_INFO\` longtext null, \`pl_w_command\` varchar(16) NULL) ENGINE=archive; '); 
prepare dynamic_create_tbl from @sql_create_tbl;
execute dynamic_create_tbl;
deallocate prepare dynamic_create_tbl;

set @sql_insert :=concat('insert into  \`mysql\`.',@tblname_dba_all_waiting_locks,' 
							(\`waiting_thread\`, \`waiting_query\`, \`pl_w_user\`, \`pl_w_host\`,
							\`blocking_thread\`, \`blocking_query\`,
							\`pl_w_TIME\`, \`pl_w_STATE\`, \`pl_w_INFO\`, \`pl_w_command\`)
							SELECT r.trx_mysql_thread_id waiting_thread,#The MySQL thread ID
							r.trx_query waiting_query, #The SQL statement that is being executed by the transaction
							pl_w.user pl_w_user, pl_w.host pl_w_host,
							b.trx_mysql_thread_id blocking_thread, #The MySQL thread ID
							b.trx_query blocking_query, #The SQL statement that is being executed by the transaction. 
							pl_w.TIME pl_w_TIME, pl_w.STATE pl_w_STATE, pl_w.INFO pl_w_INFO, pl_w.command pl_w_command
							FROM performance_schema.data_lock_waits w #This table indicates which transactions are waiting for a given lock, or for which lock a given transaction is waiting
							INNER JOIN information_schema.innodb_trx b #The INNODB_TRX table provides information about every transaction currently executing inside InnoDB, including whether the transaction is waiting for a lock, when the transaction started, and the SQL statement the transaction is executing, if any. 
							ON b.trx_id = w.BLOCKING_ENGINE_TRANSACTION_ID
							INNER JOIN information_schema.innodb_trx r #The INNODB_TRX table provides information about every transaction currently executing inside InnoDB, including whether the transaction is waiting for a lock, when the transaction started, and the SQL statement the transaction is executing, if any. 
							ON r.trx_id = w.REQUESTING_ENGINE_TRANSACTION_ID
							INNER JOIN information_schema.processlist AS pl_w 
							on pl_w.id= b.trx_mysql_thread_id;'); 
prepare dynamic_insert from @sql_insert;
execute dynamic_insert;
deallocate prepare dynamic_insert;

set @sql_drop_tbl2 :=concat(' DROP TABLE  if exists  \`mysql\`.',@tblname_dba_only_block,' ; '); 
prepare dynamic_drop_tbl2 from @sql_drop_tbl2;
execute dynamic_drop_tbl2;
deallocate prepare dynamic_drop_tbl2;

set @sql_create_tbl2 :=concat(' CREATE TABLE if not exists \`mysql\`.',@tblname_dba_only_block,' 
							(\`waiting_thread\` bigint(21) unsigned NULL, \`waiting_query\` varchar(1024) null,
							\`pl_w_user\` varchar(128) NULL, \`pl_w_host\` varchar(64) NULL,
							\`blocking_thread\` bigint(21) unsigned NULL,  \`blocking_query\` varchar(1024) null,
							\`pl_w_TIME\` int(7) NULL, \`pl_w_STATE\` varchar(64) null,
							\`pl_w_INFO\` longtext null, \`pl_w_command\` varchar(16) NULL) ENGINE=archive; '); 
prepare dynamic_create_tbl2 from @sql_create_tbl2;
execute dynamic_create_tbl2;
deallocate prepare dynamic_create_tbl2;

set @sql_insert2 :=concat('insert into  \`mysql\`.',@tblname_dba_only_block,' 
							(\`waiting_thread\`, \`waiting_query\`, \`pl_w_user\`, \`pl_w_host\`,
							\`blocking_thread\`, `blocking_query\`, \`pl_w_TIME\`, \`pl_w_STATE\`, \`pl_w_INFO\`, 
                            \`pl_w_command\`)
							SELECT ID, COMMAND, USER, HOST, null, null, null, null, null, null
							FROM information_schema.PROCESSLIST pl
							where 
							pl.id in (select blocking_thread from mysql.',@tblname_dba_all_waiting_locks,'  
                            where blocking_thread=pl.id)
							and
							pl.id not in (select waiting_thread from mysql.',@tblname_dba_all_waiting_locks,'  
                            where waiting_thread=pl.id);
                            '); 
                        
prepare dynamic_insert2 from @sql_insert2;
execute dynamic_insert2;
deallocate prepare dynamic_insert2;


set @sql_insert3 :=concat('	insert into  mysql.',@tblname_dba_only_block,' 
                            (\`waiting_thread\`, \`waiting_query\`, \`pl_w_user\`, \`pl_w_host\`,
							\`blocking_thread\`, \`blocking_query\`,
							\`pl_w_TIME\`, \`pl_w_STATE\`, \`pl_w_INFO\`, \`pl_w_command`)
							select \`waiting_thread\`, \`waiting_query\`, \`pl_w_user\`, \`pl_w_host\`,
							\`blocking_thread\`, \`blocking_query\`,
							\`pl_w_TIME\`, \`pl_w_STATE\`, \`pl_w_INFO\`, \`pl_w_command\`
							from mysql.',@tblname_dba_all_waiting_locks,' 
							where (blocking_thread<>0 or 
                            waiting_thread in (select blocking_thread from mysql.',@tblname_dba_all_waiting_locks,'));
                            '); 
                         
prepare dynamic_insert3 from @sql_insert3;
execute dynamic_insert3;
deallocate prepare dynamic_insert3;



set @sql_select :=concat('WITH recursive recursive_cte (waiting_thread, blocking_thread)
						AS (
						SELECT DISTINCT waiting_thread, blocking_thread
						FROM mysql.',@tblname_dba_only_block,' 
						UNION distinct
						SELECT e.waiting_thread, d.blocking_thread
						FROM mysql.',@tblname_dba_only_block,' e
						INNER JOIN recursive_cte d
						ON d.waiting_thread=e.blocking_thread
						WHERE d.blocking_thread!=0 )
						SELECT  distinct der.waiting_thread, concat(''kill '',der.waiting_thread,'';'') as kill_cmd,
						der.pl_w_user, der.pl_w_host, der.blocking_thread, der.waiting_query, der.pl_w_TIME,
						count(cte.blocking_thread) AS lead_blockers2,
						now() as date_collect
						FROM (SELECT DISTINCT  waiting_thread, pl_w_user, pl_w_host, blocking_thread, waiting_query,
						pl_w_TIME 
						FROM  mysql.',@tblname_dba_only_block,' ) der
						LEFT JOIN recursive_cte cte
						ON der.waiting_thread=cte.blocking_thread AND cte.blocking_thread!=0
						GROUP BY  
						der.waiting_thread, der.blocking_thread, der.waiting_query, der.pl_w_user
						ORDER BY lead_blockers2 DESC; '); 
prepare dynamic_select from @sql_select;
execute dynamic_select;
deallocate prepare dynamic_select;


set @sql_drop_tbl3 :=concat(' DROP TABLE  if exists  \`mysql\`.',@tblname_dba_all_waiting_locks,' ; '); 
prepare dynamic_drop_tbl3 from @sql_drop_tbl3;
execute dynamic_drop_tbl3;
deallocate prepare dynamic_drop_tbl3;

set @sql_drop_tbl4 :=concat(' DROP TABLE  if exists  \`mysql\`.',@tblname_dba_only_block,' ; '); 
prepare dynamic_drop_tbl4 from @sql_drop_tbl4;
execute dynamic_drop_tbl4;
deallocate prepare dynamic_drop_tbl4;

end $$;
delimiter //
