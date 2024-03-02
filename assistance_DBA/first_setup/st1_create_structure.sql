###############################
#Block create database for system Assistance DBA
###############################
drop database if exists  assistant_dba;
drop database if exists  assistant_dba_temp;
create database assistant_dba; #main database for system Assistance DBA
create database assistant_dba_temp; #external database for system Assistance DBA
###############################
#Block create tables on database for system Assistance DBA
###############################
#This table store types servers. Example prod, test, developer, analytic.
CREATE TABLE `assistant_dba`.`list_server_type` (
  `server_type_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `server_type_desc` NVARCHAR(255) NOT NULL,
  PRIMARY KEY (`server_type_id`)
  )
ENGINE=InnoDB COMMENT = 'This table store types servers. Example prod, test, developer, analytic.';
ALTER TABLE `assistant_dba`.`list_server_type` ADD UNIQUE INDEX `server_type_desc_UNIQUE` (`server_type_desc` ASC) VISIBLE;
#This table stores the names of clusters.
CREATE TABLE `assistant_dba`.`list_clusters` (
  `cluster_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `cluster_name` VARCHAR(100) NOT NULL,
  `cluster_description` VARCHAR(1000) NULL,
  PRIMARY KEY (`cluster_id`),
  UNIQUE INDEX `cluster_name_UNIQUE` (`cluster_name` ASC) VISIBLE)
