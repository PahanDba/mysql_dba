#The procedure gets a list of privileges for all users on the server with MySQL.
drop PROCEDURE if exists `mysql`.`dba_user_priv_mysql`;
DELIMITER $$
create PROCEDURE `mysql`.`dba_user_priv_mysql`()
begin
#call `mysql`.`dba_user_priv_mysql`();
/* Column-Specific Grants */
SELECT
  gcl.User AS 'user_get',
  gcl.Host AS 'host_get',
  CONCAT("",gcl.Db,"") AS 'database_get',
  CONCAT("",gcl.Table_name,"") AS 'table_get',
  CONCAT(UPPER(gcl.Column_priv)," (",GROUP_CONCAT(gcl.Column_name ORDER BY UPPER(gcl.Column_name) SEPARATOR ", "),") ") AS 'col_get',
  concat("NA") AS 'role_get',
  CONCAT("NA") AS 'role_host_get',
  concat("NA") AS 'grant_admin_role_get',
  CONCAT("GRANT ",UPPER(gcl.Column_priv)," (",
          GROUP_CONCAT(gcl.Column_name ORDER BY UPPER(gcl.Column_name)),") ",
         "ON `",gcl.Db,"`.`",gcl.Table_name,"` ",
         "TO '",gcl.User,"'@'",gcl.Host,"';") AS 'grant_stmt',
NOW() AS 'Timestamp'
FROM `mysql`.columns_priv gcl
WHERE true 
#GROUP BY CONCAT(gcl.Host,gcl.Db,gcl.User,gcl.Table_name,gcl.Column_priv)
GROUP BY gcl.Host, gcl.Db, gcl.User, gcl.Table_name, gcl.Column_priv
/* SELECT * FROM `mysql`.columns_priv */
UNION
/* Table-Specific Grants */
SELECT
  gtb.User AS 'user_get',
  gtb.Host AS 'host_get',
  CONCAT("",gtb.Db,"") AS 'database_get',
  CONCAT("",gtb.Table_name,"") AS 'table_get',
  "ALL" AS 'col_get',
  concat("NA") AS 'role_get',
  CONCAT("NA") AS 'role_host_get',
  concat("NA") AS 'grant_admin_role_get',
  CONCAT(
    "GRANT ",UPPER(gtb.Table_priv)," ",
    "ON `",gtb.Db,"`.`",gtb.Table_name,"` ",
    "TO '",gtb.User,"'@'",gtb.Host,"';"
  ) AS 'grant_stmt',
  NOW() AS 'Timestamp'
FROM `mysql`.tables_priv gtb
WHERE gtb.Table_priv!='' 
/* SELECT * FROM `mysql`.tables_priv */
UNION
/* Database-Specific Grants */
SELECT
  gdb.User AS 'user_get',
  gdb.Host AS 'host_get',
  CONCAT("",gdb.Db,"") AS 'database_get',
  "ALL" AS 'table_get',
  "ALL" AS 'col_get',
  concat("NA") AS 'role_get',
  CONCAT("NA") AS 'role_host_get',
  concat("NA") AS 'grant_admin_role_get',
  CONCAT(
    'GRANT ',
    CONCAT_WS(',',
      IF(gdb.Select_priv='Y','SELECT',NULL),
      IF(gdb.Insert_priv='Y','INSERT',NULL),
      IF(gdb.Update_priv='Y','UPDATE',NULL),
      IF(gdb.Delete_priv='Y','DELETE',NULL),
      IF(gdb.Create_priv='Y','CREATE',NULL),
      IF(gdb.Drop_priv='Y','DROP',NULL),
      IF(gdb.Grant_priv='Y','GRANT',NULL),
      IF(gdb.References_priv='Y','REFERENCES',NULL),
      IF(gdb.Index_priv='Y','INDEX',NULL),
      IF(gdb.Alter_priv='Y','ALTER',NULL),
      IF(gdb.Create_tmp_table_priv='Y','CREATE TEMPORARY TABLES',NULL),
      IF(gdb.Lock_tables_priv='Y','LOCK TABLES',NULL),
      IF(gdb.Create_view_priv='Y','CREATE VIEW',NULL),
      IF(gdb.Show_view_priv='Y','SHOW VIEW',NULL),
      IF(gdb.Create_routine_priv='Y','CREATE ROUTINE',NULL),
      IF(gdb.Alter_routine_priv='Y','ALTER ROUTINE',NULL),
      IF(gdb.Execute_priv='Y','EXECUTE',NULL),
      IF(gdb.Event_priv='Y','EVENT',NULL),
      IF(gdb.Trigger_priv='Y','TRIGGER',NULL)
    ),
    " ON `",gdb.Db,"`.* TO '",gdb.User,"'@'",gdb.Host,"';"
  ) AS 'grant_stmt',
 NOW() AS 'Timestamp'
