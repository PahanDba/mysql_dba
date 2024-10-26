/*
CREATE TABLE percona_information.`heartbeat` (
  `ts` varchar(26) NOT NULL,
  `server_id` int(10) unsigned NOT NULL,
  `file` varchar(255) DEFAULT NULL,
  `position` bigint(20) unsigned DEFAULT NULL,
  `relay_master_log_file` varchar(255) DEFAULT NULL,
  `exec_master_log_pos` bigint(20) unsigned DEFAULT NULL,
  PRIMARY KEY (`server_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

*/


#Analysis of the speed commit of replication on the replica servers.
drop table if exists percona_information.check_speed_replication_on_my_server_slave;
CREATE TABLE percona_information.check_speed_replication_on_my_server_slave (
  `server_id` int(10) unsigned NOT NULL,
  `date_collect` varchar(26) NOT NULL,
  `lag_repl_sec_on_slave` varchar(26) NOT NULL,
  `replica_name` varchar(64) NOT NULL,
  `replica_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`date_collect`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;


drop procedure if exists mysql.check_speed_replication_on_my_server_slave;
DELIMITER $$
CREATE PROCEDURE mysql.check_speed_replication_on_my_server_slave()
begin
insert percona_information.check_speed_replication_on_my_server_slave (`server_id`, `date_collect`, `lag_repl_sec_on_slave`,
    `replica_name`, `replica_id`)
SELECT server_id,now() as 'date_collect',
format(time_to_sec(timediff (now(6), ts)),1) as lag_repl_sec_on_slave, @@hostname as replica_name,@@server_id as replica_id 
FROM percona_information.heartbeat;
end$$
DELIMITER ;



drop even if exists mysql.`dba_check_speed_replication_on_my_server_slave`;
DELIMITER $$
CREATE EVENT mysql.`dba_check_speed_replication_on_my_server_slave` ON SCHEDULE EVERY 30 second STARTS '2024-09-01 00:00:00' ON COMPLETION NOT PRESERVE DISABLE ON SLAVE COMMENT 'Analysis of the speed commit of replication on my_server_slave.' DO BEGIN
  call mysql.check_speed_replication_on_my_server_slave(); 
END$$
DELIMITER ;
alter EVENT mysql.`dba_check_speed_replication_on_my_server_slave` enable;



#This script will need to help for the measure speed of replication.
#Description the fields the result.
# server_id - @@server_id main master server.
# date_collect - datetime collect event. 
# lag_repl_sec_on_slave - for how many seconds lag relication on the current replica. 
# replica_name - @@hostname replica server.  
# replica_id - @@server_id replica server.
# lag_repl_sec_on_slave_prev - previous value for how many seconds lag relication on the current replica. 
# date_collect_prev -previous value datetime collect event. 
# lag_repl_delta - delta between previous and current seconds of replication lag on the current replica.
# date_collect_delta - delta time in the seconds between previous and current datetime.
# lag_repl_speed_sec_real_sec_status - Showing how many seconds of the replication were committed in the one real second on the replica server.

select server_id, date_collect, lag_repl_sec_on_slave, replica_name, replica_id, lag_repl_sec_on_slave_prev, date_collect_prev,
format (replace (lag_repl_sec_on_slave_prev, ',','') - replace (lag_repl_sec_on_slave, ',',''),2) as  lag_repl_delta,
format(time_to_sec(timediff (date_collect,date_collect_prev)),1) as date_collect_delta,
format(((replace (lag_repl_sec_on_slave_prev, ',','') - replace (lag_repl_sec_on_slave, ',',''))/(format(time_to_sec(timediff (date_collect,date_collect_prev)),1))),2) as lag_repl_speed_sec_real_sec_status
from
(select server_id, date_collect, lag_repl_sec_on_slave, replica_name,replica_id, lag(lag_repl_sec_on_slave) over (order by date_collect) lag_repl_sec_on_slave_prev, 
lag(date_collect) over (order by date_collect) date_collect_prev
from percona_information.check_speed_replication_on_my_server_slave ) as my_subquery;