COMMENT = 'This table stores the names of clusters. Example standalone, galera, master-slave, superhidden';
#This table store types sql servers. Example mysql, postgresql, clickhouse.
CREATE TABLE `assistant_dba`.`list_sql_type` (
  `sql_type_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `sql_type_desc` NVARCHAR(255) NOT NULL,
  PRIMARY KEY (`sql_type_id`),
  UNIQUE INDEX `sql_type_desc_UNIQUE` (`sql_type_desc` ASC) VISIBLE)
ENGINE=InnoDB COMMENT = 'This table store types sql servers. Example mysql, postgresql, clickhouse.';
#This table stores all servers.
CREATE TABLE `assistant_dba`.`list_server` (
  `server_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `server_name` varchar(255) NOT NULL,
  `ip` varchar(255) NOT NULL,
  `connection_string` varchar(255) NOT NULL,
  `alive` tinyint(1) unsigned NOT NULL DEFAULT 1,
  `server_type_id` int(10) unsigned NOT NULL,
  `sql_type_id` int(10) unsigned NOT NULL,
  `comments` varchar(1000) NOT NULL,
  `ip_add` varchar(3000) DEFAULT NULL,
  `cluster_id` int(10) unsigned NOT NULL,
  PRIMARY KEY (`server_id`),
  UNIQUE KEY `server_name_UNIQUE` (`server_name`),
  UNIQUE KEY `ip_UNIQUE` (`ip`),
  KEY `FK_list_server_type_idx` (`server_type_id`),
  KEY `FK_list_sql_type_idx` (`sql_type_id`),
  KEY `FK_list_cluster_idx_idx` (`cluster_id`),
  CONSTRAINT `FK_list_cluster_idx` FOREIGN KEY (`cluster_id`) REFERENCES `list_clusters` (`cluster_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_list_server_type` FOREIGN KEY (`server_type_id`) REFERENCES `list_server_type` (`server_type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_list_sql_type` FOREIGN KEY (`sql_type_id`) REFERENCES `list_sql_type` (`sql_type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='This table stores all servers.';
#This table stores MySQL servers.
CREATE TABLE `assistant_dba`.`list_mysql_server` (
  `server_id` INT UNSIGNED NOT NULL,
  `server_id_in_cnf` INT NULL,
  `port` INT UNSIGNED NOT NULL DEFAULT 3306,
  `version` NVARCHAR(255) NULL,
  `collation_server` NVARCHAR(255) NULL,
  `auth_type` VARCHAR(255)  NULL,
  `exclude_rost` TINYINT(1) NOT NULL DEFAULT 0,
  `exclude_users` TINYINT(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`server_id`),
  CONSTRAINT `FK_list_mysql_server_list_server`
    FOREIGN KEY (`server_id`)
    REFERENCES `assistant_dba`.`list_server` (`server_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE=InnoDB COMMENT = 'This table stores MySQL servers.';
#This table stores the databases from all MySQL servers.
CREATE TABLE `assistant_dba`.`list_mysql_bases` (
  `base_id_spr` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `server_id` INT UNSIGNED NOT NULL,
  `base_name` NVARCHAR(64) NOT NULL,
  `characterset` NVARCHAR(32) NOT NULL,
  `collation_desc` NVARCHAR(255) NOT NULL,
  `del_object` TINYINT(2) UNSIGNED NOT NULL,
  `schema_comment` NVARCHAR(1024) NULL,
  `exclude_rost` TINYINT(1) UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`base_id_spr`),
  INDEX `FK_list_mysql_bases_list_mysql_server_idx` (`server_id` ASC) VISIBLE,
  CONSTRAINT `FK_list_mysql_bases_list_mysql_server`
    FOREIGN KEY (`server_id`)
    REFERENCES `assistant_dba`.`list_mysql_server` (`server_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE=InnoDB COMMENT = 'This table stores the databases from all MySQL servers.';
#This table stores the names of all tables from each database from each MySQL server''s
CREATE TABLE `assistant_dba`.`list_mysql_table` (
  `table_id_spr` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `base_id_spr` INT UNSIGNED NOT NULL,
  `table_name` NVARCHAR(255) NOT NULL,
  `table_type` NVARCHAR(255) NULL,
  `engine` NVARCHAR(255) NULL,
  `row_format` NVARCHAR(255) NULL,
  `table_collation` NVARCHAR(255) NULL,
  `table_comment` NVARCHAR(255) NULL,
  `is_active` TINYINT(1) NULL,
  PRIMARY KEY (`table_id_spr`),
  INDEX `IX_list_mysql_table_list_mysql_bases` (`base_id_spr` ASC) VISIBLE,
  CONSTRAINT `FK_list_mysql_table_list_mysql_table`
    FOREIGN KEY (`base_id_spr`)
    REFERENCES `assistant_dba`.`list_mysql_bases` (`base_id_spr`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE=InnoDB COMMENT = 'This table stores the names of all tables from each database from each MySQL server''s.';
#Table stores the history of each table from each database from each server of MySQL.
CREATE TABLE `assistant_dba`.`history_mysql_table` (
  `table_id_spr` BIGINT(20) UNSIGNED NOT NULL,
  `table_rows` BIGINT(20) NULL,
  `data_mb` DECIMAL(20,2) NULL,
  `index_mb` DECIMAL(20,2) NULL,
  `unsed_mb` DECIMAL(20,2) NULL,
  `data` DATE NOT NULL,
  PRIMARY KEY (`table_id_spr`, `data`),
  CONSTRAINT `FK_history_mysql_table_history_mysql_table`
    FOREIGN KEY (`table_id_spr`)
    REFERENCES `assistant_dba`.`list_mysql_table` (`table_id_spr`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE=InnoDB COMMENT = 'The table stores the history of each table from each database from each server of MySQL.';
#The table stores variables from all MySQL servers.
CREATE TABLE `assistant_dba`.`list_mysql_glob_var` (
  `var_id_spr` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `server_id` INT UNSIGNED NOT NULL,
  `var_name` VARCHAR(64) NOT NULL,
  PRIMARY KEY (`var_id_spr`),
  UNIQUE INDEX `UX_server_id_var_name` (`server_id` ASC, `var_name` ASC) VISIBLE,
  INDEX `FK_list_mysql_glob_var_list_mysql_server_idx` (`server_id` ASC) VISIBLE,
  CONSTRAINT `FK_list_mysql_glob_var_list_mysql_server`
    FOREIGN KEY (`server_id`)
    REFERENCES `assistant_dba`.`list_mysql_server` (`server_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE=InnoDB COMMENT = 'The table stores variables from all MySQL servers.';
#This table stores the history for each global variable from each MySQL server.
CREATE TABLE `assistant_dba`.`history_mysql_global_var` (
  `var_id_spr` BIGINT UNSIGNED NOT NULL,
  `variable_value` VARCHAR(2048) NULL,
  `data` DATE NOT NULL,
  PRIMARY KEY (`var_id_spr`, `data`),
  CONSTRAINT `FK_history_mysql_global_var_list_mysql_global_var`
    FOREIGN KEY (`var_id_spr`)
    REFERENCES `assistant_dba`.`list_mysql_glob_var` (`var_id_spr`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE=InnoDB COMMENT = 'This table stores the history for each global variable from each MySQL server.';
#This table stores the users from all MySQL server.
CREATE TABLE `assistant_dba`.`list_mysql_users` (
  `user_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `server_id` INT UNSIGNED NOT NULL,
  `user` CHAR(128) NOT NULL,
  `host` CHAR(255) NOT NULL,
  `data_find` DATE NOT NULL,
  `data_lost` DATE NULL,
  `locked` VARCHAR(1),
  `data_lock` DATE NULL,
  `password_expired` VARCHAR(1) NOT NULL,
  `is_role` VARCHAR(1) NOT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE INDEX `UX_server_id_user_host` (`server_id` ASC, `user` ASC, `host` ASC) VISIBLE,
  CONSTRAINT `FK_list_mysql_users_list_mysql_server`
    FOREIGN KEY (`server_id`)
    REFERENCES `assistant_dba`.`list_mysql_server` (`server_id`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE=InnoDB COMMENT = 'This table stores the users from all MySQL server.';
#This table stores views from each database from each MySQL server.
CREATE TABLE `assistant_dba`.`list_mysql_view` (
  `view_id_spr` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `base_id_spr` INT UNSIGNED NOT NULL,
  `table_name` NVARCHAR(255) NOT NULL,
  `view_definition` longtext NULL,
  `check_option` varchar(8)  NULL,
  `is_updatable`  varchar(3) NULL,
   `definer` varchar(384) NULL,
   `security_type` varchar(7) NULL,
   `character_set_client` varchar(32) NULL,
   `collation_connection` varchar(64) NULL,
   `algorithm` varchar(10)  NULL,
   `is_active` tinyint(1), 
  PRIMARY KEY (`view_id_spr`),
  INDEX `IX_list_mysql_view_list_mysql_bases` (`base_id_spr` ASC) VISIBLE,
  CONSTRAINT `FK_list_mysql_view_list_mysql_bases`
    FOREIGN KEY (`base_id_spr`)
    REFERENCES `assistant_dba`.`list_mysql_bases` (`base_id_spr`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE=InnoDB COMMENT = 'This table stores views from each database from each MySQL server.';
#This table stores routines from each database from each MySQL server.
CREATE TABLE `assistant_dba`.`list_mysql_routine`(
   `routine_id_spr` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
   `base_id_spr` INT UNSIGNED NOT NULL,
   `routine_name` varchar(64) NOT NULL,
   `routine_type` varchar(13) NOT NULL,
   `data_type` varchar(64) NOT NULL,
   `character_maximum_length` int(21),
   `character_octet_length` int(21),
   `numeric_precision` int(21),
   `numeric_scale` int(21),
   `datetime_precision` bigint(21) unsigned,
   `character_set_name` varchar(64),
   `collation_name` varchar(64),
   `dtd_identifier` longtext,
   `routine_body` varchar(8) NOT NULL,
   `routine_definition` longtext,
   `external_name` varchar(64),
   `external_language` varchar(64),
   `parameter_style` varchar(8) NOT NULL,
   `is_deterministic` varchar(3) NOT NULL,
   `sql_data_access` varchar(64) NOT NULL,
   `sql_path` varchar(64),
   `security_type` varchar(7) NOT NULL,
   `created` datetime NOT NULL,
   `last_altered` datetime NOT NULL,
   `sql_mode` varchar(8192) NOT NULL,
   `routine_comment` longtext NOT NULL,
   `definer` varchar(384) NOT NULL,
   `character_set_client` varchar(32) NOT NULL,
   `collation_connection` varchar(64) NOT NULL,
   `database_collation` varchar(64) NOT NULL,
   `is_active` tinyint(1), 
  PRIMARY KEY (`routine_id_spr`),
  INDEX `IX_list_mysql_routine_list_mysql_bases` (`base_id_spr` ASC) VISIBLE,
  CONSTRAINT `FK_list_mysql_routine_list_mysql_bases`
    FOREIGN KEY (`base_id_spr`)
    REFERENCES `assistant_dba`.`list_mysql_bases` (`base_id_spr`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE=InnoDB COMMENT = 'This table stores routines from each database from each MySQL server.';
#This table stores types of backup. See comment in table fields.
CREATE TABLE `assistant_dba`.`backup_type_mysql` (
  `backup_type_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `backup_type_description` VARCHAR(10) NOT NULL,
  `backup_type_comments` VARCHAR(300) NULL,
  PRIMARY KEY (`backup_type_id`),
  UNIQUE INDEX `UX_backup_type_description` (`backup_type_description` ASC) VISIBLE)
ENGINE=InnoDB COMMENT = 'This table stores types of backup. See comment in table fields.';
#manual insert type backups mysql
insert into `assistant_dba`.`backup_type_mysql` (backup_type_description,backup_type_comments)
values ('full','Full backup. Doing a backup, which stores data from all schemas and tables on the server, is done once a day.'),
('diff','Diff backup. Doing a backup, which stores data after the last Full backup and include all schemas and tables on the server, is done once a day.'),
('incr','Incr backup. Doing a backup, which stores data from the last Full backup or from the last Incremental backup include all schemas and all tables from on server.');
#This table stores all backup tasks with schedules.
CREATE TABLE `assistant_dba`.`backup_task_mysql` (
  `bt_id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `backup_task_name` VARCHAR(255) NOT NULL,
  `server_id` int(10) unsigned NOT NULL,
  `backup_type_id` int(10) unsigned NOT NULL,
  `Monday` boolean NOT NULL,
  `Tuesday` boolean NOT NULL,
  `Wednesday` boolean NOT NULL,
  `Thursday` boolean NOT NULL,
  `Friday` boolean NOT NULL,
  `Saturday` boolean NOT NULL,
  `Sunday` boolean NOT NULL,
  `start_time` time NOT NULL,
  `interval_min` smallint NOT NULL,
  `end_time` time NOT NULL,
  `last_time` datetime  NULL,
  `next_time` datetime  NULL,
  `enable` boolean NOT NULL,
  `storage_time_days` int(11)  NULL,
  PRIMARY KEY (`bt_id`),
  KEY `FK_backup_task_mysql_list_mysql_server` (`server_id`),
  KEY `FK_backup_task_mysql_backup_type_mysql` (`backup_type_id`),
  UNIQUE INDEX `backup_task_name_UNIQUE` (`backup_task_name` ASC) VISIBLE,
  CONSTRAINT `FK_backup_task_mysql_backup_type_mysql` FOREIGN KEY (`backup_type_id`) REFERENCES `backup_type_mysql` (`backup_type_id`) ON DELETE NO ACTION ON UPDATE NO ACTION,
  CONSTRAINT `FK_backup_task_mysql_list_mysql_server` FOREIGN KEY (`server_id`) REFERENCES `list_mysql_server` (`server_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB COMMENT='This table stores all backup tasks with schedules.';
#This table stores paths backups servers MySQL.
CREATE TABLE `assistant_dba`.`backup_path_variable_mysql` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `server_id` int(10) unsigned NOT NULL,
  `path_backup` varchar(2000) NOT NULL,
  `path_last_full_backup` VARCHAR(2000) NULL,
  `path_last_incr_backup` VARCHAR(2000) NULL,
  `server_for_backup` varchar(255) NOT NULL,
  `user_for_backup` varchar(45) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `server_id_UNIQUE` (`server_id`),
  KEY `FK_path_backup_variable_mysql_list_server_idx` (`server_id`),
  CONSTRAINT `FK_path_backup_variable_mysql_list_server` FOREIGN KEY (`server_id`) REFERENCES `list_server` (`server_id`) ON DELETE NO ACTION ON UPDATE NO ACTION
) ENGINE=InnoDB  COMMENT='This table stores paths backups servers MySQL.';
#This table stores backup tasks ready for execution.
CREATE TABLE `assistant_dba`.`backup_task_run_mysql` (
  `task_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `bt_id` int(10) unsigned NOT NULL ,
  `creat_time` datetime NOT NULL,
  `start_time` datetime NULL,
  `start_time_backup` DATETIME NULL,
  `end_time_backup` DATETIME NULL,
  `start_time_prepare` DATETIME NULL,
  `end_time_prepare` DATETIME NULL,
  `end_time` datetime NULL,
  `wait_task_id` bigint unsigned NULL,
  `task_progress` decimal(5, 2) NULL,
  `enable` boolean NOT NULL,
  `file_log` varchar(300) NULL,
  PRIMARY KEY (`task_id`)
) ENGINE=InnoDB COMMENT='This table stores backup tasks ready for execution.';
#This table stores a history of backup tasks.
CREATE TABLE `assistant_dba`.`backup_task_log_mysql` (
  `task_id` bigint(20) unsigned NOT NULL,
  `bt_id` int(10) unsigned NOT NULL,
  `creat_time` datetime NOT NULL,
  `start_time` datetime DEFAULT NULL,
  `start_time_backup` datetime DEFAULT NULL,
  `end_time_backup` datetime DEFAULT NULL,
  `start_time_prepare` datetime DEFAULT NULL,
  `end_time_prepare` datetime DEFAULT NULL,
  `end_time` datetime DEFAULT NULL,
  `wait_task_id` bigint(20) unsigned DEFAULT NULL,
  `task_progress` decimal(5,2) DEFAULT NULL,
  `enable` tinyint(1) NOT NULL,
  `file_log` varchar(300) DEFAULT NULL,
  `path_last_full_backup` VARCHAR(2000) NULL,
  `path_old_incr_backup` VARCHAR(2000) NULL,
  `path_cur_incr_backup` VARCHAR(2000) NULL,
  `path_diff_backup` VARCHAR(2000) NULL,
  PRIMARY KEY (`task_id`)
) ENGINE=InnoDB COMMENT='This table stores a history of backup tasks.';
#This table stores MariaDB versions with major and minor symbols.
  CREATE TABLE `assistant_dba`.`version_major_minor_mariadb` (
  `id_major_minor` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `version_number` VARCHAR(10) NOT NULL,
  PRIMARY KEY (`id_major_minor`),
  UNIQUE INDEX `version_number_UNIQUE` (`version_number` ASC) VISIBLE)
 ENGINE=InnoDB COMMENT = 'This table stores MariaDB versions with major and minor symbols.';
 #This table stores MariaDB versions with all symbols.
 CREATE TABLE `assistant_dba`.`version_compability_mariadb` (
  `id_version` SMALLINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `version_number` VARCHAR(20) NOT NULL,
  `id_major_minor` SMALLINT UNSIGNED NOT NULL,
  PRIMARY KEY (`id_version`),
  UNIQUE INDEX `version_number_id_major_minor_UX` (`version_number` ASC, `id_major_minor` ASC) VISIBLE,
  INDEX `FK_version_compability_mariadb_id_major_minor_idx` (`id_major_minor` ASC) VISIBLE,
  CONSTRAINT `FK_version_compability_mariadb_id_major_minor`
    FOREIGN KEY (`id_major_minor`)
    REFERENCES `assistant_dba`.`version_major_minor_mariadb` (`id_major_minor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
 ENGINE=InnoDB COMMENT = 'This table stores MariaDB versions with all symbols.';
insert into `assistant_dba`.`version_major_minor_mariadb` (version_number)
values ('10.11');
insert into `assistant_dba`.`version_compability_mariadb` (version_number,id_major_minor)
values
('10.11.1-MariaDB', (select id_major_minor from assistant_dba.version_major_minor_mariadb where version_number='10.11')),
('10.11.2-MariaDB', (select id_major_minor from assistant_dba.version_major_minor_mariadb where version_number='10.11')),
('10.11.3-MariaDB', (select id_major_minor from assistant_dba.version_major_minor_mariadb where version_number='10.11')),
('10.11.4-MariaDB', (select id_major_minor from assistant_dba.version_major_minor_mariadb where version_number='10.11')),
('10.11.5-MariaDB', (select id_major_minor from assistant_dba.version_major_minor_mariadb where version_number='10.11')),
('10.11.6-MariaDB', (select id_major_minor from assistant_dba.version_major_minor_mariadb where version_number='10.11')),
('10.11.7-MariaDB', (select id_major_minor from assistant_dba.version_major_minor_mariadb where version_number='10.11'));




 
####################################################################
#Block create stored procedures for system Assistance DBA
###################################################################
#This procedure adds a new server type
drop procedure  if exists `assistant_dba`.`add_new_server_type`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`add_new_server_type`(in_server_type_desc nvarchar(255))
#CALL `assistant_dba`.`add_new_server_type`('prod');
begin
INSERT INTO `assistant_dba`.`list_server_type` (server_type_desc)
VALUES (in_server_type_desc);
end$$
DELIMITER ;
#This procedure adds a new sql type
drop procedure  if exists `assistant_dba`.`add_new_sql_type`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`add_new_sql_type`(in_sql_type_desc nvarchar(255))
#CALL `assistant_dba`.`add_new_sql_type`('Mysql');
begin
INSERT INTO `assistant_dba`.`list_sql_type` (sql_type_desc)
VALUES (in_sql_type_desc);
end$$
DELIMITER ;
#This procedure adds a new cluster
drop procedure  if exists `assistant_dba`.`add_new_cluster`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`add_new_cluster`(in_cluster_name varchar(100),in_cluster_description varchar(1000))
#CALL `assistant_dba`.`add_new_cluster`('standalone','only standalone server');
begin
INSERT INTO `assistant_dba`.`list_clusters` (cluster_name,cluster_description)
VALUES (in_cluster_name,in_cluster_description);
end$$
DELIMITER ;
#This procedure adds a new database server
drop procedure  if exists `assistant_dba`.`add_new_server_mysql`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`add_new_server_mysql`(in server_name_in nvarchar(255), ip_in nvarchar(255), connection_string nvarchar(255), alive_in tinyint(1),
server_type_desc_in nvarchar(255), sql_type_desc_in nvarchar(255), port_in int , comments_in nvarchar(1000), ip_add_in varchar(3000), cluster_name_in varchar(1000) )
#CALL `assistant_dba`.`add_new_server_mysql`('server_name_dba', '10.10.30.200', 'server_name_dba', 1, 'prod','mysql',3306, 'system assistant DBA','any extra ip address','cluster name');
#CALL `assistant_dba`.`add_new_server_mysql`('mysql30200', '10.10.30.200', 'mysql30200', 1, 'prod','mysql',3306, 'system assistant DBA','not add ip address','standalone');
#server_name_in - short server name
#ip_in - ip address
#connection_string - how to you connect server. Usually short server name
#alive_in - It is =1 if server alive and =0 if server dead
#server_type_desc_in - type server. You can choise type server from table `assistant_dba`.`list_server_type`
#sql_type_desc_in - type RDBMS. You can choise type RDBMS from table `assistant_dba`.`list_sql_type`. Until this work only mysql/mariadb.
#port_in - port for connect server
#comments_in - Comment for description your server.
#ip_add_in -extra ip address
#cluster_name_in - cluster name. You can choise type server from table `assistant_dba`.`list_clusters`
begin
declare speciality condition for sqlstate '45000';
set @error_server_name:= concat ('Server with name : ', server_name_in , ' IP address: ', ip_in ,' type DBMS:', sql_type_desc_in ,'  exists. You need to change any of the specified settings') ;
set @sql_type_id:=(select sql_type_id from `assistant_dba`.`list_sql_type` where sql_type_desc=sql_type_desc_in);
set @cluster_id:=(select cluster_id from `assistant_dba`.`list_clusters` where cluster_name=cluster_name_in);
set @server_type_desc_in:=(select server_type_id from `assistant_dba`.`list_server_type` where server_type_desc=server_type_desc_in);
set @check_server_table:= (select concat(server_name,ip,cast(@sql_type_id as char)) from `assistant_dba`.`list_server` where server_name=server_name_in and ip=ip_in and sql_type_id=@sql_type_id);
set @check_server_param:=(select concat(server_name_in,ip_in,cast(@sql_type_id as char)));
if @check_server_table=@check_server_param then
       signal speciality set message_text = @error_server_name;
end if;
start transaction;
INSERT INTO `assistant_dba`.`list_server` (server_name,ip,connection_string,alive,server_type_id,sql_type_id,comments, ip_add, cluster_id)
VALUES (server_name_in, ip_in, connection_string, alive_in, @server_type_desc_in, @sql_type_id, comments_in, ip_add_in, @cluster_id);
set @server_id_new:= (select LAST_INSERT_ID());
INSERT INTO `assistant_dba`.`list_mysql_server` (server_id,port)
VALUES (@server_id_new, port_in);
commit work;
end$$
DELIMITER ;
#This procedure retrieves the 'alive' MySQL servers for the data collection module.
drop procedure  if exists `assistant_dba`.`get_alive_init_server_mysql`;
DELIMITER $$
create procedure `assistant_dba`.`get_alive_init_server_mysql` ()
#call assistant_dba.get_alive_server_mysql ()
begin
SELECT ls.server_id,ls.server_name,ls.connection_string,ls.ip,lms.port
FROM `assistant_dba`.`list_server` ls
join `assistant_dba`.`list_mysql_server` lms
on lms.server_id=ls.server_id
where ls.alive=1 and lms.exclude_rost=0;
end$$
DELIMITER ;
#This procedure refreshes information about MySQL servers for the data collection module.
drop procedure  if exists `assistant_dba`.`insert_filtered_option_server_mysql`;
DELIMITER $$
create procedure `assistant_dba`.`insert_filtered_option_server_mysql` ( in in_server_id int, in_server_id_in_cnf int, in_collation_server nvarchar(255), in_version nvarchar(255))
#call assistant_dba.insert_filtered_option_server_mysql(1,100,'boss1', 'boss1')
begin
update `assistant_dba`.`list_mysql_server`
set server_id_in_cnf=in_server_id_in_cnf, collation_server=in_collation_server, version=in_version
where server_id=in_server_id;
end$$
DELIMITER ;
#This procedure inserts the databases list in a temporary table into the database assistant_dba_temp.
drop procedure  if exists `assistant_dba`.`insert_list_db` ;
DELIMITER $$
create procedure `assistant_dba`.`insert_list_db` (in db_server_name_list_db nvarchar(1024), in tbl_server_name_list_db nvarchar(1024), in in_server_id int, in in_server_name nvarchar(255), in in_schema_name varchar(64),in in_default_character_set_name varchar(32), in in_default_collation_name varchar(64), in in_schema_comment nvarchar(1024) ) 
#call assistant_dba.insert_list_db ('assistant_dba_temp','dba_server_name_list_db',1, 'vasek' , 'schema_name', 'default_character_set_name', 'default_collation_name','') ;
begin
set @in_server_id=in_server_id;
set @in_server_name=in_server_name;
set @in_schema_name=in_schema_name;
set @in_default_character_set_name=in_default_character_set_name;
set @in_default_collation_name=in_default_collation_name;
set @in_schema_comment=in_schema_comment;
set @db_name=db_server_name_list_db;
set @table_name1:=tbl_server_name_list_db;
set @sql_exec:=concat('insert into  \`' ,@db_name, '\`.\`' ,@table_name1, '\` (server_id, server_name, schema_name, default_character_set_name, default_collation_name, schema_comment)
values(',@in_server_id,',"',@in_server_name,'","',@in_schema_name,'","',@in_default_character_set_name,'","',@in_default_collation_name,'","', @in_schema_comment,'")');
prepare dynamic_statement from @sql_exec;
execute dynamic_statement;
deallocate prepare dynamic_statement;
end$$
DELIMITER ;
#This procedure inserts and updates in the database information about server_name.
drop procedure  if exists `assistant_dba`.`check_db` ;
DELIMITER $$
create procedure `assistant_dba`.`check_db`(in db_server_name_list_db nvarchar(1024), in tbl_server_name_list_db nvarchar(1024), in in_server_id int) 
#call assistant_dba.check_db('assistant_dba_temp','dba_server_name_list_db',1) ;
begin
set @in_server_id=in_server_id;
set @db_name=db_server_name_list_db; #"assistant_dba_temp"; #
set @table_name1:=tbl_server_name_list_db;#"dba_server_name_list_db"
#The database server doesn't have the database listed in the reference and del_object=0.
set @sql_del_object:=concat('if exists (select 1 
	from \`assistant_dba\`.\`list_mysql_bases\` as lmb
    left join \`',@db_name,'\`.\`',@table_name1,'\` tts
    	on tts.schema_name=lmb.base_name 
	where tts.schema_name is null and  lmb.server_id=@in_server_id and lmb.del_object=0 limit 1)
then 
	begin
		update  `assistant_dba`.`list_mysql_bases` as lmb
		left join \`',@db_name,'\`.\`',@table_name1,'\` tts
   		on tts.schema_name=lmb.base_name 
		set del_object=2 
		where tts.schema_name is null and  lmb.server_id=@in_server_id and lmb.del_object=0;
	end;
end if;
');
prepare dynamic_del_object from @sql_del_object;
execute dynamic_del_object;
deallocate prepare dynamic_del_object;
#update characterset
set @sql_characterset:=concat('update  \`assistant_dba\`.\`list_mysql_bases\` as lmb
inner join \`',@db_name,'\`.\`',@table_name1,'\` tts
on tts.schema_name=lmb.base_name 
set lmb.characterset=tts.default_character_set_name
where (lmb.characterset is null or tts.default_character_set_name<>lmb.characterset) and  lmb.server_id=',@in_server_id,' and lmb.del_object=0;');
prepare dynamic_characterset from @sql_characterset;
execute dynamic_characterset;
deallocate prepare dynamic_characterset;
#update collation_desc
set @sql_collation_desc:=concat('update  \`assistant_dba\`.\`list_mysql_bases\` as lmb
inner join \`',@db_name,'\`.\`',@table_name1,'\` tts
on tts.schema_name=lmb.base_name 
set lmb.collation_desc=tts.default_collation_name
where (lmb.collation_desc is null or tts.default_collation_name<>lmb.collation_desc) and  lmb.server_id=',@in_server_id,' and lmb.del_object=0;');
prepare dynamic_collation_desc from @sql_collation_desc;
execute dynamic_collation_desc;
deallocate prepare dynamic_collation_desc;
#update schema_comment
set @sql_schema_comment:=concat('update  \`assistant_dba\`.\`list_mysql_bases\` as lmb
inner join \`',@db_name,'\`.\`',@table_name1,'\` tts
on tts.schema_name=lmb.base_name 
set lmb.schema_comment=tts.schema_comment
where (lmb.schema_comment is null or tts.schema_comment<>lmb.schema_comment) and  lmb.server_id=',@in_server_id,' and lmb.del_object=0;');
prepare dynamic_schema_comment from @sql_schema_comment;
execute dynamic_schema_comment;
deallocate prepare dynamic_schema_comment;
#inserting a new database
set @sql_insert:=concat('if exists (select 1 
	from \`',@db_name,'\`.\`',@table_name1,'\` tts
	left join \`assistant_dba\`.\`list_mysql_bases\` as lmb
	on tts.schema_name=lmb.base_name and lmb.server_id=',@in_server_id,'
	where lmb.base_id_spr is null limit 1)
then 
	begin
		insert into `assistant_dba`.`list_mysql_bases`  (server_id, base_name, characterset, collation_desc, del_object, schema_comment, exclude_rost)
		select tts.server_id, tts.schema_name, tts.default_character_set_name, tts.default_collation_name, 0, tts.schema_comment,0
		FROM \`',@db_name,'\`.\`',@table_name1,'\` as tts
		left join `assistant_dba`.`list_mysql_bases` lmb
		on tts.schema_name=lmb.base_name and lmb.server_id=',@in_server_id,'
		where lmb.base_id_spr is null;
	end;
end if;');
prepare dynamic_insert from @sql_insert;
execute dynamic_insert;
deallocate prepare dynamic_insert;
#Dropping staging tables prefixed with $in_server "dba_"$in_server_name"_list_db".
set @sql_drop_intermediate:=concat('drop table if exists  \`',@db_name,'\`.\`',@table_name1,'\` ;');
prepare dynamic_drop_intermediate from @sql_drop_intermediate;
execute dynamic_drop_intermediate;
deallocate prepare dynamic_drop_intermediate;
end$$
DELIMITER ;
#This procedure gets the database list for the selected server_name.
drop procedure  if exists `assistant_dba`.`get_list_db_my_spr` ;
DELIMITER $$
create procedure `assistant_dba`.`get_list_db_my_spr` ( in in_server_id int) 
#call assistant_dba.get_list_db_my_spr (1) ;
begin
set @in_server_id=in_server_id;
SELECT lmb.`base_id_spr`, lmb.`server_id`, ls.`server_name`, lmb.`base_name`, lmb.`characterset`, lmb.`collation_desc`
FROM `assistant_dba`.`list_mysql_bases` lmb
join `assistant_dba`.`list_mysql_server` lms
on lms.server_id=lmb.server_id
join `assistant_dba`.`list_server` ls
on ls.server_id=lms.server_id
where ls.alive=1 and lms.exclude_rost=0 and lmb.exclude_rost=0 and lmb.del_object=0 and lmb.server_id=@in_server_id ;
end$$
DELIMITER ;
#This procedure forced run table analysis on all schemas and all tables excluding performance_schema.
drop procedure  if exists `mysql`.`dba_analyze_table` ;
DELIMITER $$
create procedure `mysql`.`dba_analyze_table` ()
#call assistant_dba.insert_history_global_priv(1,'assistant_dba_temp','tu_18_global_priv');
begin
declare var_schema_name varchar(64);
declare var_table_name varchar(64);
declare done int default 0;
declare table_cur cursor for 
	select table_schema, table_name 
	from information_schema.TABLES 
    where table_type='BASE TABLE' and (table_schema!='performance_schema' ) 
    order by table_schema, table_name;
DECLARE CONTINUE HANDLER FOR SQLSTATE '02000'
	set done=1;
DECLARE CONTINUE HANDLER FOR SQLSTATE '23000'
	set done=1;
open table_cur;
	while done=0 do
		fetch table_cur into var_schema_name, var_table_name;
		set @sql_analyze_tbl:=concat('analyze table \`',var_schema_name,'\`.\`',var_table_name,'`\;');
		set @sql_nanalyze_tbl_print= concat(' start ',@sql_analyze_tbl,' ',now());
		select @sql_nanalyze_tbl_print;
		prepare dynamic_analyze_tbl from @sql_analyze_tbl;
		execute dynamic_analyze_tbl;
		deallocate prepare dynamic_analyze_tbl;
	end while;
close table_cur;
end$$
DELIMITER ;
#This procedure inserts and updates information about tables from each database from each MySQL servers.
drop procedure  if exists `assistant_dba`.`check_table` ;
DELIMITER $$
create procedure `assistant_dba`.`check_table` ( in in_server_id int, in in_server_name nvarchar(255), in in_db_name varchar(64), in in_tbl_server_name_db nvarchar(300)) 
begin
set @in_server_id=in_server_id;
set @in_server_name=in_server_name;
set @in_db_name=in_db_name;
set @in_tbl_server_name_db=in_tbl_server_name_db;
#insert new tables
set @sql_tbl_insert:=concat('insert into \`assistant_dba\`.\`list_mysql_table\` (\`base_id_spr\`,\`table_name\`,\`table_type\`,\`engine\`,\`row_format\`,\`table_collation\`,\`table_comment\`,
\`is_active\`)
SELECT tb1.\`base_id_spr\`, tb1.\`table_name\`, tb1.\`table_type\`, tb1.\`engine\`, tb1.\`row_format\`, tb1.\`table_collation\`, tb1.\`table_comment\`, 1
FROM ',@in_tbl_server_name_db,' tb1
left join \`assistant_dba\`.\`list_mysql_table\` lmb
on  tb1.base_id_spr=lmb.base_id_spr and tb1.table_name=lmb.table_name
where lmb.table_name is null
');
prepare dynamic_insert from @sql_tbl_insert;
execute dynamic_insert;
deallocate prepare dynamic_insert;
#updating the sign of the existence of a table set is_active=0
set @sql_tbl_active0:=concat('update  \`assistant_dba\`.\`list_mysql_table\` lmb
left join ',@in_tbl_server_name_db,' tb1
on lmb.base_id_spr=tb1.base_id_spr and lmb.table_name=tb1.table_name
set lmb.is_active=0
where tb1.table_name is null and 
lmb.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_tbl_active0 from @sql_tbl_active0;
execute dynamic_tbl_active0;
deallocate prepare dynamic_tbl_active0;
#updating the sign of the existence of a table set is_active=1
set @sql_tbl_active1:=concat('update  \`assistant_dba\`.\`list_mysql_table\` lmb
left join ',@in_tbl_server_name_db,' tb1
on lmb.base_id_spr=tb1.base_id_spr and lmb.table_name=tb1.table_name
set lmb.is_active=1
where lmb.table_name=tb1.table_name and lmb.is_active<>1 and
lmb.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_tbl_active1 from @sql_tbl_active1;
execute dynamic_tbl_active1;
deallocate prepare dynamic_tbl_active1;
#updating the sign of the table_type  a table
set @sql_tbl_type:=concat('update  \`assistant_dba\`.\`list_mysql_table\` lmb
left join ',@in_tbl_server_name_db,' tb1
on lmb.base_id_spr=tb1.base_id_spr and lmb.table_name=tb1.table_name
set lmb.table_type=tb1.table_type
where lmb.table_name =tb1.table_name and lmb.table_type!=tb1.table_type and
lmb.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_tbl_type from @sql_tbl_type;
execute dynamic_tbl_type;
deallocate prepare dynamic_tbl_type;
#updating the sign of the engine  a table
set @sql_engine:=concat('update  \`assistant_dba\`.\`list_mysql_table\` lmb
left join ',@in_tbl_server_name_db,' tb1
on lmb.base_id_spr=tb1.base_id_spr and lmb.table_name=tb1.table_name
set lmb.engine=tb1.engine
where lmb.table_name =tb1.table_name and lmb.engine!=tb1.engine and
lmb.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_tbl_engine from @sql_engine;
execute dynamic_tbl_engine;
deallocate prepare dynamic_tbl_engine;
#updating the sign of the row_format  a table
set @sql_row_format:=concat('update  \`assistant_dba\`.\`list_mysql_table\` lmb
left join ',@in_tbl_server_name_db,' tb1
on lmb.base_id_spr=tb1.base_id_spr and lmb.table_name=tb1.table_name
set lmb.row_format=tb1.row_format
where lmb.table_name =tb1.table_name and lmb.row_format!=tb1.row_format and
lmb.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,'''
and server_id=',@in_server_id,');');
prepare dynamic_tbl_row_format from @sql_row_format;
execute dynamic_tbl_row_format;
deallocate prepare dynamic_tbl_row_format;
#updating the sign of the table_collation  a table
set @sql_table_collation:=concat('update  \`assistant_dba\`.\`list_mysql_table\` lmb
left join ',@in_tbl_server_name_db,' tb1
on lmb.base_id_spr=tb1.base_id_spr and lmb.table_name=tb1.table_name
set lmb.table_collation=tb1.table_collation
where lmb.table_name =tb1.table_name and lmb.table_collation!=tb1.table_collation and
lmb.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_tbl_table_collation from @sql_table_collation;
execute dynamic_tbl_table_collation;
deallocate prepare dynamic_tbl_table_collation;
#updating the sign of the table_comment  a table
set @sql_table_comment:=concat('update  \`assistant_dba\`.\`list_mysql_table\` lmb
left join ',@in_tbl_server_name_db,' tb1
on lmb.base_id_spr=tb1.base_id_spr and lmb.table_name=tb1.table_name
set lmb.table_comment=tb1.table_comment
where lmb.table_name =tb1.table_name and lmb.table_comment!=tb1.table_comment and
lmb.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_tbl_table_comment from @sql_table_comment;
execute dynamic_tbl_table_comment;
deallocate prepare dynamic_tbl_table_comment;
end$$
DELIMITER ;
#This procedure inserts and updates information about routines from each database from each MySQL servers.
drop procedure  if exists `assistant_dba`.`check_routine` ;
DELIMITER $$
create procedure `assistant_dba`.`check_routine` ( in in_server_id int, in in_server_name nvarchar(255), in in_db_name varchar(64), in in_routine_server_name_db nvarchar(300)) 
begin
set @in_server_id=in_server_id;
set @in_server_name=in_server_name;
set @in_db_name=in_db_name;
set @in_routine_server_name_db=in_routine_server_name_db;
#insert new routine
set @sql_routine_insert:=concat('insert into \`assistant_dba\`.\`list_mysql_routine\` (\`base_id_spr\`,\`routine_name\`,\`routine_type\`,\`data_type\`,\`character_maximum_length\`,\`character_octet_length\`,\`numeric_precision\`,
\`numeric_scale\`,\`datetime_precision\`,\`character_set_name\`,\`collation_name\`,\`dtd_identifier\`,\`routine_body\`,\`routine_definition\`,\`external_name\`,
\`external_language\`, \`parameter_style\`,\`is_deterministic\`,\`sql_data_access\`,\`sql_path\`,\`security_type\`,\`created\`,\`last_altered\`,\`sql_mode\`,
\`routine_comment\`,\`definer\`,\`character_set_client\`,\`collation_connection\`,\`database_collation\`,\`is_active\`)
SELECT tb1.\`base_id_spr\`,tb1.\`routine_name\`,tb1.\`routine_type\`,tb1.\`data_type\`,tb1.\`character_maximum_length\`,tb1.\`character_octet_length\`,tb1.\`numeric_precision\`,
tb1.\`numeric_scale\`,tb1.\`datetime_precision\`,tb1.\`character_set_name\`,tb1.\`collation_name\`,tb1.\`dtd_identifier\`,tb1.\`routine_body\`,tb1.\`routine_definition\`,tb1.\`external_name\`,
tb1.\`external_language\`, tb1.\`parameter_style\`,tb1.\`is_deterministic\`,tb1.\`sql_data_access\`,tb1.\`sql_path\`,tb1.\`security_type\`,tb1.\`created\`,tb1.\`last_altered\`,tb1.\`sql_mode\`,
tb1.\`routine_comment\`,tb1.\`definer\`,tb1.\`character_set_client\`,tb1.\`collation_connection\`,tb1.\`database_collation\`, 1
FROM ',@in_routine_server_name_db,' tb1
left join \`assistant_dba\`.\`list_mysql_routine\` lmr
on  tb1.base_id_spr=lmr.base_id_spr and tb1.routine_name=lmr.routine_name
where lmr.routine_name is null
');
prepare dynamic_insert from @sql_routine_insert;
execute dynamic_insert;
deallocate prepare dynamic_insert;
#updating the sign of the existence of a routine set is_active=0
set @sql_routine_active0:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.is_active=0
where tb1.routine_name is null and 
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_routine_active0 from @sql_routine_active0;
execute dynamic_routine_active0;
deallocate prepare dynamic_routine_active0;
#updating the sign of the existence of a routine set is_active=1
set @sql_routine_active1:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.is_active=1
where lmr.routine_name=tb1.routine_name and lmr.is_active<>1 and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_routine_active1 from @sql_routine_active1;
execute dynamic_routine_active1;
deallocate prepare dynamic_routine_active1;
#updating the sign of the routine_type  a routine
set @sql_routine_type:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.routine_type=tb1.routine_type
where lmr.routine_name =tb1.routine_name and lmr.routine_type!=tb1.routine_type and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_routine_type from @sql_routine_type;
execute dynamic_routine_type;
deallocate prepare dynamic_routine_type;
#updating the sign of the data_type  a routine
set @sql_data_type:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.data_type=tb1.data_type
where lmr.routine_name =tb1.routine_name and lmr.data_type!=tb1.data_type and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_data_type from @sql_data_type;
execute dynamic_data_type;
deallocate prepare dynamic_data_type;
#updating the sign of the character_maximum_length  a routine
set @sql_character_maximum_length:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.character_maximum_length=tb1.character_maximum_length
where lmr.routine_name =tb1.routine_name and lmr.character_maximum_length!=tb1.character_maximum_length and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_character_maximum_length from @sql_character_maximum_length;
execute dynamic_character_maximum_length;
deallocate prepare dynamic_character_maximum_length;
#updating the sign of the character_octet_length  a routine
set @sql_character_octet_length:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.character_octet_length=tb1.character_octet_length
where lmr.routine_name =tb1.routine_name and lmr.character_octet_length!=tb1.character_octet_length and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_character_octet_length from @sql_character_octet_length;
execute dynamic_character_octet_length;
deallocate prepare dynamic_character_octet_length;
#updating the sign of the numeric_precision  a routine
set @sql_numeric_precision:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.numeric_precision=tb1.numeric_precision
where lmr.routine_name =tb1.routine_name and lmr.numeric_precision!=tb1.numeric_precision and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_numeric_precision from @sql_numeric_precision;
execute dynamic_numeric_precision;
deallocate prepare dynamic_numeric_precision;
#updating the sign of the numeric_scale  a routine
set @sql_numeric_scale:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.numeric_scale=tb1.numeric_scale
where lmr.routine_name =tb1.routine_name and lmr.numeric_scale!=tb1.numeric_scale and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_numeric_scale from @sql_numeric_scale;
execute dynamic_numeric_scale;
deallocate prepare dynamic_numeric_scale;
#updating the sign of the datetime_precision  a routine
set @sql_datetime_precision:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.datetime_precision=tb1.datetime_precision
where lmr.routine_name =tb1.routine_name and lmr.datetime_precision!=tb1.datetime_precision and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_datetime_precision from @sql_datetime_precision;
execute dynamic_datetime_precision;
deallocate prepare dynamic_datetime_precision;
#updating the sign of the character_set_name  a routine
set @sql_character_set_name:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.character_set_name=tb1.character_set_name
where lmr.routine_name =tb1.routine_name and lmr.character_set_name!=tb1.character_set_name and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_character_set_name from @sql_character_set_name;
execute dynamic_character_set_name;
deallocate prepare dynamic_character_set_name;
#updating the sign of the collation_name  a routine
set @sql_collation_name:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.collation_name=tb1.collation_name
where lmr.routine_name =tb1.routine_name and lmr.collation_name!=tb1.collation_name and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_collation_name from @sql_collation_name;
execute dynamic_collation_name;
deallocate prepare dynamic_collation_name;
#updating the sign of the dtd_identifier  a routine
set @sql_dtd_identifier:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.dtd_identifier=tb1.dtd_identifier
where lmr.routine_name =tb1.routine_name and lmr.dtd_identifier!=tb1.dtd_identifier and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_dtd_identifier from @sql_dtd_identifier;
execute dynamic_dtd_identifier;
deallocate prepare dynamic_dtd_identifier;
#updating the sign of the routine_body  a routine
set @sql_routine_body:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.routine_body=tb1.routine_body
where lmr.routine_name =tb1.routine_name and lmr.routine_body!=tb1.routine_body and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_routine_body from @sql_routine_body;
execute dynamic_routine_body;
deallocate prepare dynamic_routine_body;
#updating the sign of the routine_definition  a routine
set @sql_routine_definition:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.routine_definition=tb1.routine_definition
where lmr.routine_name =tb1.routine_name and lmr.routine_definition!=tb1.routine_definition and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_routine_definition from @sql_routine_definition;
execute dynamic_routine_definition;
deallocate prepare dynamic_routine_definition;
#updating the sign of the external_name  a routine
set @sql_external_name:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.external_name=tb1.external_name
where lmr.routine_name =tb1.routine_name and lmr.external_name!=tb1.external_name and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_external_name from @sql_external_name;
execute dynamic_external_name;
deallocate prepare dynamic_external_name;
#updating the sign of the external_language  a routine
set @sql_external_language:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.external_language=tb1.external_language
where lmr.routine_name =tb1.routine_name and lmr.external_language!=tb1.external_language and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_external_language from @sql_external_language;
execute dynamic_external_language;
deallocate prepare dynamic_external_language;
#updating the sign of the parameter_style  a routine
set @sql_parameter_style:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.parameter_style=tb1.parameter_style
where lmr.routine_name =tb1.routine_name and lmr.parameter_style!=tb1.parameter_style and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_parameter_style from @sql_parameter_style;
execute dynamic_parameter_style;
deallocate prepare dynamic_parameter_style;
#updating the sign of the is_deterministic  a routine
set @sql_is_deterministic:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.is_deterministic=tb1.is_deterministic
where lmr.routine_name =tb1.routine_name and lmr.is_deterministic!=tb1.is_deterministic and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_is_deterministic from @sql_is_deterministic;
execute dynamic_is_deterministic;
deallocate prepare dynamic_is_deterministic;
#updating the sign of the sql_data_access  a routine
set @sql_sql_data_access:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.sql_data_access=tb1.sql_data_access
where lmr.routine_name =tb1.routine_name and lmr.sql_data_access!=tb1.sql_data_access and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_sql_data_access from @sql_sql_data_access;
execute dynamic_sql_data_access;
deallocate prepare dynamic_sql_data_access;
#updating the sign of the sql_path  a routine
set @sql_sql_path:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.sql_path=tb1.sql_path
where lmr.routine_name =tb1.routine_name and lmr.sql_path!=tb1.sql_path and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_sql_path from @sql_sql_path;
execute dynamic_sql_path;
deallocate prepare dynamic_sql_path;
#updating the sign of the security_type  a routine
set @sql_security_type:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.security_type=tb1.security_type
where lmr.routine_name =tb1.routine_name and lmr.security_type!=tb1.security_type and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_security_type from @sql_security_type;
execute dynamic_security_type;
deallocate prepare dynamic_security_type;
#updating the sign of the created  a routine
set @sql_created:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.created=tb1.created
where lmr.routine_name =tb1.routine_name and lmr.created!=tb1.created and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_created from @sql_created;
execute dynamic_created;
deallocate prepare dynamic_created;
#updating the sign of the last_altered  a routine
set @sql_last_altered:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.last_altered=tb1.last_altered
where lmr.routine_name =tb1.routine_name and lmr.last_altered!=tb1.last_altered and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_last_altered from @sql_last_altered;
execute dynamic_last_altered;
deallocate prepare dynamic_last_altered;
#updating the sign of the sql_mode  a routine
set @sql_sql_mode:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.sql_mode=tb1.sql_mode
where lmr.routine_name =tb1.routine_name and lmr.sql_mode!=tb1.sql_mode and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_sql_mode from @sql_sql_mode;
execute dynamic_sql_mode;
deallocate prepare dynamic_sql_mode;
#updating the sign of the routine_comment  a routine
set @sql_routine_comment:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.routine_comment=tb1.routine_comment
where lmr.routine_name =tb1.routine_name and lmr.routine_comment!=tb1.routine_comment and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_routine_comment from @sql_routine_comment;
execute dynamic_routine_comment;
deallocate prepare dynamic_routine_comment;
#updating the sign of the definer  a routine
set @sql_definer:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.definer=tb1.definer
where lmr.routine_name =tb1.routine_name and lmr.definer!=tb1.definer and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_definer from @sql_definer;
execute dynamic_definer;
deallocate prepare dynamic_definer;
#updating the sign of the character_set_client  a routine
set @sql_character_set_client:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.character_set_client=tb1.character_set_client
where lmr.routine_name =tb1.routine_name and lmr.character_set_client!=tb1.character_set_client and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_character_set_client from @sql_character_set_client;
execute dynamic_character_set_client;
deallocate prepare dynamic_character_set_client;
#updating the sign of the collation_connection  a routine
set @sql_collation_connection:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.collation_connection=tb1.collation_connection
where lmr.routine_name =tb1.routine_name and lmr.collation_connection!=tb1.collation_connection and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_collation_connection from @sql_collation_connection;
execute dynamic_collation_connection;
deallocate prepare dynamic_collation_connection;
#updating the sign of the database_collation  a routine
set @sql_database_collation:=concat('update  \`assistant_dba\`.\`list_mysql_routine\` lmr
left join ',@in_routine_server_name_db,' tb1
on lmr.base_id_spr=tb1.base_id_spr and lmr.routine_name=tb1.routine_name
set lmr.database_collation=tb1.database_collation
where lmr.routine_name =tb1.routine_name and lmr.database_collation!=tb1.database_collation and
lmr.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_database_collation from @sql_database_collation;
execute dynamic_database_collation;
deallocate prepare dynamic_database_collation;
set @sql_drop_intermediate:=concat('drop table if exists  ',@in_routine_server_name_db,' ;');
prepare dynamic_drop_intermediate from @sql_drop_intermediate;
execute dynamic_drop_intermediate;
deallocate prepare dynamic_drop_intermediate;
end$$
DELIMITER ;
#This procedure inserts and updates information about views from each database from each MySQL servers.
drop procedure  if exists `assistant_dba`.`check_view` ;
DELIMITER $$
create procedure `assistant_dba`.`check_view` ( in in_server_id int, in in_server_name nvarchar(255), in in_db_name varchar(64), in in_view_server_name_db nvarchar(300)) 
begin
set @in_server_id=in_server_id;
set @in_server_name=in_server_name;
set @in_db_name=in_db_name;
set @in_view_server_name_db=in_view_server_name_db;
#insert new views
set @sql_view_insert:=concat('insert into \`assistant_dba\`.\`list_mysql_view\` (\`base_id_spr\`,\`table_name\`,\`view_definition\`,\`check_option\`,\`is_updatable\`,\`definer\`,\`security_type\`,
\`character_set_client\`,\`collation_connection\`,\`algorithm\`,\`is_active\`)
SELECT tb1.\`base_id_spr\`, tb1.\`table_name\`, tb1.\`view_definition\`,tb1.\`check_option\`,tb1.\`is_updatable\`,tb1.\`definer\`,tb1.\`security_type\`,
tb1.\`character_set_client\`,tb1.\`collation_connection\`,tb1.\`algorithm\`, 1
FROM ',@in_view_server_name_db,' tb1
left join \`assistant_dba\`.\`list_mysql_view\` lmv
on  tb1.base_id_spr=lmv.base_id_spr and tb1.table_name=lmv.table_name
where lmv.table_name is null
');
prepare dynamic_insert from @sql_view_insert;
execute dynamic_insert;
deallocate prepare dynamic_insert;
#updating the sign of the existence of a view set is_active=0
set @sql_view_active0:=concat('update  \`assistant_dba\`.\`list_mysql_view\` lmv
left join ',@in_view_server_name_db,' tb1
on lmv.base_id_spr=tb1.base_id_spr and lmv.table_name=tb1.table_name
set lmv.is_active=0
where tb1.table_name is null and 
lmv.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_view_active0 from @sql_view_active0;
execute dynamic_view_active0;
deallocate prepare dynamic_view_active0;
#updating the sign of the existence of a view set is_active=1
set @sql_view_active1:=concat('update  \`assistant_dba\`.\`list_mysql_view\` lmv
left join ',@in_view_server_name_db,' tb1
on lmv.base_id_spr=tb1.base_id_spr and lmv.table_name=tb1.table_name
set lmv.is_active=1
where lmv.table_name=tb1.table_name and lmv.is_active<>1 and
lmv.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_view_active1 from @sql_view_active1;
execute dynamic_view_active1;
deallocate prepare dynamic_view_active1;
#updating the sign of the view_definition  a view
set @sql_view_definition:=concat('update  \`assistant_dba\`.\`list_mysql_view\` lmv
left join ',@in_view_server_name_db,' tb1
on lmv.base_id_spr=tb1.base_id_spr and lmv.table_name=tb1.table_name
set lmv.view_definition=tb1.view_definition
where lmv.table_name =tb1.table_name and lmv.view_definition!=tb1.view_definition and
lmv.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_view_definition from @sql_view_definition;
execute dynamic_view_definition;
deallocate prepare dynamic_view_definition;
#updating the sign of the check_option  a view
set @sql_check_option:=concat('update  \`assistant_dba\`.\`list_mysql_view\` lmv
left join ',@in_view_server_name_db,' tb1
on lmv.base_id_spr=tb1.base_id_spr and lmv.table_name=tb1.table_name
set lmv.check_option=tb1.check_option
where lmv.table_name =tb1.table_name and lmv.check_option!=tb1.check_option and
lmv.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_check_option from @sql_check_option;
execute dynamic_check_option;
deallocate prepare dynamic_check_option;
#updating the sign of the row_format  a table
set @sql_is_updatable:=concat('update  \`assistant_dba\`.\`list_mysql_view\` lmv
left join ',@in_view_server_name_db,' tb1
on lmv.base_id_spr=tb1.base_id_spr and lmv.table_name=tb1.table_name
set lmv.is_updatable=tb1.is_updatable
where lmv.table_name =tb1.table_name and lmv.is_updatable!=tb1.is_updatable and
lmv.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,'''
and server_id=',@in_server_id,');');
prepare dynamic_is_updatable from @sql_is_updatable;
execute dynamic_is_updatable;
deallocate prepare dynamic_is_updatable;
#updating the sign of the definer  a view
set @sql_definer:=concat('update  \`assistant_dba\`.\`list_mysql_view\` lmv
left join ',@in_view_server_name_db,' tb1
on lmv.base_id_spr=tb1.base_id_spr and lmv.table_name=tb1.table_name
set lmv.definer=tb1.definer
where lmv.table_name =tb1.table_name and lmv.definer!=tb1.definer and
lmv.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_definer from @sql_definer;
execute dynamic_definer;
deallocate prepare dynamic_definer;
#updating the sign of the security_type  a view
set @sql_security_type:=concat('update  \`assistant_dba\`.\`list_mysql_view\` lmv
left join ',@in_view_server_name_db,' tb1
on lmv.base_id_spr=tb1.base_id_spr and lmv.table_name=tb1.table_name
set lmv.security_type=tb1.security_type
where lmv.table_name =tb1.table_name and lmv.security_type!=tb1.security_type and
lmv.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_security_type from @sql_security_type;
execute dynamic_security_type;
deallocate prepare dynamic_security_type;
#updating the sign of the character_set_client  a view
set @sql_character_set_client:=concat('update  \`assistant_dba\`.\`list_mysql_view\` lmv
left join ',@in_view_server_name_db,' tb1
on lmv.base_id_spr=tb1.base_id_spr and lmv.table_name=tb1.table_name
set lmv.character_set_client=tb1.character_set_client
where lmv.table_name =tb1.table_name and lmv.character_set_client!=tb1.character_set_client and
lmv.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_character_set_client from @sql_character_set_client;
execute dynamic_character_set_client;
deallocate prepare dynamic_character_set_client;
#updating the sign of the collation_connection  a view
set @sql_collation_connection:=concat('update  \`assistant_dba\`.\`list_mysql_view\` lmv
left join ',@in_view_server_name_db,' tb1
on lmv.base_id_spr=tb1.base_id_spr and lmv.table_name=tb1.table_name
set lmv.collation_connection=tb1.collation_connection
where lmv.table_name =tb1.table_name and lmv.collation_connection!=tb1.collation_connection and
lmv.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_collation_connection from @sql_collation_connection;
execute dynamic_collation_connection;
deallocate prepare dynamic_collation_connection;
#updating the sign of the algorithm  a view
set @sql_algorithm:=concat('update  \`assistant_dba\`.\`list_mysql_view\` lmv
left join ',@in_view_server_name_db,' tb1
on lmv.base_id_spr=tb1.base_id_spr and lmv.table_name=tb1.table_name
set lmv.algorithm=tb1.algorithm
where lmv.table_name =tb1.table_name and lmv.algorithm!=tb1.algorithm and
lmv.base_id_spr=(select base_id_spr from \`assistant_dba\`.\`list_mysql_bases\` where base_name=''',@in_db_name,''' 
and server_id=',@in_server_id,');');
prepare dynamic_algorithm from @sql_algorithm;
execute dynamic_algorithm;
deallocate prepare dynamic_algorithm;
set @sql_drop_intermediate:=concat('drop table if exists  ',@in_view_server_name_db,' ;');
prepare dynamic_drop_intermediate from @sql_drop_intermediate;
execute dynamic_drop_intermediate;
deallocate prepare dynamic_drop_intermediate;
end$$
DELIMITER ;
#This procedure involves inserting historical data about the size of the table.
drop procedure  if exists `assistant_dba`.`insert_history_table` ;
DELIMITER $$
create procedure `assistant_dba`.`insert_history_table` ( in in_server_id int, in in_server_name nvarchar(255), in in_db_name varchar(64),  in in_base_id_spr int, in in_tbl_server_name_db nvarchar(300)) 
begin
set @in_server_id=in_server_id;
set @in_server_name=in_server_name;
set @in_db_name=in_db_name;
set @in_base_id_spr=in_base_id_spr;
set @in_tbl_server_name_db=in_tbl_server_name_db;
#exclude double data
set @sql_del_get_date:=concat('delete hmt 
from \`assistant_dba\`.\`history_mysql_table\` hmt 
join \`assistant_dba\`.\`list_mysql_table\`  lmt 
on lmt.table_id_spr=hmt.table_id_spr 
join \`assistant_dba\`.\`list_mysql_bases\` lmb 
on lmb.base_id_spr=lmt.base_id_spr 
where lmb.server_id=',@in_server_id,' and lmb.base_id_spr=',@in_base_id_spr,' and hmt.data=curdate();'); #
prepare dynamic_del_get_date from @sql_del_get_date;
execute dynamic_del_get_date;
deallocate prepare dynamic_del_get_date;
set @sql_insert_history:=concat('INSERT INTO \`assistant_dba\`.\`history_mysql_table\` (table_id_spr,table_rows,data_mb,index_mb,unsed_mb,data)
SELECT lmt.table_id_spr,  t1.table_rows, t1.data_mb, t1.index_mb, t1.unsed_mb, curdate()
FROM ',@in_tbl_server_name_db,' t1
join \`assistant_dba\`.\`list_mysql_table\` lmt
on lmt.base_id_spr= t1.base_id_spr and lmt.table_name=t1.table_name;');
prepare dynamic_insert_history from @sql_insert_history;
execute dynamic_insert_history;
deallocate prepare dynamic_insert_history;
set @sql_drop_intermediate_history:=concat('drop table if exists  ',in_tbl_server_name_db,' ;');
prepare dynamic_drop_intermediate_history from @sql_drop_intermediate_history;
execute dynamic_drop_intermediate_history;
deallocate prepare dynamic_drop_intermediate_history;
end$$
DELIMITER ;
#This procedure inserts a global variable in a temporary table for each server.
drop procedure  if exists `assistant_dba`.`insert_global_var`;
DELIMITER $$
create procedure `assistant_dba`.`insert_global_var` (in db_server_name_list_db nvarchar(1024), in server_name_global_var nvarchar(1024), in in_server_id int, in in_variable_name varchar(64),in in_variable_value varchar(2048)) 
begin
set @db_name=db_server_name_list_db;
set @table_name1:=server_name_global_var;
set @in_server_id=in_server_id;
set @in_variable_name=in_variable_name;
set @in_variable_value=in_variable_value;
set @sql_exec:=concat('insert into  \`' ,@db_name, '\`.\`' ,@table_name1, '\` (server_id, variable_name, variable_value)
values(',@in_server_id,',"',@in_variable_name,'","',@in_variable_value,'")');
prepare dynamic_statement from @sql_exec;
execute dynamic_statement;
deallocate prepare dynamic_statement;
end$$
DELIMITER ;
#This procedure inserts a new global variables for MySQL server.
drop procedure  if exists `assistant_dba`.`check_global_var` ;
DELIMITER $$
create procedure `assistant_dba`.`check_global_var`(in db_server_name_list_db nvarchar(1024), in server_name_global_var nvarchar(1024), in in_server_id int) 
begin
set @in_server_id=in_server_id;
set @db_name=db_server_name_list_db; #"assistant_dba_temp"; #
set @table_name1:=server_name_global_var;#"dba_server_name_any_list_db"; #tbl_server_name_list_db;
#inserting a new global_var
set @sql_insert:=concat('if exists (select 1 
	from \`',@db_name,'\`.\`',@table_name1,'\` tts
	left join \`assistant_dba\`.\`list_mysql_glob_var\` as lmgv
	on tts.variable_name=lmgv.var_name and lmgv.server_id=',@in_server_id,'
	where lmgv.var_id_spr is null limit 1)
then 
	begin
		insert into `assistant_dba`.`list_mysql_glob_var`  (server_id, var_name)
		select tts.server_id, tts.variable_name
		FROM \`',@db_name,'\`.\`',@table_name1,'\` as tts
		left join `assistant_dba`.`list_mysql_glob_var`  as lmgv
		on tts.variable_name=lmgv.var_name and lmgv.server_id=',@in_server_id,'
		where lmgv.var_id_spr is null;
	end;
end if;');
prepare dynamic_insert from @sql_insert;
execute dynamic_insert;
deallocate prepare dynamic_insert;
set @sql_drop_intermediate:=concat('drop table if exists  \`',@db_name,'\`.\`',@table_name1,'\` ;');
prepare dynamic_drop_intermediate from @sql_drop_intermediate;
execute dynamic_drop_intermediate;
deallocate prepare dynamic_drop_intermediate;
end$$
DELIMITER ;
#This procedure gets a list of global variables for the MySQL server.
drop procedure  if exists `assistant_dba`.`get_list_global_var_spr` ;
DELIMITER $$
create procedure `assistant_dba`.`get_list_global_var_spr` ( in in_server_id int) 
begin
set @in_server_id=in_server_id;
SELECT lmgv.`var_id_spr`, lmgv.`server_id`, ls.`server_name`, lmgv.`var_name`
FROM `assistant_dba`.`list_mysql_glob_var` lmgv
join `assistant_dba`.`list_mysql_server` lms
on lms.server_id=lmgv.server_id
join `assistant_dba`.`list_server` ls
on ls.server_id=lms.server_id
where ls.alive=1 and lms.exclude_rost=0 and lmgv.server_id=@in_server_id ;
end$$
DELIMITER ;
#This procedure inserts values into a global variable in a temporary table for each MySQL server.
drop procedure  if exists `assistant_dba`.`insert_global_var_ext`;
DELIMITER $$
create procedure `assistant_dba`.`insert_global_var_ext` (in db_server_name_list_db nvarchar(1024), in server_name_global_var nvarchar(1024),in in_var_id_spr bigint, in in_server_id int, in in_variable_name varchar(64),in in_variable_value varchar(2048)) 
#call assistant_dba.insert_global_var_ext('$conn_db_main_temp','$tbl_server_name_global_var_ext', $var_id_spr, $server_id, '$variable_name','$variable_value')
begin
set @db_name=db_server_name_list_db;
set @table_name1:=server_name_global_var;
set @in_var_id_spr=in_var_id_spr;
set @in_server_id=in_server_id;
set @in_variable_name=in_variable_name;
set @in_variable_value=in_variable_value;
set @sql_exec:=concat('insert into  \`' ,@db_name, '\`.\`' ,@table_name1, '\` (server_id, var_id_spr,variable_name, variable_value)
values(',@in_server_id,',',@in_var_id_spr,',"',@in_variable_name,'","',@in_variable_value,'")');
prepare dynamic_statement from @sql_exec;
execute dynamic_statement;
deallocate prepare dynamic_statement;
end$$
DELIMITER ;
#This procedure inserts historical data about global variables.
drop procedure  if exists `assistant_dba`.`insert_history_global_var`;
DELIMITER $$
create procedure `assistant_dba`.`insert_history_global_var` ( in in_server_id int, in in_dba_conn_temp nvarchar(64))
begin
set @in_server_id=in_server_id;
set @in_dba_conn_temp=in_dba_conn_temp;
set @in_tbl_server_name_db=concat('',@in_dba_conn_temp,'.dba_',@in_server_id,'_global_var_ext');
set @sql_del_get_date:=concat('delete hmgv 
from \`assistant_dba\`.\`history_mysql_global_var\` hmgv 
join \`assistant_dba\`.\`list_mysql_glob_var\`  lmgv 
on lmgv.var_id_spr=hmgv.var_id_spr 
where lmgv.server_id=',@in_server_id,' and hmgv.data=curdate();'); 
select @sql_del_get_date;
prepare dynamic_del_get_date from @sql_del_get_date;
execute dynamic_del_get_date;
deallocate prepare dynamic_del_get_date;
set @sql_insert_history:=concat('INSERT INTO \`assistant_dba\`.\`history_mysql_global_var\` (var_id_spr,variable_value,data)
SELECT lmgv.var_id_spr,  t1.variable_value, curdate()
FROM ',@in_tbl_server_name_db,' t1
join \`assistant_dba\`.\`list_mysql_glob_var\` lmgv
on lmgv.var_id_spr= t1.var_id_spr and lmgv.server_id=t1.server_id;');
select @sql_insert_history;
prepare dynamic_insert_history from @sql_insert_history;
execute dynamic_insert_history;
deallocate prepare dynamic_insert_history;
set @sql_drop_intermediate:=concat('drop table if exists  ',@in_tbl_server_name_db,' ;');
prepare dynamic_drop_intermediate from @sql_drop_intermediate;
execute dynamic_drop_intermediate;
deallocate prepare dynamic_drop_intermediate;
end$$
DELIMITER ;
######################################
#module backup
#add backup path variable mysql
DELIMITER $$
CREATE PROCEDURE `assistant_dba`.`add_backup_path_variable_mysql`(in server_name_in varchar(255), path_backup_in nvarchar(2000), server_for_backup_in nvarchar(255), user_for_backup_in varchar(45) )
begin
set @sql_insert:=concat('INSERT INTO `assistant_dba`.`backup_path_variable_mysql` (server_id,path_backup,server_for_backup, user_for_backup )
VALUES ((select server_id from assistant_dba.list_server where server_name=''',server_name_in,'''), ''',path_backup_in,''', ''',server_for_backup_in,''', ''',user_for_backup_in,''');
');
prepare dynamic_insert from @sql_insert;
execute dynamic_insert;
deallocate prepare dynamic_insert;
end$$
DELIMITER ;
#add new backup task 
drop procedure  if exists `assistant_dba`.`add_backup_task_mysql`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`add_backup_task_mysql`(in server_name_in varchar(255), backup_type_description varchar(10), monday_in boolean,
tuesday_in boolean, wednesday_in boolean,thursday_in boolean,friday_in boolean,saturday_in boolean,sunday_in boolean, start_time_in time, interval_min_in int,
end_time_in time, enable_in boolean, storage_time_days_int int )
begin
declare speciality condition for sqlstate '45000';
#I checked interval min
set @check_interval_min_error=concat('This is interval_min for server : ', server_name_in ,' not valid. Change interval_min between 1 and 720.') ;  
if interval_min_in <0 or interval_min_in>720 then
	signal speciality set message_text = @check_interval_min_error;
end if;
#I checking the server_name in assistant_dba.list_server and it exists in assistant_dba.list_mysql_server.
set @check_server_name=''; #This is the variable needed to check the server_name.
set @check_server_name_error=concat('This is server : ', server_name_in ,' not registered in the system or is not mysql/mariadb.') ;
set @dyn_check_server_name =concat('select server_id into @check_server_name from assistant_dba.list_mysql_server 
where server_id =(select server_id from assistant_dba.list_server where server_name=''',server_name_in,''');');
prepare dynamic_check_server_name from @dyn_check_server_name;
execute dynamic_check_server_name;
deallocate prepare dynamic_check_server_name;
if @check_server_name='' or @check_server_name=null
	then  signal speciality set message_text = @check_server_name_error;
end if;    
#I checking the type of backups in assistant_dba.backup_type_mysql.
set @check_backup_type_description=''; #This is the variable needed to check the backup_type_description.
set @check_backup_type_description_error=concat('This is type  backup : ', backup_type_description ,' not exists in system .') ;
set @dyn_check_backup_type_description =concat('select backup_type_id into @check_backup_type_description from assistant_dba.backup_type_mysql where backup_type_description=''',backup_type_description,''';');
prepare dynamic_check_backup_type_description from @dyn_check_backup_type_description;
execute dynamic_check_backup_type_description;
deallocate prepare dynamic_check_backup_type_description;
if @check_backup_type_description='' or @check_server_name=null
	then signal speciality set message_text = @check_backup_type_description_error;
end if; 
#The full backup backup is done once a day, so interval_min_in always equals 0
if backup_type_description='full' 
	then set interval_min_in=0;
end if;
#When do you create a full backup task, always end_time_in must equal start_time_in.
if  start_time_in != end_time_in and backup_type_description='full'
	then set end_time_in=start_time_in;
end if;    
#You don't create diff and incr backup tasks if you had not created a full backup task
set @check_full_backup=''; #This is the variable needed to check if the task has a full backup.
set @dyn_check_full_backup:=concat('select bt_id into @check_full_backup from assistant_dba.backup_task_mysql where server_id=(
select server_id from assistant_dba.list_server where server_name=''',server_name_in,''' )
and backup_type_id=(select backup_type_id from assistant_dba.backup_type_mysql where backup_type_description=''full'') ; ');
prepare dynamic_check_full_backup from @dyn_check_full_backup;
execute dynamic_check_full_backup;
deallocate prepare dynamic_check_full_backup;
set @error_check_full_backup:= concat ('You don''t create diff and incr backup tasks if you had not created a full backup task for Server with the name : ', server_name_in ,'') ;
if backup_type_description!='FULL' and ( @check_full_backup='' or @check_full_backup = null)  then
       signal speciality set message_text = @error_check_full_backup;
end if;
#I checking in the table `assistant_dba`.`backup_path_variable_mysql` path for backup this is server
set @check_backup_path_variable_mysql='';
set @dyn_check_backup_path_variable_mysql:=concat('select server_id into @check_backup_path_variable_mysql from assistant_dba.backup_path_variable_mysql
where server_id=(select server_id from assistant_dba.list_server where server_name=''',server_name_in,'''  );');
prepare dynamic_check_backup_path_variable_mysql from @dyn_check_backup_path_variable_mysql;
execute dynamic_check_backup_path_variable_mysql;
deallocate prepare dynamic_check_backup_path_variable_mysql;
set @error_check_backup_path_variable_mysql:= concat ('You don''t create a backup task if you have not executed the assistant_dba.add_backup_path_variable_mysql for Server with the name : ', server_name_in ,'') ;
if  @check_backup_path_variable_mysql='' or @check_backup_path_variable_mysql is null  then
       signal speciality set message_text = @error_check_backup_path_variable_mysql;
end if;
set @sql_name_task=concat('',server_name_in,'_',backup_type_description,'');
set @sql_insert:=concat('INSERT INTO assistant_dba.backup_task_mysql(server_id, backup_task_name,
backup_type_id,
Monday,Tuesday,Wednesday,Thursday,Friday,Saturday,Sunday,
start_time,interval_min,end_time,enable,storage_time_days)
VALUES ((select server_id from assistant_dba.list_server where server_name=''',server_name_in,'''), 
''',@sql_name_task,''',
(select backup_type_id from assistant_dba.backup_type_mysql where backup_type_description=''',backup_type_description,'''), 
''',monday_in,''',''',tuesday_in,''',''',wednesday_in,''',''',thursday_in,''',''',friday_in,''',''',saturday_in,''',''',sunday_in,''', 
''',start_time_in,''',',interval_min_in,',''',end_time_in,''',',enable_in,',',storage_time_days_int,');');
prepare dynamic_insert from @sql_insert;
execute dynamic_insert;
deallocate prepare dynamic_insert;
end$$
DELIMITER ;
#Calculation of the next run of backup tasks
drop procedure  if exists `assistant_dba`.`task_scheduler_mysql`;
DELIMITER $$
CREATE  PROCEDURE `assistant_dba`.`task_scheduler_mysql`(in bt_id_in int, date_in datetime)
begin
#call assistant_dba.task_scheduler_mysql(1,'2023-06-10 17:37:21');
declare speciality condition for sqlstate '45000';
set @date_in1=date_in;
set @check_type_backup=(select btm1.backup_type_description from assistant_dba.backup_type_mysql btm1 join assistant_dba.backup_task_mysql btm2 on btm2.backup_type_id=btm1.backup_type_id where btm2.bt_id=bt_id_in);
###Full backup
if @check_type_backup='full' then
	set @check_run_1=0; #I checked founded value for next time start.
	#set @day_add=0; #I used for add count days
    set @day_add=0; #I used for add count days
		while @check_run_1 !=1 do
			set @day_add=@day_add+1;
			set @tomorrow_while_full=''; #I calculated next day of week start backup task full.
			set @stmt_tommorow_while_full:=concat( 'select dayname((''',@date_in1,''') + interval ', @day_add,' day) into @tomorrow_while_full ;'); 
			prepare dynamic_tommorow_while_full  from @stmt_tommorow_while_full;
			execute dynamic_tommorow_while_full ;
			deallocate prepare dynamic_tommorow_while_full;
			set @dyn_check_run_1 =concat('select ',@tomorrow_while_full,' into @check_run_1 from assistant_dba.backup_task_mysql where bt_id=',bt_id_in,' ;');
			prepare dynamic_check_run_1  from @dyn_check_run_1;
			execute dynamic_check_run_1 ;
			deallocate prepare dynamic_check_run_1;
		end while;
	set @next_time_full='';#I calculated next possible datetime start backup task full.
	set @stmt_next_time_full:=concat( 'select ((''',@date_in1,''') + interval ', @day_add,' day) into @next_time_full ;');
	prepare dynamic_next_time_full  from @stmt_next_time_full;
	execute dynamic_next_time_full ;
	deallocate prepare dynamic_next_time_full;
	set @next_time_time_full=(select start_time from assistant_dba.backup_task_mysql where bt_id=bt_id_in);
	set @next_time_end_full='';
	set @dyn_next_time_end_full:=concat('select date(@next_time_full) ''',@next_time_time_full,''' into @next_time_end_full;');
	prepare dynamic_next_time_end_full  from @dyn_next_time_end_full;
	execute dynamic_next_time_end_full ;
	deallocate prepare dynamic_next_time_end_full;
	set @dyn_next_time_end1_full:=concat(@next_time_end_full,' ',@next_time_time_full);#I calculated end next datetime start backup task full.
    select 'This is backup task: ',@check_type_backup as 'backup type', bt_id_in ,@dyn_next_time_end1_full as 'next datetime run sch' ;
	update assistant_dba.backup_task_mysql
	set next_time=@dyn_next_time_end1_full
	where bt_id=bt_id_in;
end if;
#####Diff backup
if @check_type_backup='diff' then
#I checked if there was a last_time full backup. If you didn't  comply  full backup or last_time is null, diff backup won't start.
	set @full_last_time=(select last_time from assistant_dba.backup_task_mysql
	where bt_id=(select bt_id from assistant_dba.backup_task_mysql where 
	backup_type_id=(select backup_type_id from assistant_dba.backup_type_mysql where backup_type_description='full'
	and server_id=(select server_id from assistant_dba.backup_task_mysql where bt_id=bt_id_in))));
	set @server_name=(select server_name from assistant_dba.list_server where server_id=(select server_id from assistant_dba.backup_task_mysql where bt_id=bt_id_in));
	set @error_full_last_time:=concat('You cannot start diff backup on server: ',@server_name,' bt_id:',bt_id_in,', because you haven''t run a full backup before. ');
	if @full_last_time='' or @full_last_time  is null then 
		update  assistant_dba.backup_task_mysql
		set next_time=null
		where bt_id=bt_id_in;
        select @error_full_last_time;
	else
	#This block calculates the possible maximum time to start a diff backup today.
	set @today_diff=(select dayname(@date_in1)); #I checked today's day name.
	set @check_today_run_diff=''; #I checked to see if the diff backup task would run again today
	set @stmt_check_today_run_diff:=concat('select ',@today_diff,' into @check_today_run_diff from assistant_dba.backup_task_mysql where bt_id=',bt_id_in,'');
	prepare dynamic_check_today_run_diff  from @stmt_check_today_run_diff;
	execute dynamic_check_today_run_diff ;
	deallocate prepare dynamic_check_today_run_diff;
    set @end_time_diff_sch=''; #This is only the time equal to end_time for diff backup.
    set @stmt_end_time_diff_sch:=concat('select end_time into @end_time_diff_sch from assistant_dba.backup_task_mysql where bt_id=',bt_id_in,'');
	prepare dynamic_end_time_diff_sch  from @stmt_end_time_diff_sch;
	execute dynamic_end_time_diff_sch ;
	deallocate prepare dynamic_end_time_diff_sch;
	set @input_time=time(@date_in1);
 #If you get time today for more end_time task, then next datetime run diff backup task in the schedule.   
 	set @diff_interval_min_chek0=(select interval_min from assistant_dba.backup_task_mysql where bt_id=bt_id_in );
	if @diff_interval_min_chek0=0 then 
		set @diff_interval_min=1440; #if  interval_min=0 and tasks run today then I calculated interval_min=1440
    end if;    
    if @check_today_run_diff=1 and @input_time>=@end_time_diff_sch then
    set @check_today_run_diff=0;
    end if; 
	if @check_today_run_diff=0 then
		set @check_run_1_diff=0; #I checked founded value for next time start.
		set @day_add_diff=0; #I used for add count days
		while @check_run_1_diff !=1 do
			set @day_add_diff=@day_add_diff+1;
			set @tomorrow_while_diff=''; #I calculated next time start backup task full or diff.
			set @stmt_tommorow_while:=concat( 'select dayname((@date_in1) + interval ', @day_add_diff,' day) into @tomorrow_while_diff ;');
			prepare dynamic_tommorow_while_diff  from @stmt_tommorow_while;
			execute dynamic_tommorow_while_diff ;
			deallocate prepare dynamic_tommorow_while_diff;
			set @stmt_check_run_1_diff =concat('select ',@tomorrow_while_diff,' into @check_run_1_diff from assistant_dba.backup_task_mysql where bt_id=',bt_id_in,' ;');
			prepare dynamic_check_run_1_diff  from @stmt_check_run_1_diff;
			execute dynamic_check_run_1_diff ;
			deallocate prepare dynamic_check_run_1_diff;
		end while;
		set @next_time_time_diff_sch=(select start_time from assistant_dba.backup_task_mysql where bt_id=bt_id_in);
		set @next_time_date_diff_sch='';
		set @stmt_next_time_date_diff_sch:=concat('select ((@date_in1)+ interval ', @day_add_diff,' day ) into @next_time_date_diff_sch;');
		prepare dynamic_next_time_date_diff_sch  from @stmt_next_time_date_diff_sch;
		execute dynamic_next_time_date_diff_sch ;
		deallocate prepare dynamic_next_time_date_diff_sch;
		set @next_time_datetime_diff_sch=concat(date(@next_time_date_diff_sch), ' ',@next_time_time_diff_sch);
		update assistant_dba.backup_task_mysql 
		set next_time=@next_time_datetime_diff_sch
		where bt_id=bt_id_in;
        select 'This is backup task: ',@check_type_backup as 'backup type', bt_id_in , @next_time_date_diff_sch as 'next datetime run sch' ;
	end if;
	if @check_today_run_diff=1 then
		set @check_run_1_diff=0; #I checked founded value for next time start.
		set @day_add_diff=0; #I used for add count days
		set @diff_interval_min=(select interval_min from assistant_dba.backup_task_mysql where bt_id=bt_id_in );
		if @diff_interval_min=0 then 
			set @diff_interval_min=1440; #if  interval_min=0 and tasks run today then I calculated interval_min=1440
        end if;    
		set @time_diff_start=''; #time start diff backup task
		set @dyn_time_diff_start:=concat('select start_time into @time_diff_start from assistant_dba.backup_task_mysql where bt_id=',bt_id_in,' ;');
		prepare dynamic_time_diff_start  from @dyn_time_diff_start;
		execute dynamic_time_diff_start ;
		deallocate prepare dynamic_time_diff_start;
		set @datetime_diff_start='';#datetime start diff backup
        set @datetime_diff_start=concat(date(@date_in1), ' ',@time_diff_start);
        #select @datetime_diff_start;
		set @datetime_diff_start_sch='';#I checked new datetime in schedule
		set @datetime_diff_start_sch=@datetime_diff_start;
		while @datetime_diff_start_sch<@date_in1 do
		set @smtm_datetime_diff_start_sch:=concat('select date_add(''',@datetime_diff_start_sch,''', INTERVAL ',@diff_interval_min,' MINUTE) into @datetime_diff_start_sch;');
		prepare dynamic_datetime_diff_start_new  from @smtm_datetime_diff_start_sch;
		execute dynamic_datetime_diff_start_new ;
		deallocate prepare dynamic_datetime_diff_start_new;
		end while;
   		update assistant_dba.backup_task_mysql 
		set next_time=@datetime_diff_start_sch
		where bt_id=bt_id_in;
		select 'This is backup task: ',@check_type_backup as 'backup type', bt_id_in , @datetime_diff_start_sch as 'next datetime run sch' ;
	end if;
	end if;  
end if;
#####log backup
if @check_type_backup='incr' then
#I checked if there was a last_time full backup. If you didn't  comply  full backup or last_time is null, log backup won't start.
	set @full_last_time=(select last_time from assistant_dba.backup_task_mysql
	where bt_id=(select bt_id from assistant_dba.backup_task_mysql where 
	backup_type_id=(select backup_type_id from assistant_dba.backup_type_mysql where backup_type_description='full'
	and server_id=(select server_id from assistant_dba.backup_task_mysql where bt_id=bt_id_in))));
	set @server_name=(select server_name from assistant_dba.list_server where server_id=(select server_id from assistant_dba.backup_task_mysql where bt_id=bt_id_in));
	set @error_full_last_time:=concat('You cannot start log backup on server: ',@server_name,' bt_id:',bt_id_in,', because you haven''t run a full backup before. ');
	if @full_last_time='' or @full_last_time  is null then 
		update  assistant_dba.backup_task_mysql
		set next_time=null
		where bt_id=bt_id_in;
        select @error_full_last_time;
	else
	#This block calculates the possible maximum time to start a log backup today.
	set @today_log=(select dayname(@date_in1)); #I checked today's day name.
	set @check_today_run_log=''; #I checked to see if the log backup task would run again today
	set @stmt_check_today_run_log:=concat('select ',@today_log,' into @check_today_run_log from assistant_dba.backup_task_mysql where bt_id=',bt_id_in,'');
	prepare dynamic_check_today_run_log  from @stmt_check_today_run_log;
	execute dynamic_check_today_run_log ;
	deallocate prepare dynamic_check_today_run_log;
    set @end_time_log_sch=''; #This is only the time equal to end_time for log backup.
    set @stmt_end_time_log_sch:=concat('select end_time into @end_time_log_sch from assistant_dba.backup_task_mysql where bt_id=',bt_id_in,'');
	prepare dynamic_end_time_log_sch  from @stmt_end_time_log_sch;
	execute dynamic_end_time_log_sch ;
	deallocate prepare dynamic_end_time_log_sch;
	set @input_time=time(@date_in1);
 #If get time today more end time tasks, then next datetime run log backup task in scheduler.   
    if @check_today_run_log=1 and @input_time>=@end_time_log_sch then
    set @check_today_run_log=0;
    end if; 
	if @check_today_run_log=0 then
		set @check_run_1_log=0; #I checked founded value for next time start.
		set @day_add_log=0; #I used for add count days
		while @check_run_1_log !=1 do
			set @day_add_log=@day_add_log+1;
			set @tomorrow_while_log=''; #I calculated next time start backup task full or log.
			set @stmt_tommorow_while:=concat( 'select dayname((@date_in1) + interval ', @day_add_log,' day) into @tomorrow_while_log ;');
			prepare dynamic_tommorow_while_log  from @stmt_tommorow_while;
			execute dynamic_tommorow_while_log ;
			deallocate prepare dynamic_tommorow_while_log;
			set @stmt_check_run_1_log =concat('select ',@tomorrow_while_log,' into @check_run_1_log from assistant_dba.backup_task_mysql where bt_id=',bt_id_in,' ;');
			prepare dynamic_check_run_1_log  from @stmt_check_run_1_log;
			execute dynamic_check_run_1_log ;
			deallocate prepare dynamic_check_run_1_log;
		end while;
		set @next_time_time_log_sch=(select start_time from assistant_dba.backup_task_mysql where bt_id=bt_id_in);
		set @next_time_date_log_sch='';
		set @stmt_next_time_date_log_sch:=concat('select ((@date_in1)+ interval ', @day_add_log,' day ) into @next_time_date_log_sch;');
		prepare dynamic_next_time_date_log_sch  from @stmt_next_time_date_log_sch;
		execute dynamic_next_time_date_log_sch ;
		deallocate prepare dynamic_next_time_date_log_sch;
		set @next_time_datetime_log_sch=concat(date(@next_time_date_log_sch), ' ',@next_time_time_log_sch);
		update assistant_dba.backup_task_mysql 
		set next_time=@next_time_datetime_log_sch
		where bt_id=bt_id_in;
		select 'This is backup task: ',@check_type_backup as 'backup type', bt_id_in ,@next_time_datetime_log_sch as 'next datetime run sch' ;
	end if;
	if @check_today_run_log=1 then
		set @check_run_1_log=0; #I checked founded value for next time start.
		set @day_add_log=0; #I used for add count days
		set @log_interval_min=(select interval_min from assistant_dba.backup_task_mysql where bt_id=bt_id_in );
   		if @log_interval_min=0 then 
			set @log_interval_min=60; #if  interval_min=0 and tasks run today then I calculated interval_min=60
        end if;    
		set @time_log_start=''; #time start log backup task
		set @dyn_time_log_start:=concat('select start_time into @time_log_start from assistant_dba.backup_task_mysql where bt_id=',bt_id_in,' ;');
		prepare dynamic_time_log_start  from @dyn_time_log_start;
		execute dynamic_time_log_start ;
		deallocate prepare dynamic_time_log_start;
		set @datetime_log_start='';#datetime start log backup
        set @datetime_log_start=concat(date(@date_in1), ' ',@time_log_start);
        #select @datetime_log_start;
		set @datetime_log_start_sch='';#I checked new datetime in scheduler
		set @datetime_log_start_sch=@datetime_log_start;
		while @datetime_log_start_sch<@date_in1 do
		set @smtm_datetime_log_start_sch:=concat('select date_add(''',@datetime_log_start_sch,''', INTERVAL ',@log_interval_min,' MINUTE) into @datetime_log_start_sch;');
		prepare dynamic_datetime_log_start_new  from @smtm_datetime_log_start_sch;
		execute dynamic_datetime_log_start_new ;
		deallocate prepare dynamic_datetime_log_start_new;
		end while;
   		update assistant_dba.backup_task_mysql 
		set next_time=@datetime_log_start_sch
		where bt_id=bt_id_in;
		#select 'run today', @log_interval_min,@date_in1,@time_log_start, @datetime_log_start, @datetime_log_start_sch;
		select 'This is backup task: ',@check_type_backup as 'backup type', bt_id_in ,@datetime_log_start_sch as 'next datetime run sch' ;
	end if;   
    end if;
end if;
end$$
DELIMITER ;
#Adding backup tasks to the table for running tasks.
drop procedure  if exists `assistant_dba`.`queue_task_mysql`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`queue_task_mysql`()
begin
#call assistant_dba.queue_task_mysql();
declare speciality condition for sqlstate '45000';
declare done int default 0;
declare bt_id_cur int;
set @date_in=now();
set @count_probably_full_tasks_for_run=0;#Counting  tasks full backups ready to start 
set @count_probably_diff_log_tasks_for_run=0;#Counting  tasks diff and log backups ready to start
set @count_probably_full_tasks_for_run=(select count(bt_id) from  assistant_dba.backup_task_mysql btm where btm.enable=1 and (btm.next_time<=@date_in or btm.next_time is null) and btm.backup_type_id= (select backup_type_id from assistant_dba.backup_type_mysql where backup_type_description in ('full')) );
set @count_probably_diff_log_tasks_for_run=(
	select  count(t1.bt_id)
	#from (select btm1.* from assistant_dba.backup_task_mysql btm1 where btm1.enable=1 and btm1.next_time<=@date_in ) as t1 
    from (select btm1.* from assistant_dba.backup_task_mysql btm1 where btm1.enable=1 and (btm1.next_time<=@date_in or btm1.next_time is null) ) as t1 
	join assistant_dba.backup_task_mysql t2
	on t2.server_id=t1.server_id  and t2.backup_type_id!=t1.backup_type_id and t2.enable=1 and t1.enable=1
	where t2.last_time is not null and t2.backup_type_id= (select backup_type_id from assistant_dba.backup_type_mysql where backup_type_description in ('full'))
	);
if @count_probably_full_tasks_for_run >0 or @count_probably_diff_log_tasks_for_run>0 then
begin
    DECLARE bt_id_for_run_cursor CURSOR FOR 
        select btm.bt_id as bt_id_cur from  assistant_dba.backup_task_mysql btm 
  		where btm.enable=1 and (btm.next_time<=@date_in or btm.next_time is null) and btm.backup_type_id= (select backup_type_id from assistant_dba.backup_type_mysql where backup_type_description in ('full')) 
        #where btm.enable=1 and (btm.next_time<=@date_in or btm.next_time is null)
		union 
		select  t1.bt_id as bt_id_cur
		#from (select btm1.* from assistant_dba.backup_task_mysql btm1 where btm1.enable=1 and btm1.next_time<=@date_in) as t1 
        from (select btm1.* from assistant_dba.backup_task_mysql btm1 where btm1.enable=1 and (btm1.next_time<=@date_in or btm1.next_time is null) ) as t1  
		join assistant_dba.backup_task_mysql t2
		on t2.server_id=t1.server_id  and t2.backup_type_id!=t1.backup_type_id and t2.enable=1 and t1.enable=1
		where t2.last_time is not null and t2.backup_type_id= (select backup_type_id from assistant_dba.backup_type_mysql where backup_type_description in ('full'));
	DECLARE CONTINUE HANDLER FOR SQLSTATE '02000' set done=1;
	DECLARE CONTINUE HANDLER FOR SQLSTATE '23000' set done=1;
	open bt_id_for_run_cursor;
   FETCH bt_id_for_run_cursor INTO bt_id_cur;
		while done=0 do
			insert into assistant_dba.backup_task_run_mysql (bt_id,creat_time,wait_task_id,enable)
            select  bt_id_cur,@date_in, (select btrm.task_id from assistant_dba.backup_task_run_mysql btrm
			join  assistant_dba.backup_task_mysql btm
			on btm.bt_id=btrm.bt_id
			where btm.bt_id=bt_id_cur or 
			btm.server_id in (select server_id from assistant_dba.backup_task_mysql where bt_id=bt_id_cur ) 
			order by task_id desc limit 1) as wait_task_id,1
			from assistant_dba.backup_task_mysql btm limit 1;
            call assistant_dba.task_scheduler_mysql (bt_id_cur,@date_in);
		FETCH bt_id_for_run_cursor INTO bt_id_cur;
		end while;
    CLOSE bt_id_for_run_cursor;
end;  
end if;
end$$
DELIMITER ;
#Selecting backup tasks to execute.
drop procedure  if exists `assistant_dba`.`run_task_mysql`;
DELIMITER $$
CREATE PROCEDURE `assistant_dba`.`run_task_mysql`(in check_count TINYINT(1))
begin
declare speciality condition for sqlstate '45000';
set @start_time_null=0 ; #Count tasks waiting on a queue to start.
set @start_time_n_null_task_progress_null=0; #Count the tasks that are running.
set @start_time_n_null_task_progress_null=(select count(bt_id) from assistant_dba.backup_task_run_mysql where start_time is not null and task_progress is not null );
set @start_time_null=(select count(bt_id) from assistant_dba.backup_task_run_mysql where start_time is null);
set @in_check_count=check_count;
set @error_check_count:= concat ('The parameter @check_count can equals 0 or 1 ') ;
if @in_check_count!=0 and @in_check_count!=1 then
       signal speciality set message_text = @error_check_count;
end if;
if @start_time_null >0 or @start_time_n_null_task_progress_null<60 then
if @in_check_count=0 then
	set @sql_exec:=concat('select  count(btrm.task_id)
				from assistant_dba.backup_task_run_mysql btrm
				join assistant_dba.backup_task_mysql btm
				on btm.bt_id=btrm.bt_id
				join assistant_dba.list_mysql_server lms
				on lms.server_id=btm.server_id
				join assistant_dba.list_server ls
				on ls.server_id=lms.server_id
				join assistant_dba.backup_path_variable_mysql bpvm
				on bpvm.server_id=btm.server_id
				join assistant_dba.backup_type_mysql btm1
				on btm1.backup_type_id=btm.backup_type_id
				where btrm.start_time is null and btrm.enable=1 and btrm.wait_task_id is null and task_progress is null order by btrm.task_id ;
	');
	prepare dynamic_statement from @sql_exec;
	execute dynamic_statement;
	deallocate prepare dynamic_statement;
end if;
if  @in_check_count=1 then
select  btrm.task_id, btrm.bt_id, btm1.backup_type_description,
		replace(btrm.creat_time,' ','T'),  
        if(length(btrm.wait_task_id)=0 , null,btrm.wait_task_id) as wait_task_id, 
        btrm.enable, 
	if(length(btrm.file_log)=0 , null,btrm.file_log) as file_log,
	ls.server_id, ls.server_name, lms.version, ls.ip, backup_task_name, 
	if(length(bpvm.path_backup)=0 , null,bpvm.path_backup) as path_backup,
	if(length(bpvm.path_last_backup)=0 , null,bpvm.path_last_backup) as path_last_backup,
        if(length(bpvm.path_last_full_backup)=0 , null,bpvm.path_last_full_backup) as path_last_full_backup, 
	if(length(bpvm.path_last_incr_backup)=0 , null,bpvm.path_last_incr_backup) as path_last_incr_backup, 
	bpvm.server_for_backup,  
	bpvm.user_for_backup, 
        if(length(bpvm.process_last_full_backup)=0 , null,bpvm.process_last_full_backup) as process_last_full_backup,  
	if(length(bpvm.prepare_last_full_backup)=0 , null,bpvm.prepare_last_full_backup) as prepare_last_full_backup,   
	if(length(bpvm.process_last_incr_backup)=0 , null,bpvm.process_last_incr_backup) as process_last_incr_backup,    
	if(length(bpvm.prepare_last_incr_backup)=0 , null,bpvm.prepare_last_incr_backup) as prepare_last_incr_backup   
			from assistant_dba.backup_task_run_mysql btrm
			join assistant_dba.backup_task_mysql btm
			on btm.bt_id=btrm.bt_id
            join assistant_dba.list_mysql_server lms
            on lms.server_id=btm.server_id
            join assistant_dba.list_server ls
            on ls.server_id=lms.server_id
            join assistant_dba.backup_path_variable_mysql bpvm
            on bpvm.server_id=btm.server_id
            join assistant_dba.backup_type_mysql btm1
            on btm1.backup_type_id=btm.backup_type_id
            where btrm.start_time is null and btrm.enable=1 and btrm.wait_task_id is null and task_progress is null order by btrm.task_id ;
end if;
end if;
end$$
DELIMITER ;
#Update start time all  task=task_id
drop procedure  if exists `assistant_dba`.`upd_btrm_start_time`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btrm_start_time`(in_task_id bigint, in_start_time datetime)
#CALL `assistant_dba`.`upd_btrm_start_time`(1,'2024-01-18 13:46:47');
begin
update  `assistant_dba`.`backup_task_run_mysql`
set start_time=in_start_time
where task_id=in_task_id;
end$$
DELIMITER ;
#Update start time backup  task=task_id
drop procedure  if exists `assistant_dba`.`upd_btrm_start_time_backup`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btrm_start_time_backup`(in_task_id bigint, in_start_time_backup datetime)
#CALL `assistant_dba`.`upd_btrm_start_time_backup`(1,'2024-01-18 13:46:47');
begin
update  `assistant_dba`.`backup_task_run_mysql`
set start_time_backup=in_start_time_backup
where task_id=in_task_id;
end$$
DELIMITER ;
#Update end time backup  task=task_id
drop procedure  if exists `assistant_dba`.`upd_btrm_end_time_backup`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btrm_end_time_backup`(in_task_id bigint, in_end_time_backup datetime)
#CALL `assistant_dba`.`upd_btrm_end_time_backup`(1,'2024-01-18 13:46:47');
begin
update  `assistant_dba`.`backup_task_run_mysql`
set end_time_backup=in_end_time_backup
where task_id=in_task_id;
end$$
DELIMITER ;
#Update end time all  task=task_id
drop procedure  if exists `assistant_dba`.`upd_btrm_end_time`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btrm_end_time`(in_task_id bigint, in_end_time datetime)
#CALL `assistant_dba`.`upd_btrm_end_time`(1,'2024-01-18 13:46:47');
begin
update  `assistant_dba`.`backup_task_run_mysql`
set end_time=in_end_time
where task_id=in_task_id;
end$$
DELIMITER ;
#Update file_log  task=task_id
drop procedure  if exists `assistant_dba`.`upd_btrm_file_log`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btrm_file_log`(in_task_id bigint, in_file_log varchar(300))
#CALL `assistant_dba`.`upd_btrm_file_log`(1,'2024-01-18 13:46:47');
begin
update  `assistant_dba`.`backup_task_run_mysql`
set file_log=in_file_log
where task_id=in_task_id;
end$$
DELIMITER ;
#Update task_progress  task=task_id
drop procedure  if exists `assistant_dba`.`upd_btrm_task_progress`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btrm_task_progress`(in_task_id bigint, in_task_progress decimal(5,2))
#CALL `assistant_dba`.`upd_btrm_task_progress`(1,-99);
begin
update  `assistant_dba`.`backup_task_run_mysql`
set task_progress=in_task_progress
where task_id=in_task_id;
end$$
DELIMITER ;
#Update start_time_prepare  task=task_id
drop procedure  if exists `assistant_dba`.`upd_btrm_start_time_prepare`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btrm_start_time_prepare`(in_task_id bigint, in_start_time_prepare datetime)
#CALL `assistant_dba`.`upd_btrm_start_time_prepare`(1,'2024-01-18 13:46:47');
begin
update  `assistant_dba`.`backup_task_run_mysql`
set start_time_prepare=in_start_time_prepare
where task_id=in_task_id;
end$$
DELIMITER ;
#Update end_time_prepare  task=task_id
drop procedure  if exists `assistant_dba`.`upd_btrm_end_time_prepare`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btrm_end_time_prepare`(in_task_id bigint, in_end_time_prepare datetime)
#CALL `assistant_dba`.`upd_btrm_end_time_prepare`(1,'2024-01-18 13:46:47');
begin
update  `assistant_dba`.`backup_task_run_mysql`
set end_time_prepare=in_end_time_prepare
where task_id=in_task_id;
end$$
DELIMITER ;
#Moving the row bt_id from backup_task_run_mysql to backup_task_log_mysql.
drop procedure  if exists `assistant_dba`.`backup_tasks_move_from_run_to_log`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`backup_tasks_move_from_run_to_log`(in_task_id bigint)
#call assistant_dba.backup_tasks_move_from_run_to_log(1);
begin
start transaction;
insert into `assistant_dba`.`backup_task_log_mysql` (`task_id`, `bt_id`, `creat_time`, `start_time`, `start_time_backup`,
`end_time_backup`, `start_time_prepare`, `end_time_prepare`, `end_time`, `wait_task_id`, `task_progress`, `enable`, `file_log`)
select `task_id`, `bt_id`, `creat_time`, `start_time`, `start_time_backup`,
`end_time_backup`, `start_time_prepare`, `end_time_prepare`, `end_time`, `wait_task_id`, `task_progress`, `enable`, `file_log`
from `assistant_dba`.`backup_task_run_mysql` 
where task_id=(in_task_id) for update;
delete from assistant_dba.backup_task_run_mysql
where task_id=(in_task_id);
commit work;
end$$
DELIMITER ;
#Update path_last_full_backup.
drop procedure  if exists `assistant_dba`.`upd_bpvm_path_last_full_backup`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_bpvm_path_last_full_backup`(in_server_id int, in_path_last_full_backup varchar(2000))
#call assistant_dba.backup_tasks_move_from_run_to_log(1);
begin
update `assistant_dba`.`backup_path_variable_mysql`
set path_last_full_backup=in_path_last_full_backup
where server_id=in_server_id;
end$$
DELIMITER ;
#Update wait_task_id.
drop procedure  if exists `assistant_dba`.`upd_btrm_wait_task_id`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btrm_wait_task_id`(in_task_id bigint)
#call assistant_dba.backup_tasks_move_from_run_to_log(1);
begin
update assistant_dba.backup_task_run_mysql
set wait_task_id=null
where wait_task_id=in_task_id;
end$$
DELIMITER ;
#Get path_last_full_backup 
drop procedure  if exists `assistant_dba`.`get_bpvm_path_last_full_backup`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`get_bpvm_path_last_full_backup`(in_server_id int)
#CALL `assistant_dba`.`upd_btrm_start_time_backup`(1,'2024-01-19 13:46:47');
begin
SELECT path_last_full_backup    
FROM `assistant_dba`.`backup_path_variable_mysql`
where server_id=in_server_id;
end$$
DELIMITER ;
#Update path_last_incr_backup
drop procedure  if exists `assistant_dba`.`upd_bpvm_path_last_incr_backup`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_bpvm_path_last_incr_backup`(in_server_id int, in_path_last_incr_backup varchar(2000))
begin
update `assistant_dba`.`backup_path_variable_mysql`
set path_last_incr_backup=in_path_last_incr_backup
where server_id=in_server_id;
end$$
DELIMITER ;
#Update path_last_full_backup in backup_task_log_mysql
drop procedure  if exists `assistant_dba`.`upd_btlm_path_last_full_backup`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btlm_path_last_full_backup`(in_task_id bigint, in_path_last_full_backup varchar(2000))
begin
update `assistant_dba`.`backup_task_log_mysql`
set path_last_full_backup=in_path_last_full_backup
where task_id=in_task_id;
end$$
DELIMITER ;
#Update path_old_incr_backup in backup_task_log_mysql
drop procedure  if exists `assistant_dba`.`upd_btlm_path_old_incr_backup`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btlm_path_old_incr_backup`(in_task_id bigint, in_path_old_incr_backup varchar(2000))
begin
update `assistant_dba`.`backup_task_log_mysql`
set path_old_incr_backup=in_path_old_incr_backup
where task_id=in_task_id;
end$$
DELIMITER ;
#Update path_cur_incr_backup in backup_task_log_mysql
drop procedure  if exists `assistant_dba`.`upd_btlm_path_cur_incr_backup`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btlm_path_cur_incr_backup`(in_task_id bigint, in_path_cur_incr_backup varchar(2000))
begin
update `assistant_dba`.`backup_task_log_mysql`
set path_cur_incr_backup=in_path_cur_incr_backup
where task_id=in_task_id;
end$$
DELIMITER ;
#Update path_diff_backup in backup_task_log_mysql
drop procedure  if exists `assistant_dba`.`upd_btlm_path_diff_backup`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btlm_path_diff_backup`(in_task_id bigint, in_path_diff_backup varchar(2000))
begin
update `assistant_dba`.`backup_task_log_mysql`
set path_diff_backup=in_path_diff_backup
where task_id=in_task_id;
end$$
DELIMITER ;
#Update last_time in backup_task_mysql
drop procedure  if exists `assistant_dba`.`upd_btm_last_time`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`upd_btm_last_time`(in_bt_id int)
begin
update `assistant_dba`.`backup_task_mysql`
set last_time=now()
where bt_id=in_bt_id;
end$$
DELIMITER ;
#compare_version_mariabackup
drop procedure  if exists `assistant_dba`.`compare_version_mariabackup`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`compare_version_mariabackup`(in_version_number_db varchar(20), in_version_number_sb varchar(20))
begin
with value_sb as (
select vmmm.id_major_minor 
from `assistant_dba`.`version_major_minor_mariadb` vmmm
join `assistant_dba`.`version_compability_mariadb` vcm
on vcm.id_major_minor=vmmm.id_major_minor
where vcm.version_number= in_version_number_sb),
value_db as (
select vmmm.id_major_minor 
from `assistant_dba`.`version_major_minor_mariadb` vmmm
join `assistant_dba`.`version_compability_mariadb` vcm
on vcm.id_major_minor=vmmm.id_major_minor
where vcm.version_number= in_version_number_db)
SELECT EXISTS(SELECT value_sb.id_major_minor, value_db.id_major_minor FROM value_sb join value_db on value_db.id_major_minor=value_sb.id_major_minor) as result;
end$$
DELIMITER ;
#add version number major_minor_mariadb
drop procedure  if exists `assistant_dba`.`add_version_major_minor_mariadb`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`add_version_major_minor_mariadb`(in_version_number_db varchar(10))
begin
insert into `assistant_dba`.`version_major_minor_mariadb` (version_number) values (in_version_number_db);
end$$
DELIMITER ;
#add version number major_minor_mariadb
drop procedure  if exists `assistant_dba`.`add_version_compability_mariadb`;
DELIMITER $$
create PROCEDURE `assistant_dba`.`add_version_compability_mariadb`(in_version_number_all varchar(20), in_version_number_mm varchar(10))
begin
insert into `assistant_dba`.`version_compability_mariadb` (version_number,id_major_minor) 
values (in_version_number_all, (select id_major_minor from assistant_dba.version_major_minor_mariadb where version_number=in_version_number_mm));
end$$
DELIMITER ;

