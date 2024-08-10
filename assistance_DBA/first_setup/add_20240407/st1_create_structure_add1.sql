#module permissions
#This table stores the users from all MySQL server.
#In MariaDB there is sign which can distinguish role and user.
#In MySQL impossible exactly distinguish  role and user.
#In MySQL I can execute follow script 
#mysql>create user 'user_test1';
#mysql>alter user 'user_test2' account lock;
#mysql>create role 'role_test1';
#When I executed script 
#mysql> select user, host, authentication_string, account_locked from mysql.user
#mysql> where user in ('role_test1','user_test2');
#I'll get the result
# user	        |host	|authentication_string	|account_locked |password_expired
#role_test1	    |%		|                       |Y              |Y
#user_test1	    |%		|                       |Y              |Y
#For the MySQL/Percona in the column  `is_role` always been value 'E' until I can't exactly distinguish  role and user.
#I corrected the structure this is column `is_role` in the table. 
alter TABLE `assistant_dba`.`list_mysql_users` MODIFY COLUMN `is_role` VARCHAR(1) NULL default 'E';
ALTER TABLE `assistant_dba`.`list_mysql_users` CHANGE COLUMN `user` `user` CHAR(32) NOT NULL ;

#The table stores historical data about privileges for users on the database server MySQL.
#drop table if exists `assistant_dba`.`history_mysql_privileges`;
create table `assistant_dba`.`history_mysql_privileges`
(
`id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
`server_id` int UNSIGNED not null,
`user` char (32) not null,
`host` char(255) null,
`base_name` varchar(64) not null,
`table_name` varchar(64) not null,
`column_name`  varchar(64) not null,
`role_name` char (32) not null,
`role_name_host` char(255) null,
`grant_admin_role` char(5) not null,
`grant_stmt` longtext,
`data` date,
PRIMARY KEY (`id`),
key `ix_server_id_data_user` (`server_id` ASC, `data` ASC, `user` ASC) VISIBLE,
 CONSTRAINT `FK_history_mysql_privileges_mysql_server_idx`
  FOREIGN KEY (`server_id`)
  REFERENCES `assistant_dba`.`list_mysql_server` (`server_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
);

#The table stores historical data about privileges for users on the database server MariaDB.
#drop table if exists `assistant_dba`.`history_mariadb_privileges`;
create table `assistant_dba`.`history_mariadb_privileges`
(
`id` bigint UNSIGNED NOT NULL AUTO_INCREMENT,
`server_id` int UNSIGNED not null,
`user` char (32) not null,
`host` char(255) null,
`base_name` varchar(64) not null,
`table_name` varchar(64) not null,
`column_name`  varchar(64) not null,
`role_name` char (32) not null,
`grant_admin_role` char(5) not null,
`grant_stmt` longtext,
`data` date,
PRIMARY KEY (`id`),
key `ix_server_id_data_user` (`server_id` ASC, `data` ASC, `user` ASC) VISIBLE,
 CONSTRAINT `FK_history_mariadb_privileges_mysql_server_idx`
  FOREIGN KEY (`server_id`)
  REFERENCES `assistant_dba`.`list_mysql_server` (`server_id`)
  ON DELETE NO ACTION
  ON UPDATE NO ACTION
);



##procedure get alive servers mysql for module permissions 
DELIMITER $$
CREATE PROCEDURE  `assistant_dba`.`get_alive_users_server_mysql`()
begin
SELECT ls.server_id,ls.server_name,ls.connection_string,ls.ip,lms.port, lms.version
FROM `assistant_dba`.`list_server` ls
join `assistant_dba`.`list_mysql_server` lms
on lms.server_id=ls.server_id
where ls.alive=1 and lms.exclude_rost=0 and lms.exclude_users=0;
end$$
DELIMITER ;

