############################################################
# Granting privileges on system.
############################################################
drop user if exists 'maverick'@'%' ;
create user 'maverick'@'%' identified by 'mysql12';
grant  create, create view, create temporary tables,  alter routine , create routine, drop on assistant_dba_temp.* to 'maverick'@'%';
grant select, insert, update, delete on assistant_dba_temp.* to 'maverick'@'%';
grant file on *.* to  'maverick'@'%';
#module collect data growth size table
grant execute on procedure assistant_dba.get_alive_init_server_mysql to 'maverick'@'%';
grant execute on procedure assistant_dba.insert_filtered_option_server_mysql to 'maverick'@'%';
grant execute on procedure assistant_dba.insert_list_db to 'maverick'@'%';
grant execute on procedure assistant_dba.check_db to 'maverick'@'%';
grant execute on procedure assistant_dba.get_list_db_my_spr  to 'maverick'@'%';
grant execute on procedure mysql.dba_analyze_table  to 'maverick'@'%';
grant execute on procedure assistant_dba.check_table  to 'maverick'@'%';
grant execute on procedure assistant_dba.check_routine to 'maverick'@'%';
grant execute on procedure assistant_dba.check_view to 'maverick'@'%';
grant execute on procedure assistant_dba.insert_history_table  to 'maverick'@'%';
grant execute on procedure assistant_dba.insert_global_var  to 'maverick'@'%';
grant execute on procedure assistant_dba.check_global_var to 'maverick'@'%';
grant execute on procedure assistant_dba.get_list_global_var_spr to 'maverick'@'%';
grant execute on procedure assistant_dba.insert_global_var_ext to 'maverick'@'%';
grant execute on procedure assistant_dba.insert_history_global_var  to 'maverick'@'%';
grant show databases, references on *.* TO 'maverick'@'%';
grant execute on procedure mysql.dba_analyze_table  to 'maverick'@'%';
#module backup
grant execute on procedure assistant_dba.run_task_mysql   to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btrm_start_time   to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btrm_start_time_backup   to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btrm_end_time_backup  to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btrm_end_time  to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btrm_file_log  to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btrm_task_progress  to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btrm_start_time_prepare  to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btrm_end_time_prepare  to 'maverick'@'%';
grant execute on procedure assistant_dba.backup_tasks_move_from_run_to_log  to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_bpvm_path_last_full_backup  to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btrm_wait_task_id  to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_bpvm_path_last_incr_backup  to 'maverick'@'%';
grant execute on procedure assistant_dba.get_bpvm_path_last_full_backup  to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btlm_path_old_incr_backup  to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btlm_path_cur_incr_backup  to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btlm_path_diff_backup  to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btlm_path_last_full_backup   to 'maverick'@'%';
grant execute on procedure assistant_dba.upd_btm_last_time   to 'maverick'@'%';
grant execute on procedure assistant_dba.queue_task_mysql   to 'maverick'@'%';
grant execute on procedure assistant_dba.task_scheduler_mysql  to 'maverick'@'%';
grant execute on procedure assistant_dba.compare_version_mariabackup  to 'maverick'@'%';
grant execute on procedure assistant_dba.compare_version_mysql_percona to 'maverick'@'%';
#module permissions
grant execute on procedure assistant_dba.get_alive_users_server_mysql to 'maverick'@'%';
grant execute on procedure assistant_dba.check_users  to 'maverick'@'%';
grant execute on procedure assistant_dba.save_track_user_permissions_mysql  to 'maverick'@'%';
grant execute on procedure assistant_dba.save_track_user_permissions_mariadb  to 'maverick'@'%';
 