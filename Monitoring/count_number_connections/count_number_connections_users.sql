create database if not exists assistant_dba;
drop function if exists assistant_dba.`regexp_replace`;
DELIMITER $$
CREATE  FUNCTION assistant_dba.`regexp_replace`(ori_str varchar(64),pattern VARCHAR(64),repl_str VARCHAR(64)) RETURNS longtext CHARSET utf8mb4
    DETERMINISTIC
BEGIN  
#Thank you for this function the website https://www.cnblogs.com/rainbow--/p/17026987.html
#This is an analog of function regexp_replace from MySQL 8.0 to MySQL 5.7
	DECLARE tmp_str LONGTEXT;  
	DECLARE target_str LONGTEXT;  
	DECLARE str0 LONGTEXT;  
	DECLARE i1 INT;
	DECLARE i2 INT;
	SET tmp_str = ori_str; 
	loop0: LOOP
		IF NOT tmp_str REGEXP pattern THEN  
			LEAVE loop0;  
		END IF;
		SET i1 = 1;
		SET i2 = CHAR_LENGTH(tmp_str);
		loop1: LOOP
			SET str0 = SUBSTR(tmp_str, i1, i2-i1+1);
			IF NOT str0 REGEXP pattern THEN
				SET i1 = i1-1; 
				LEAVE loop1;
			ELSE
				SET i1 = i1+1;
			END IF;
		END LOOP;
		loop2: LOOP
			SET str0 = SUBSTR(tmp_str, i1, i2-i1+1);
			IF NOT str0 REGEXP pattern THEN
				SET i2 = i2+1; 
				LEAVE loop2;
			ELSE
				SET i2 = i2-1;  
			END IF;
		END LOOP;
		SET target_str = SUBSTR(tmp_str, i1, i2-i1+1);
		SET tmp_str = REPLACE(tmp_str, target_str, repl_str);
	END LOOP;  
	RETURN tmp_str;
END$$
DELIMITER ;
DROP PROCEDURE if exists assistant_dba.`count_con_each_users`;
DELIMITER $$
CREATE PROCEDURE assistant_dba.`count_con_each_users`()
begin
declare speciality condition for sqlstate '45000';
SET sql_log_bin = 0;
set @error_mysql_version:= concat ('Warning! This procedure doesn''t work with MySQL less than 5.7.') ;
set @error_check_function:= concat ('Warning! The function ''assistant_dba.regexp_replace'' doesn''t exist on this database server.') ;
#call `assistant_dba`.`count_con_each_users` ();
set @var_server_id := (select @@server_id);
set @var_server_name :=(select @@hostname);
set @var_server_version := (select @@version);
set @var_first_number_server_version := (select substring(@@version,1,3));
#set @var_first_number_server_version := 5.0;
#I check the version MySQL. If MySQL has a version less than 5.7, then this procedure has finished with an error.
    if @var_first_number_server_version<5.7 then
       signal speciality set message_text = @error_mysql_version;
	end if;

if @var_first_number_server_version<8 then 
	set @check_version=5;
	set @check_function=(select  coalesce((select 1 from information_schema.routines where ROUTINE_SCHEMA='assistant_dba' and ROUTINE_NAME='regexp_replace' and ROUTINE_TYPE='FUNCTION'),0,1));
    if @check_function!=1 then
       signal speciality set message_text = @error_check_function;
	end if;
    #I'll create the table which called server_idsevername. For example, the global variables has values server_id=3043 and hostname=mysql3043.
    #The table will be named 3043mysql3043.
    #I remove from the hostname the characters that do not satisfy the condition [a-z] or [A-Z] or [0-9] or _.
    #set @var_server_name='wddjh34u0--dhbjdb--_!23!@#';
    #set @var_server_name_end :=(select assistant_dba.`regexp_replace`(@var_server_name ,'[^a-zA-Z0-9_]',''));
    set @tblname_count_con_each_users=concat('t_',@var_server_id,'_',(select assistant_dba.`regexp_replace`(@var_server_name ,'[^a-zA-Z0-9_]','')));
end if;    

if @var_first_number_server_version>=8 then 
	set @check_version=8;
	#set @check_function=(select  coalesce((select 1 from information_schema.routines where ROUTINE_SCHEMA='assistant_dba' and ROUTINE_NAME='regexp_replace' and ROUTINE_TYPE='FUNCTION'),0,1));
    #if @check_function!=1 then
    #   signal speciality set message_text = @error_check_function;
	#end if;
    #I'll create the table which called server_idsevername. For example, the global variables has values server_id=3043 and hostname=mysql3043.
    #The table will be named 3043mysql3043.
    #I remove from the hostname the characters that do not satisfy the condition [a-z] or [A-Z] or [0-9] or _.
    #set @var_server_name='wddjh34u0--dhbjdb--_!23!@#';
    #set @var_server_name_end :=(select regexp_replace(@var_server_name ,'[^a-zA-Z0-9_]',''));
    set @tblname_count_con_each_users=concat('t_',@var_server_id,'_',(select regexp_replace(@var_server_name ,'[^a-zA-Z0-9_]','')));
end if;  
	set @sql_create_tbl :=concat(' CREATE TABLE if not exists \`assistant_dba\`.',@tblname_count_con_each_users,' (\`id\` INT UNSIGNED NOT NULL AUTO_INCREMENT, \`user_name\` VARCHAR(64) NOT NULL, \`host_name\`  VARCHAR(64) NOT NULL, cnt int not null, date_collect datetime not null, PRIMARY KEY (\`id\`), key \`IX_user_host_date_collect\` (\`user_name\` asc, \`host_name\` asc, \`date_collect\`) ); '); 
        #select @sql_create_tbl;
		prepare dynamic_create_tbl from @sql_create_tbl;
		execute dynamic_create_tbl;
        deallocate prepare dynamic_create_tbl;

	set @sql_insert :=concat(' insert into \`assistant_dba\`.',@tblname_count_con_each_users,' (\`user_name\` , \`host_name\`, \`cnt\` , \`date_collect\`) 
								select distinct user, left(host,(locate(":",host))-1) host_name,count(*) cnt, now() date_collect
                                from information_schema.processlist 
                                group by user, host_name; '); 
        #select @sql_insert;
		prepare dynamic_insert from @sql_insert;
		execute dynamic_insert;
        deallocate prepare dynamic_insert;

        
#select @var_server_id,@var_server_name, @var_server_version, @var_first_number_server_version, @tblname_count_con_each_users;
end$$
DELIMITER ;


drop event if exists assistant_dba.`dba_count_con_each_users`;
DELIMITER $$
CREATE EVENT assistant_dba.`dba_count_con_each_users` ON SCHEDULE EVERY 30 second STARTS '2024-12-14 00:00:00' ON COMPLETION NOT PRESERVE DISABLE ON SLAVE COMMENT 'Collecting information how many connections each user opened.' DO BEGIN
  call assistant_dba.count_con_each_users(); 
END$$
DELIMITER ;
alter EVENT assistant_dba.`dba_count_con_each_users` enable;

