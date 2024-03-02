############################################################
# Granting privileges on remote servers
############################################################
#create user 'maverick'@'%' identified by 'mysql12';
##процедура принудительного запуска analyze table по всем схемам - таблица исключая performance_schema
drop procedure  if exists mysql.dba_analyze_table ;
DELIMITER $$
create procedure mysql.dba_analyze_table ()
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

grant show databases, references on *.* TO 'maverick'@'%';
grant execute on procedure mysql.dba_analyze_table  to 'maverick'@'%';