FROM `mysql`.db gdb
WHERE gdb.Db != '' 
/* SELECT * FROM `mysql`.db */
union
/* User-Role Specific Grants */
SELECT
  mre.to_User AS 'user_get',
  mre.to_Host AS 'host_get',
  CONCAT("NA") AS 'database_get',
  CONCAT("NA") AS 'table_get',
  CONCAT("NA") AS 'col_get',
  CONCAT("",mre.from_user,"") AS 'role_get',
  CONCAT("",mre.from_host,"") AS 'role_host_get',
  CONCAT("",mre.with_admin_option,"") AS 'grant_admin_role_get',
CONCAT(concat("GRANT `",mre.from_user,"`@`",mre.from_host,"` ",
         "TO '",mre.to_User,"'@'",mre.to_Host,"'",IF(mre.with_admin_option='Y'," WITH ADMIN OPTION ",""),"; " ),
        coalesce( concat(CASE
			#WHEN mu.default_role<>'' AND mu.default_role=mre.role  THEN concat("SET DEFAULT ROLE `" ,"",mu.default_role,"` for '", mre.User,"'@'", mre.Host,"' ;")
            when mre.from_User=mdr.DEFAULT_ROLE_USER and mre.from_Host=mdr.DEFAULT_ROLE_host
            and mre.to_User=mdr.USER and mre.to_Host=mdr.host THEN concat("SET DEFAULT ROLE `" ,"",mdr.DEFAULT_ROLE_USER,"`@`",DEFAULT_ROLE_HOST,"` to '", mre.to_User,"'@'", mre.to_Host,"' ;")
			WHEN mre.from_User!=mdr.DEFAULT_ROLE_USER and mre.from_Host!=mdr.DEFAULT_ROLE_USER THEN concat("")
		END ),'')
        ) AS 'grant3',  
  NOW() AS 'Timestamp'
FROM `mysql`.role_edges mre
join `mysql`.user mu
on mu.user=mre.to_User and mu.host=mre.to_Host
join `mysql`.default_roles mdr
on mu.user=mdr.user and mu.host=mdr.host
WHERE true 
GROUP BY mre.to_Host , mre.to_User,  mre.from_user, from_host, mdr.DEFAULT_ROLE_USER, mdr.DEFAULT_ROLE_HOST 