#procedure insert-update information about users
drop procedure  if exists  `assistant_dba`.`check_users` ;
DELIMITER $$
create procedure  `assistant_dba`.`check_users`(in db_server_name_list_users char(64), in tbl_server_name_list_users char(64), in in_server_id int) 
#call assistant_dba.check_db('assistant_dba_temp','tblu_1_users',1) ;
begin
set @in_server_id=in_server_id;
set @db_name=db_server_name_list_users; #"assistant_dba_temp"; 
set @table_name1:=tbl_server_name_list_users;#"dba_server_name_list_db"; 
SET SESSION group_concat_max_len = 100000;
#inserting a new database
set @sql_insert:=concat('if exists (select 1 
	from \`',@db_name,'\`.\`',@table_name1,'\` tts
	left join \`assistant_dba\`.\`list_mysql_users\` as lmu
	on tts.user=lmu.user and tts.host=lmu.host and lmu.server_id=',@in_server_id,'
	where lmu.user_id is null limit 1)
then 
	begin
		insert into `assistant_dba`.`list_mysql_users`  (server_id, user, host, data_find, data_lost, locked, data_lock,password_expired,is_role )
		select tts.server_id, tts.user, tts.host, curdate(), NULL, tts.locked, NULL, tts.password_expired, tts.is_role
		FROM \`',@db_name,'\`.\`',@table_name1,'\` as tts
		left join `assistant_dba`.`list_mysql_users` lmu
		on tts.user=lmu.user and tts.host=lmu.host and lmu.server_id=',@in_server_id,'
		where lmu.user_id is null;
	end;
end if;');
#select @sql_insert;
prepare dynamic_insert from @sql_insert;
execute dynamic_insert;
deallocate prepare dynamic_insert;
#update data_lost
set @sql_data_lost:=concat('if exists (select 1 
	from \`assistant_dba\`.\`list_mysql_users\` as lmu
    left join \`',@db_name,'\`.\`',@table_name1,'\` tts
        on tts.user=lmu.user and tts.host=lmu.host
	where tts.user is null and tts.host is null and lmu.data_lost is not null and  lmu.server_id=',@in_server_id,')
then 
	begin
		update  `assistant_dba`.`list_mysql_users` as lmu
		left join \`',@db_name,'\`.\`',@table_name1,'\` tts
		on tts.user=lmu.user and tts.host=lmu.host
		set lmu.data_lost=curdate() 
		where tts.user is null and tts.host is null and  lmu.server_id=',@in_server_id,';
	end;
end if;
');
#select @sql_data_lost;
prepare dynamic_data_lost from @sql_data_lost;
execute dynamic_data_lost;
deallocate prepare dynamic_data_lost;
#a user with the same name has appeared again. update all fields smu.data_find=curdate(),
set @sql_appeared_again:=concat('if exists (select 1 
	from \`assistant_dba\`.\`list_mysql_users\` as lmu
    left join \`',@db_name,'\`.\`',@table_name1,'\` tts
        on tts.user=lmu.user and tts.host=lmu.host
	where tts.user=lmu.user and tts.host=lmu.host and lmu.data_lost is not null and  lmu.server_id=',@in_server_id,')
then 
	begin
		update  `assistant_dba`.`list_mysql_users` as lmu
		left join \`',@db_name,'\`.\`',@table_name1,'\` tts
		on tts.user=lmu.user and tts.host=lmu.host
		set  lmu.data_lost=null, 
        lmu.data_lock = CASE 
        when tts.locked=''N'' then null
        when tts.locked=''Y'' then curdate()
        end,
        lmu.locked=tts.locked,  lmu.password_expired=tts.password_expired, lmu.is_role=tts.is_role 
		where tts.user=lmu.user and tts.host=lmu.host  and lmu.data_lost is not null and  lmu.server_id=',@in_server_id,';
	end;
end if;
');
#select @sql_appeared_again;
prepare dynamic_appeared_again from @sql_appeared_again;
execute dynamic_appeared_again;
deallocate prepare dynamic_appeared_again;
#first locked user
set @sql_update_locked_y:=concat('
if exists 
(select lmu.user_id, lmu.server_id, lmu.user, lmu.host, lmu.locked, lmu.data_lock, tts.locked, curdate() as tts_data_locked
	from `assistant_dba`.`list_mysql_users` as lmu
	left join \`',@db_name,'\`.\`',@table_name1,'\` tts
    on tts.user=lmu.user and tts.host=lmu.host
    where tts.user=lmu.user and tts.host=lmu.host  and  lmu.server_id=',@in_server_id,' and lmu.locked=''N'' and tts.locked=''Y'')
then
	begin
		update `assistant_dba`.`list_mysql_users` as lmu
		left join \`',@db_name,'\`.\`',@table_name1,'\` tts 
		on tts.user=lmu.user and tts.host=lmu.host
        set lmu.locked=''Y'', lmu.data_lock=curdate()
        where lmu.user_id in 
        (select lmu.user_id
		from `dw_dba`.`list_mysql_users` as lmu
		left join \`',@db_name,'\`.\`',@table_name1,'\` tts
		on tts.user=lmu.user and tts.host=lmu.host
		where tts.user=lmu.user and tts.host=lmu.host  and  lmu.server_id=',@in_server_id,' and lmu.locked=''N'' and tts.locked=''Y'') 
        and  tts.user=lmu.user and tts.host=lmu.host  and  lmu.server_id=',@in_server_id,';
	end;
end if;
');
#select @sql_update_locked_y;
prepare dynamic_update_locked_y from @sql_update_locked_y;
execute dynamic_update_locked_y;
deallocate prepare dynamic_update_locked_y;
#unlocked user
set @sql_update_locked_n:=concat('
if exists 
(select lmu.user_id, lmu.server_id, lmu.user, lmu.host, lmu.locked, lmu.data_lock, tts.locked, curdate() as tts_data_locked
	from `assistant_dba`.`list_mysql_users` as lmu
	left join \`',@db_name,'\`.\`',@table_name1,'\` tts
    on tts.user=lmu.user and tts.host=lmu.host
    where tts.user=lmu.user and tts.host=lmu.host  and  lmu.server_id=',@in_server_id,' and lmu.locked=''Y'' and tts.locked=''N'')
then
	begin
		update `assistant_dba`.`list_mysql_users` as lmu
		left join \`',@db_name,'\`.\`',@table_name1,'\` tts 
		on tts.user=lmu.user and tts.host=lmu.host
        set lmu.locked=''N'', lmu.data_lock=NULL
        where lmu.user_id in 
        (select lmu.user_id
		from `dw_dba`.`list_mysql_users` as lmu
		left join \`',@db_name,'\`.\`',@table_name1,'\` tts
		on tts.user=lmu.user and tts.host=lmu.host
		where tts.user=lmu.user and tts.host=lmu.host  and  lmu.server_id=',@in_server_id,' and lmu.locked=''Y'' and tts.locked=''N'') 
        and  tts.user=lmu.user and tts.host=lmu.host  and  lmu.server_id=',@in_server_id,';
	end;
end if;
');
#select @sql_update_locked_n;
prepare dynamic_update_locked_n from @sql_update_locked_n;
execute dynamic_update_locked_n;
deallocate prepare dynamic_update_locked_n;
#update password_expired
set @sql_password_expired:=concat('if exists 
(select lmu.user_id, lmu.server_id, lmu.user, lmu.host, lmu.locked, lmu.data_lock, tts.locked, curdate() as tts_data_locked
	from `assistant_dba`.`list_mysql_users` as lmu
	left join \`',@db_name,'\`.\`',@table_name1,'\` tts
    on tts.user=lmu.user and tts.host=lmu.host
    where tts.user=lmu.user and tts.host=lmu.host  and  lmu.server_id=',@in_server_id,' and tts.password_expired!=lmu.password_expired)
then
	begin
		update `assistant_dba`.`list_mysql_users` as lmu
		left join \`',@db_name,'\`.\`',@table_name1,'\` tts 
		on tts.user=lmu.user and tts.host=lmu.host
        set lmu.password_expired=tts.password_expired
        where lmu.user_id in 
        (select lmu.user_id
		from `dw_dba`.`list_mysql_users` as lmu
		left join \`',@db_name,'\`.\`',@table_name1,'\` tts
		on tts.user=lmu.user and tts.host=lmu.host
		where tts.user=lmu.user and tts.host=lmu.host  and  lmu.server_id=',@in_server_id,' and tts.password_expired!=lmu.password_expired) 
        and  tts.user=lmu.user and tts.host=lmu.host and lmu.server_id=',@in_server_id,';
	end;
end if;
');
prepare dynamic_password_expired from @sql_password_expired;
execute dynamic_password_expired;
deallocate prepare dynamic_password_expired;
#update role
set @sql_role:=concat('if exists 
(select lmu.user_id, lmu.server_id, lmu.user, lmu.host, lmu.locked, lmu.data_lock, tts.locked, 
lmu.is_role as lmu_is_role, tts.is_role as tts_is_role, tts.user as tts_user, tts.host as tts_host
from `assistant_dba`.`list_mysql_users` as lmu
left join \`',@db_name,'\`.\`',@table_name1,'\` tts
on tts.user=lmu.user and (tts.host='''' or tts.host=null)
where lmu.is_role=''Y'' and tts.user is null and tts.is_role is null and  lmu.server_id=',@in_server_id,')
then
	begin
		update `assistant_dba`.`list_mysql_users` as lmu
		left join \`',@db_name,'\`.\`',@table_name1,'\` tts 
		on tts.user=lmu.user and tts.is_role=''Y''
        set lmu.data_lost=curdate() 
        where lmu.user_id in 
        (select lmu.user_id
		from `dw_dba`.`list_mysql_users` as lmu
		left join \`',@db_name,'\`.\`',@table_name1,'\` tts
		on tts.user=lmu.user and (tts.host='''' or tts.host=null)
		where lmu.is_role=''Y'' and tts.user is null and tts.is_role is null and  lmu.server_id=',@in_server_id,') 
        and  lmu.is_role=''Y'' and tts.user is null and tts.is_role is null and  lmu.server_id=',@in_server_id,';
	end;
end if;
');
#select @sql_role;
prepare dynamic_role from @sql_role;
execute dynamic_role;
deallocate prepare dynamic_role;
set @sql_drop_intermediate:=concat('drop table if exists  ', '\`',@db_name,'\`.\`',@table_name1,'\`;');
#select @sql_drop_intermediate;
prepare dynamic_drop_intermediate from @sql_drop_intermediate;
execute dynamic_drop_intermediate;
deallocate prepare dynamic_drop_intermediate;
end$$
DELIMITER ;




#The procedure keeps track of and saves user permissions on MySQL servers.  
drop procedure  if exists  `assistant_dba`.`save_track_user_permissions_mysql` ;
DELIMITER $$
create procedure  `assistant_dba`.`save_track_user_permissions_mysql`(in db_temp char(64), in in_tbl_user_priv_mysql char(64), in in_server_id int) 
#call assistant_dba.save_track_user_permissions_mysql('assistant_dba_temp','tblu_1_priv',1) ; ;
begin
set @in_server_id=in_server_id;
set @tbl_user_priv_mysql=db_temp; #"assistant_dba_temp"; 
set @table_name1:=in_tbl_user_priv_mysql;#"tblu_1_priv"; 
set @full_tbl_name=concat(@tbl_user_priv_mysql,'.',@table_name1);
SET SESSION group_concat_max_len = 100000;

#exclude double data
set @sql_del_get_date:=concat('delete hmp 
from \`assistant_dba\`.\`history_mysql_privileges\` hmp 
where hmp.server_id=',@in_server_id,' and hmp.data=curdate();'); #
prepare dynamic_del_get_date from @sql_del_get_date;
execute dynamic_del_get_date;
deallocate prepare dynamic_del_get_date;
set @sql_insert_history:=concat('INSERT INTO \`assistant_dba\`.\`history_mysql_privileges\` (server_id, user, host, base_name, table_name, column_name, role_name, 
role_name_host, grant_admin_role, grant_stmt, data )
SELECT ',@in_server_id,',  user_get, host_get, database_get, table_get, col_get, role_get, role_host_get, grant_admin_role_get, grant_stmt, data_collect
FROM ',@full_tbl_name,' ;');
#select @sql_insert_history;
prepare dynamic_insert_history from @sql_insert_history;
execute dynamic_insert_history;
deallocate prepare dynamic_insert_history;
set @sql_drop_intermediate_history:=concat('drop table if exists  ',@full_tbl_name,' ;');
prepare dynamic_drop_intermediate_history from @sql_drop_intermediate_history;
execute dynamic_drop_intermediate_history;
deallocate prepare dynamic_drop_intermediate_history;
end$$
DELIMITER ;

#The procedure keeps track of and saves user permissions on MariaDB servers.  
drop procedure  if exists  `assistant_dba`.`save_track_user_permissions_mariadb` ;
DELIMITER $$
create procedure  `assistant_dba`.`save_track_user_permissions_mariadb`(in db_temp char(64), in in_tbl_user_priv_mysql char(64), in in_server_id int) 
#call assistant_dba.save_track_user_permissions_mariadb('assistant_dba_temp','tblu_1_priv',1) ; ;
begin
set @in_server_id=in_server_id;
set @tbl_user_priv_mysql=db_temp; #"assistant_dba_temp"; 
set @table_name1:=in_tbl_user_priv_mysql;#"tblu_1_priv"; 
set @full_tbl_name=concat(@tbl_user_priv_mysql,'.',@table_name1);
SET SESSION group_concat_max_len = 100000;

#exclude double data
set @sql_del_get_date:=concat('delete hmp 
from \`assistant_dba\`.\`history_mariadb_privileges\` hmp 
where hmp.server_id=',@in_server_id,' and hmp.data=curdate();'); #
prepare dynamic_del_get_date from @sql_del_get_date;
execute dynamic_del_get_date;
deallocate prepare dynamic_del_get_date;
set @sql_insert_history:=concat('INSERT INTO \`assistant_dba\`.\`history_mariadb_privileges\` (server_id, user, host, base_name, table_name, column_name, role_name, 
 grant_admin_role, grant_stmt, data )
SELECT ',@in_server_id,',  user_get, host_get, database_get, table_get, col_get, role_get, grant_admin_role_get, grant_stmt, data_collect
FROM ',@full_tbl_name,' ;');
select @sql_insert_history;
prepare dynamic_insert_history from @sql_insert_history;
execute dynamic_insert_history;
deallocate prepare dynamic_insert_history;
set @sql_drop_intermediate_history:=concat('drop table if exists  ',@full_tbl_name,' ;');
prepare dynamic_drop_intermediate_history from @sql_drop_intermediate_history;
execute dynamic_drop_intermediate_history;
deallocate prepare dynamic_drop_intermediate_history;
end$$
DELIMITER ;









