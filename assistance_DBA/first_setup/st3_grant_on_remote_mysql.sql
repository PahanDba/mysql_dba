#MySQL/Percona
grant select on mysql.user to 'maverick'@'%';
grant execute on procedure mysql.dba_user_priv_mysql  to 'maverick'@'%';