UNION
/* User-Specific Grants */
SELECT
  usr.User AS 'user_get',
  usr.Host AS 'host_get',
  "ALL" AS 'database_get',
  "ALL" AS 'table_get',
  "ALL" AS 'col_get',
  CONCAT("NA") AS 'role_get',
  CONCAT("NA") AS 'role_host_get',
  CONCAT("NA") AS 'grant_admin_role_get',
  CONCAT(
    "GRANT ",
    IF((usr.Select_priv='N')&(usr.Insert_priv='N')&(usr.Update_priv='N')&(usr.Delete_priv='N')&(usr.Create_priv='N')&(usr.Drop_priv='N')&(usr.Reload_priv='N')&(usr.Shutdown_priv='N')&(usr.Process_priv='N')&(usr.File_priv='N')&(usr.References_priv='N')&(usr.Index_priv='N')&(usr.Alter_priv='N')&(usr.Show_db_priv='N')&(usr.Super_priv='N')&(usr.Create_tmp_table_priv='N')&(usr.Lock_tables_priv='N')&(usr.Execute_priv='N')&(usr.Repl_slave_priv='N')&(usr.Repl_client_priv='N')&(usr.Create_view_priv='N')&(usr.Show_view_priv='N')&(usr.Create_routine_priv='N')&(usr.Alter_routine_priv='N')&(usr.Create_user_priv='N')&(usr.Event_priv='N')&(usr.Trigger_priv='N')&(usr.Create_tablespace_priv='N')&(usr.Grant_priv='N'),
      "USAGE",
      IF((usr.Select_priv='Y')&(usr.Insert_priv='Y')&(usr.Update_priv='Y')&(usr.Delete_priv='Y')&(usr.Create_priv='Y')&(usr.Drop_priv='Y')&(usr.Reload_priv='Y')&(usr.Shutdown_priv='Y')&(usr.Process_priv='Y')&(usr.File_priv='Y')&(usr.References_priv='Y')&(usr.Index_priv='Y')&(usr.Alter_priv='Y')&(usr.Show_db_priv='Y')&(usr.Super_priv='Y')&(usr.Create_tmp_table_priv='Y')&(usr.Lock_tables_priv='Y')&(usr.Execute_priv='Y')&(usr.Repl_slave_priv='Y')&(usr.Repl_client_priv='Y')&(usr.Create_view_priv='Y')&(usr.Show_view_priv='Y')&(usr.Create_routine_priv='Y')&(usr.Alter_routine_priv='Y')&(usr.Create_user_priv='Y')&(usr.Event_priv='Y')&(usr.Trigger_priv='Y')&(usr.Create_tablespace_priv='Y')&(usr.Grant_priv='Y'),
        "ALL PRIVILEGES",
        CONCAT_WS(',',
          IF(usr.Select_priv='Y','SELECT',NULL),
          IF(usr.Insert_priv='Y','INSERT',NULL),
          IF(usr.Update_priv='Y','UPDATE',NULL),
          IF(usr.Delete_priv='Y','DELETE',NULL),
          IF(usr.Create_priv='Y','CREATE',NULL),
          IF(usr.Drop_priv='Y','DROP',NULL),
          IF(usr.Reload_priv='Y','RELOAD',NULL),
          IF(usr.Shutdown_priv='Y','SHUTDOWN',NULL),
          IF(usr.Process_priv='Y','PROCESS',NULL),
          IF(usr.File_priv='Y','FILE',NULL),
          IF(usr.References_priv='Y','REFERENCES',NULL),
          IF(usr.Index_priv='Y','INDEX',NULL),
          IF(usr.Alter_priv='Y','ALTER',NULL),
          IF(usr.Show_db_priv='Y','SHOW DATABASES',NULL),
          IF(usr.Super_priv='Y','SUPER',NULL),
          IF(usr.Create_tmp_table_priv='Y','CREATE TEMPORARY TABLES',NULL),
          IF(usr.Lock_tables_priv='Y','LOCK TABLES',NULL),
          IF(usr.Execute_priv='Y','EXECUTE',NULL),
          IF(usr.Repl_slave_priv='Y','REPLICATION SLAVE',NULL),
          IF(usr.Repl_client_priv='Y','REPLICATION CLIENT',NULL),
          IF(usr.Create_view_priv='Y','CREATE VIEW',NULL),
          IF(usr.Show_view_priv='Y','SHOW VIEW',NULL),
          IF(usr.Create_routine_priv='Y','CREATE ROUTINE',NULL),
          IF(usr.Alter_routine_priv='Y','ALTER ROUTINE',NULL),
          IF(usr.Create_user_priv='Y','CREATE USER',NULL),
          IF(usr.Event_priv='Y','EVENT',NULL),
          IF(usr.Trigger_priv='Y','TRIGGER',NULL),
          IF(usr.Create_tablespace_priv='Y','CREATE TABLESPACE',NULL)
        )
      )
    ),
    " ON *.* TO '",usr.User,"'@'",usr.Host,"' REQUIRE ",
    CASE usr.ssl_type
      WHEN 'ANY' THEN
        "SSL "
      WHEN 'X509' THEN
        "X509 "
      WHEN 'SPECIFIED' THEN
        CONCAT_WS("AND ",
          IF((LENGTH(usr.ssl_cipher)>0),CONCAT("CIPHER '",CONVERT(usr.ssl_cipher USING utf8mb4),"' "),NULL),
          IF((LENGTH(usr.x509_issuer)>0),CONCAT("ISSUER '",CONVERT(usr.ssl_cipher USING utf8mb4),"' "),NULL),
          IF((LENGTH(usr.x509_subject)>0),CONCAT("SUBJECT '",CONVERT(usr.ssl_cipher USING utf8mb4),"' "),NULL)
        )
      ELSE "NONE "
    END,
    "WITH ",
    IF(usr.Grant_priv='Y',"GRANT OPTION ",""),
    "MAX_QUERIES_PER_HOUR ",usr.max_questions," ",
    "MAX_CONNECTIONS_PER_HOUR ",usr.max_connections," ",
    "MAX_UPDATES_PER_HOUR ",usr.max_updates," ",
    "MAX_USER_CONNECTIONS ",usr.max_user_connections,
    ";"
  ) AS 'grant_stmt',
  NOW() AS 'Timestamp'
FROM `mysql`.user usr
WHERE usr.authentication_string != ''
order by 1,2;
end$$
DELIMITER ;
